#!/usr/bin/env python3
"""Source-bound full-game translation inventory and bounded JSONL exchange.

This tool never generates translations, converts Chinese scripts, deletes locale
files, or changes shipping claims. ``inventory`` separates source, present,
validated and receipted leaves. A successful batch is not full-game completion.
``export`` emits a manifest followed by source rows. The response has the same
manifest and one {id, locale, source_sha256, prompt_version, text} per source row.
``check`` is read-only; ``import --accept`` merges only those validated leaves.
Unverified dynamic candidates and fields outside the existing overlay validator
contract can be exported for drafting but not imported.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ("ja", "zh-CN", "zh-TW")
PROMPT_VERSION = "full-ko-direct-2026-09-07.1"
SCHEMA_VERSION = 1
# Exact nine historical receipts from 6e088e5 (three unused condition notes per
# locale). Never recompute this from mutable metadata to accept new/deleted notes.
RETAINED_ENDING_NOTES_SHA256 = "fec66e4714d357df965e1d3576dcf61991ad5615326d78e8e2795ec701f77fdb"
GROUPS = ("events", "endings", "catalog", "ui", "ui_unverified")
READER = re.compile(r"^chapter5_[a-z0-9_]+_reads$")
CHAPTER5_INLINE_SLOT = re.compile(r"\[\[c5read:[0-9]+\]\]")
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")


class ContractError(ValueError):
    pass


def strict_pairs(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ContractError(f"duplicate raw JSON key: {key}")
        result[key] = value
    return result


def loads(text: str) -> Any:
    return json.loads(text, object_pairs_hook=strict_pairs,
                      parse_constant=lambda token: (_ for _ in ()).throw(
                          ContractError(f"nonfinite JSON value: {token}")))


def read_json(path: Path) -> Any:
    return loads(path.read_text(encoding="utf-8"))


def digest(value: Any) -> str:
    return hashlib.sha256(json.dumps(value, ensure_ascii=False, sort_keys=True,
                                    separators=(",", ":")).encode()).hexdigest()


def sha_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pointer(tokens: tuple[Any, ...]) -> str:
    return "/" + "/".join(str(x).replace("~", "~0").replace("/", "~1") for x in tokens)


@dataclass(frozen=True)
class Leaf:
    group: str
    owner: str
    source_path: str
    path: tuple[Any, ...]
    source: str
    category: str
    lifecycle: str = "not_applicable"
    protected: bool = False
    runtime_support: str = "builtin_overlay_static_only"
    format_template: bool = False

    @property
    def id(self) -> str:
        return f"{self.group}:{self.owner}:{pointer(self.path)}"

    @property
    def source_sha256(self) -> str:
        return digest({"path": self.source_path, "field": self.path, "ko": self.source})


def row_index(rows: Any, owner: str) -> dict[str, dict[str, Any]]:
    if not isinstance(rows, list):
        raise ContractError(f"{owner}: expected ID array")
    result = {}
    for row in rows:
        if not isinstance(row, dict) or not isinstance(row.get("id"), str) or not row["id"]:
            raise ContractError(f"{owner}: malformed ID row")
        if row["id"] in result:
            raise ContractError(f"{owner}: duplicate ID {row['id']}")
        result[row["id"]] = row
    return result


def strings(value: Any, path: tuple[Any, ...] = ()):
    if isinstance(value, str):
        yield path, value
    elif isinstance(value, dict):
        for key, child in value.items():
            yield from strings(child, path + (key,))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from strings(child, path + (index,))


def reader_strings(value: Any, path: tuple[Any, ...]):
    if isinstance(value, str):
        yield path, value
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from reader_strings(child, path + (index,))
    else:
        raise ContractError(f"reader texts contain a non-array/non-string at {pointer(path)}")


def event_overlay_support(path: tuple[Any, ...]) -> str:
    """The permissive built-in loader alone does not prove gate support."""
    from i18n_coverage_check import TEXT_CHOICE_KEYS, TEXT_EVENT_KEYS

    if not path or path[0] not in TEXT_EVENT_KEYS \
            or (path[0] == "choices" and (len(path) < 3 or path[2] not in TEXT_CHOICE_KEYS)):
        return "validator_contract_missing"
    return "builtin_overlay_static_only"


def unsupported_relationship_display_names(owner: str, row: dict[str, Any], file: str) -> list[dict[str, Any]]:
    """Record display copy embedded in gameplay payloads, without overlaying it."""
    result = []
    for path, text in strings(row):
        if len(path) == 5 and path[0] == "choices" and path[2] == "relationship_effects" \
                and path[4] == "name" and HANGUL.search(text):
            result.append({"kind": "unsupported_relationship_display_name",
                           "source_id": f"events:{owner}:{pointer(path)}", "source_path": file,
                           "path": pointer(path), "ko": text,
                           "detail": "Stored/displayed without a locale resolver; gameplay overlay remains forbidden."})
    return result


def get_at(value: Any, path: tuple[Any, ...]) -> Any:
    try:
        for key in path:
            value = value[key]
        return value
    except (KeyError, IndexError, TypeError):
        return None


def set_at(value: Any, path: tuple[Any, ...], text: str) -> None:
    for index, key in enumerate(path):
        last = index == len(path) - 1
        if isinstance(value, list):
            if not isinstance(key, int) or key < 0:
                raise ContractError("array path must be a nonnegative index")
            while len(value) <= key:
                value.append(None)
        elif not isinstance(value, dict) or not isinstance(key, str):
            raise ContractError("target container shape drift")
        if last:
            value[key] = text
        else:
            if get_at(value, (key,)) is None:
                value[key] = [] if isinstance(path[index + 1], int) else {}
            value = value[key]


def _safe_path(root: Path, relative: str) -> Path:
    path = root / relative
    if Path(relative).is_absolute() or ".." in Path(relative).parts:
        raise ContractError(f"unsafe path: {relative}")
    if root.resolve() not in path.resolve().parents:
        raise ContractError(f"path escapes checkout: {relative}")
    return path


def private_dir(root: Path, locale: str) -> Path:
    if locale not in LOCALES:
        raise ContractError("unsupported locale")
    result = subprocess.run(["git", "rev-parse", "--absolute-git-dir"], cwd=root,
                            capture_output=True, text=True, check=True)
    return Path(result.stdout.strip()) / "full-game-localization" / locale / PROMPT_VERSION


def collect(root: Path = ROOT) -> dict[str, Any]:
    """Collect source independently of targets; never infer coverage from a cache."""
    import ja_translation_pipeline as ja
    import demo_localization_scope as demo
    import story_demo_localization_audit as public
    from event_lifecycle import audit_author_only

    if root.resolve() != ROOT.resolve():
        raise ContractError("repository collectors require this tool's checkout")
    leaves: list[Leaf] = []
    source_files: set[str] = set()
    unsupported: list[dict[str, Any]] = []
    internal_ending_notes: list[dict[str, str]] = []
    public_pairs, public_errors, _ = public.ui_pairs()
    if public_errors:
        raise ContractError("public-demo protection source: " + "; ".join(public_errors))
    protected_ui = set(public_pairs) | {"김민준"}
    lifecycle = audit_author_only(root)
    if lifecycle.errors:
        raise ContractError("lifecycle: " + "; ".join(lifecycle.errors))
    author_only = set(lifecycle.exempt_ids)
    source_events: dict[str, Any] = {}
    source_endings: dict[str, Any] = {}
    source_catalog: dict[str, Any] = {}

    def add(group, owner, file, path, text, category, **kwargs):
        if not isinstance(text, str):
            raise ContractError(f"{file}:{owner}:{pointer(path)}: non-string text")
        if not text.strip():
            return
        if group == "events":
            kwargs["runtime_support"] = event_overlay_support(tuple(path))
        leaves.append(Leaf(group, owner, file, tuple(path), text, category, **kwargs))
        if leaves[-1].runtime_support == "validator_contract_missing":
            unsupported.append({"kind": "validator_contract_missing", "source_id": leaves[-1].id,
                                "source_path": file, "path": pointer(tuple(path)),
                                "detail": "Built-in loader permits this field, but i18n_coverage_check rejects it."})

    for file in sorted((root / "content/events").glob("*.json")):
        relative = file.relative_to(root).as_posix()
        source_files.add(relative)
        for eid, row in row_index(read_json(file), relative).items():
            if eid in source_events:
                raise ContractError(f"duplicate source event ID: {eid}")
            source_events[eid] = row
            unsupported.extend(unsupported_relationship_display_names(eid, row, relative))
            kwargs = {"lifecycle": "author_only" if eid in author_only else "shipping",
                      "protected": eid in public.EVENT_IDS}
            for field in ja.EVENT_TEXT_FIELDS:
                if field in row:
                    add("events", eid, relative, (field,), row[field], "event_standard", **kwargs)
            for field in ja.EVENT_DICT_FIELDS:
                if field in row:
                    if not isinstance(row[field], dict):
                        raise ContractError(f"{eid}:{field}: expected text dictionary")
                    for key, text in row[field].items():
                        add("events", eid, relative, (field, key), text, "event_standard", **kwargs)
            for index, choice in enumerate(row.get("choices", [])):
                if not isinstance(choice, dict):
                    raise ContractError(f"{eid}: malformed choice")
                for field in (*ja.CHOICE_TEXT_FIELDS, "foreshadow"):
                    if field in choice:
                        category = "choice_foreshadow" if field == "foreshadow" else "event_standard"
                        add("events", eid, relative, ("choices", index, field), choice[field], category, **kwargs)
                for field in ja.CHOICE_DICT_FIELDS:
                    if field in choice:
                        for key, text in choice[field].items():
                            add("events", eid, relative, ("choices", index, field, key), text, "event_standard", **kwargs)
            for field, value in row.items():
                if READER.fullmatch(field):
                    if not isinstance(value, dict) or "texts" not in value:
                        raise ContractError(f"{eid}:{field}: malformed reader")
                    for path, text in reader_strings(value["texts"], (field, "texts")):
                        add("events", eid, relative, path, text, "chapter5_reader", **kwargs)

    ending_file = "content/endings.json"
    source_files.add(ending_file)
    source_endings = row_index(read_json(root / ending_file), ending_file)
    for eid, row in source_endings.items():
        for field in ja.ENDING_TEXT_FIELDS:
            if field in row:
                if field == "condition":
                    note = Leaf("endings", eid, ending_file, (field,), row[field], "internal_metadata")
                    internal_ending_notes.append({"id": note.id, "source": note.source,
                                                  "source_sha256": note.source_sha256})
                    continue
                add("endings", eid, ending_file, (field,), row[field], "ending")
        for field in ja.ENDING_DICT_FIELDS:
            for key, text in row.get(field, {}).items():
                add("endings", eid, ending_file, (field, key), text, "ending")
    for section, (relative, fields) in ja.CATALOG_SOURCES.items():
        source_files.add(relative)
        source_catalog[section] = row_index(read_json(root / relative), relative)
        for eid, row in source_catalog[section].items():
            for field in fields:
                if field in row:
                    for path, text in strings(row[field], (section, eid, field)):
                        add("catalog", section + ":" + eid, relative, path, text, "catalog",
                            protected=(section, eid, field) == ("jobs", "job_01", "name"))

    ui = ja.collect_ui_inventory()
    unsupported.extend({"kind": "static_ui_contract", "detail": e} for e in ui.errors)
    ui_seen: set[str] = set()
    for entry in ui.entries:
        key = entry.context_id or entry.source
        add("ui", key, "runtime:static_ui", (key,), entry.source, "ui_static_context",
            protected=key in protected_ui, format_template=entry.format_template)
        ui_seen.add(key)
    _, runtime, errors = demo.build_scope()
    unsupported.extend({"kind": "demo_dynamic_contract", "detail": e} for e in errors)
    demo_keys = set(runtime["merged_pairs"])
    for key in sorted(demo_keys - ui_seen):
        add("ui", key, "runtime:demo_dynamic", (key,), key, "ui_demo_dynamic",
            protected=key in protected_ui, format_template="%" in key)
        ui_seen.add(key)

    # Literal pairs outside the old demo are candidates until their runtime
    # consumer is proven. Counting them does not declare the lookup supported.
    candidates: dict[str, list[str]] = defaultdict(list)
    for file in sorted((root / "content").rglob("*.json")):
        relative = file.relative_to(root).as_posix()
        if any(p.startswith("events_") for p in file.parts) or re.search(r"endings_[^.]+\.json$", file.name):
            continue
        if file.name in {"full_game_localization.json"}:
            continue
        value = read_json(file)
        pairs, pair_errors = demo.collect_json_suffix_pairs(value, relative)
        inline, inline_errors = demo.collect_json_inline_pairs(value, relative)
        unsupported.extend({"kind": "unresolved_json_pair", "detail": error}
                           for error in pair_errors + inline_errors)
        if pairs or inline:
            source_files.add(relative)
        for pair in pairs + inline:
            candidates[pair.korean].append(pair.source_id)
    for directory in ja.RUNTIME_DIRS:
        for file in sorted((root / directory).rglob("*.gd")):
            relative = file.relative_to(root).as_posix()
            source_files.add(relative)
            source = file.read_text(encoding="utf-8")
            for pattern in (demo.GD_SUFFIX_PAIR, demo.GD_T_ET_PAIR):
                for match in pattern.finditer(source):
                    korean = loads(match.group("ko"))
                    if isinstance(korean, str) and korean.strip():
                        candidates[korean].append(f"{relative}:{source.count(chr(10), 0, match.start()) + 1}")
            for match in re.finditer(r"\bis_english\s*\(", source):
                unsupported.append({"kind": "legacy_language_branch", "path": relative,
                                    "line": source.count("\n", 0, match.start()) + 1})
    for korean, locations in sorted(candidates.items()):
        if korean in ui_seen:
            continue
        add("ui_unverified", korean, locations[0], (korean,), korean, "ui_global_candidate",
            protected=korean in protected_ui, runtime_support="unverified_consumer")
        unsupported.append({"kind": "unverified_dynamic_pair", "source_id": leaves[-1].id,
                            "locations": sorted(set(locations))})
    source_files.update({"content/meta/event_lifecycle.json", "content/meta/demo_localization_scope.json",
                         "playtests/order124/StoryChoiceM1M6Playtest.gd"})
    if len({leaf.id for leaf in leaves}) != len(leaves):
        raise ContractError("duplicate collected leaf ID")
    hashes = {name: sha_file(root / name) for name in sorted(source_files)}
    return {"leaves": sorted(leaves, key=lambda leaf: leaf.id), "source_hashes": hashes,
            "source_manifest_sha256": digest(hashes), "unsupported": unsupported,
            "internal_ending_notes": internal_ending_notes,
            "events": source_events, "endings": source_endings, "catalog": source_catalog,
            "source_counts": {"packaged_events": len(source_events), "shipping_events": len(source_events) - len(author_only),
                              "author_only_events": len(author_only), "endings": len(source_endings),
                              "ui_static_context": len(ui.entries), "demo_dynamic_unique": len(demo_keys),
                              "demo_dynamic_overlap_static": len(demo_keys & {e.source for e in ui.entries})}}


def _ja_father_call_time_numbers(source: str, target: str):
    """Normalize only this completed call's three differently owned quantities."""
    expected_source = (
        '한 시간이 지났다.\n\n'
        '평소엔 10분이었는데. 날씨, 음식, 서울 집값, 고향 동네 이야기.\n\n'
        '일요일 오전에 이유 없이 먼저 건 전화 하나가 — 이 대화를 만든 것이다.'
    )
    if source != expected_source:
        return None
    # Keep the elapsed hour, usual duration and earlier outgoing call in their
    # original paragraphs. An incoming call, plan or later correct quotation
    # cannot supply one of these slots. These are grammar-bound counts, not a
    # licence for arbitrary Japanese written numerals elsewhere in the leaf.
    lines = target.split('\n')
    errors = []
    spans = []
    replacements = []
    slots = (
        (0, r'(?P<number>[1１一])\s*時間(?:が)?(?:過ぎた|過ぎていた|経った|経っていた|たった|たっていた|経過した|経過していた)。',
         '1', True, 'elapsed hour/state'),
        (2, r'(?:いつも|普段|ふだん)(?:は|なら)(?P<number>10|１０|十)\s*分'
            r'(?:だったのに|なのに|だったが|だったのだが|で終わるのに|で終わっていたのに|で済んでいたのに)。',
         '10', False, 'usual minutes'),
        (4, r'日曜(?:日)?(?:の)?午前(?:中)?(?:に)?、?'
            r'(?:用事もなく|用もなく|特に用事もなく|特に用もなく|何の用事もなく|何の用もなく|理由もなく)'
            r'、?(?:(?:自分|こちら)(?:のほう)?から(?:先に)?|先に)かけた'
            r'(?P<number>[1１一])\s*(?:本|通)(?:の)?電話が(?:――|—|、)'
            r'(?:この|今の|今回の)会話(?:を(?:生んだ|生み出した|作った|もたらした)|につながった)'
            r'(?:のだ|のだった|んだ)?。',
         '1', True, 'earlier outgoing call'),
    )
    for line_index, pattern, number, whole_line, label in slots:
        match = None
        if len(lines) > line_index:
            match = (re.fullmatch if whole_line else re.match)(pattern, lines[line_index])
        if match is None:
            errors.append(f'source-bound father call {label} mismatch')
            continue
        offset = sum(len(line) + 1 for line in lines[:line_index])
        spans.append((offset + match.start(), offset + match.end()))
        start, end = match.span('number')
        replacements.append((offset + start, offset + end, number))
    # The legitimate 10 minutes must be consumed too; reusing the older
    # one-hour-only callback scanner would wrongly reject that second slot.
    for quantity in re.finditer(
        r'[+\-−]?[0-9０-９零一二三四五六七八九十百千万萬億兆]+\s*'
        r'(?:か月|ヶ月|カ月|年|月|週間|週|日|時間|時|分|秒|本|通)', target,
    ):
        if not any(start <= quantity.start() and quantity.end() <= end for start, end in spans):
            errors.append('source-bound father call added/displaced quantity mismatch')
    normalized_target = target
    for start, end, number in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + number + normalized_target[end:]
    normalized_source = source.replace('한 시간', '1 시간', 1).replace('전화 하나', '전화 1', 1)
    numeric = re.compile(r'(?<![\d.])[+-]?\d+(?:[,.]\d+)*')
    if numeric.findall(normalized_source) != numeric.findall(normalized_target):
        errors.append('source-bound father call ordered quantity mismatch')
    return normalized_source, normalized_target, errors



def _ja_investment_life_numbers(source: str, target: str):
    """Bind written quantities to the complete observed Korean narrative.

    Only owned numeral spans are canonicalized; unrelated digits and the
    subsequent money/value/sign checks are deliberately left in the stream.
    The contract is selected by source prose, never an event ID or target list.
    """
    contracts = {
        "50만 원을 넣었다. 처음엔 두 배가 됐다.\n그리고 반 토막. 다시 조금 올라와서 -30%에 멈췄다.\n팔아야 하는데, 손에 안 잡혔다.\n코인의 마력은 그거였다. 손절이 불가능하다.": [[["두 배","2 배"]],[[0,"(?:初め|最初)(?:は|に)@N@倍になった。",2,"","observed value factor"]],"倍"],
        "두 달 뒤 코인 시장이 42% 빠졌을 때 동창의 다온 상태 메시지가 조용해졌다.\n{name}은 아무 말도 안 했다.\n때로 가장 좋은 투자는 안 하는 것이다.": [[["두 달","2 달"]],[[0,"^@N@(?:か月|ヶ月|カ月|箇月)後、暗号資産市場が42%下落したとき",2,"","elapsed market months"]],"(?:か月|ヶ月|カ月|箇月|週間|週|日|年)"],
        "SNS 피드가 코인 얘기로 도배됐다. 고등학교 동창이 코어코인으로 3000만 원 벌었다는 다온 상태 메시지를 올렸다. 직장 후배는 점심 때마다 코인 얘기만 한다. 나만 모르는 건가, 나만 뒤처진 건가. {name}은 처음으로 업비트 앱을 깔아봤다.": [[["3000만 원","30000000원"]],[[0,"高校(?:時代)?の同級生が、?コアコインで@N@ウォン(?:儲けた|もうけた|稼いだ)とダオンのステータスメッセージに書いた",30000000,"","classmate claimed profit"]],"(?:ウォン|ドル|円|ユーロ)"],
        "완벽한 타이밍을 기다리는 동안 세 달이 지났다. 결국 그 타이밍은 오지 않았다.": [[["세 달","3 달"]],[[0,"完璧なタイミングを待つ(?:うち|間)に、?@N@(?:か月|ヶ月|カ月|箇月)が(?:過ぎた|経った)。",3,"","waiting months"]],"(?:か月|ヶ月|カ月|箇月|週間|週|日|年)"],
        "밤 11시, 유튜브 알고리즘이 '미국 대형주 ETF 하나로 끝내는 투자법' 영상을 추천했다. 호기심에 클릭했다가 세 편을 연달아 봤다. 개별 종목을 고르는 스트레스 없이 시장 전체에 투자한다는 개념이 솔깃했다. {name}은 맥주를 내려놓고 메모장을 꺼냈다.": [[["ETF 하나","ETF 1"],["세 편","3 편"]],[[0,"ETF@N@(?:つ|本)で完結する投資法",1,"","quoted ETF count"],[0,"そのまま@N@(?:本|編)(?:続けて|連続で)見た。",3,"","watched videos"]],"(?:本|編|つ|人|時間)"],
        "잘 모르지만 일단 발을 담갔다. 100달러짜리 경험이 앞으로 1000달러를 지켜줄 것이다.": [[],[[0,"。(?:ここで得た)?@N@ドル(?:分)?の経験が、",100,"","experience USD"],[0,"(?:この先|これから|今後)の@N@ドルを守ってくれる(?:だろう|はずだ)。",1000,"","future protected USD"]],"(?:ドル|ウォン|円|ユーロ)"],
        "시장 평균보다 낮아도, 원금을 지키며 1년을 버텼다는 게 이미 대단한 일이다. 내일의 {name}은 오늘보다 강하다.": [[],[[0,"元本を守りながら@N@年(?:間)?(?:持ちこたえた|耐えた)。",1,"","completed principal year"]],"(?:年(?:間)?|か月|ヶ月|日|時間)"],
        "1월 1일, {name}은 증권사 앱에서 '연간 수익률 리포트'를 열었다. +7.3%. 코스피 기준치는 +11.2%. 1년 동안 열심히 했는데 시장 평균을 못 이겼다는 숫자가 화면에 박혀 있다. 잘한 건지 못한 건지, 뭘 바꿔야 할지, 그냥 괜찮은 건지 — 아무도 정답을 알려주지 않는다.": [[],[[0,"。@N@年(?:間)?頑張ったのに、市場平均には勝てなかった。",1,"","worked review year"]],"(?:年(?:間)?|か月|ヶ月|時間)"],
        "1년 수익률 점검": [[],[[0,"^@N@年(?:間)?の収益率を(?:振り返る|見直す|確認する|点検する|チェックする)$",1,"","review title year"]],"(?:年(?:間)?|か月|ヶ月|日|時間)"],
        "저녁 뉴스에서 경제학자 세 명이 동시에 '부동산 버블 붕괴가 임박했다'고 경고했다. 댓글창엔 '이번엔 진짜다'와 '맨날 틀린 소리'가 반반이다. {name}의 포트폴리오에는 부동산 리츠가 꽤 많이 담겨 있다. 불안한 마음에 커피를 마시며 수익률 화면을 계속 새로고침 했다.": [[["세 명","3 명"]],[[0,"経済学者@N@(?:人|名)が(?:そろって|同時に)『不動産バブルの崩壊が迫っている』と警告した。",3,"","simultaneous economist warning"]],"(?:人|名|時間|年)"],
        "세 시간 뒤 결론 없이 영상 탭을 닫았지만, 적어도 리밸런싱의 원칙은 이해했다. 지식이 쌓이면 결정이 조금씩 빨라진다.": [[["세 시간","3 시간"]],[[0,"^@N@時間後、結論(?:の出ないまま|が出ないまま)動画のタブを閉じた。",3,"","elapsed closing hours"]],"(?:時間|日|年|分|秒)"],
        "요즘 핫한 K-뷰티 스타트업 공모주 청약이 열렸다. SNS에선 '상장 당일 따상 확실'이라는 말이 돈다. 경쟁률은 이미 820대 1을 넘겼고, 증권사 앱은 터질 듯 느리다. {name}은 청약 증거금 50만 원을 준비해두고 클릭을 망설이고 있다.": [[["따상","2 따상"]],[[0,"SNSでは『上場日に初値@N@倍、そのままストップ高は確実』という話が飛び交っている。",2,"","quoted IPO opening factor"]],"(?:倍|歳|年)"],
        "세금 신고 시즌이 왔다. 홈택스 화면을 열었다가 모르는 항목이 너무 많았다. 친구에게 물어보니 '배당·이자 소득이 2000만 원 넘으면 종합과세 대상이야'라고 한다. {name}의 작년 금융소득을 계산해보니 그 선이 아슬아슬하다. 세금을 잘못 내면 나중에 더 큰 문제가 생길 수 있다.": [[["2000만 원","20000000원"]],[[0,"友人に聞くと『配当と利子の所得が@N@ウォンを超えると、総合課税の対象だよ』と言う。",20000000,"","quoted tax threshold"]],"(?:ウォン|ドル|円|ユーロ)"],
        "유튜브 알고리즘이 보여준 영상이었다.\n'3배 레버리지 ETF, 1년 수익률 280%'\n\n댓글창은 열광했고, 몇몇은 '나도 했다'고 썼다.\n\n{name}은 계산기를 꺼냈다.\n지금 가진 돈에 3을 곱하면.": [[],[[1,"^『3倍レバレッジETF、@N@年(?:間)?の収益率280%』$",1,"","quoted leverage year"]],"(?:年(?:間)?|か月|ヶ月|日|時間)"],
        "3억 2천. 그냥 나를 위한 돈이 아니다.\n\n언젠가 아이를 키우려면, 지금 이 싸움에서 지면 안 된다. 두렵지만, 동시에 목표가 선명해지는 기분이었다.": [[["3억 2천","320000000원"]],[[0,"^@N@(?:ウォン)?(?=。ただ自分のためのお金ではない。)",320000000,"won","implicit child amount"]],"(?:億|万|ウォン|ドル|円|ユーロ)"],
        "뉴스 기사를 보다가 손이 멈췄다.\n「자녀 1인당 양육비 평균 3억 2천만 원」\n\n민준은 잠깐 계산기를 켰다. 대학까지 보내면 월 얼마가 드나. 사교육까지 더하면.\n\n숫자가 쌓일수록 가슴 한쪽이 무거워졌다.": [[["3억 2천만 원","320000000원"]],[[1,"^『子ども@N@人(?:当たり|あたり)の養育費、平均",1,"","per-child denominator"],[1,"養育費、平均@N@ウォン』$",320000000,"","average child cost"]],"(?:人|ウォン|ドル|円|ユーロ)"],
        "이모티콘 몇 개 보내고 카톡창을 닫았다.\n\n서른셋. 대체 나는 뭘 하고 있나. 잠깐 그런 생각이 지나갔다. 지워야 할 생각이었지만, 쉽게 안 지워졌다.": [[["서른셋","33살"]],[[2,"^@N@歳。一体、自分は何をしているんだろう。",33,"","self age"]],"(?:歳|才|年|か月|日)"],
        "고등학교 친구에게서 카톡이 왔다.\n「야 나 임신했어. 다음 달에 돌잔치 아니고… 아 그 전에 결혼식 먼저. 하하.」\n\n축하 이모티콘을 보내면서 민준은 잠깐 멈췄다.\n같은 나이다. 서른셋. 그 친구는 이미 다음 챕터로 넘어가고 있다.": [[["돌잔치","1살 돌잔치"],["서른셋","33살"]],[[1,"来月は@N@歳のお祝いじゃなくて",1,"","negated first birthday"],[4,"^同い年だ。@N@歳。その友人は、もう次の章へ進んでいる。",33,"","shared age"]],"(?:歳|才|年|か月|日)"],
        "뉴스 헤드라인이 눈에 들어왔다.\n「국민연금 2055년 완전 고갈 전망... 지금 서른 세대는 한 푼도 못 받을 수도」\n\n2055년. 지금은 멀어 보여도, 민준이 노후를 살아갈 시간 안에 있는 해였다.\n\n그냥 지나치기엔 숫자가 너무 구체적이었다.": [[["서른","30"]],[[1,"今@N@歳の世代は、一銭も受け取れない可能性も』$",30,"","pension cohort possibility"]],"(?:歳|才|か月|日)"],
        "짐을 정리하다가 대학 1학년 때 노트가 나왔다.\n\n「10년 안에 내 이름을 건 회사를 만들겠다. 30살에 세상을 바꾸겠다.」\n\n그때의 글씨가 지금보다 굵었다.": [[],[[0,"大学@N@年(?:生|次)のときのノートが出てきた。",1,"","university first year"]],"年(?:生|次)"],
        "\"알겠습니다\" 하고 나왔다.\n\n1년을 갈아넣었다. B+. 다음 해도 같은 말을 듣게 될 것 같은 기분이 들었다. 이 회사에서 S는 가능한 걸까.": [[],[[2,"^(?:この)?@N@年(?:間)?を(?:すり減らして働いた|仕事につぎ込んだ)。B\\+。",1,"","completed work year"]],"(?:年(?:間)?|か月|ヶ月|日|時間)"],
    }
    contract = contracts.get(source)
    if contract is None:
        return None
    import unicodedata

    # This parser is local to the licensed slots. It is not a global allowance
    # for Japanese numerals, group separators, money labels or omitted units.
    digits = '〇零一二三四五六七八九'
    digit_values = dict(zip(digits, (0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)))

    def integer(raw):
        raw = unicodedata.normalize('NFKC', raw)
        if not raw or raw[0] in '+-−':
            return None
        if ',' in raw and not re.fullmatch(
            r'(?:(?:[1-9][0-9]{0,2}(?:,[0-9]{3})+|[0-9]+)[億万]?)+', raw,
        ):
            return None
        raw = raw.replace(',', '')
        total, section, pending = 0, 0, ''
        for char in raw:
            if char.isascii() and char.isdigit():
                pending += char
            elif char in digit_values:
                pending += str(digit_values[char])
            elif char in '十百千':
                section += (int(pending) if pending else 1) * {'十': 10, '百': 100, '千': 1000}[char]
                pending = ''
            elif char in '万億':
                section += int(pending) if pending else 0
                total += (section or 1) * {'万': 10000, '億': 100000000}[char]
                section, pending = 0, ''
            else:
                return None
        return total + section + (int(pending) if pending else 0)

    numeral = r'[+＋\-－−]?[0-9０-９〇零一二三四五六七八九十百千万億,，]+'
    number_group = r'(?P<number>' + numeral + ')'
    rewrites, slots, unit_pattern = contract
    lines = target.split('\n')
    errors, replacements, owned = [], [], []
    for line_index, pattern, value, mode, label in slots:
        matches = list(re.finditer(pattern.replace('@N@', number_group),
                                   lines[line_index])) if line_index < len(lines) else []
        if len(matches) != 1:
            errors.append(f'source-bound investment/life {label} role/state/position mismatch')
            continue
        match = matches[0]
        offset = sum(len(line) + 1 for line in lines[:line_index])
        start, end = (offset + point for point in match.span('number'))
        # Signed, malformed or changed values cannot borrow a later correct slot.
        if integer(match.group('number')) != value:
            errors.append(f'source-bound investment/life {label} value/sign mismatch')
        owned.append((start, end))
        if mode == 'won':
            # Korean source omits 만 원 here, but its immediately following
            # money/child-purpose sentence licenses exactly 320 million won.
            end = offset + match.end()
            replacements.append((start, end, str(value) + 'ウォン'))
        else:
            replacements.append((start, end, str(value)))

    # Inspect all occurrences of the licensed unit family, not only the first
    # valid witness. Extra/displaced/negated clauses cannot be laundered by
    # repeating the normal clause in this line or a later paragraph.
    for quantity in re.finditer('(?P<number>' + numeral + r')\s*(?:' + unit_pattern + ')', target):
        start, end = quantity.span('number')
        if not any(a <= start and end <= b for a, b in owned):
            errors.append('source-bound investment/life added/displaced quantity mismatch')
    normalized_source = source
    for old, new in rewrites:
        normalized_source = normalized_source.replace(old, new, 1)
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return normalized_source, normalized_target, errors


SECTOR_LITERAL_PERCENT_SOURCE = "전세 사기 피해자 300명 뉴스가 터졌다.\n\n부동산 관련 종목들이 장 시작부터 빠지고 있었다.\n건설사 -3.2%. REITs -4.1%. 부동산 플랫폼 -2.8%.\n\n{name}은 포트폴리오를 봤다.\n공포가 가격을 만들 때, 지금이 기회인가 아직 바닥이 아닌가."

def _sector_literal_percent_pair(source: str, target: str):
    """Only this prose quote has a percent/full-stop/REIT, not printf %. R."""
    if source != SECTOR_LITERAL_PERCENT_SOURCE:
        return None
    # Mask only the literal percent sign at a number's end. Actual %s, width
    # syntax, brace tokens and other printf sequences still reach the validators.
    literal = re.compile(r"(?<=[0-9])%(?=[.。]\s*REITs?\b)")
    return literal.sub("％", source), literal.sub("％", target)


def _sector_percentage_errors(source: str, target: str) -> list[str]:
    """Do not let the literal-percent token repair hide changed rate slots."""
    if source != SECTOR_LITERAL_PERCENT_SOURCE:
        return []
    percentage = re.compile(
        r"(?<![0-9０-９.+＋\-－−])[+-]?[0-9]+(?:\.[0-9]+)?[%％]"
        r"(?![%％‰‱]|\s*(?:[/／]|ウォン|ドル|円|ユーロ|韓元|韩元|元|倍))"
    )
    def rates(value):
        return [(value.count("\n", 0, match.start()), match.group().replace("％", "%"))
                for match in percentage.finditer(value)]
    if rates(source) != rates(target):
        return ["source-bound sector percentage value/sign/unit/line/order mismatch"]
    return []


def _ja_market_admin_numbers(source: str, target: str):
    """Complete-source licences for observed money, native counts and units.

    Each quantity is attached to its owner/action and original line. Only the
    numeric span is canonicalized; all other numbers remain in the final stream.
    Shared won parsing is consumed on the ORIGINAL source, before any rewrite.
    """
    contracts = {
        "구독 서비스 두 개를 해지했다.\n합산 4만 8천원.\n월세 인상분을 다른 곳에서 메꿨다.": {"rewrites":[["두 개","2 개"]],"slots":[[0,"^(?:(?:利用|使用|契約)していた|使っていた|不要な)?(?:サブスク|サブスクリプション|定額サービス)(?:を)?@N@(?:つ|件|個)(?:を)?解約した。$",2,"","cancelled subscriptions"],[1,"^(?:合計|合算|合わせて)@N@ウォン。$","money","","combined subscriptions cost"]],"units":"(?:つ|件|個|ウォン|ドル|円|ユーロ)","money":True},
        "오전 8시 41분.\n은행 앱 알림이 울렸다.\n\n'잔액이 마이너스입니다. 마이너스 통장 이자가 적용됩니다.'\n\n숫자: -34,200원.\n마이너스 통장 한도 잔액: 496만 7천800원.\n\n{name}은 앱을 닫았다가 다시 열었다.\n숫자는 그대로였다.": {"rewrites":[],"slots":[[5,"^(?:表示された)?(?:数字|金額|残高)(?:は|[：:])@N@ウォン。$","money","","negative account balance"],[6,"^(?:当座貸越|マイナス通帳)の(?:利用可能残額|利用可能な残額|残りの利用可能額|残り利用可能額)(?:は|[：:])@N@ウォン。$","money","","available overdraft balance"]],"units":"(?:ウォン|ドル|円|ユーロ)","money":True},
        "편의점 알바 공고. 시급 10,320원.\n최저임금이다. 4대보험 적용, 주휴수당 포함 시 실질 시급은 조금 더 높다.\n\n편의점 점장이 이력서를 훑어봤다.\n\"지금 다른 알바 하고 있어요?\" 첫 질문이었다.": {"rewrites":[],"slots":[[1,"^(?:最低賃金だ。)?(?:韓国の)?@N@大(?:社会)?保険(?:が|の)適用(?:され|あり)、",4,"","Korean statutory insurance schemes"]],"units":"(?:大(?:社会)?保険|年間の社会保険)","money":False},
        "팀장이 단체 카톡을 보냈다.\n\"오늘 저녁 회식! 다들 참석 부탁드립니다 :)\"\n\n물음표가 없다. 요청이지만 거절이 어렵다.\n삼겹살집, 2차는 노래방, 3차는 포장마차.": {"rewrites":[],"slots":[[4,"^サムギョプサル(?:の店)?、(?:第)?@N@次会はカラオケ、",2,"","second karaoke round"],[4,"、(?:第)?@N@次会はポジャンマチャ。$",3,"","third street-stall round"]],"units":"(?:次会|軒目|時間)","money":False},
        "1차까지만 — 일찍 빠진다": {"rewrites":[],"slots":[[0,"^@N@(?:次会|軒目)(?:だけ|まで)[—―－ー–-]+(?:早めに|早く)(?:抜ける|帰る|切り上げる)$",1,"","first-round departure choice"]],"units":"(?:次会|軒目|時間)","money":False},
        "\"내일 일이 있어서요.\" 1차 삼겹살에서 나왔다.\n\n팀장이 \"그래, 먼저 가.\" 했다. 표정은 읽기 어려웠다.\n이 눈치를 어떻게 받아들일지는, 아직 모르겠다.": {"rewrites":[],"slots":[[0,"^[「『][^「」『』\\n]*[」』](?:第)?@N@次会のサムギョプサル(?:で(?:切り上げた|帰った)|の店を出た)。$",1,"","completed first-round departure"]],"units":"(?:次会|軒目|日目|時間)","money":False},
        "다운로드 창을 닫고 단톡방 알림도 껐다.\n새벽 두 시, 손은 다시 화면을 찾았지만 앱은 없었다.": {"rewrites":[["새벽 두 시","새벽2시"]],"slots":[[1,"^(?:午前|深夜|夜中の)@N@時[、，,](?:手は)?(?:また|再び)画面(?:を(?:求めた|探した|探った)|に(?:伸びた|伸ばした))が、?アプリは(?:なかった|消えていた|入っていなかった)。$",2,"","late-night absent app"]],"units":"(?:時(?:間)?|日|分|秒)","money":False},
        "화면을 닫았다.\n두 시간 후에 다시 열었다.\n시장은 위아래로 흔들렸다가 제자리였다.": {"rewrites":[["두 시간","2 시간"]],"slots":[[1,"^@N@時間(?:後(?:に)?|経ってから)[、，,]?(?:画面を)?(?:また|再び|もう一度)(?:画面を)?開いた。$",2,"","completed screen reopening after hours"]],"units":"(?:時間|日|時|分|秒)","money":False},
        "직장 선배에게서 귀띔이 왔다.\n\"이번 AI 반도체 관련 기업 공모주, 기관들이 엄청 밀고 있어.\n균등배정으로 들어가면 상한가 두세 번은 기본이래.\"\n\n청약 증거금이 묶이고, 배정 여부는 운이지만,\n지금 이 시장 분위기라면 올 것 같다는 느낌이 든다.\n뭘 얼마나 넣을지가 관건이다.": {"rewrites":[["두세 번","2~3 번"]],"slots":[[2,"^(?:均等配分|均等割当)で(?:申し込めば|入れば)、?(?:ストップ高(?:は|が)?)?@N@(?:回|度)?[、，,〜～~・-](?=[0-9０-９〇零一二三四五六七八九十百千万億])",2,"","quoted limit-up range lower"],[2,"[、，,〜～~・-]@N@(?:回|度)(?:のストップ高)?(?:は)?(?:堅い|基本|当たり前|普通)(?:だ)?(?:らしい|そうだ)(?:よ)?[」』]$",3,"","quoted limit-up range upper"]],"units":"(?:回|度|年|倍)","money":False},
        "뉴스를 켰다.\n\n'강남 아파트 평균 25억 돌파'\n\n25억.\n지금 {name}의 통장 잔고의 몇 배인지 계산이 안 됐다.\n\n그런데 저 아파트에 사는 사람들은 어떻게 산 걸까.": {"rewrites":[["25억","2500000000원"],["25억","2500000000원"]],"slots":[[2,"^[「『]カンナムのマンション(?:[、，,](?:平均|平均価格(?:が|は)?)|(?:の)?平均価格[、，,はが])@N@ウォン(?:を)?(?:突破|超えた)[」』]$",2500000000,"","quoted average apartment price"],[4,"^@N@(?:ウォン)?。$",2500000000,"implicit_won","repeated apartment price"]],"units":"(?:ウォン|ドル|円|ユーロ|億|万)","money":False},
        "3분의 1을 샀다.\n다음날 2% 더 빠졌다.\n추가로 3분의 1을 더 샀다. 분할의 이유였다.": {"rewrites":[],"money":False,"units":"(?:分|[/／]|[%％]|パーセント)","slots":[[0,"^(?:まず|先に)?@F@を(?:買った|買い付けた|購入した)。",[3,1],"fraction","first completed purchase fraction"],[1,"^(?:翌日|次の日)(?:、(?:そこから)?)?(?:さらに|また)?@N@[%％](?:さらに)?(?:下がった|下落した|落ちた)。$",2,"","next-day additional decline"],[2,"^(?:追加(?:で|に)(?:もう)?|もう|さらに)(?:、)?@F@を(?:さらに|もう)?(?:買った|買い足した|買い増した|買い付けた|購入した)。",[3,1],"fraction","additional completed purchase fraction"]]},
        "공포에 살 수 있었다.\n2개월 뒤 시장은 50% 반등했고, 그 포지션은 두 배가 됐다.": {"rewrites":[["두 배","2 배"]],"money":False,"units":"(?:か月|ヶ月|カ月|箇月|日|年|倍|[%％])","slots":[[1,"^@N@(?:か月|ヶ月|カ月|箇月)後[、，,]",2,"","market rebound elapsed months"],[1,"市場(?:は|が)@N@[%％](?:反発|反騰|回復|上昇)し[、，,]",50,"","market rebound rate"],[1,"(?:その|あの)ポジション(?:の価値)?(?:は|が)@N@倍(?:になった|に増えた|となった)。$",2,"","realized position factor"]]},
    }
    contract = contracts.get(source)
    if contract is None:
        return None
    import unicodedata

    def integer(raw):
        raw = unicodedata.normalize("NFKC", raw).replace("−", "-")
        if not raw:
            return None
        sign = -1 if raw.startswith("-") else 1
        if raw.startswith(("+", "-")):
            raw = raw[1:]
        if not raw or ("," in raw and not re.fullmatch(
            r"(?:(?:[1-9][0-9]{0,2}(?:,[0-9]{3})+|[0-9]+)[億万千百十]?)+", raw,
        )):
            return None
        raw = raw.replace(",", "")
        digits = dict(zip("〇零一二三四五六七八九", (0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)))
        total, section, pending = 0, 0, ""
        for char in raw:
            if char.isascii() and char.isdigit():
                pending += char
            elif char in digits:
                pending += str(digits[char])
            elif char in "十百千":
                section += (int(pending) if pending else 1) * {"十": 10, "百": 100, "千": 1000}[char]
                pending = ""
            elif char in "万億":
                section += int(pending) if pending else 0
                total += (section or 1) * {"万": 10000, "億": 100000000}[char]
                section, pending = 0, ""
            else:
                return None
        return sign * (total + section + (int(pending) if pending else 0))

    numeral = r"[+＋\-－−]?[0-9０-９〇零一二三四五六七八九十百千万億,，]+"
    group = "(?P<number>" + numeral + ")"
    fraction_group = ("(?P<fraction>(?:(?P<den>" + numeral + ")分の(?P<num>" + numeral + ")|"
                      "(?P<slash_num>" + numeral + ")[/／](?P<slash_den>" + numeral + ")))" )
    lines = target.split("\n")
    errors, replacements, owned, source_replacements = [], [], [], []
    money_by_line = {}
    if contract["money"]:
        from zh_translation_audit import _source_money_amounts
        for amount in _source_money_amounts(source):
            line = source.count("\n", 0, amount.start)
            money_by_line.setdefault(line, []).append(amount)
        for line, _, value, _, label in contract["slots"]:
            if value != "money":
                continue
            amounts = money_by_line.get(line, [])
            if len(amounts) != 1:
                errors.append(f"source-bound market/admin {label} shared source amount mismatch")
                continue
            amount = amounts[0]
            source_replacements.append((amount.start, amount.end, format(amount.won, "f") + "원"))

    for line, pattern, expected, mode, label in contract["slots"]:
        pattern = pattern.replace("@N@", group).replace("@F@", fraction_group)
        matches = list(re.finditer(pattern, lines[line])) if line < len(lines) else []
        if len(matches) != 1:
            errors.append(f"source-bound market/admin {label} role/state/unit/position mismatch")
            continue
        match = matches[0]
        if mode == "fraction":
            # Denominator/numerator belong to one completed purchase, never a
            # duration. Slash typography has the inverse written order; retain
            # both values in source order rather than deleting either numeral.
            den, num = ((match.group("den"), match.group("num")) if match.group("den") is not None
                        else (match.group("slash_den"), match.group("slash_num")))
            if [integer(den), integer(num)] != expected or any(
                unicodedata.normalize("NFKC", raw).startswith(("+", "-", "−")) for raw in (den, num)
            ):
                errors.append(f"source-bound market/admin {label} value/sign mismatch")
            offset = sum(len(part) + 1 for part in lines[:line])
            start, end = (offset + point for point in match.span("fraction"))
            owned.append((start, end))
            replacements.append((start, end, f"{expected[0]}分の{expected[1]}"))
            continue
        if expected == "money":
            amounts = money_by_line.get(line, [])
            if len(amounts) != 1:
                continue
            expected = amounts[0].won
        raw = match.group("number")
        value = integer(raw)
        canonical_raw = unicodedata.normalize("NFKC", raw).replace("−", "-")
        if value != expected or canonical_raw.startswith("+") or (
            expected >= 0 and canonical_raw.startswith("-")
        ):
            errors.append(f"source-bound market/admin {label} value/sign mismatch")
        offset = sum(len(part) + 1 for part in lines[:line])
        start, end = (offset + index for index in match.span("number"))
        owned.append((start, end))
        if mode == "implicit_won":
            end = offset + match.end() - 1  # preserve the final full stop
            replacement = str(expected) + "ウォン"
        else:
            replacement = str(expected)
        replacements.append((start, end, replacement))

    # A second correct witness cannot excuse an extra, wrong, signed, displaced
    # or differently owned native quantity elsewhere in the same source leaf.
    for quantity in re.finditer("(?P<number>" + numeral + r")\s*(?:" + contract["units"] + ")", target):
        start, end = quantity.span("number")
        if not any(a <= start and end <= b for a, b in owned):
            errors.append("source-bound market/admin added/displaced quantity mismatch")
    normalized_source = source
    for start, end, replacement in sorted(source_replacements, reverse=True):
        normalized_source = normalized_source[:start] + replacement + normalized_source[end:]
    for old, new in contract["rewrites"]:
        normalized_source = normalized_source.replace(old, new, 1)
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return normalized_source, normalized_target, errors



def _ja_korean_culture_numbers(source: str, target: str):
    """Observed Korean-life quantities: source identity, local role, line and unit.

    Only the owned number spans are canonicalized. Unrelated prose is not a
    translation template, and extra amounts/counts remain visible to both the
    local coverage check and the existing complete numeric stream.
    """
    contracts = {
        "온수 탕에 발을 담그자 온몸이 녹았다.\n\n찜질복 입고 계란 하나 까먹으며 누워 있었다.\n서울 생존의 비밀 중 하나다. 1만 2천 원에 온기, 샤워, 잠자리.": {"rewrites":[["1만 2천 원","12000원"]],"slots":[[3,"@N@ウォン(?:で|に対し)",12000,"spa package price"]],"units":"ウォン|ドル|円|ユーロ|元","checks":[]},
        "라면 기계에서 뽑은 사천 원짜리 행복.\n강바람이 국물 위로 불었다.\n\n치킨 시킨 옆 돗자리가 부럽지 않았다고 하면 거짓말이지만 —\n그래도 오늘 밤 한강은 모두에게 공평했다.": {"rewrites":[["사천 원","4000원"]],"slots":[[0,"@N@ウォン(?:の|分の|で(?:得た|買った|買える|手に入れた|手に入る))(?:ささやかな)?(?:幸せ|幸福)",4000,"ramyeon happiness price"]],"units":"ウォン|ドル|円|ユーロ|元","checks":[]},
        "새벽 1시, 배는 고프고 돈은 없다.\n유튜브를 열었더니 알고리즘이 먹방을 추천한다.\n\n1인분 짜장면을 네 그릇째 먹는 유튜버.\n섬네일만 봐도 침이 고인다.": {"rewrites":[["네 그릇째","4그릇째"]],"slots":[[0,"(?:午前|深夜|夜中の)@N@時",1,"late-night clock"],[3,"@N@人前(?:の|分の)?(?:チャジャン麺|ジャージャー麺)",1,"serving size"],[3,"@N@(?:杯|皿|鉢)(?:目)",4,"streamer bowl ordinal"]],"units":"人前|杯|皿|鉢|時(?:間)?|分|秒","checks":[[3,"(?:ユーチューバー|配信者|動画投稿者)","streamer owner"],[3,"(?:食べ進めている|食べている|食べ続けている|食べる)","eating state"]]},
        "다온 오픈채팅 '서울 2030 재테크 모임'.\n익명으로 들어왔다.\n\n채팅창이 쉬지 않고 올라온다.\n부동산, 주식, 코인, 그리고 아파트 청약.": {"rewrites":[["2030","20 30"]],"slots":[[0,"[「『]ソウル(?:の)?\\s*@N@(?:代)?(?:[・、〜～~]|と)",20,"quoted young-adult lower decade"],[0,"(?:[・、〜～~]|と)@N@代",30,"quoted young-adult upper decade"]],"units":"代|年|歳","checks":[[0,"(?:資産運用|資産づくり|財テク|投資|マネー)[^「」『』\\n]*[」』]","quoted finance group"]]},
        "고화질 모니터로 채용 공고와 부동산 시세를 뒤졌다.\n집보다 빠른 인터넷, 천오백 원어치는 했다.": {"rewrites":[["천오백 원","1500원"]],"slots":[[1,"@N@ウォン(?:分|の|だけ|程度)",1500,"PC room received value"]],"units":"ウォン|ドル|円|ユーロ|元","checks":[[1,"(?:価値|元は取れ|見合|甲斐)","received value"]]},
        "결국 들어가지 않았다. 천오백 원도 아껴야 했다.\n빗속을 걸으며 라면 냄새만 기억에 담았다.": {"rewrites":[["천오백 원","1500원"]],"slots":[[0,"@N@ウォン",1500,"not-entered money to save"]],"units":"ウォン|ドル|円|ユーロ|元","checks":[[0,"(?:入らなかった|入らず|入店しなかった|入店せず)","not-entered state"],[0,"(?:節約|惜し|浮か|出費|大事)","saving purpose"]]},
        "비 오는 오후, 갈 데가 없어 PC방에 들어갔다.\n시간당 천오백 원. 알바생이 자리 번호를 찍어준다.\n\n옆자리에서 누군가 시킨 컵라면 냄새가 모니터를 타고 넘어온다.\n— 피방 라면은 왜 더 맛있을까.": {"rewrites":[["시간당 천오백 원","1시간1500원"]],"slots":[[1,"(?:@N@)?時間(?:あたり|当たり|につき)?|毎時",1,"hourly rate denominator"],[1,"@N@ウォン",1500,"hourly PC room rate"]],"units":"時間|日|分|秒|ウォン|ドル|円|ユーロ|元","checks":[]},
        "4월 첫째 주, 벚꽃이 폭발했다.\n여의도 둑방, 석촌호수, 경복궁 돌담길.\n\n꽃이 지기까지는 일주일.\n서울 전체가 이 일주일에 몰려든다.": {"rewrites":[["첫째","1"],["일주일","1주"],["일주일","1주"]],"slots":[[0,"@N@月",4,"blossom calendar month"],[0,"(?:第)?@N@週|最初の週",1,"blossom first week"],[3,"@N@週(?:間)?",1,"flower remaining week"],[4,"@N@週(?:間)?",1,"crowd same week"]],"units":"月|週|日|年","checks":[]},
        "11월 셋째 주 목요일.\n전투기가 이착륙을 멈추고, 주식 시장이 한 시간 늦게 열렸다.\n\n대한민국이 18세 아이들 시험 하나에\n잠깐 일시정지 버튼을 눌렀다.": {"rewrites":[["셋째","3"],["한 시간","1시간"],["시험 하나","시험1"]],"slots":[[0,"@N@月",11,"exam calendar month"],[0,"(?:第)?@N@週(?:の|[、，,])?(?:木曜日|木曜)",3,"exam third-week Thursday"],[1,"@N@時間(?:遅く|遅れ(?:て|で))",1,"stock opening delay"],[3,"@N@歳",18,"candidate age"],[3,"@N@つの試験",1,"single exam"]],"units":"月|週|時間|歳|つ","checks":[[1,"(?:株式市場|株式相場|株式の市場|株式取引|証券市場)","stock market owner"],[1,"(?:開いた|開き|始まった|始まり|開始した)","completed later opening"]]},
        "30분 뒤 문 앞에 도착한 치킨.\n혼자 먹는데도 '문 앞에 두고 가주세요'를 누르는 게 한국식.\n\n배달비가 아깝다가도, 따뜻한 한 끼 앞에선 다 잊힌다.\n오늘 하루를 버틴 나에게 주는 만 9천 원짜리 상.": {"rewrites":[["만 9천 원","19000원"],["오늘 하루","오늘1일"]],"slots":[[0,"@N@分(?:後|経って)",30,"delivery elapsed minutes"],[4,"今日@N@日",1,"survived day reward"],[4,"@N@ウォン(?:の|分の)(?:ご褒美|褒美|賞)",19000,"received reward price"]],"units":"分|時間|日|ウォン|ドル|円|ユーロ|元","checks":[[0,"(?:届いた|到着した)","completed delivery"]]},
        "결국 앱을 껐다. 편의점 도시락에 컵라면.\n\n배달비 3천 5백 원을 아낀 게 뿌듯하면서도 좀 서글펐다.\n이 작은 계산들이 모여 강남으로 가는 거라고, 스스로를 다독였다.": {"rewrites":[["3천 5백 원","3500원"]],"slots":[[2,"(?:配達料|配送料|送料)(?:の|は|を)?\\s*@N@ウォン",3500,"saved delivery fee"]],"units":"ウォン|ドル|円|ユーロ|元","checks":[[2,"(?:節約でき|節約した|浮かせ|浮い|節約して)","saved fee state"]]},
        "야근 후 텅 빈 고시원 방.\n배달앱을 켠다. 최소주문 1만 5천, 배달비 3천 5백.\n\n장바구니에 담았다 뺐다를 반복한다.\n별점 4.8과 4.6 사이에서, 또 한참 고민한다.": {"rewrites":[["1만 5천","15000원"],["3천 5백","3500원"]],"slots":[[1,"(?:最低注文額|最低注文金額|最低注文)(?:は|が|の)?\\s*@N@ウォン",15000,"minimum order price"],[1,"(?:配達料|配送料|送料)(?:は|が|の)?\\s*@N@ウォン",3500,"delivery fee"]],"units":"ウォン|ドル|円|ユーロ|元","checks":[]},
        "1인 1만 5천 원 고기 무한리필.\n불판 위에 삼겹살이 지글거린다.\n\n'본전은 뽑아야 한다'는 한국인의 본능이 깨어난다.\n상추에 고기, 마늘, 쌈장 — 한입 가득.": {"rewrites":[["1만 5천 원","15000원"]],"slots":[[0,"@N@人(?:あたり|当たり|につき)?",1,"buffet person denominator"],[0,"@N@ウォン",15000,"buffet per-person price"]],"units":"人|ウォン|ドル|円|ユーロ|元","checks":[[0,"(?:食べ放題|おかわり自由)","buffet price role"]]},
        "아무도 없는 서울을 걸었다.\n\n강변이 비어있었다. 한강 다리가 멀리 보였다.\n1년에 한 번, 이 도시가 숨 쉬는 날이다.": {"rewrites":[["1년에 한 번","1년1번"]],"slots":[[3,"(?:@N@)?年(?:に|ごとに)|毎年",1,"once-year denominator"],[3,"@N@(?:度|回)",1,"annual occurrence"]],"units":"年|月|週|日|度|回","checks":[]},
        "1인분이라 좀 멋쩍었지만, 아주머니가 떡을 더 얹어줬다.\n\"많이 먹어요, 총각.\"\n그 한마디에 떡볶이보다 마음이 더 데워졌다.": {"rewrites":[],"slots":[[0,"@N@人前",1,"served portion"]],"units":"人前|人分|時間|週間","checks":[]},
        "기본 떡볶이 1인분만": {"rewrites":[],"slots":[[0,"@N@人前(?:だけ|のみ)",1,"only selected serving"]],"units":"人前|人分|時間|週間","checks":[]},
        "스펙을 올리려고 영어 학원을 등록했다.\n수강생 대부분이 직장인이다. 저녁 7시 반 수업.\n\n선생님이 자기소개를 시킨다.\n\"My name is... I am... working at...\"": {"rewrites":[["저녁 7시 반","19:30"]],"slots":[],"units":"時(?:間)?|分|秒","checks":[[1,"(?:授業|クラス|講義)","evening class owner"]],"clock":True},
        "계란까지 풀어 끓인 라면에 게임 한 판. 한 판이 세 판이 됐다.\n\n죄책감 반, 행복 반.\n그래도 비 오는 날 피방만 한 도피처가 없다는 건 사실이었다.": {"rewrites":[["한 판","1판"],["한 판","1판"],["세 판","3판"]],"slots":[[0,"ゲーム(?:を)?@N@(?:戦|回|ゲーム)",1,"initial game count"],[0,"[。．]@N@(?:戦|回|ゲーム)が",1,"repeated initial game count"],[0,"(?:戦|回|ゲーム)が@N@(?:戦|回|ゲーム)(?:になった|に増えた)",3,"realized game count"]],"units":"戦|回|ゲーム|時間|分|日","checks":[]},
        "밤 10시, 대치동 학원 거리.\n중고등학생들이 학원에서 쏟아져 나온다.\n\n수학, 영어, 과학, 논술...\n이 거리의 부모들은 강남 집값의 3분의 1을 교육비에 쓴다고 한다.": {"rewrites":[],"slots":[[4,"(?:住宅|家|住居|マンション)(?:の)?(?:価格|値段)の@F@",[3,1],"reported parental education price fraction"]],"units":"分の|[/／]","checks":[[4,"(?:親|保護者).*カンナム","parents own comparison"],[4,"教育費.*(?:という|そうだ|らしい|とのこと)","reported education expense"]]},
        "막차가 끊긴 밤, 골목 코인노래방.\n천 원에 네 곡. 부스 안은 혼자다.\n\n끈적한 소파, 탬버린 하나, 그리고 익숙한 발라드 번호.\n오늘 하루가 무거웠다.": {"rewrites":[["천 원","1000원"],["네 곡","4곡"]],"slots":[[1,"@N@ウォン(?:で|払えば|を払えば)",1000,"four-song bundle price"],[1,"@N@曲",4,"four-song bundle count"]],"units":"ウォン|ドル|円|曲|時間|分|秒","checks":[]},
    }
    contract = contracts.get(source)
    if contract is None:
        return None
    import unicodedata

    def integer(raw):
        if raw is None:  # 시간당 / 年に can have an implicit denominator of one.
            return 1
        raw = unicodedata.normalize("NFKC", raw).replace("−", "-")
        if raw.startswith(("+", "-")):
            return None
        if "," in raw and not re.fullmatch(
            r"(?:(?:[1-9][0-9]{0,2}(?:,[0-9]{3})+|[0-9]+)[万千百十]?)+", raw,
        ):
            return None
        digits = dict(zip("〇零一二三四五六七八九", (0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)))
        total, section, pending = 0, 0, ""
        for char in raw.replace(",", ""):
            if char.isascii() and char.isdigit():
                pending += char
            elif char in digits:
                pending += str(digits[char])
            elif char in "十百千":
                section += (int(pending) if pending else 1) * {"十": 10, "百": 100, "千": 1000}[char]
                pending = ""
            elif char == "万":
                total += (section + (int(pending) if pending else 0) or 1) * 10000
                section, pending = 0, ""
            else:
                return None
        return total + section + (int(pending) if pending else 0)

    number = r"[+＋\-－−]?[0-9０-９〇零一二三四五六七八九十百千万億,，]+"
    group = "(?P<number>" + number + ")"
    fraction = ("(?P<fraction>(?P<den>" + number + ")分の(?P<num>" + number + ")|"
                "(?P<num_slash>" + number + ")[/／](?P<den_slash>" + number + "))")
    lines = target.split("\n")
    errors, replacements, owned = [], [], []
    if contract.get("clock"):
        # This source alone says evening 7:30. The 12/24-hour renderings own
        # the same instant, not a duration or a different class on another line.
        pattern = (r"(?P<phase>午後|夜|晩|午前|朝)?(?P<hour>" + number + ")"
                   r"(?::(?P<minute>" + number + ")|：(?P<wide_minute>" + number + ")|"
                   r"時(?:(?P<word_minute>" + number + r")分|(?P<half>半)))")
        matches = list(re.finditer(pattern, lines[1])) if len(lines) > 1 else []
        if len(matches) != 1:
            errors.append("source-bound Korean-life evening class clock missing/duplicated")
        else:
            match = matches[0]
            hour = integer(match.group("hour"))
            minute = 30 if match.group("half") else integer(
                match.group("minute") or match.group("wide_minute") or match.group("word_minute"))
            phase = match.group("phase")
            if phase in ("午後", "夜", "晩") and hour is not None and 0 < hour < 12:
                hour += 12
            if phase in ("午前", "朝") or hour != 19 or minute != 30:
                errors.append("source-bound Korean-life evening class clock value/phase mismatch")
            if re.match(r"(?:ではな|じゃな|時間|分|秒)", lines[1][match.end():]):
                errors.append("source-bound Korean-life evening class clock state/unit mismatch")
            offset = len(lines[0]) + 1
            owned.append((offset + match.start(), offset + match.end()))
            replacements.append((offset + match.start(), offset + match.end(), "19:30"))
    for line, pattern, expected, label in contract["slots"]:
        pattern = pattern.replace("@N@", group).replace("@F@", fraction)
        matches = list(re.finditer(pattern, lines[line])) if line < len(lines) else []
        if len(matches) != 1:
            errors.append(f"source-bound Korean-life {label} role/unit/position mismatch")
            continue
        match = matches[0]
        if isinstance(expected, list):
            den = match.group("den") or match.group("den_slash")
            num = match.group("num") or match.group("num_slash")
            if [integer(den), integer(num)] != expected:
                errors.append(f"source-bound Korean-life {label} value/sign mismatch")
            offset = sum(len(part) + 1 for part in lines[:line])
            start, end = match.span("fraction")
            owned.append((offset + start, offset + end))
            replacements.append((offset + start, offset + end, f"{expected[0]}分の{expected[1]}"))
            continue
        raw = match.group("number")
        if integer(raw) != expected:
            errors.append(f"source-bound Korean-life {label} value/sign mismatch")
        start, end = match.span("number") if raw is not None else (match.start(), match.start())
        # A digit/scale immediately before a local match cannot be discarded as
        # prose; neither can a native wrong unit followed by a correct witness.
        if start and re.search(number + r"$", lines[line][:start]):
            errors.append(f"source-bound Korean-life {label} numeric prefix mismatch")
        offset = sum(len(part) + 1 for part in lines[:line])
        owned.append((offset + start, offset + end))
        replacements.append((offset + start, offset + end, str(expected)))
        tail = lines[line][match.end():]
        if re.match(r"\s*(?:[/／]|毎(?:時|日|月|年)|(?:円|ドル|ウォン|元|ユーロ)|"
                    r"ではな(?:く|い|かった)|じゃな(?:い|かった|く)|未満|以上|以下|超|より(?:安|高)|"
                    r"[（(]\s*(?:毎|月|日|年|時|ドル|円))", tail):
            errors.append(f"source-bound Korean-life {label} qualifier mismatch")

    for line, pattern, label in contract["checks"]:
        if line >= len(lines) or not re.search(pattern, lines[line]) or re.search(
            r"(?:届かな|到着しな|開かな|開始しな|食べ(?:ていない|なかった|ない)|"
            r"節約できな|節約しな(?!くては)|価値はな|価値がな)", lines[line],
        ):
            errors.append(f"source-bound Korean-life {label} state/owner mismatch")
    for quantity in re.finditer("(?P<number>" + number + r")\s*(?:" + contract["units"] + ")", target):
        start, end = quantity.span("number")
        if not any(a <= start and end <= b for a, b in owned):
            errors.append("source-bound Korean-life added/displaced quantity mismatch")
    normalized_source = source
    for old, new in contract["rewrites"]:
        normalized_source = normalized_source.replace(old, new, 1)
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return normalized_source, normalized_target, errors


def _ja_leisure_gambling_numbers(source: str, target: str):
    """Source-exact leisure/race quantities, with local roles and line ownership.

    Canonicalize only the owned numerals. The existing won parser, complete
    numeric stream, token and paragraph checks still run afterwards. This is
    not a target-prose template, a global native-number waiver or a legal claim.
    """
    contracts = {
        "2시간에 2만원 손실.\n근데 두 번 블러핑에 성공했고, 한 번은 큰 팟을 땄다가 다시 잃었다.\n\n계단 올라오면서 생각했다. 이거 공부할 게 있는 게임이구나.": {
            "rewrites": [["2만원","20000원"],["두 번","2번"],["한 번","1번"]],
            "slots": [
                [0,"@N@時間(?:で|に)",2,"first-visit elapsed hours"],
                [0,"@N@ウォン(?:の)?損失",20000,"first-visit actual loss"],
                [1,["@N@(?:回|度)(?:の)?ブラフ(?:が|は)?成功(?:し|した)","ブラフ(?:は|が)?@N@(?:回|度)成功(?:し|した)"],2,"successful bluff count"],
                [1,"@N@(?:回|度)(?:は)?大きなポットを(?:取って|獲得して|勝ち取って)",1,"big-pot win count"],
            ],
            "checks": [[1,"(?:また|再び|もう一度)失った","big pot subsequently lost"]],
            "forbidden": [[1,"成功しな|成功していない|取っていない|失わな|失っていない"]],
        },
        "집에 있던 {name}의 휴대폰이 짧게 울렸다. 앞서 소개받은 카지노 클럽의 숙박 안내였다.\n\n「객실 1박과 조식을 무료로 제공합니다. 이용 가능한 날짜를 문의해 주세요.」\n\n누구 이름도 적혀 있지 않은 안내였다. 그래도 {name}은 '무료'라는 단어 위에서 손가락을 멈췄다.\n\n답장을 쓰려다 달력을 열었다. 비어 있는 칸 하나에 넓은 침대와 늦은 아침이 먼저 들어왔다. 그다음에는 호텔 아래층의 테이블이 떠올랐다.\n\n화면 밖은 여전히 익숙한 방이었다. 메시지 입력 칸의 커서가 깜빡였다.": {
            "rewrites": [["칸 하나","칸 1"]],
            "slots": [
                [2,"@N@泊(?:分)?(?:の)?(?:お部屋|部屋|客室|宿泊)",1,"offered room nights"],
                [6,"(?:空いている|空いた|空白の|空の|空白|空欄|空き枠(?:が)?|空きマス(?:が)?)@N@(?:枠|マス|つ|個)",1,"empty calendar slot"],
            ],
            "checks": [[2,"(?:朝食|朝ごはん|朝御飯)","breakfast offer"],[2,"無料(?:で|にて)?(?:ご)?(?:提供|用意|案内)|無料(?:です|となります)","free offer"],[2,"(?:日程|日付|日時|日|日取り).*(?:お問い合わせ|問い合わせ|お尋ね|おたずね|ご相談|相談)(?:ください|下さい|願います)","date inquiry not reservation"]],
            "forbidden": [[2,"有料|予約済|予約した|予約され|予約が(?:成立|確定)|予約を(?:承|取)|提供しない|提供いたしません|無料ではな"],[6,"空いていない|埋まった|埋まっている"]],
        },
        "발판을 밟다 보니 금세 숨이 찼다. 옆 고수가 흘끔 봤다.\n\n못해도 재밌었다. 이게 한국식 리듬게임.\n오백 원으로 헬스장 한 타임 효과를 봤다.": {
            "rewrites": [["오백 원","500원"],["한 타임","1타임"]],
            "slots": [
                [3,"@N@ウォン(?:で|を使って|払って|を払って)",500,"pump exercise cost"],
                [3,"(?:ジム|スポーツジム|フィットネスジム)(?:に|での|で|の)?@N@(?:回|度)(?:行った)?分",1,"gym session equivalent"],
            ],
            "checks": [[3,"(?:運動|トレーニング)(?:に|を|の).*(?:なった|した|得た)|(?:効果|運動量).*(?:得た|あった|になった|だった)","received exercise equivalent"]],
            "forbidden": [[3,"ならな|なっていない|しなかった|予定|つもり|なかった|効果がない"]],
        },
        "번화가 오락실.\n펌프(댄스 발판), 농구 게임, 그리고 인생네컷 부스.\n\n동전 교환기에 천 원을 넣자 100원짜리가 쏟아진다.\n— 오랜만이다, 이 소리.": {
            "rewrites": [["인생네컷","사진4컷"],["천 원","1000원"]],
            "slots": [
                [1,"@N@コマ(?:写真|の写真)?",4,"photo format count"],
                [3,"(?:両替機|硬貨交換機)(?:に|へ)@N@ウォン(?:を)?(?:入れ|投入)",1000,"cash inserted"],
                [3,"@N@ウォン(?:の)?(?:硬貨|コイン)",100,"coin denomination"],
            ],
            "checks": [[3,"(?:硬貨|コイン)(?:が|は|の).*(?:出てくる|出てきた|出た|こぼれ|落ち|流れ)","coin output"]],
            "forbidden": [[3,"入れな|投入しな|出てこな|出なかった|予定|つもり"]],
        },
        "한강을 따라 달렸다. 바람, 윤슬, 다리 밑 그늘.\n\n천 원으로 이만한 자유가 또 없다.\n페달을 밟는 동안만큼은 30억도, 마감도 뒤로 밀렸다.": {
            "rewrites": [["천 원","1000원"],["30억","3000000000원"]],
            "slots": [
                [2,"@N@ウォン(?:で|にして|を払って)",1000,"cycling freedom price"],
                [3,"@N@ウォン(?:も|や|は|と)",3000000000,"deferred financial goal"],
            ],
            "checks": [[3,"(?:ペダル|自転車|こいで|漕いで)","cycling period"],[3,"(?:締め切り|締切).*(?:後回し|頭の隅|追いや|忘れ|気になら|遠の|置き去り)","goal and deadline deferred"]],
            "forbidden": [[3,"所有|手に入れ|達成した|達成して|獲得した"]],
        },
        "서울 공공자전거 따릉이.\n앱으로 QR을 찍고 천 원에 한 시간. 거치대에서 자전거를 뺀다.\n\n날이 좋다. 페달을 밟자 바람이 분다.": {
            "rewrites": [["천 원","1000원"],["한 시간","1시간"]],
            "slots": [
                [1,"@N@ウォン(?:で|につき|を払って)",1000,"cycle hire price"],
                [1,"(?:ウォン(?:で|につき)|利用時間(?:は|が)|借り(?:られる|る)(?:のは)?)[、，,\\s]*@N@時間",1,"cycle hire duration"],
            ],
            "checks": [[1,"(?:ラック|スタンド|駐輪台|自転車置き場).*(?:引き出す|取り出す|出す|外す|取り外す)","actual bicycle removal"]],
            "forbidden": [[1,"引き出していない|取り出していない|引き出さな|取り出さな|出さな|外していない|予定|つもり"]],
        },
        "라면 한 그릇 끓여 먹고, 만화 스무 권을 다 봤다.\n\n해가 진 줄도 몰랐다. 목이 뻐근했지만 마음은 가벼웠다.\n이천 원짜리 도피처치고 완벽했다.": {
            "rewrites": [["한 그릇","1그릇"],["스무 권","20권"],["이천 원","2000원"]],
            "slots": [
                [0,"ラーメン(?:を|の)?@N@杯",1,"cooked noodle bowl"],
                [0,"漫画(?:を|の)?@N@冊",20,"completed comics"],
                [3,"@N@ウォン(?:の|で(?:得た|買った)|にしては)",2000,"escape-place price"],
            ],
            "checks": [[0,"(?:全部|すべて|全て)?(?:読んだ|読み終えた|読み切った)","completed comic reading"]],
            "forbidden": [[0,"読んでいない|読まな|読む予定|読むつもり"]],
        },
        "지인들과 방탈출 카페.\n1인 2만 원, 제한시간 60분. 자물쇠, 암호, 자외선 펜.\n\n문이 잠기고 타이머가 빨갛게 줄어들기 시작한다.\n\"단서는 다 방 안에 있습니다.\"": {
            "rewrites": [["2만 원","20000원"]],
            "slots": [
                [1,"@N@人(?:あたり|当たり|につき|分)?",1,"escape person denominator"],
                [1,"@N@ウォン",20000,"escape person fee"],
                [1,"(?:制限時間|持ち時間|タイムリミット)(?:は|が|[：:])?@N@分",60,"escape limit minutes"],
            ],
            "checks": [],
            "forbidden": [[1,"経過時間|制限時間ではな|持ち時間ではな"]],
        },
        "8만원을 썼다. 만회는 없었다.\n\n경마공원역 계단을 내려오면서 총합을 계산했다.\n3주 합산 -23만원.\n\n숫자가 나오자 머릿속이 조용해졌다.\n이 조용함이 제일 나쁜 신호라는 걸 — 아직 모르고 있었다.": {
            "rewrites": [["8만원","80000원"],["-23만원","-230000원"]],
            "slots": [
                [0,"@N@ウォン(?:を)?(?:使った|払った|費やした)",80000,"actual spent amount"],
                [3,"@N@週(?:間)?",3,"loss accumulation period"],
                [3,"(?:合計|累計|総計|通算)(?:は|で|[：:])?[、，,\\s]*@N@ウォン",-230000,"accumulated negative balance"],
            ],
            "checks": [[0,"(?:取り返せなかった|取り戻せなかった|取り返すことはできなかった|取り戻すことはできなかった|巻き返せなかった|挽回できなかった)","no recovery"]],
            "forbidden": [],
        },
        "한 시간 동안 경마신문을 읽었다.\n\n3연단, 단승, 연승, 복승, 쌍승 — 베팅 방식만 여섯 가지였다.\n기수 승률, 조교사 기록, 주로별 특성.\n\n이걸 다 보는 사람들이 있다는 게 신기했다.\n'읽는다'는 게 무슨 말인지 조금 알 것 같았다.": {
            "rewrites": [["한 시간","1시간"],["여섯 가지","6가지"]],
            "slots": [
                [0,"@N@時間",1,"completed newspaper reading duration"],
                [2,"@N@連単",3,"ordered three-horse betting form"],
                [2,"(?:賭け方|賭けの方法|賭ける方法|ベットの種類|賭式|賭けの種類|賭け方の種類)(?:だけでも|だけで|だけ|は|が|でも)?@N@(?:種類|種)",6,"reported betting form count"],
            ],
            "checks": [[0,"競馬新聞(?:を)?(?:[^。\\n]*)(?:読んだ|読み終えた|読み通した)","completed newspaper reading"]],
            "forbidden": [[0,"読まな|読んでいない|予定|つもり"]],
        },
        "그날의 마지막 경주.\n\n베팅창 앞이 유독 붐볐다. {name}은 줄에 섰다.\n\n앞 사람이 만원짜리를 세고 있었다. 손이 떨렸다. 지폐가 몇 장 안 남아 있었다.\n뒤 사람은 혼잣말을 했다. \"이번엔 진짜… 이번엔 돼야 하는데.\"\n\n마지막 경주에는, 오늘 잃은 걸 만회하려는 사람들만 남는다.\n\n{name}도 그 줄의 한 명이었다.": {
            "rewrites": [["만원짜리","10000원짜리"],["한 명","1명"]],
            "slots": [
                [4,"(?:前の人|前に並ぶ人|前にいる人)(?:が|は)@N@ウォン(?:の)?(?:札|紙幣)",10000,"front person's denomination"],
                [9,"(?:その|あの|この)(?:列|行列)(?:の|にいる)?@N@人",1,"protagonist among queue"],
            ],
            "checks": [[4,"(?:札|紙幣)(?:を)?数えていた","front person's counting"]],
            "forbidden": [[4,"数えていな|数えていない|数えなかった|数える予定"]],
        },
        "5위.\n\n만원짜리 한 장이 종이 한 장이 됐다.\n아저씨를 찾았다. 이미 다른 사람에게 다른 번호를 팔고 있었다.\n\n{name}은 계단을 내려오면서 다음 경주 시간을 확인했다.\n그게 문제였다.": {
            "rewrites": [["만원짜리","10000원짜리"],["한 장","1장"],["한 장","1장"]],
            "slots": [
                [0,"^@N@(?:着|位)(?:だった)?[。．]?$",5,"horse finish rank"],
                [2,"@N@ウォン",10000,"losing ticket amount"],
                [2,"ウォン(?:の)?(?:馬券|券|札)?@N@枚",1,"original ticket count"],
                [2,"(?:ただの)?(?:紙切れ|紙)(?:の)?@N@枚",1,"worthless paper count"],
            ],
            "checks": [[2,"(?:紙切れ|紙)(?:の)?[^。\\n]*(?:になった|に変わった|となった)","ticket became paper"]],
            "forbidden": [[2,"なる予定|なるつもり|ならな|変わらな|なっていない"]],
        },
        "만원치고 괜찮은 구경이었다.\n경주마가 달리는 건 생각보다 웅장했다.\n{name}은 거기서 멈추기로 했다. 오늘은.": {
            "rewrites": [["만원치고","10000원치고"]],
            "slots": [
                [0,"@N@ウォン(?:にしては|で(?:見た|得た)(?:もの)?としては|の値段にしては)",10000,"completed viewing value"],
            ],
            "checks": [[0,"(?:見物|見世物|観戦|見応え|見ごたえ).*(?:だった|があった|の価値はあった)","completed viewing"]],
            "forbidden": [[0,"になるだろう|になる予定|になるはず|見る予定"]],
        },
    }
    contract = contracts.get(source)
    if contract is None:
        return None
    import unicodedata

    def integer(raw):
        raw = unicodedata.normalize("NFKC", raw).replace("−", "-")
        raw = raw.replace("マイナス", "-").replace("プラス", "+")
        if not raw or raw.startswith("+"):
            return None
        sign = -1 if raw.startswith("-") else 1
        raw = raw.lstrip("-")
        if not raw or ("," in raw and not re.fullmatch(
            r"(?:(?:[1-9][0-9]{0,2}(?:,[0-9]{3})+|[0-9]+)[億万千百十]?)+", raw,
        )):
            return None
        digits = dict(zip("〇零一二三四五六七八九", (0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)))
        total, section, pending = 0, 0, ""
        for char in raw.replace(",", ""):
            if char.isascii() and char.isdigit():
                pending += char
            elif char in digits:
                pending += str(digits[char])
            elif char in "十百千":
                section += (int(pending) if pending else 1) * {"十": 10, "百": 100, "千": 1000}[char]
                pending = ""
            elif char in "万億":
                total += (section + (int(pending) if pending else 0) or 1) * {"万": 10000, "億": 100000000}[char]
                section, pending = 0, ""
            else:
                return None
        return sign * (total + section + (int(pending) if pending else 0))

    number = r"(?:マイナス|プラス|[+＋\-－−])?[0-9０-９〇零一二三四五六七八九十百千万億,，]+"
    group = "(?P<number>" + number + ")"
    lines = target.split("\n")
    errors, replacements, owned = [], [], []
    for line, pattern, expected, label in contract["slots"]:
        patterns = pattern if isinstance(pattern, list) else [pattern]
        matches = [match for local_pattern in patterns
                   for match in re.finditer(local_pattern.replace("@N@", group), lines[line])] if line < len(lines) else []
        if len(matches) != 1:
            errors.append(f"source-bound leisure/race {label} role/unit/position mismatch")
            continue
        match = matches[0]
        raw = match.group("number")
        if integer(raw) != expected:
            errors.append(f"source-bound leisure/race {label} value/sign mismatch")
        start, end = match.span("number")
        # Do not match a good suffix inside an extra sign/number, or silently
        # accept a second denomination, hourly rate or negated/approximate price.
        if start and re.search(number + r"\s*$", lines[line][:start]):
            errors.append(f"source-bound leisure/race {label} numeric prefix mismatch")
        if re.match(r"\s*(?:[/／]|毎(?:時|日|月|年)|未満|以上|以下|程度|ぐらい|くらい|"
                    r"(?:円|ドル|ウォン|元|ユーロ)|ではな|じゃな|"
                    r"[（(]\s*(?:毎|月|日|年|時|円|ドル|元))", lines[line][match.end():]):
            errors.append(f"source-bound leisure/race {label} qualifier mismatch")
        offset = sum(len(part) + 1 for part in lines[:line])
        owned.append((offset + start, offset + end))
        replacements.append((offset + start, offset + end, str(expected)))
    for line, pattern, label in contract["checks"]:
        if line >= len(lines) or not re.search(pattern, lines[line]):
            errors.append(f"source-bound leisure/race {label} state/owner mismatch")
    for line, pattern in contract["forbidden"]:
        if line < len(lines) and re.search(pattern, lines[line]):
            errors.append("source-bound leisure/race changed local state/owner mismatch")
    # Coverage is bounded to the licensed leaf, and keeps duplicate/native
    # amounts, periods and counts visible even after a correct later witness.
    units = (r"ウォン|ドル|円|ユーロ|元|泊|枠|マス|個|つ|回|度|コマ|時間|"
             r"年間|年|か月|ヶ月|日|週間|週|分|秒|冊|杯|人|名|枚|着|位|連単|種類|種")
    for quantity in re.finditer("(?P<number>" + number + r")\s*(?:" + units + ")", target):
        start, end = quantity.span("number")
        if not any(a <= start and end <= b for a, b in owned):
            errors.append("source-bound leisure/race added/displaced quantity mismatch")
    normalized_source = source
    for old, new in contract["rewrites"]:
        normalized_source = normalized_source.replace(old, new, 1)
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return normalized_source, normalized_target, sorted(set(errors))


def _ja_cafe_encounter_money_numbers(source: str, target: str):
    """Normalize witnessed cafe/encounter money slots, never an entire leaf.

    Complete KO source licenses own amounts and the adjacent counters sharing
    their ordered stream. Japanese prose outside those slots is not templated.
    Original currency, token, paragraph and mixed-money checks still follow.
    """
    contracts = {
        (
            "{name}은 6,500원짜리 아메리카노를 시켰다.\n"
            "그래도 한 번은,\n"
            "강남에서 큰돈 이야기가 오가는 자리에 앉아 보고 싶었다.\n"
            "\n"
            "옆 테이블. 정장 입은 남자가 통화 중이다.\n"
            "\"그 입주권 마지막 한 자리예요. 오늘 안 잡으면 끝나요.\n"
            "재개발 확정 났다니까. ...네, 현금 5천이면 됩니다.\"\n"
            "\n"
            "{name}의 귀가 저절로 그쪽으로 기운다."
        ): {
            "rewrites": [["6,500원","6500원"],["한 번","1 번"],["한 자리","1 자리"],["현금 5천","현금 50000000원"]],
            "slots": [
                [0,"@N@ウォン(?:の|する)?アメリカーノ",6500,"coffee_price"],
                [1,"@N@(?:度|回)(?:は)",1,"one_wished_visit"],
                [5,"(?:最後の|ラストの)@N@(?:枠|席|口)",1,"quoted_last_slot"],
                [6,"(?:現金|キャッシュ)(?:は|が|なら)?\\s*@N@ウォン",50000000,"cash_quote"],
            ],
        },
        (
            "\"이쪽 일을 하신다. 그래요?\"\n"
            "남자의 눈이 가늘어진다. 시험하듯 묻는다.\n"
            "\"매매가 5억, 전세 3억 5천, 대출 1억이면\n"
            "취득비 빼고 실투자금 얼마 잡아요?\"\n"
            "\n"
            "{name}은 계산하지 못했다.\n"
            "등에서 식은땀이 흐른다."
        ): {
            "rewrites": [["5억","500000000원"],["3억 5천","350000000원"],["1억","100000000원"]],
            "slots": [
                [2,"(?:売買価格|売値)(?:は|が)?@N@ウォン",500000000,"sale_price"],
                [2,"(?:チョンセ(?:保証金)?)(?:は|が|の)?@N@ウォン",350000000,"jeonse_deposit"],
                [2,"(?:借入(?:金)?|ローン)(?:は|が|の)?@N@ウォン",100000000,"loan"],
            ],
        },
        (
            "\"한 2억쯤...?\" {name}이 아무 숫자나 던졌다.\n"
            "남자가 코웃음을 쳤다.\n"
            "\"5억에서 전세 3억 5천, 대출 1억을 빼면 5천이잖아. 학생, 아는 척하려면 계산부터 하고 와.\"\n"
            "\n"
            "옆 테이블 사람들이 힐끔거렸다.\n"
            "{name}의 얼굴이 화끈거렸다. 숫자 하나만으로도 허세는 바로 들켰다."
        ): {
            "rewrites": [["2억","200000000원"],["5억","500000000원"],["3억 5천","350000000원"],["1억","100000000원"],["5천이잖아","50000000원이잖아"],["숫자 하나","숫자 1"]],
            "slots": [
                [0,"@N@ウォン(?:くらい|ぐらい|ほど)",200000000,"wrong_approx_answer"],
                [2,"@N@ウォンから",500000000,"sale_price"],
                [2,"(?:チョンセ(?:保証金)?)(?:の|は)?@N@ウォン",350000000,"jeonse_deposit"],
                [2,"(?:借入(?:金)?|ローン)(?:の|は)?@N@ウォン",100000000,"loan"],
                [2,"(?:引けば|残るのは|差額は)[、，\\s]*@N@ウォン",50000000,"remainder"],
                [5,"(?:たった)?@N@(?:つ|個)(?:の)?数字",1,"one_wrong_number"],
            ],
        },
        (
            "신호음 세 번. \"여보세요.\"\n"
            "김 부장은 {name}을 기억 못 했다. {name}은 둘러댔다.\n"
            "\"그때 카페에서... 입주권 건 소개받았던 사람입니다.\"\n"
            "\n"
            "잠깐의 침묵. 그러더니 목소리가 부드러워진다.\n"
            "\"아아, 그거. 아직 한 자리 있어요. 근데 프리미엄 올랐어.\n"
            "지금 7천. 오늘내일 안에 결정해야 돼. 어떻게, 들어와요?\""
        ): {
            "rewrites": [["세 번","3 번"],["한 자리","1 자리"],["지금 7천","지금 70000000원"]],
            "slots": [
                [0,"呼び出し音(?:が|は)?@N@(?:回|度)",3,"rings"],
                [5,"(?:まだ)?@N@(?:枠|席|口)(?:あります|残って)",1,"remaining_slot"],
                [6,"(?:今(?:は|なら)|現在(?:は)?|いま(?:は|なら))@N@ウォン",70000000,"raised_premium_quote"],
            ],
        },
        (
            "{name}은 김 부장에게 등기를 들이밀었다.\n"
            "\"2천은 거품이잖아요. 5천에 합시다. 아니면 신고하든가.\"\n"
            "김 부장의 표정이 일그러졌다. 그러더니, 마지못해 끄덕였다.\n"
            "\"...물건은 볼 줄 아네. 좋아, 5천.\"\n"
            "\n"
            "검증한 자만이 깎을 수 있다. {name}은 제값에 들어갈 문턱까지 왔다."
        ): {
            "rewrites": [["2천은","20000000원은"],["5천에","50000000원에"],["5천.","50000000원."]],
            "slots": [
                [1,"@N@ウォン(?:は|が)?(?:水増し|上乗せ分)",20000000,"markup"],
                [1,"@N@ウォン(?:に|で)(?:しましょう|しよう|お願いします)",50000000,"counteroffer"],
                [3,"(?:いいよ|よし|わかった)[、，\\s]*@N@ウォン",50000000,"agreed_quote"],
            ],
        },
        (
            "김 부장에게 등기를 내밀었다. \"2천은 거품이잖아요.\" 그가 눈을 피했다."
        ): {
            "rewrites": [["2천은","20000000원은"]],
            "slots": [
                [0,"@N@ウォン(?:は|が)?(?:水増し|上乗せ分)",20000000,"markup"],
            ],
        },
        (
            "{name}은 사흘을 매달렸다. 등기부등본, 부동산 카페, 뉴스.\n"
            "진실은 절반이었다 — 재개발은 진짜다. 확정도 맞다.\n"
            "근데 김 부장은 조합원도 뭣도 아닌 그냥 브로커였고,\n"
            "7천 중 2천은 그의 '수고비'로 부풀려진 거품이었다.\n"
            "\n"
            "진짜 기회 위에, 가짜 가격표가 붙어 있었다."
        ): {
            "rewrites": [["사흘","3일"],["7천 중 2천","70000000원 중 20000000원"]],
            "slots": [
                [0,"@N@日(?:間)?(?:[、，]|調べ|かけ|を)",3,"investigation_days"],
                [3,"@N@ウォンのうち",70000000,"total_quote"],
                [3,"(?:のうち|うち|中の)[、，\\s]*@N@ウォン",20000000,"included_markup"],
            ],
        },
        (
            "비 오는 날은 콜이 많고, 할증이 붙는다.\n"
            "그만큼 위험하고, 그만큼 번다.\n"
            "\n"
            "{name}은 새벽 한 시까지 뛰었다.\n"
            "젖은 옷, 시린 손, 통장에 찍힌 4만 8천원.\n"
            "\n"
            "몸은 부서질 것 같았지만, 숫자는 정직했다.\n"
            "이렇게라도 메워야, 본업 월급이 온전히 남는다.\n"
            "\n"
            "강남은 이 빗속 어딘가에서, 한 콜씩 가까워지고 있었다."
        ): {
            "rewrites": [["한 시","1 시"],["4만 8천원","48000원"],["한 콜씩","1 콜씩"]],
            "slots": [
                [3,"(?:午前|深夜|夜中の)@N@時まで(?:走|働|配達)",1,"shift_end_am"],
                [4,"(?:口座(?:に|へ)(?:記された|入った|振り込まれた)|入金された)[、，\\s]*@N@ウォン",48000,"actual_shift_earnings"],
                [9,"(?:依頼|配達|注文)@N@件ずつ",1,"one_delivery_at_a_time"],
            ],
        },
        (
            "야간 알바 마감 정리 중. 마지막 손님이 나가고 자동문이 잠긴 뒤였다.\n"
            "\n"
            "{name}은 의자를 올리고 테이블 아래를 닦다가 검은 봉투 하나를 발견했다. 안에는 고무줄로 묶인 5만원권이 들어 "
            "있었다. 두 번 세어도 50만원이었다.\n"
            "\n"
            "천장 모서리의 CCTV 표시등이 붉게 깜박였다. 쓰레기봉투를 묶는 동안에도 자동문 너머로 돌아오는 사람은 없었다."
        ): {
            "rewrites": [["봉투 하나","봉투 1"],["5만원권","50000원권"],["두 번","2 번"],["50만원","500000원"]],
            "slots": [
                [2,"(?:黒い|黒の)?袋を@N@(?:つ|個)",1,"one_found_bag"],
                [2,"@N@ウォン(?:の)?(?:札|紙幣)",50000,"banknote_denomination"],
                [2,"@N@(?:度|回)数え",2,"countings"],
                [2,"(?:数えても|総額は|合計は)@N@ウォン",500000,"bag_total"],
            ],
        },
        (
            "5만원짜리 세 장이 있었다.\n"
            "\n"
            "역무원이 지나갔다. {name}은 계단을 내려갔다.\n"
            "\n"
            "집까지 오는 내내 발걸음이 무거웠다.\n"
            "15만원이 생겼는데 아무것도 안 생긴 것 같았다."
        ): {
            "rewrites": [["5만원짜리","50000원짜리"],["세 장","3 장"],["15만원","150000원"]],
            "slots": [
                [0,"@N@ウォン(?:の)?(?:札|紙幣)",50000,"banknote_denomination"],
                [0,"(?:札|紙幣)(?:が|は)?@N@枚",3,"banknote_count"],
                [5,"@N@ウォン(?:が|を)(?:手に入った|手にした|得た)",150000,"acquired_total"],
            ],
        },
        (
            "퇴근 인파가 빠진 지하철역 계단. 벽 쪽에 검은 지갑 하나가 펼쳐진 채 떨어져 있었다.\n"
            "\n"
            "{name}은 지나쳤다가 두 칸을 다시 올라왔다. 안에는 ○○그룹 전무이사라고 적힌 명함, 카드 여러 장, 5만원권 "
            "세 장이 가지런히 끼워져 있었다.\n"
            "\n"
            "개찰구 쪽에서는 안내 방송이 반복됐다. 지갑을 든 손 앞에서 계단을 오르내리는 사람들은 아무도 멈추지 않았다."
        ): {
            "rewrites": [["두 칸","2 칸"],["5만원권","50000원권"],["세 장","3 장"]],
            "slots": [
                [2,"@N@段(?:上り|登り|上がり)",2,"stairs_retraced"],
                [2,"@N@ウォン(?:の)?(?:札|紙幣)",50000,"banknote_denomination"],
                [2,"(?:札|紙幣)(?:が|は)?@N@枚",3,"banknote_count"],
            ],
        },
        (
            "십 분이 삼십 분이 됐다.\n"
            "갭투자, 레버리지, 입주권, 프리미엄 —\n"
            "{name}은 처음 듣는 부동산 용어를 수첩에 적었다.\n"
            "\n"
            "남자는 명함도 주지 않았고 이름도 알려 주지 않았다. 그래도 오늘 들은 숫자와 용어는 수첩에 남았다."
        ): {
            "rewrites": [["십 분이","10 분이"],["삼십 분이","30 분이"]],
            "slots": [
                [0,"^@N@分(?:が|のはずが|の予定が)",10,"promised_minutes"],
                [0,"(?:が|のはずが|の予定が)@N@分(?:になった|となった|に延びた)",30,"actual_minutes"],
            ],
        },
        (
            "남자가 잠깐 생각했다.\n"
            "\"저도 33살에 서울 올라왔어요. 편하게 얘기 한 번 해요.\"\n"
            "\n"
            "명함을 받았다. 작은 투자사 대표였다.\n"
            "\n"
            "물건 3만원을 팔고, 연락처를 얻었다.\n"
            "중고 거래가 이렇게 쓰이는 줄은 몰랐다."
        ): {
            "rewrites": [["한 번","1 번"],["3만원","30000원"]],
            "slots": [
                [1,"(?:私|僕|俺)(?:も|は)@N@歳(?:で|のときに|の頃に)ソウル(?:に|へ)",33,"speaker_move_age"],
                [1,"(?:@N@(?:度|回)[、，]?)?(?:気軽に|気楽に)(?:お)?話(?:し)?(?:を)?しましょう",1,"open_chat_invitation"],
                [5,"(?:物|品物)(?:を|が)?@N@ウォンで(?:売り|売って|売った)",30000,"actual_sale_proceeds"],
            ],
        },
        (
            "5만원.\n"
            "\n"
            "2등도 1등도 아니지만 5만원이었다.\n"
            "\n"
            "{name}은 그걸 다시 투자하거나 복권을 더 사지 않았다.\n"
            "그냥 밥을 사먹었다. 좋은 거 먹었다.\n"
            "\n"
            "그게 복권의 올바른 사용법인지는 모르겠지만, 기분은 좋았다."
        ): {
            "rewrites": [["5만원.","50000원."],["5만원이었다","50000원이었다"]],
            "slots": [
                [0,"^@N@ウォン[。.]?$",50000,"lottery_prize"],
                [2,"^@N@等(?:でも|も)",2,"excluded_second_rank"],
                [2,"(?:でも|も)@N@等(?:でも|も)(?:ない|なく)",1,"excluded_first_rank"],
                [2,"(?:が|けれど|それでも)[、，\\s]*@N@ウォン",50000,"repeated_prize"],
            ],
        },
    }
    contract = contracts.get(source)
    if contract is None:
        return None
    import unicodedata

    def integer(raw):
        raw = unicodedata.normalize("NFKC", raw).replace("−", "-")
        if not raw or raw.startswith("+"):
            return None
        sign = -1 if raw.startswith("-") else 1
        raw = raw.lstrip("-")
        if not raw or ("," in raw and not re.fullmatch(
            r"(?:(?:[1-9][0-9]{0,2}(?:,[0-9]{3})+|[0-9]+)[億万千百十]?)+", raw,
        )):
            return None
        digits = dict(zip("〇零一二三四五六七八九", (0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)))
        total, section, pending = 0, 0, ""
        for char in raw.replace(",", ""):
            if char.isascii() and char.isdigit():
                pending += char
            elif char in digits:
                pending += str(digits[char])
            elif char in "十百千":
                section += (int(pending) if pending else 1) * {"十": 10, "百": 100, "千": 1000}[char]
                pending = ""
            elif char in "万億":
                total += (section + (int(pending) if pending else 0) or 1) * {"万": 10000, "億": 100000000}[char]
                section, pending = 0, ""
            else:
                return None
        return sign * (total + section + (int(pending) if pending else 0))

    number = r"[+＋\-－−]?[0-9０-９〇零一二三四五六七八九十百千万億,，]+"
    group = r"(?<![0-9０-９〇零一二三四五六七八九十百千万億,.，．])(?P<number>" + number + ")"
    lines = target.split("\n")
    errors, replacements, owned = [], [], []
    for line, pattern, expected, label in contract["slots"]:
        matches = list(re.finditer(pattern.replace("@N@", group), lines[line])) if line < len(lines) else []
        if len(matches) != 1:
            errors.append(f"source-bound cafe/encounter {label} role/unit/line/count mismatch")
            continue
        match = matches[0]
        start, end = match.span("number")
        raw_number = match.group("number")
        if raw_number is None and label == "open_chat_invitation":
            # Korean 한 번 is a nonfixed invitation here. Japanese may leave
            # the single encounter implicit, but must still invite, not report
            # a completed meeting. Insert only a canonical stream marker.
            start = end = match.start()
        elif raw_number is None or integer(raw_number) != expected:
            errors.append(f"source-bound cafe/encounter {label} value/sign mismatch")
        if start and re.search(r"[+＋\-－−0-9０-９〇零一二三四五六七八九十百千万億,.，．]\s*$", lines[line][:start]):
            errors.append(f"source-bound cafe/encounter {label} numeric prefix mismatch")
        suffix = lines[line][match.end():]
        if re.match(r"\s*(?:[/／]|毎(?:時|日|月|年)|未満|以上|以下|"
                    r"(?:円|ドル|ウォン|元|ユーロ)|ではな|じゃな|"
                    r"[（(]\s*(?:毎|月|日|年|時|円|ドル|元))", suffix):
            errors.append(f"source-bound cafe/encounter {label} qualifier mismatch")
        if label != "wrong_approx_answer" and re.match(r"\s*(?:程度|ぐらい|くらい|ほど)", suffix):
            errors.append(f"source-bound cafe/encounter {label} approximate amount mismatch")
        offset = sum(len(part) + 1 for part in lines[:line])
        owned.append((offset + start, offset + end))
        replacements.append((offset + start, offset + end, str(expected)))
    # Reject extra amounts/counts before or after a valid witness; no later
    # correct price can pay for a duplicate, another role, unit or hourly rate.
    units = r"ウォン|ドル|円|ユーロ|元|枠|席|口|個|つ|回|度|時間|時|日|分|秒|人|名|枚|段|件|歳|等"
    for quantity in re.finditer(group + r"\s*(?:" + units + ")", target):
        start, end = quantity.span("number")
        if not any(a <= start and end <= b for a, b in owned):
            errors.append("source-bound cafe/encounter added/displaced quantity mismatch")
    normalized_source = source
    for old, new in contract["rewrites"]:
        normalized_source = normalized_source.replace(old, new, 1)
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return normalized_source, normalized_target, sorted(set(errors))


def _ja_chain_support_salary_numbers(source: str, target: str):
    """Read native JA numerals only in two complete KO benefit/salary sources.

    Owned quantities keep their line, role, unit and value. This supplies an
    ordered numeric stream to existing checks; unrelated prose is not licensed.
    """
    contracts = {
        (
            "서류를 갖춰 신청했다. 선정됐다.\n"
            "\n"
            "월세 지원 6개월. 총 120만원.\n"
            "\n"
            "{name}은 선정 문자 화면을 캡처해 보냈다.\n"
            "'덕분에 신청했어요. 고마워요.'\n"
            "\n"
            "잠시 뒤 엄지손가락 이모티콘 하나가 도착했다."
        ): {
            "rewrites": (("이모티콘 하나", "이모티콘 1"),),
            "slots": (
                (2, r"(?:家賃|月家賃)(?:の)?(?:補助|支援)(?:は)?\s*@N@(?:か月|ヶ月|カ月|箇月)", 6, "support_months"),
                (2, r"(?:合計|総額|計)(?:は)?\s*@N@万ウォン", 120, "total_won"),
                (7, r"絵文字が@N@(?:つ|個)(?:届いた|来た)", 1, "reply_emoji"),
            ),
        },
        (
            "\"지하철역에서 지갑을 주워서 돌려드렸습니다. 그게 전부입니다.\"\n"
            "\n"
            "면접관들이 서로를 봤다. 한 명이 웃었다.\n"
            "\"그 얘기 들었어요. 본인 입으로 듣고 싶었습니다.\"\n"
            "\n"
            "합격 통보는 사흘 뒤에 왔다. 기본급은 월 455만원이었다.\n"
            "\n"
            "첫 출근 날, {name}은 목에 건 사원증의 계열사 로고를 엄지로 한 번 문질렀다."
        ): {
            "rewrites": (("한 명", "1 명"), ("사흘", "3일"), ("한 번", "1 번")),
            "slots": (
                (2, r"@N@人が笑った", 1, "interviewer"),
                (5, r"合格の(?:通知|知らせ)は@N@日後に(?:来た|届いた)", 3, "notification_days"),
                (5, r"基本給は月@N@万ウォン", 455, "monthly_base_won"),
                (7, r"親指で@N@(?:度|回)(?:こすった|擦った)", 1, "thumb_action"),
            ),
        },
    }
    contract = contracts.get(source)
    if contract is None:
        return None
    import unicodedata
    from zh_translation_audit import _chinese_cardinal_value

    digits = r"0-9０-９〇零一二三四五六七八九十百千"
    number = r"(?<![" + digits + r"万億,.，．])(?P<number>[+＋\-－−]?[" + digits + r"]+)"
    lines = target.split("\n")
    errors, replacements, owned = [], [], []
    for line, pattern, expected, label in contract["slots"]:
        matches = list(re.finditer(pattern.replace("@N@", number), lines[line])) if line < len(lines) else []
        if len(matches) != 1:
            errors.append(f"source-bound chain support/salary {label} role/unit/line/count mismatch")
            continue
        match = matches[0]
        start, end = match.span("number")
        raw = unicodedata.normalize("NFKC", match.group("number"))
        if raw[:1] in "+-−" or _chinese_cardinal_value(raw) != expected:
            errors.append(f"source-bound chain support/salary {label} value/sign mismatch")
        if re.search(r"[+＋\-－−" + digits + r"万億,.，．]\s*$", lines[line][:start]):
            errors.append(f"source-bound chain support/salary {label} numeric prefix mismatch")
        if re.match(r"\s*(?:[/／]|毎(?:時|日|月|年)|未満|以上|以下|程度|ほど|くらい|ぐらい|"
                    r"円|ドル|ウォン|元|ユーロ|ではな|じゃな|"
                    r"[（(]\s*(?:毎|月|日|年|時|円|ドル|元))", lines[line][match.end():]):
            errors.append(f"source-bound chain support/salary {label} qualifier mismatch")
        offset = sum(len(part) + 1 for part in lines[:line])
        owned.append((offset + start, offset + end))
        replacements.append((offset + start, offset + end, str(expected)))
    # An extra/wrong quantity cannot borrow a later correct amount or counter.
    units = r"(?:万|億)?(?:ウォン|円|ドル|元)|か月|ヶ月|カ月|箇月|年|日|時間|分|秒|人|名|回|度|つ|個"
    for quantity in re.finditer(number + r"\s*(?:" + units + ")", target):
        start, end = quantity.span("number")
        if not any(a <= start and end <= b for a, b in owned):
            errors.append("source-bound chain support/salary added/displaced quantity mismatch")
    normalized_source = source
    for old, new in contract["rewrites"]:
        normalized_source = normalized_source.replace(old, new, 1)
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return normalized_source, normalized_target, sorted(set(errors))


def _ja_amb_tradeoff_numbers(source: str, target: str):
    """Bind witnessed trade-off counters/income to complete Korean sources.

    Each owned quantity keeps its role, unit, value and source line. Japanese
    numeral typography is normalized for existing checks; no leaf is waived
    and prose outside the numerical neighbourhood is not a target template.
    """
    contracts = {
        (
            "{name}은 분명히 선을 그었다. 부장은 떨떠름하게 \"알았어\" 했다.\n"
            "호구는 면했다. 부장도 함부로 못 하게 됐다.\n"
            "대신 둘 사이엔 서늘한 거리가 생겼다.\n"
            "존중은 요구해야 얻어지지만 — 그 대가는 편안함이다."
        ): {
            "rewrites": [["둘 사이","2 사이"]],
            "slots": (
                (2, "@N@人の(?:間|あいだ)(?:には|に)[^。\\n]{0,12}(?:距離|隔たり)(?:が|は)(?:生まれた|できた)", 2, "pair_distance"),
            ),
        },
        (
            "독대"
        ): {
            "rewrites": [["독대","2 대"]],
            "slots": (
                (0, "^@N@人(?:きり|だけ)(?:で)?$", 2, "private_pair"),
            ),
        },
        (
            "{name}은 임원에게 따로 자료 원본을 보냈다. '참고하시라'며.\n"
            "임원은 알아챘다. {name}의 이름이 윗선에 각인됐다.\n"
            "대신 부장은 — 누가 찔렀는지 안다. 보이지 않는 칼이 갈리기 시작했다.\n"
            "인정을 얻은 값으로, {name}은 적을 하나 만들었다."
        ): {
            "rewrites": [["적을 하나","적을 1"]],
            "slots": (
                (3, "(?:敵を@N@(?:人|名)|@N@(?:人|名)の敵を)(?:作った|つくった|増やした)", 1, "enemy_created"),
            ),
        },
        (
            "{name}은 결국 도장을 찍었다. 친구는 눈물까지 글썽이며 고마워했다.\n"
            "우정은 지켰다. 대신 — 남의 빚이 {name}의 어깨에 얹혔다.\n"
            "그 사업이 잘되길, {name}은 매일 빌게 됐다.\n"
            "호의로 찍은 도장 하나가, 평생의 불안이 될 줄도 모르고."
        ): {
            "rewrites": [["도장 하나","도장 1"]],
            "slots": (
                (3, "(?:押した|捺した)(?:(?:ハンコ|判子|印鑑)@N@(?:つ|個)|@N@(?:つ|個)の(?:ハンコ|判子|印鑑))", 1, "signed_stamp"),
            ),
        },
        (
            "고등학교 친구가 오랜만에 술을 사겠다며 불러냈다.\n"
            "몇 잔 돌고 나서야 본론이 나온다.\n"
            "\"사업 자금 대출인데, 보증인 한 명이 모자라. 도장만 찍어주면 돼.\n"
            "절대 너한테 피해 안 가. 우리 사이에 이 정도도 못 해줘?\"\n"
            "\n"
            "{name}은 안다. 보증은 남의 빚을 내 빚으로 만드는 일이라는 걸.\n"
            "그리고 — 거절은, 20년 우정에 금을 낸다는 것도."
        ): {
            "rewrites": [["한 명","1 명"]],
            "slots": (
                (2, "保証人(?:が|は)@N@(?:人|名)(?:足りない|不足して)", 1, "missing_guarantor"),
                (6, "@N@年(?:の|間の)?友情", 20, "friendship_years"),
            ),
        },
        (
            "도장 하나만"
        ): {
            "rewrites": [["하나","1"]],
            "slots": (
                (0, "^(?:(?:ハンコ|判子|印鑑)@N@(?:つ|個)|@N@(?:つ|個)の(?:ハンコ|判子|印鑑))だけ$", 1, "stamp_title"),
            ),
        },
        (
            "한 잔 더"
        ): {
            "rewrites": [["한 잔","1 잔"]],
            "slots": (
                (0, "^(?:もう|あと)@N@杯$", 1, "additional_drink"),
            ),
        },
        (
            "{name}은 숙취해소제를 털어넣고 출근했다.\n"
            "비틀거리며 하루를 버텼다. 결근은 면했지만,\n"
            "몸은 한참을 회복하지 못했다. 관계를 산 값은, 늘 몸으로 치른다."
        ): {
            "rewrites": [["하루","1일"]],
            "slots": (
                (1, "@N@日(?:間)?を(?:乗り切った|耐え抜いた|しのいだ)", 1, "worked_day"),
            ),
        },
        (
            "{name}은 반차를 냈다. 종일 앓았다.\n"
            "어제 쌓은 점수가 오늘 조금 깎였다.\n"
            "관계도, 건강도 다 가질 수는 없다는 걸 — 또 배웠다."
        ): {
            "rewrites": [["종일","1일"]],
            "slots": (
                (0, "@N@日(?:中|じゅう)(?:苦しんだ|寝込んだ|うなされた)", 1, "sick_day"),
            ),
        },
        (
            "{name}은 \"일이 있다\"고 둘러댔다. 비교당할 일도, 차비 쓸 일도 없었다.\n"
            "대신 명절 내내 지금 사는 방에 혼자 있었다.\n"
            "아버지가 보낸 '밥은 챙겨 먹어라' 문자에 — 한참 답을 못 했다."
        ): {
            "rewrites": [["혼자","1 자"]],
            "slots": (
                (1, "(?:部屋で|部屋に)(?:@N@人|@NATIVE@)(?:だった|で過ごした|きりだった)", 1, "holiday_alone"),
            ),
        },
        (
            "{name}은 큰집은 건너뛰고, 아버지만 따로 찾아뵀다.\n"
            "둘이 먹은 국밥 한 그릇. 비교도, 잔소리도 없었다.\n"
            "차비는 들었지만 — 가장 보고 싶던 사람만, 조용히 보고 왔다."
        ): {
            "rewrites": [["둘이","2 이"],["한 그릇","1 그릇"]],
            "slots": (
                (1, "@N@人で食べた", 2, "shared_diners"),
                (1, "@N@杯のクッパ", 1, "shared_bowl"),
            ),
        },
        (
            "신호음이 세 번 울렸다. 집주인은 \"별 문제 없다\"며 말을 짧게 잘랐다."
        ): {
            "rewrites": [["세 번","3 번"]],
            "slots": (
                (0, "呼び出し音(?:が|は)@N@(?:回|度)(?:鳴った|響いた)", 3, "phone_rings"),
            ),
        },
        (
            "옆집 아주머니가 {name}을 붙잡고 속삭인다.\n"
            "\"그 집주인 양반, 이 건물 말고도 빚이 산더미래.\n"
            "등기부는 떼봤어? 요즘 전세 사기 무서워.\"\n"
            "\n"
            "{name}의 전세보증금 — 몇 년을 모은 전 재산이 —\n"
            "그 집에 묶여 있다. '깡통전세' 네 글자가 머릿속을 맴돈다."
        ): {
            "rewrites": [["네 글자","4 글자"]],
            "slots": (
                (5, "韓国語(?:の)?@N@文字", 4, "korean_character_count"),
            ),
        },
        (
            "등기부를 떼보니 — 근저당이 시세의 80%.\n"
            "집주인이 무너지면 보증금은 한 푼도 못 건진다.\n"
            "다행히 아직 전세보증보험에 들 수 있는 마지노선은 넘기지 않았다.\n"
            "\n"
            "보험료 30만원. {name}의 한 달 식비보다 많다."
        ): {
            "rewrites": [["한 달","1 달"]],
            "slots": (
                (0, "(?:相場|時価|市場価格)の@N@[%％]", 80, "mortgage_ratio"),
                (4, "保険料(?:は|が)?@N@万ウォン", 30, "insurance_cost"),
                (4, "@N@(?:か月|ヶ月|カ月|箇月)(?:の|分の)食費", 1, "food_month"),
            ),
        },
        (
            "{name}은 사직서를 냈다. 안정된 월급을 제 손으로 버렸다.\n"
            "새 사무실은 활기차고, 사람들은 눈이 반짝였다.\n"
            "그리고 — 야근은 두 배, 미래는 안갯속.\n"
            "스톡옵션 종이 한 장이, 휴지가 될지 인생이 될지."
        ): {
            "rewrites": [["두 배","2 배"],["한 장","1 장"]],
            "slots": (
                (2, "残業(?:は|が)(?:@N@|(?P<double>))倍", 2, "overtime_multiple"),
                (3, "ストックオプション(?:の)?(?:紙@N@枚|@N@枚の紙)", 1, "option_sheet"),
            ),
        },
        (
            "카페에서 두 시간을 보냈다. 화이트보드 그림과 \"수익구조\"라는 단어가 반복됐다."
        ): {
            "rewrites": [["두 시간","2 시간"]],
            "slots": (
                (0, "カフェで@N@時間(?:を)?(?:過ごした|費やした)", 2, "cafe_hours"),
            ),
        },
        (
            "{name}은 \"관심 없어\" 하고 대화를 닫았다.\n"
            "동창은 \"기회를 발로 찬다\"며 비아냥댔고, 인연은 거기서 끊겼다.\n"
            "월 천의 환상도 함께 접었다. 절박할수록, 단호해야 했다."
        ): {
            "rewrites": [["월 천","월 10000000원"]],
            "slots": (
                (2, "月(?:に|収(?:は)?)?@N@ウォン", 10000000, "abandoned_monthly_income"),
            ),
        },
        (
            "연락 끊겼던 동창에게서 카톡이 왔다. 반가운 인사.\n"
            "\"잘 지내? 요즘 뭐 해? 나 좋은 사업 하나 하는데,\n"
            "무자본으로 월 천도 가능해. 너 같은 사람한테 딱이야.\n"
            "시간 되면 한번 보자, 응?\"\n"
            "\n"
            "무직에 통장은 바닥. {name}은 그게 뭔지 어렴풋이 안다.\n"
            "그래도 — '월 천'이라는 네 글자가 자꾸 눈에 밟힌다."
        ): {
            "rewrites": [["월 천도","월 10000000원도"],["'월 천'","'월 10000000'"],["네 글자","4 글자"]],
            "slots": (
                (2, "月(?:に|収(?:は)?)?@N@ウォン(?:も|だって)?(?:いける|可能|稼げる)", 10000000, "quoted_monthly_income"),
                (6, "[『「']月(?:に|収(?:は)?)?@N@(?:ウォン)?[』」']", 10000000, "recalled_monthly_income"),
                (6, "@N@文字", 4, "recalled_character_count"),
            ),
        },
        (
            "다단계로 떠안은 물건은 창고에 그대로다. 한 개도 못 팔았다.\n"
            "그리고 — 300만원 카드값이 돌아왔다. 독촉 전화가 빗발친다.\n"
            "그 동창은 연락이 끊겼다. 처음부터 {name}은 '고객'이 아니라 '먹잇감'이었다.\n"
            "\n"
            "그날의 '한 번뿐인 기회'가, 매일 울리는 빚 독촉으로 돌아왔다."
        ): {
            "rewrites": [["한 개","1 개"],["한 번뿐","1 번뿐"]],
            "slots": (
                (0, "@N@(?:つ|個|点)(?:も)?(?:売れなかった|売れていない|売れず)", 1, "unsold_item"),
                (1, "@N@万ウォン(?:の)?(?:カード請求|カードの請求)", 300, "card_bill"),
                (4, "@N@(?:度|回)(?:きり|限り)のチャンス", 1, "one_time_opportunity"),
            ),
        },
        (
            "{name}은 어머니에게 전화를 걸어 처음부터 끝까지 말했다.\n"
            "어머니는 아버지와 함께 비상금으로 남겨 둔 돈에서 300만원을 보냈다. \"왜 이 지경이 될 때까지 혼자 있었니.\"\n"
            "카드값은 막았지만, 이미 떠난 사람의 몫까지 모아 둔 돈을 빌렸다는 사실이 오래 남았다."
        ): {
            "rewrites": [["아버지와 함께","아버지와 2"],["혼자","1 자"]],
            "slots": (
                (1, "父と@N@人で", 2, "parents_saved_pair"),
                (1, "@N@万ウォンを(?:送った|送金した|振り込んだ)", 300, "mother_transferred_won"),
                (1, "(?:@N@人|@NATIVE@)で(?:抱えていた|抱え込んでいた)", 1, "child_alone"),
            ),
        },
        (
            "{name}은 모른 척 발걸음을 옮겼다.\n"
            "남의 돈도, 양심의 짐도 지지 않았다.\n"
            "다만 버스 안에서 내내 그 지갑이 생각났다.\n"
            "아무것도 안 하는 것도, 하나의 선택이었다."
        ): {
            "rewrites": [["하나의 선택","1 선택"]],
            "slots": (
                (3, "(?:何もしないのも|何もしないことも)[、，]?@N@(?:つ|個)の選択(?:だった|であった)", 1, "inaction_choice"),
            ),
        },
        (
            "{name}은 주말마다 사장님 가게에 나갔다. 일당도, 배움도 쏠쏠했다.\n"
            "사장님은 장사 노하우와 사람 쓰는 법을 아낌없이 알려줬다.\n"
            "대신 {name}의 주말은 사라졌다. 쉴 틈은 줄었지만,\n"
            "정직이 만든 인연 하나가 — 든든한 뒷배가 되어갔다."
        ): {
            "rewrites": [["인연 하나","인연 1"]],
            "slots": (
                (3, "(?:正直さ|誠実さ)が(?:生んだ|もたらした)@N@(?:つ|個)の縁", 1, "honest_connection"),
            ),
        },
    }

    contract = contracts.get(source)
    if contract is None:
        return None
    import unicodedata
    from zh_translation_audit import _chinese_cardinal_value

    digits = r"0-9０-９〇零一二三四五六七八九十百千万億"
    number = r"(?<![" + digits + r",.，．])(?P<number>[+＋\-－−]?[" + digits + r",，]+)"
    lines = target.split("\n")
    errors, replacements, owned = [], [], []
    for line, pattern, expected, label in contract["slots"]:
        # Noun-before/after variants share one slot. Rename repeated group
        # definitions so exactly one alternative capture can be populated.
        parts = pattern.replace("@NATIVE@", "(?P<native>ひとり)").split("@N@")
        compiled = parts[0]
        for index, part in enumerate(parts[1:]):
            compiled += number.replace("number>", f"number{index}>") + part
        matches = list(re.finditer(compiled, lines[line])) if line < len(lines) else []
        if len(matches) != 1:
            errors.append(f"source-bound amb tradeoff {label} role/unit/line/count mismatch")
            continue
        match = matches[0]
        captures = [(key, raw) for key, raw in match.groupdict().items() if raw is not None]
        if len(captures) != 1:
            errors.append(f"source-bound amb tradeoff {label} quantity slot mismatch")
            continue
        key, raw = captures[0]
        start, end = match.span(key)
        normalized = unicodedata.normalize("NFKC", raw).replace(",", "")
        if "," in unicodedata.normalize("NFKC", raw) and not re.fullmatch(
            r"[1-9][0-9]{0,2}(?:,[0-9]{3})+(?:万)?", unicodedata.normalize("NFKC", raw)
        ):
            errors.append(f"source-bound amb tradeoff {label} numeric grouping mismatch")
        if key == "native":
            value = 1
        elif key == "double":
            # Bare 倍 means twice only in this exact-source overtime slot.
            # The zero-width capture inserts its numeric marker; 半/-/other
            # numerals cannot be swallowed by the empty alternative.
            value = 2
        elif normalized.endswith("万"):
            # The witnessed monthly quote is 千万/1000万, not 千ウォン.
            coefficient = _chinese_cardinal_value(normalized[:-1])
            value = coefficient * 10000 if coefficient is not None else None
        else:
            value = _chinese_cardinal_value(normalized)
        if (raw and raw[:1] in "+＋-－−") or value != expected:
            errors.append(f"source-bound amb tradeoff {label} value/sign mismatch")
        if re.search(r"[+＋\-－−" + digits + r",.，．]\s*$", lines[line][:start]):
            errors.append(f"source-bound amb tradeoff {label} numeric prefix mismatch")
        if label == "overtime_multiple" and lines[line][match.end():].startswith("半"):
            errors.append("source-bound amb tradeoff overtime_multiple fractional multiplier mismatch")
        if re.match(r"\s*(?:[/／]|毎(?:時|日|月|年)|未満|以上|以下|程度|ほど|くらい|ぐらい|"
                    r"円|ドル|ウォン|元|ユーロ|ではな|じゃな|"
                    r"[（(]\s*(?:毎|月|日|年|時|円|ドル|元))", lines[line][match.end():]):
            errors.append(f"source-bound amb tradeoff {label} qualifier mismatch")
        offset = sum(len(part) + 1 for part in lines[:line])
        amount_unit = 1 if lines[line][end:match.end()].startswith("万ウォン") else 0
        owned.append((offset + start, offset + end + amount_unit))
        # A native lexical 'ひとり' owns the same one-person slot; replace its
        # whole span with the numeric stream marker, not the surrounding prose.
        replacements.append((offset + start, offset + end, str(expected)))
    # Fixed lexical Japanese 二日酔い is a hangover, not a two-day duration.
    # These only remove that lexical span from this exact-source quantity scan;
    # they never remove an Arabic number from the existing numeric comparison.
    scan = target
    for token in ("二日酔い",):
        scan = scan.replace(token, " " * len(token))
    units = r"(?:万|億)?(?:ウォン|円|ドル|元)|か月|ヶ月|カ月|箇月|年|日|時間|分|秒|人|名|回|度|つ|個|点|杯|枚|倍|文字|[%％]"
    for quantity in re.finditer(number + r"\s*(?:" + units + ")", scan):
        start, end = quantity.span("number")
        if not any(a <= start and end <= b for a, b in owned):
            errors.append("source-bound amb tradeoff added/displaced quantity mismatch")
    normalized_source = source
    for old, new in contract["rewrites"]:
        normalized_source = normalized_source.replace(old, new, 1)
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return normalized_source, normalized_target, sorted(set(errors))


def _ja_callback_shadow_numbers(source: str, target: str):
    """Normalize only ten witnessed callback/shadow quantity contracts.

    Whole Korean sources license line-local typed slots, not complete target
    sentences. Original prose still runs through every existing text validator.
    """
    contracts = {
        (
            "토요일. 과천. 4호선.\n\n'딱 한 번'은 다섯 경주가 됐다. 15만원이 녹았다.\n\n90만원의 기억이 문제였다.\n그 기억이 있는 한 '"
            "한 번만'은 거짓말이다.\n자신에게 하는 거짓말. 제일 잘 속는 상대에게.\n\n돌아오는 지하철에서 {name}은 창에 비친 얼굴을 봤다.\n"
            "낯익은 표정이었다. 어디서 봤더라.\n\n— 베팅창 앞 아저씨들 표정이었다."
        ): (
            (0, "4호선", "4호선",
                "(?:地下鉄)?@N@号線",
                4, "subway_route", "number"),
            (2, "한 번", "1 번",
                "[「『]@N@(?:度|回)(?:だけ|きり)[」』](?:が|は)",
                1, "once_became_races", "number"),
            (2, "다섯 경주", "5 경주",
                "@N@レース(?:になった|に増えた)",
                5, "actual_races", "number"),
            (2, "15만원", "150000원",
                "@M@(?:が|を)(?:溶かした|溶けた|失った)",
                150000, "actual_loss", "money"),
            (4, "90만원", "900000원",
                "@M@の記憶",
                900000, "remembered_win", "money"),
            (5, "한 번만", "1 번만",
                "[「『]@N@(?:度|回)(?:だけ|きり)[」』](?:は)?(?:嘘|うそ)",
                1, "once_is_lie", "number"),
        ),
        (
            "월급날. 통장에 숫자가 찍혔다.\n\n한 달을 갈아 넣은 돈.\n\n그런데 머릿속에 다른 숫자가 떠올랐다.\n과천에서 쌍승이 터졌던 날. 5만원"
            "이 90만원이 되는 데 걸린 시간 — 2분.\n\n한 달 vs 2분.\n\n이 비교가 시작되는 순간이 제일 위험하다는 걸, 어디선가 읽은 적이"
            " 있다."
        ): (
            (2, "한 달", "1 달",
                "@N@(?:か月|ヶ月|カ月|箇月)(?:間)?(?:を|分)",
                1, "salary_month", "number"),
            (5, "5만원", "50000원",
                "@M@が",
                50000, "past_stake", "money"),
            (5, "90만원", "900000원",
                "@M@に(?:なるまで|なったのは)",
                900000, "past_return", "money"),
            (5, "2분", "2분",
                "(?:――|—|、|たった)@N@分",
                2, "past_win_minutes", "number"),
            (7, "한 달", "1 달",
                "@N@(?:か月|ヶ月|カ月|箇月)(?:間)?(?:と|対)",
                1, "compared_month", "number"),
            (7, "2분", "2분",
                "(?:と|対)@N@分",
                2, "compared_minutes", "number"),
        ),
        (
            "서류 접수, 심사, 두 달.\n\n보증금 전액이 돌아왔다.\n\n같은 건물 다른 세입자들은 배당 순위에서 밀려 절반도 못 건졌다.\n복도에서 마"
            "주친 옆집 사람의 얼굴을 잊을 수가 없다.\n\n30만원. 한 달 식비.\n그게 수천만원을 지켰다.\n\n보험은 손해 보는 게임이라고들 한다.\n"
            "맞다. 단 한 번만 빼고."
        ): (
            (0, "두 달", "2 달",
                "(?:審査[、，]|審査に)@N@(?:か月|ヶ月|カ月|箇月)",
                2, "insurance_review_months", "number"),
            (7, "30만원", "300000원",
                "@M@[。．]",
                300000, "paid_premium", "money"),
            (7, "한 달", "1 달",
                "@N@(?:か月|ヶ月|カ月|箇月)分の食費",
                1, "food_month", "number"),
            (8, "수천만원", "근사원화",
                "(?P<approx>(?:数千万|何千万)ウォン)",
                None, "protected_approximate_won", "approx"),
            (11, "한 번", "1 번",
                "(?:たった|ただ)?@N@(?:度|回)を(?:除いて|除けば)",
                1, "insurance_exception", "number"),
        ),
        (
            "법원, 등기소, 주민센터를 한 달 동안 돌았다.\n\n최우선변제금과 배당으로 보증금의 60%를 건졌다.\n40%는 — 800만원은 사라졌다."
            "\n\n그날 보험료 30만원이 아까웠다.\n그 30만원이 800만원이었다.\n\n수업료치고 너무 비쌌다. 근데 이런 수업은 한 번이면 평생 간다"
            "."
        ): (
            (0, "한 달", "1 달",
                "@N@(?:か月|ヶ月|カ月|箇月)(?:を|かけて|間)",
                1, "procedure_month", "number"),
            (2, "60%", "60%",
                "保証金の@N@[%％]を(?:取り戻した|回収した)",
                60, "recovered_share", "number"),
            (3, "40%", "40%",
                "@N@[%％]は",
                40, "lost_share", "number"),
            (3, "800만원", "8000000원",
                "@M@は(?:消えた|失われた)",
                8000000, "lost_principal", "money"),
            (5, "30만원", "300000원",
                "@M@の保険料",
                300000, "foregone_premium", "money"),
            (6, "30만원", "300000원",
                "(?:その|あの)@M@が",
                300000, "compared_premium", "money"),
            (6, "800만원", "8000000원",
                "@M@(?:だった|に相当した)",
                8000000, "compared_loss", "money"),
            (8, "한 번", "1 번",
                "(?:授業は|授業なら)@N@(?:度|回)で",
                1, "lasting_lesson", "number"),
        ),
        (
            "임대인 주소지를 찾아갔다. 이미 비어 있었다.\n\n같은 피해자가 열일곱 명이라는 걸 거기서 알았다.\n집단 소송에 이름을 올렸지만 — 회수"
            " 가능성은 낮다고 했다.\n\n법적 절차를 놓친 사이 배당요구 기한이 지났다.\n분노가 절차를 잡아먹었다.\n\n1,200만원. 서울이 가르치는"
            " 방식은 늘 이렇게 비싸다."
        ): (
            (2, "열일곱 명", "17 명",
                "(?:被害に遭った人が|被害者が|被害者は)@N@(?:人|名)(?:いる|いた|だった)",
                17, "victims", "number"),
            (8, "1,200만원", "12000000원",
                "@M@[。．]",
                12000000, "lost_won", "money"),
        ),
        (
            "2차 끝나고 팀장을 따로 잡았다.\n\n\"사실은 사업이 아니라 — 아버지 빚을 갚았습니다. 6년.\"\n\n팀장이 소주를 한 잔 따랐다. 한참 "
            "말이 없었다.\n\n\"발표는 내가 미룰게. 근데 — 빚 6년 갚은 놈이 사업 준비한 놈보다 나아.\n끈기는 못 꾸며내거든.\"\n\n거짓말은 사라"
            "졌다. 이상하게, 더 단단해진 채로."
        ): (
            (0, "2차", "2차",
                "@N@次会(?:が|の)?(?:終わ|終了)",
                2, "after_party_round", "number"),
            (0, "따로", "2명 따로",
                "(?P<private>個別|内々)に|@N@人(?:だけ|きり)?で(?:話した|話をした)",
                2, "private_conversation", "private"),
            (2, "6년", "6년",
                "@N@年(?:間)?[」』]",
                6, "confessed_repayment_years", "number"),
            (4, "한 잔", "1 잔",
                "ソジュを@N@杯[、，]?(?:注いだ|ついだ)",
                1, "poured_soju", "number"),
            (6, "6년", "6년",
                "借金を@N@年(?:間)?返した",
                6, "manager_recalled_years", "number"),
        ),
        (
            "일주일 동안 새벽 3시까지 사업계획서 양식을 공부했다.\n\n발표는 — 통과됐다. 임원이 고개를 끄덕였다.\n\n돌아오는 길에 팀장이 어깨를 "
            "쳤다. \"역시 경험자네.\"\n\n그 말이 칭찬인데 체했다.\n\n거짓말은 이제 실력이 됐다. 근데 거짓말이 사라진 건 아니었다.\n더 깊이 들어"
            "갔을 뿐."
        ): (
            (0, "일주일", "1주일",
                "@N@週間[、，]",
                1, "study_week", "number"),
            (0, "3시", "3시",
                "(?:明け方|早朝|午前)@N@時まで",
                3, "dawn_deadline", "number"),
        ),
        (
            "카톡이 왔다. 그 동창이었다.\n\n호텔 세미나실에서 어깨를 감싸던. 등록비 300만원을 말하던.\n\n'야. 나 그거 나왔다. 너 박차고 나"
            "간 날 — 사실 그날부터 흔들렸어.\n빚 1,400 남았는데 그래도 나왔다.\n물류 일 시작했어. 한 번 보자. 내가 국밥 산다.'"
        ): (
            (2, "300만원", "3000000원",
                "登録料@M@を(?:口にした|話した)",
                3000000, "old_registration_fee", "money"),
            (5, "1,400", "14000000원",
                "借金はまだ@M@(?:ある|残って(?:いる|る))",
                14000000, "remaining_debt", "money"),
        ),
        (
            "{name}은 지금은 답을 확정할 수 없고 칠 주 안에 자기 쪽 결정을 다시 보내겠다고 적었다. 화면에는 발신 시각만 남았다. 상대가 "
            "기다리겠다는 답이나 약속은 생기지 않았다."
        ): (
            (0, "칠 주", "7 주",
                "@N@週間(?:以内|のうち)に",
                7, "own_future_deadline", "number"),
        ),
        (
            "칠 주 전에 자기 손으로 넣어 둔 달력 알림이 떴다. 예전 DM에는 그날 보낸 말과 발신 시각만 남아 있었다. 읽음도 답장도 없었으므로"
            " 상대가 기다렸는지, 이미 떠났는지는 알 수 없었다.\n\n{name}이 확인할 수 있는 것은 자기 쪽에서 약속한 날짜가 오늘이라는 사실뿐"
            "이었다."
        ): (
            (0, "칠 주", "7 주",
                "@N@週間前",
                7, "own_past_calendar", "number"),
        ),
    }
    slots = contracts.get(source)
    if slots is None:
        return None
    import unicodedata
    from zh_translation_audit import _chinese_cardinal_value

    digits = r"0-9０-９〇零一二三四五六七八九十百千"
    number = (r"(?<![" + digits + r"万億,.，．数何])"
              r"(?P<number>[+＋\-－−]?[" + digits + r",，]+)")
    money = r"(?P<money>" + number + r"(?P<scale>万|億)?ウォン)"
    lines = target.split("\n")
    source_lines = source.split("\n")
    errors, replacements, owned = [], [], []
    for line, old, canonical, pattern, expected, label, mode in slots:
        expression = pattern.replace("@M@", money).replace("@N@", number)
        matches = list(re.finditer(expression, lines[line])) if line < len(lines) else []
        if len(matches) != 1:
            errors.append(f"source-bound callback/shadow {label} role/unit/line/count mismatch")
        else:
            match = matches[0]
            native = match.groupdict().get("private")
            approximate = match.groupdict().get("approx")
            raw = match.groupdict().get("number") or ""
            value = None
            if native is not None:
                start, end = match.span("private")
                value = 2
            elif approximate is not None:
                start, end = match.span("approx")
                value = None
            else:
                start, end = match.span("money" if mode == "money" else "number")
                normalized = unicodedata.normalize("NFKC", raw)
                if "," in normalized and not re.fullmatch(r"[1-9][0-9]{0,2}(?:,[0-9]{3})+", normalized):
                    errors.append(f"source-bound callback/shadow {label} comma grouping mismatch")
                value = _chinese_cardinal_value(normalized.replace(",", ""))
                if mode == "money" and value is not None:
                    value *= {"万": 10000, "億": 100000000, None: 1}[match.group("scale")]
                if raw and raw[0] in "+＋-－−":
                    errors.append(f"source-bound callback/shadow {label} sign mismatch")
            if value != expected:
                errors.append(f"source-bound callback/shadow {label} value mismatch")
            if re.search(r"[" + digits + r"万億,.，．+＋\-－−]\s*$", lines[line][:start]):
                errors.append(f"source-bound callback/shadow {label} numeric prefix mismatch")
            if re.match(r"\s*(?:[/／]|以上|以下|未満|程度|ほど|くらい|ぐらい|"
                        r"円|ドル|ウォン|元|ユーロ|"
                        r"[（(]\s*(?:毎|月|日|年|時|円|ドル|元))", lines[line][end:]):
                errors.append(f"source-bound callback/shadow {label} qualifier mismatch")
            offset = sum(len(part) + 1 for part in lines[:line])
            owned.append((offset + start, offset + end))
            replacement = "金額概算" if mode == "approx" else str(expected)
            if mode == "money":
                replacement += "ウォン"
            replacements.append((offset + start, offset + end, replacement))
        # Only the exact source and witnessed source line own this rewrite.
        source_lines[line] = source_lines[line].replace(old, canonical, 1)

    units = (r"(?:万|億)?(?:ウォン|円|ドル|元)|週間|か月|ヶ月|カ月|箇月|"
             r"時間|レース|号線|次会|年|日|分|秒|人|名|回|度|つ|個|杯|枚|倍|[%％]")
    for quantity in re.finditer(number + r"\s*(?:" + units + ")", target):
        start, end = quantity.span("number")
        if not any(a <= start and end <= b for a, b in owned):
            errors.append("source-bound callback/shadow added/displaced quantity mismatch")
    normalized_target = target
    for start, end, replacement in sorted(replacements, reverse=True):
        normalized_target = normalized_target[:start] + replacement + normalized_target[end:]
    return "\n".join(source_lines), normalized_target, sorted(set(errors))


def _ja_korean_culture_address(source: str, target: str):
    """Permit ordinary male address only in the two observed non-romance quotes.

    Jiyeon's 오빠 rule is unchanged. No global term deletion: every occurrence
    must belong to the source-licensed reply or shopkeeper quote on its line.
    """
    contracts = {
        "\"잘 되시길 바라요.\" 복도에서 짧게 했다.\n\"고맙습니다. 형도요.\" 돌아온 답.\n\n서로의 이름도 모르지만, 이 고시원 복도에서 가장 따뜻한 인사였다.": "[「『](?:どうも|本当に)?(?:ありがとうございます|ありがとう)。お兄さんも(?:頑張ってください)?[。！!]?[」』](?:と(?:いう)?(?:返事|答え)?が?|という返事が)?(?:返ってきた|返って来た|返された|返事があった|答えた|言われた)",
        "1인분이라 좀 멋쩍었지만, 아주머니가 떡을 더 얹어줬다.\n\"많이 먹어요, 총각.\"\n그 한마디에 떡볶이보다 마음이 더 데워졌다.": "[「『](?:いっぱい|たくさん)(?:食べ(?:なさい|て)(?:ね|ください)?|召し上が(?:れ|ってください))[、，,]お兄さん[。！!]?[」』]",
    }
    pattern = contracts.get(source)
    if pattern is None or "お兄さん" not in target:
        return False
    lines = target.split("\n")
    if len(lines) < 2 or target.count("お兄さん") != 1:
        return False
    match = re.search(pattern, lines[1])
    return bool(match and "お兄さん" in match.group()
                and not re.search(r"(?:ジヨン|ヒョンス|返ってこな|言わな|答えな|なかった)", lines[1]))



def translation_errors(leaf: Leaf, locale: str, text: Any) -> list[str]:
    import ja_translation_pipeline as ja
    if leaf.group == "endings" and leaf.path == ("condition",):
        return ["internal ending condition is not player translation"]
    if locale not in LOCALES:
        return ["unsupported locale"]
    if not isinstance(text, str) or not text.strip():
        return ["blank/non-string translation"]
    literal_pair = None if leaf.format_template else _sector_literal_percent_pair(leaf.source, text)
    placeholder_source, placeholder_target = literal_pair or (leaf.source, text)
    if locale == "ja":
        errors = ja.validate_translation(ja.Entry(leaf.id, placeholder_source, leaf.owner,
                                                 format_template=leaf.format_template), placeholder_target)
        if _ja_korean_culture_address(leaf.source, text):
            errors = [error for error in errors if error != "forbidden term お兄さん"]
        # Exact catalogue names may legitimately be all Latin. This does not
        # excuse English descriptions or partial brand-only translations.
        if leaf.group == "catalog":
            from zh_translation_audit import catalog_latin_only, CATALOG_YOUNG_ADULT_SOURCES
            if catalog_latin_only(leaf.source, text):
                errors = [e for e in errors if e != "no Japanese glyphs in translated Korean source"]
        if leaf.source.count("\n") != text.count("\n"):
            errors.append("newline mismatch")
        # Explicit Arabic digits remain exact; written counters are a reviewer gate.
        numeric = re.compile(r"(?<![\d.])[+-]?\d+(?:[,.]\d+)*")
        source_numbers = ja.PLACEHOLDER.sub("", placeholder_source)
        target_numbers = ja.PLACEHOLDER.sub("", placeholder_target)
        leisure_gambling = _ja_leisure_gambling_numbers(leaf.source, text)
        if leisure_gambling is not None:
            source_numbers, target_numbers, quantity_errors = leisure_gambling
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        chain_support = _ja_chain_support_salary_numbers(leaf.source, text)
        amb_tradeoff = _ja_amb_tradeoff_numbers(leaf.source, text)
        callback_shadow = _ja_callback_shadow_numbers(leaf.source, text)
        if callback_shadow is not None:
            source_numbers, target_numbers, quantity_errors = callback_shadow
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        if amb_tradeoff is not None:
            source_numbers, target_numbers, quantity_errors = amb_tradeoff
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        if chain_support is not None:
            source_numbers, target_numbers, quantity_errors = chain_support
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        korean_culture = _ja_korean_culture_numbers(leaf.source, text)
        cafe_encounter = _ja_cafe_encounter_money_numbers(leaf.source, text)
        if cafe_encounter is not None:
            source_numbers, target_numbers, quantity_errors = cafe_encounter
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        if korean_culture is not None:
            source_numbers, target_numbers, quantity_errors = korean_culture
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        market_admin = _ja_market_admin_numbers(leaf.source, text)
        if market_admin is not None:
            source_numbers, target_numbers, quantity_errors = market_admin
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        investment_life = _ja_investment_life_numbers(leaf.source, text)
        if investment_life is not None:
            source_numbers, target_numbers, quantity_errors = investment_life
            source_numbers = ja.PLACEHOLDER.sub("", source_numbers)
            target_numbers = ja.PLACEHOLDER.sub("", target_numbers)
            errors.extend(quantity_errors)
        father_call = _ja_father_call_time_numbers(source_numbers, target_numbers)
        if father_call is not None:
            source_numbers, target_numbers, call_errors = father_call
            errors.extend(call_errors)
        from zh_translation_audit import (
            _source_money_amounts, _target_money_amounts,
            _has_numeric_sign_prefix, MoneyAmount,
        )
        # U+2212 is the minus sign in the lottery's won cost, not a dash to
        # discard. Canonicalize only the complete observed won denomination.
        source_numbers = re.sub(r"−(?=\d+(?:,\d{3})*원)", "-", source_numbers)
        target_numbers = re.sub(r"−(?=\d+(?:,\d{3})*ウォン)", "-", target_numbers)
        # The first 1+1 promotion explains buy-one/get-one before retaining
        # its label. Bind that exact equivalence, not arbitrary added counts.
        if '1+1 행사를 발견했다.' in leaf.source:
            for promotion in re.finditer('1個買うと1個もらえる、1\\+1キャンペーン', target_numbers):
                if _has_numeric_sign_prefix(target_numbers, promotion.start()):
                    errors.append('promotion count has an invalid numeric prefix')
            target_numbers = target_numbers.replace(
                '1個買うと1個もらえる、1+1キャンペーン', '1+1キャンペーン',
            )
        # One lottery entry is 一口 in Japanese. Its quoted price remains won.
        if '로또 1장에 1000원.' in leaf.source:
            target_numbers = target_numbers.replace('ロト一口、1,000ウォン', 'ロト1口、1,000ウォン')
        # A dramatic ellipsis is not the decimal point before the match count.
        if '...3개 일치. 5등.' in leaf.source:
            source_numbers = source_numbers.replace('...3개 일치. 5등.', '…3개 일치. 5등.')
            for match_count in re.finditer(r'3個一致', target_numbers):
                if _has_numeric_sign_prefix(target_numbers, match_count.start()):
                    errors.append('lottery match count has an invalid numeric prefix')
        # Observed per-person price, one-night room and first-week calendar.
        # Normalize only a complete source-bound phrase, preserving its line,
        # unit and value; this is not a waiver for arbitrary written numerals.
        for source_pattern, target_pattern, source_old, source_new, target_old, target_new in (
            (r'1인 128,000원', r'(?<![0-9一二三四五六七八九十百千万億兆])(?:一|1)人128,000ウォン(?!円|ドル|ウォン)',
             '1인', '1인', '一人', '1人'),
            (r'1박 35만원', r'(?<![0-9一二三四五六七八九十百千万億兆])(?:一|1)泊35万ウォン(?!円|ドル|ウォン)',
             '1박', '1박', '一泊', '1泊'),
            (r'10월 첫째 주', r'10月の第1週',
             '첫째', '1', '第1', '第1'),
        ):
            source_spans = list(re.finditer(source_pattern, source_numbers))
            if not source_spans:
                continue
            target_spans = list(re.finditer(target_pattern, target_numbers))
            if len(source_spans) != len(target_spans) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                for match in target_spans
            ) or [source_numbers.count('\n', 0, match.start()) for match in source_spans] != \
                    [target_numbers.count('\n', 0, match.start()) for match in target_spans]:
                errors.append('source-bound social fee/night/week unit mismatch')
            for match in target_spans:
                if re.match(r'\s*(?:ではない|未満|以上|以下|より後|より前|'
                            r'[（(]\s*(?:円|ドル|元|人民元|韓元|韩元|ウォン)\s*[）)])',
                            target_numbers[match.end():]):
                    errors.append('source-bound social fee/night/week qualifier mismatch')
            for is_source, value, spans, old_piece, new_piece in (
                (True, source_numbers, source_spans, source_old, source_new),
                (False, target_numbers, target_spans, target_old, target_new),
            ):
                for match in reversed(spans):
                    value = value[:match.start()] + match.group().replace(old_piece, new_piece) + value[match.end():]
                if is_source:
                    source_numbers = value
                else:
                    target_numbers = value
        # Mixed Korean thousand/hundred-man, grouped/plain thousands and the observed
        # native 오천 amount are each one won amount, independent of grouping.
        # Match its value/currency, then normalize those exact spans so Japanese
        # comma grouping does not pretend to change the explicit digit contract.
        mixed_source = [amount for amount in _source_money_amounts(source_numbers)
            if (source_numbers[amount.start:amount.end].endswith('원')
                and re.search(r'\d+\s*[천백]|\d+,\d{3}|\d{4,}원|오천\s*원', source_numbers[amount.start:amount.end]))
            or (re.fullmatch(r'6억\s+8천', source_numbers[amount.start:amount.end])
                and source_numbers[:amount.start].endswith('분양가 '))
            or (re.fullmatch(r'1억\s+2천', source_numbers[amount.start:amount.end])
                and (source_numbers[:amount.start].endswith('네 지분 가치 지금 ')
                     or source_numbers[amount.end:].startswith('이 이제 시작이다.')))]
        mixed_target = list(re.finditer(
            r"[+-]?\d+(?:,\d{3})*(?:億\s*\d+(?:,\d{3})*)?(?:(?:千万|万|千)(?:\d+(?:,\d{3})*)?)?ウォン(?!\s*(?:円|韓元|韩元|元|ドル|ウォン|[%％‰‱万萬億亿兆千百倍]))", target_numbers,
        ))
        consumed = []
        if '1인당 4만 5천원이 나왔다' in leaf.source or re.search(r'(?:12만 8천원|각 2만 5천원)', leaf.source):
            mixed_target.extend(re.finditer(
                r"[+-]?\d+万\d+千ウォン(?!\s*(?:円|韓元|韩元|元|ドル|ウォン|[%％‰‱万萬億亿兆千百倍]))",
                target_numbers,
            ))
            mixed_target.sort(key=lambda item: item.start())
        for amount in mixed_source:
            value = amount.won
            required_plus = source_numbers[amount.start:amount.end].startswith('+')
            found = None
            for candidate in mixed_target:
                if candidate.start() in {start for start, _ in consumed}:
                    continue
                # A leading minus owns the whole compound amount (not just
                # its first component): -1万2,000 is -12,000, never -8,000.
                raw_candidate = candidate.group()
                parsed = _target_money_amounts(raw_candidate.lstrip('+-').replace('ウォン', '韓元'))
                signed_value = parsed[0].won * (-1 if raw_candidate.startswith('-') else 1) if len(parsed) == 1 else None
                if signed_value == value \
                        and candidate.group().startswith('+') == required_plus \
                        and not _has_numeric_sign_prefix(target_numbers, candidate.start()) \
                        and not re.match(r"\s*[（(]\s*(?:円|ドル|元|人民元|韓元|韩元|ウォン)\s*[）)]", target_numbers[candidate.end():]) \
                        and not (re.fullmatch(r'6억\s+8천', source_numbers[amount.start:amount.end])
                            and re.match(r'\s*[（(]\s*(?:月|年|日|時間)\s*[）)]', target_numbers[candidate.end():])) \
                        and not (re.fullmatch(r'1억\s+2천', source_numbers[amount.start:amount.end])
                            and (source_numbers.count('\n', 0, amount.start) != target_numbers.count('\n', 0, candidate.start())
                                 or re.match(r'\s*(?:ではない|未満|以上|以下|程度|[/／]\s*(?:月|年|日|時間|週|分)|'
                                             r'[（(]\s*(?:月|年|日|時間)\s*[）)])', target_numbers[candidate.end():]))):
                    found = candidate
                    break
            if found is None:
                errors.append('mixed Korean thousand-hundred-man won amount/currency mismatch')
            else:
                consumed.append((found.start(), found.end()))
        # Keep the normalized amounts in the ordered numeric stream. Masking
        # them would let two correctly valued fees exchange their owners, or
        # let a mixed amount move across an ordinary number unnoticed.
        def normalized_money_numbers(value, spans):
            for span in sorted(spans, key=lambda item: item.start, reverse=True):
                value = value[:span.start] + format(span.won, 'f') + value[span.end:]
            return value
        source_numbers = normalized_money_numbers(source_numbers, mixed_source)
        target_numbers = normalized_money_numbers(target_numbers, [
            MoneyAmount(start, end, amount.won)
            for amount, (start, end) in zip(mixed_source, consumed)
        ]) if len(consumed) == len(mixed_source) else target_numbers
        if re.search(r'(?<=분양가 )6억\s+8천(?=[.。])', leaf.source):
            # One purchase price cannot borrow a correct total placed after
            # an invented native-number monthly fee or a different owner.
            prices = list(re.finditer(r'[+\-−]?[0-9,一二三四五六七八九十百千万萬億兆]+\s*ウォン', text))
            if len(prices) != 1 or not text[:prices[0].start()].endswith('分譲価格は'):
                errors.append('source-bound apartment price owner/extra amount mismatch')
        # Korean mixed notation 5백만원 is 500万ウォン, not 5万ウォン.
        # Bind both the magnitude and currency before normalizing digits.
        for amount in re.finditer(r"(?<![\d.])(?P<number>[+-]?\d+)백만원", source_numbers):
            from zh_translation_audit import _has_numeric_sign_prefix
            raw = amount.group('number')
            normalized = ('+' if raw.startswith('+') else '') + str(int(raw) * 100)
            pattern = re.escape(normalized) + r"万ウォン"
            matches = list(re.finditer(pattern, target_numbers))
            if len(matches) != len(re.findall(re.escape(amount.group()), source_numbers)) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                for match in matches
            ):
                errors.append("mixed Korean hundred-man won amount/currency mismatch")
        source_numbers = re.sub(r"(?<![\d.])([+-]?\d+)백만원",
                                lambda m: ('+' if m.group(1).startswith('+') else '') + str(int(m.group(1)) * 100) + '만원',
                                source_numbers)
        # A reunion's third WEEK Saturday is not necessarily the month's third
        # Saturday. Bind the whole calendar phrase before normalizing its native
        # ordinal; do not exempt arbitrary written numerals in Japanese prose.
        source_week = list(re.finditer(r"(?<![가-힣])다음 달 셋째 주 토요일", source_numbers))
        target_week = list(re.finditer(r"来月(?:の)?第(?:3|三)週(?:の)?土曜日", target_numbers))
        if source_week or target_week:
            if len(source_week) != len(target_week) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                or re.search(r"再\s*$", target_numbers[:match.start()])
                for match in target_week
            ):
                errors.append("source-bound calendar week/day mismatch")
            source_numbers = source_numbers.replace("다음 달 셋째 주 토요일", "다음 달 3 주 토요일")
            target_numbers = re.sub(r"来月(?:の)?第三週(?:の)?土曜日",
                                    lambda match: match.group().replace("第三", "第3"), target_numbers)
        # Source 1인 5만 원 is a per-person fee, not a new one-person event.
        # Accept its native counter only next to the exact unsigned won fee.
        source_person_fee = list(re.finditer(r"(?<![가-힣\d])1인\s+5만\s*원", source_numbers))
        target_person_fee = list(re.finditer(
            r"(?<![0-9一二三四五六七八九十百千萬万億兆])(?:一|1)人(?:当たり)?\s*5万ウォン(?!円|韓元|韩元|元|ドル|ウォン)",
            target_numbers,
        ))
        if source_person_fee or target_person_fee:
            if len(source_person_fee) != len(target_person_fee) or any(
                _has_numeric_sign_prefix(value, match.start())
                for value, matches in ((source_numbers, source_person_fee), (target_numbers, target_person_fee))
                for match in matches
            ):
                errors.append("source-bound per-person won fee mismatch")
            for match in reversed(target_person_fee):
                value = match.group()
                if value.startswith("一"):
                    target_numbers = target_numbers[:match.start()] + "1" + value[1:] + target_numbers[match.end():]
        # This exam title uses D-14 as days remaining, not negative fourteen.
        # Bind the complete countdown title so days cannot turn into hours,
        # an elapsed interval, or a number borrowed from another clause.
        if leaf.source == "자격증 시험 D-14":
            if not re.fullmatch(r"資格試験(?:まであと(?:14|十四)日|\s+D-14)", text):
                errors.append("source-bound exam countdown days mismatch")
            else:
                source_numbers = source_numbers.replace("D-14", "14")
                target_numbers = target_numbers.replace("D-14", "14").replace("十四日", "14日")
        # Observed life-event native time expressions. Bind clock phase,
        # elapsed time or a still-future break, then retain ordered values.
        # This is deliberately not a waiver for arbitrary written numerals.
        native_time_bound = False
        for source_pattern, target_pattern, number in (
            (r"새벽 두 시(?=\.)", r"午前(?:2|二)時(?=。)", "2"),
            (r"밤 열 시(?=에 폰을)", r"夜(?:10|十)時(?=にスマホを)", "10"),
            (r"두 시간 후(?=에 더 심해졌다)", r"(?:2|二)時間後(?=には、もっとひどくなった)", "2"),
            (r"한 시간 만에(?= 그쳤다)", r"(?:1|一)時間で(?=やんだ)", "1"),
            (r"(?<![가-힣\d])한 달(?=은 안 가기로\.)",
             r"(?:1|一)か月(?=は行かないことにする。)", "1"),
            (r"(?<![가-힣\d])한 달(?=\.\n\n한 달이면)",
             r"(?:1|一)か月(?=。\n\n(?:1|一)か月あれば)", "1"),
            (r"(?<![가-힣\d])한 달(?=이면 충분히 멀어질 수 있었다\.)",
             r"(?:1|一)か月(?=あれば、十分に距離を置けるはずだった。)", "1"),
        ):
            source_times = list(re.finditer(source_pattern, source_numbers))
            if not source_times:
                continue
            native_time_bound = True
            target_times = list(re.finditer(target_pattern, target_numbers))
            if len(source_times) != len(target_times) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                for match in target_times
            ):
                errors.append("source-bound native clock/elapsed-time mismatch")
            for value, matches, is_source in (
                (source_numbers, source_times, True), (target_numbers, target_times, False),
            ):
                for match in reversed(matches):
                    value = value[:match.start()] + number + value[match.end():]
                if is_source:
                    source_numbers = value
                else:
                    target_numbers = value
        # Callback recollections put a native Korean month interval at the end
        # of the opening sentence. Bind the past/elapsed syntax, number, unit
        # and first-line ownership before admitting Japanese Arabic digits.
        # Neither a future appointment nor an extra interval can supply it.
        callback_month = re.search(
            r'(?:게 |지 )(?P<number>한|두|석|세) 달(?: 전이다\.|이 지났다\.|\.)$',
            source_numbers.split('\n', 1)[0],
        )
        # These observed openings use -고, not -지. Bind their actual past
        # action before allowing the same elapsed interval; no generic -고 waiver.
        callback_past_actions = {
            '그림자 투자에 데이고 두 달이 지났다.': r'影の投資で痛手を負ってから',
            '홀덤에서 크게 따고 두 달이 지났다.': r'(?:テキサス)?ホールデムで大勝ちしてから',
            '경마에서 크게 따고 두 달이 지났다.': r'競馬で大勝ちしてから',
        }
        callback_past_action = callback_past_actions.get(leaf.source.split('\n', 1)[0])
        if callback_past_action:
            callback_month = re.search(r'고 (?P<number>두) 달이 지났다\.$',
                                       source_numbers.split('\n', 1)[0])
        # These witnessed bare te/de clauses express the source's elapsed
        # action or decision. Bind the whole opening and actor; do not accept
        # arbitrary past plans merely because they also end in te/de.
        callback_te_actions = {
            "카페에서 공개적으로 망신을 당한 지 두 달.": "カフェで人前で恥をかいて",
            "카페 일을 일찍 그만둔 지 두 달.": "カフェの仕事を早々に辞めて",
            "카페에서 훔친 돈을 도박에 쓴 지 두 달.": "カフェで盗んだ金を賭け事に使って",
            "카페에서 훔친 돈으로 투자한 지 두 달.": "カフェで盗んだ金を投資して",
            "카페 상황을 발판으로 새로운 기회를 연 지 두 달.": "カフェでの状況を足がかりに、新たな機会を切り開いて",
            "카페에서 실수하고 만회하려 한 지 두 달.": "カフェで過ちを犯し、埋め合わせようとして",
            "콘텐츠 하나가 크게 퍼진 지 두 달.": "ひとつのコンテンツが大きく広まって",
            "신용이 손상된 지 세 달.": "信用が傷ついて",
            "신용 문제에서 더 이상 참지 않겠다고 선을 그은 지 두 달.": "信用の問題で、もう我慢しないと一線を引いて",
            "무언가를 포기하고 다은을 선택한 지 두 달.": "何かを諦めて、ダウンを選んで",
            "다은과 곁을 지켜주기로 한 지 두 달.": "ダウンと互いのそばにいると約束して",
            "다은과 끝난 지 두 달.": "ダウンとの関係が終わって",
            "다은을 보내준 지 두 달.": "ダウンを送り出して",
            "다은과 함께하기로 한 지 두 달.": "ダウンと一緒に歩むと決めて",
            "명확하지 않은 경계를 넘어선 지 두 달.": "曖昧な境界を越えて",
            "다들 한다는 분위기에 휩쓸려 투자한 지 두 달.": "みんながやっているという空気に流されて投資して",
            "프리랜서로 독립한 지 두 달.": "フリーランスとして独立して",
            "실력과 성과로 승진한 지 두 달.": "実力と成果で昇進して",
            "자격증을 취득한 지 세 달.": "資格を取得して",
            "재혁에게 이용당했다는 걸 알게 된 지 두 달.": "ジェヒョクに利用されたと知って",
            "재혁과 파트너십을 맺은 지 두 달.": "ジェヒョクとパートナーシップを結んで",
            "재혁의 제안을 거절한 지 두 달.": "ジェヒョクの提案を断って",
            "재혁에게 사기당했다는 게 확정된 지 두 달.": "ジェヒョクにだまされたことが確定して",
            "재혁에게 직접 맞선 지 두 달.": "ジェヒョクに直接立ち向かって",
            "재혁을 완전히 믿고 모든 것을 공유한 지 두 달.": "ジェヒョクを完全に信じ、すべてを共有して",
            "지연이 강남에서 먼저 연락해온 지 두 달.": "ジヨンがカンナムから先に連絡してきて",
            "지연과 함께하기로 한 지 두 달.": "ジヨンと一緒に歩むと決めて",
            "돈을 주고 내부 정보를 산 지 두 달.": "お金を払って内部情報を買って",
            "의심스러운 내부 정보를 신고한 지 두 달.": "不審な内部情報を通報して",
            "정체불명의 USB를 열어본 지 두 달.": "正体不明のUSBの中身を開いて",
            "엘리트 트랙을 선택한 지 세 달.": "エリートのトラックを選んで",
            "퀀트 투자 전문화 트랙을 선택한 지 세 달.": "クオンツ投資の専門化トラックを選んで",
            "인맥 상승 트랙을 선택한 지 세 달.": "人脈で上を目指すトラックを選んで",
            "사회적 기업가 트랙을 선택한 지 세 달.": "社会起業家のトラックを選んで",
            "투기 트랙을 선택한 지 세 달.": "投機のトラックを選んで",
            "테크 창업 트랙을 선택한 지 세 달.": "テック起業のトラックを選んで",
            "아무 연관 없는 낯선 사람을 도운 지 두 달.": "何のつながりもない、見知らぬ人を助けて",
            "반찬가게 알바에서 얻은 정보로 취업 기회를 잡은 지 두 달.": "おかず屋のアルバイトで得た情報から、就職の機会をつかんで",
            "인테리어 현장 관리를 맡은 지 두 달.": "内装工事の現場管理を任されて",
            "고시원 이웃과 가까워진 지 두 달.": "コシウォンの隣人と親しくなって",
            "마지막 단계에서 공격적인 전략을 선택한 지 두 달.": "最後の段階で攻める戦略を選んで",
            "마지막 단계에서 지키는 전략을 선택한 지 두 달.": "最後の段階で守る戦略を選んで",
            "마지막 단계에서 지나온 길을 돌아보기로 한 지 두 달.": "最後の段階で歩んできた道を振り返ろうと決めて",
            "보증 문제를 타협으로 마무리한 지 두 달.": "保証の問題に妥協で区切りをつけて",
            "정보 관련 사건을 정리하고 넘어간 지 두 달.": "情報にまつわる一件に区切りをつけ、先へ進んで",
            "부모 빚을 전부 갚은 지 두 달.": "親の借金をすべて返して",
            "집안 빚을 대신 갚아주기로 한 지 두 달.": "家の借金を代わりに返すことにして",
            "이력서 거짓말을 덮고 계속 쌓아가기로 한 지 두 달.": "履歴書の嘘を覆い隠し、そのまま積み重ねていくことにして",
            "이력서에 토익 점수를 부풀린 지 두 달.": "履歴書のTOEICの点数を水増しして",
        }
        callback_te_action = callback_te_actions.get(leaf.source.split('\n', 1)[0])
        callback_spans = []
        callback_original_target = target_numbers
        if callback_month:
            native_time_bound = True
            number = {'한': '1', '두': '2', '석': '3', '세': '3'}[callback_month.group('number')]
            native = {'1': '一', '2': '二', '3': '三'}[number]
            opening = target_numbers.split('\n', 1)[0]
            if callback_past_action and not re.fullmatch(
                callback_past_action + r'、?[2二](?:か月|ヶ月|カ月)が過ぎた。$', opening,
            ):
                errors.append('source-bound callback actual setback/win mismatch')
            # These two observed predicates report an accomplished resolution
            # and an actual change in distance. A past plan to do either is
            # not the same elapsed event, even with the correct month value.
            for source_opening, action in (
                ('카페에서의 일로 생긴 죄책감을 해소했던 게 두 달 전이다.',
                 r'罪悪感を解消したのは、?[123一二三](?:か月|ヶ月|カ月)前'),
                ('다은이 거리를 둔 지 두 달.',
                 r'ダウンが距離を置くようになって、?[123一二三](?:か月|ヶ月|カ月)'),
            ):
                if leaf.source.split('\n', 1)[0] == source_opening and not re.search(action, opening):
                    errors.append('source-bound callback accomplished-action mismatch')
            interval = re.search(
                r'(?:のは、?(?P<ago>[123一二三])(?:か月|ヶ月|カ月)前(?:のことだ|だった|だ)。|'
                r'(?:てから|でから|になって|始めて)、?(?P<elapsed>[123一二三])'
                r'(?:か月|ヶ月|カ月)(?:が過ぎた。|。))$', opening,
            )
            if callback_te_action:
                interval = re.fullmatch(re.escape(callback_te_action) +
                    r'(?:から)?、?(?P<elapsed>[123一二三])(?:か月|ヶ月|カ月)(?:が過ぎた。|。)', opening)
            if interval is None:
                errors.append('source-bound callback elapsed-month syntax/unit mismatch')
            else:
                group = 'ago' if interval.groupdict().get('ago') is not None else 'elapsed'
                start, end = interval.span(group)
                if interval.group(group) not in (number, native) or _has_numeric_sign_prefix(opening, start):
                    errors.append('source-bound callback elapsed-month value/sign mismatch')
                callback_spans.append((start, interval.end()))
                target_numbers = target_numbers[:start] + number + target_numbers[end:]
            start, end = callback_month.span('number')
            source_numbers = source_numbers[:start] + number + source_numbers[end:]
        # The source repeats the two-month span when looking back, and other
        # observed leaves use a duration, an earlier comparison or a bare title.
        # Match each complete source and the corresponding line/action before
        # normalizing just that one native count. Keep both app-history spans.
        callback_observed_month = False
        if leaf.source == '느리다고 느꼈다.\n하지만 두 달에 100명—이 속도가 나쁜 게 아니었다.' \
                and target_numbers.split('\n', 1)[0] != '遅いと感じた。':
            errors.append('source-bound follower pace perception/actor mismatch')
        if leaf.source == '도박 앱을 전부 지운 지 두 달.\n처음엔 손이 갔다.\n오늘 두 달을 돌아봤다.' \
                and not re.fullmatch(r'賭博アプリをすべて消してから[2二](?:か月|ヶ月|カ月)。',
                                     target_numbers.split('\n', 1)[0]):
            errors.append('source-bound callback actual app deletion mismatch')
        for source, source_piece, number, line_index, target_pattern in (
            ('도박 앱을 전부 지운 지 두 달.\n처음엔 손이 갔다.\n오늘 두 달을 돌아봤다.',
             '오늘 두 달', '2', 2,
             r'今日、この(?P<number>[2二])(?:か月|ヶ月|カ月)を振り返った。'),
            ('두 달 동안 손대지 않았다.\n지운 것이 장벽이 됐다.',
             '두 달', '2', 0,
             r'(?P<number>[2二])(?:か月|ヶ月|カ月)間、手を出さなかった。'),
            ('아직 멀었다.\n하지만 방향이 생긴 것만으로—세 달 전과 달랐다.',
             '세 달', '3', 1,
             r'それでも方向が定まっただけで――(?P<number>[3三])(?:か月|ヶ月|カ月)前とは違った。'),
            ('느리다고 느꼈다.\n하지만 두 달에 100명—이 속도가 나쁜 게 아니었다.',
             '두 달', '2', 1,
             r'だが、(?P<number>[2二])(?:か月|ヶ月|カ月)で100人――悪いペースではなかった。'),
            ('창업한 지 두 달', '두 달', '2', 0,
             r'起業して(?P<number>[2二])(?:か月|ヶ月|カ月)'),
        ):
            if leaf.source != source:
                continue
            native_time_bound = callback_observed_month = True
            lines = target_numbers.split('\n')
            match = re.fullmatch(target_pattern, lines[line_index]) if len(lines) > line_index else None
            if match is None:
                errors.append('source-bound callback duration/retrospect/title mismatch')
            else:
                offset = sum(len(line) + 1 for line in lines[:line_index])
                start, end = (offset + pos for pos in match.span('number'))
                callback_spans.append((start, offset + match.end()))
                target_numbers = target_numbers[:start] + number + target_numbers[end:]
            native_word = {'2': '두', '3': '세'}[number]
            source_numbers = source_numbers.replace(source_piece,
                source_piece.replace(native_word, number), 1)
        # This recollection has two different horizons: an elapsed two-month
        # decision and today's five-year retrospective. Bind the latter to its
        # complete source and third line, not to a spare numeral elsewhere.
        reflective_source = ('마지막 단계에서 지나온 길을 돌아보기로 한 지 두 달.\n'
                             '숫자보다 의미를 생각했다.\n오늘 5년을 돌아봤다.')
        if leaf.source == reflective_source:
            native_time_bound = True
            lines = target_numbers.split('\n')
            retrospective = re.fullmatch(r'今日、(?P<number>[5五])年を振り返った。',
                                         lines[2]) if len(lines) == 3 else None
            if retrospective is None:
                errors.append('source-bound final retrospective year/action mismatch')
            else:
                offset = sum(len(line) + 1 for line in lines[:2])
                start, end = (offset + pos for pos in retrospective.span('number'))
                callback_spans.append((start, offset + retrospective.end()))
                target_numbers = target_numbers[:start] + '5' + target_numbers[end:]
        # The one-hour conversation is already completed; it is not a plan,
        # a clock time, or an added hour attached to another paragraph.
        conversation_source = '한 시간을 이야기했다.\n오래 말씀하시게 된 게 — 관계가 달라졌다는 뜻이었다.'
        if leaf.source == conversation_source:
            native_time_bound = True
            conversation = re.match(r'(?:1|一)時間、話した。(?=\n)', target_numbers)
            if conversation is None:
                errors.append('source-bound completed conversation hour mismatch')
            else:
                callback_spans.append((0, conversation.end()))
                target_numbers = '1' + target_numbers[1:]
            source_numbers = '1' + source_numbers[1:]
        if callback_month or callback_observed_month or leaf.source == conversation_source:
            # Scan the pre-time-normalization text, including earlier money
            # normalization; the one-character time substitutions keep offsets.
            # A spelled-out extra quantity must not bypass the Arabic stream.
            for quantity in re.finditer(
                r'[+\-−]?[0-9０-９零一二三四五六七八九十百千万萬億兆]+\s*'
                r'(?:か月|ヶ月|カ月|年|月|週間|週|日|時間|時|分|秒)', callback_original_target,
            ):
                if not any(start <= quantity.start() and quantity.end() <= end
                           for start, end in callback_spans):
                    errors.append('source-bound callback added/displaced time mismatch')
        # This final-sprint opening has less than one year before age 38.
        # Bind the complete sentence (including its limit), then admit 一年;
        # a different age, interval, sign or paragraph cannot supply the count.
        sprint_source = '38세까지 1년이 채 남지 않았다.'
        if source_numbers.startswith(sprint_source):
            sprint_target = re.match(r'38歳まで、もう(?:一|1)年もない。', target_numbers)
            if sprint_target is None:
                errors.append('source-bound final-sprint age/remaining-year mismatch')
            else:
                for interval in re.finditer(
                    r'[+\-−]?[0-9一二三四五六七八九十百千]+\s*(?:歳|年|か月|ヶ月|週間|日|時間|秒)',
                    target_numbers,
                ):
                    if interval.end() > sprint_target.end():
                        errors.append('source-bound final-sprint added age/interval mismatch')
                target_numbers = sprint_target.group().replace('一年', '1年') + target_numbers[sprint_target.end():]
        # A chaebol heir is second-generation, not a two-year-old. Bind the
        # observed complete title before admitting the native Japanese number.
        if leaf.source == '재벌 2세와의 접촉':
            if not re.fullmatch(r'財閥(?:二|2)世との接触', text):
                errors.append('source-bound chaebol generation mismatch')
            else:
                target_numbers = target_numbers.replace('二世', '2世')
        if leaf.source == '재벌 3세의 연락':
            if not re.fullmatch(r'財閥(?:三|3)世からの連絡', text):
                errors.append('source-bound chaebol third-generation mismatch')
            else:
                target_numbers = target_numbers.replace('三世', '3世')
        # In the media scene 2030 labels young adults twice, not the year 2030.
        # Normalize only source-bound age-group spans; another number cannot
        # supply a missing group and neither occurrence may become a year.
        source_youth = list(re.finditer(r'(?<![\d가-힣])2030(?=\s+(?:청년|공감))', source_numbers))
        if leaf.group == 'events' and source_youth:
            target_youth = list(re.finditer(r'20[・、/]\s*30代(?=の(?:若者|共感))', target_numbers))
            if len(source_youth) != len(target_youth) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                for match in target_youth
            ):
                errors.append('source-bound young-adult group mismatch')
            if [source_numbers.count('\n', 0, match.start()) for match in source_youth] != \
                    [target_numbers.count('\n', 0, match.start()) for match in target_youth]:
                errors.append('source-bound young-adult paragraph ownership mismatch')
            for source_group, target_group in zip(source_youth, target_youth):
                if source_numbers[source_group.end():].startswith(' 공감'):
                    titles = list(re.finditer(r'「(?P<age>20[・、/]\s*30代)の共感を呼ぶコンテンツとして話題」', target_numbers))
                    if len(titles) != 1 or titles[0].start('age') != target_group.start():
                        errors.append('source-bound young-adult news-title ownership mismatch')
            for age in re.finditer(r'[0-9一二三四五六七八九十百千]+\s*(?:代|歳)', target_numbers):
                if not any(group.start() <= age.start() and age.end() <= group.end() for group in target_youth):
                    errors.append('source-bound added young-adult age mismatch')
            for match in reversed(source_youth):
                source_numbers = source_numbers[:match.start()] + '20 30' + source_numbers[match.end():]
        if leaf.group == "catalog":
            if leaf.source in CATALOG_YOUNG_ADULT_SOURCES:
                age_groups = list(re.finditer(r"(?<![0-9一二三四五六七八九十百千])20[・、/](?:\s*)30代(?!\d)", text))
                if len(age_groups) != 1:
                    errors.append("catalog age-group grammar mismatch")
                for age in re.finditer(r"[0-9一二三四五六七八九十百千]+\s*(?:代|歳)", text):
                    if not any(group.start() <= age.start() and age.end() <= group.end() for group in age_groups):
                        errors.append("catalog added age mismatch")
                source_numbers = source_numbers.replace("2030", "20 30")
                remainder = text
                for group in reversed(age_groups):
                    remainder = remainder[:group.start()] + " " * (group.end() - group.start()) + remainder[group.end():]
                if re.search(r"[二三四五六七八九十百千萬万億兆]", remainder):
                    errors.append("catalog added native number mismatch")
            for source, before, after in (
                ("2차전지주", "二次電池", "2次電池"),
                ("1인 가구", "一人暮らし", "1人暮らし"),
                ("2차 창업자 네트워크", "二度目", "2度目"),
            ):
                if leaf.source == source:
                    allowed = list(re.finditer(re.escape(before) + "|" + re.escape(after), target_numbers))
                    if len(allowed) != 1:
                        errors.append("catalog numeric expression count mismatch")
                    for value in allowed:
                        if re.search(r"[0-9一二三四五六七八九十百千萬万億兆]\s*$", target_numbers[:value.start()]):
                            errors.append("catalog native numeric prefix mismatch")
                    remainder = target_numbers
                    for value in reversed(allowed):
                        remainder = remainder[:value.start()] + " " * (value.end() - value.start()) + remainder[value.end():]
                    if re.search(r"[二三四五六七八九十百千萬万億兆]", remainder):
                        errors.append("catalog added native number mismatch")
                    target_numbers = re.sub(r"(?<![0-9一二三四五六七八九十百千萬万億兆])" + re.escape(before), after, target_numbers)
        # The apology loses five thousand subscribers, not fifty million won.
        # Bind the count to its subject and loss verb before expanding digits.
        source_lost_subscribers = list(re.finditer(r'(?<=구독자 )5천 명(?=이 빠졌지만)', source_numbers))
        if source_lost_subscribers:
            target_lost_subscribers = list(re.finditer(r'(?<=登録者は)5,?000人(?=減ったが)', target_numbers))
            for count in re.finditer(r'[+\-−]?[0-9,零一二三四五六七八九十百千万萬億兆]+\s*(?:人|名|ウォン|円)', target_numbers):
                if not any(group.start() <= count.start() and count.end() <= group.end() for group in target_lost_subscribers):
                    errors.append('source-bound lost-subscriber added count/owner mismatch')
            if len(source_lost_subscribers) != len(target_lost_subscribers) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                for match in target_lost_subscribers
            ) or [source_numbers.count('\n', 0, match.start()) for match in source_lost_subscribers] != \
                    [target_numbers.count('\n', 0, match.start()) for match in target_lost_subscribers]:
                errors.append('source-bound lost-subscriber count/unit mismatch')
            for value, matches, is_source in (
                (source_numbers, source_lost_subscribers, True),
                (target_numbers, target_lost_subscribers, False),
            ):
                for match in reversed(matches):
                    value = value[:match.start()] + '5000' + value[match.end():]
                if is_source:
                    source_numbers = value
                else:
                    target_numbers = value
        if sorted(numeric.findall(source_numbers)) != sorted(numeric.findall(target_numbers)):
            errors.append("explicit numeric value/sign mismatch")
        if mixed_source and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("mixed Korean-won ordered numeric ownership mismatch")
        if investment_life is not None and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("source-bound investment/life ordered numeric ownership mismatch")
        if market_admin is not None and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("source-bound market/admin ordered numeric ownership mismatch")
        if korean_culture is not None and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("source-bound Korean-life ordered numeric ownership mismatch")
        if leisure_gambling is not None and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("source-bound leisure/race ordered numeric ownership mismatch")
        if cafe_encounter is not None and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("source-bound cafe/encounter ordered numeric ownership mismatch")
        if amb_tradeoff is not None and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("source-bound amb tradeoff ordered numeric ownership mismatch")
        if callback_shadow is not None and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("source-bound callback/shadow ordered numeric ownership mismatch")
        if native_time_bound and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("native time ordered numeric ownership mismatch")
    else:
        from zh_translation_audit import validate_text
        errors = validate_text(locale, leaf.id, leaf.source, text)
        if leaf.format_template:
            errors.extend(ja.ui_placeholder_errors(leaf.source, text))
    # StoryMode replaces each indexed slot exactly once, in source order, then
    # rejects any leftover c5read prefix. Generic printf/BBCode audits do not
    # recognize this runtime-owned syntax.
    source_slots = CHAPTER5_INLINE_SLOT.findall(leaf.source)
    target_slots = CHAPTER5_INLINE_SLOT.findall(text)
    if source_slots != target_slots or leaf.source.count("[[c5read:") != len(source_slots) \
            or text.count("[[c5read:") != len(target_slots):
        errors.append("Chapter 5 inline slot token/order/count mismatch")
    if not leaf.format_template:
        source_printf = [t for t in ja.PLACEHOLDER.findall(placeholder_source) if t.startswith("%")]
        target_printf = [t for t in ja.PLACEHOLDER.findall(placeholder_target) if t.startswith("%")]
        if source_printf != target_printf:
            errors.append("printf token order mismatch")
        errors.extend(_sector_percentage_errors(leaf.source, text))
    return sorted(set(errors))


def retained_ending_notes(root: Path, locale: str, inventory: dict[str, Any]) -> dict[str, dict[str, str]]:
    """Keep the first pilot's unused notes byte-bound, outside accepted text."""
    path = root / "content/meta/full_game_localization.json"
    if not path.exists():
        if root.resolve() == ROOT.resolve():
            raise ContractError("retained internal metadata ledger disappeared")
        return {}
    ledger = read_json(path)
    records = ledger.get("retained_internal_metadata")
    if records is None:
        raise ContractError("retained internal metadata is missing")
    if not isinstance(records, dict) or set(records) != set(LOCALES) \
            or ledger.get("retained_internal_metadata_sha256") != digest(records):
        raise ContractError("retained internal metadata locale/checksum mismatch")
    if digest(records) != RETAINED_ENDING_NOTES_SHA256:
        raise ContractError("retained internal metadata historical fingerprint changed")
    for values in records.values():
        if not isinstance(values, dict):
            raise ContractError("retained internal metadata must be leaf receipts")
        for key, receipt in values.items():
            owner = key.split(":")[1] if isinstance(key, str) and key.count(":") == 2 else ""
            source = inventory["endings"].get(owner, {}).get("condition")
            if key != f"endings:{owner}:/condition" or not isinstance(source, str) \
                    or not isinstance(receipt, dict) or set(receipt) != {"source_sha256", "target_sha256"} \
                    or any(not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for v in receipt.values()):
                raise ContractError("retained internal metadata ID/hash shape mismatch")
            note = Leaf("endings", owner, "content/endings.json", ("condition",), source, "internal_metadata")
            if receipt["source_sha256"] != note.source_sha256:
                raise ContractError("retained internal metadata source changed")
    return records[locale]


def targets(root: Path, locale: str, inventory: dict[str, Any]) -> tuple[dict[str, Any], dict[str, str]]:
    """Load target arrays without last-row/last-file wins; reject gameplay keys."""
    documents: dict[str, Any] = {}
    event_files: dict[str, str] = {}
    retained_notes = retained_ending_notes(root, locale, inventory)
    observed_notes: set[str] = set()
    allowed: dict[tuple[str, str], set[tuple[Any, ...]]] = defaultdict(set)
    for leaf in inventory["leaves"]:
        allowed[(leaf.group, leaf.owner)].add(leaf.path)
    paths = sorted((root / f"content/events_{locale}").glob("*.json"))
    paths += [root / f"content/endings_{locale}.json", root / f"locale/catalog_{locale}.json",
              root / f"locale/ui_{locale}.json"]
    for file in paths:
        if not file.exists():
            continue
        relative = file.relative_to(root).as_posix()
        value = read_json(file)
        documents[relative] = value
        if file.parent.name.startswith("events_") or file.name.startswith("endings_"):
            group = "events" if file.parent.name.startswith("events_") else "endings"
            for eid, row in row_index(value, relative).items():
                if (group, eid) not in allowed:
                    raise ContractError(f"{relative}: extra target ID {eid}")
                if group == "events":
                    if eid in event_files:
                        raise ContractError(f"duplicate target event ID across files: {eid}")
                    event_files[eid] = relative
                paths_allowed = allowed[(group, eid)]
                if group == "endings" and "condition" in row:
                    key = f"endings:{eid}:/condition"
                    if key not in retained_notes or retained_notes[key]["target_sha256"] != digest(row["condition"]):
                        raise ContractError("new/changed internal ending note is not a translation")
                    observed_notes.add(key)
                    paths_allowed = paths_allowed | {("condition",)}
                validate_overlay(row, paths_allowed, inventory[group][eid])
        elif not isinstance(value, dict):
            raise ContractError(f"{relative}: expected dictionary")
        elif file.name.startswith("catalog_"):
            all_catalog_paths = {leaf.path for leaf in inventory["leaves"] if leaf.group == "catalog"}
            validate_overlay(value, all_catalog_paths, inventory["catalog"])
        elif any(not isinstance(text, str) or not text.strip() for text in value.values()):
            raise ContractError(f"{relative}: UI values must be nonblank strings")
    if observed_notes != set(retained_notes):
        raise ContractError("retained internal ending note disappeared")
    return documents, event_files


def validate_overlay(row: dict[str, Any], allowed: set[tuple[Any, ...]], source: dict[str, Any]) -> None:
    def walk(value: Any, path: tuple[Any, ...]):
        if path == ("id",):
            return
        if not path or any(p[:len(path)] == path for p in allowed):
            if isinstance(value, dict):
                for key, child in value.items():
                    walk(child, path + (key,))
                return
            if isinstance(value, list):
                source_array = get_at(source, path)
                if not isinstance(source_array, list) or len(value) != len(source_array):
                    raise ContractError("array length drift / incomplete translated array")
                if len(path) == 3 and path[0] in {"chapter5_causal_reads", "chapter5_finale_reads"} \
                        and path[1] == "texts":
                    # StoryMode rejects duplicate alternatives within each read
                    # source row, not repeated copy across unrelated rows.
                    if any(not isinstance(text, str) for text in value) or len(set(value)) != len(value):
                        raise ContractError("Chapter 5 reader alternatives must be distinct strings per row")
                for index, child in enumerate(value):
                    walk(child, path + (index,))
                return
            if path in allowed and isinstance(value, str) and value.strip():
                if len(path) == 4 and path[:2] == ("chapter5_finale_reads", "texts") \
                        and "[[c5read:" in value:
                    raise ContractError("Chapter 5 finale reader text cannot introduce an inline slot")
                return
        raise ContractError(f"overlay gameplay/extra/blank/shape field: {pointer(path)}")
    walk(row, ())


def target_location(leaf: Leaf, locale: str, event_files: dict[str, str]) -> tuple[str, tuple[Any, ...]]:
    if leaf.group == "events":
        relative = event_files.get(leaf.owner, f"content/events_{locale}/{Path(leaf.source_path).name}")
    elif leaf.group == "endings":
        relative = f"content/endings_{locale}.json"
    elif leaf.group == "catalog":
        relative = f"locale/catalog_{locale}.json"
    else:
        relative = f"locale/ui_{locale}.json"
    return relative, leaf.path


def target_value(leaf: Leaf, documents: dict[str, Any], locale: str, event_files: dict[str, str]) -> Any:
    relative, path = target_location(leaf, locale, event_files)
    value = documents.get(relative)
    if leaf.group in {"events", "endings"}:
        value = next((r for r in value or [] if r.get("id") == leaf.owner), None)
    return get_at(value, path)


def committed_receipts(root: Path, inventory: dict[str, Any], locale: str) -> dict[str, list[dict[str, str]]]:
    """Portable machine acceptance evidence, never a native-review verdict."""
    path = root / "content/meta/full_game_localization.json"
    if not path.exists():
        return {}
    ledger = read_json(path)
    if not isinstance(ledger, dict) or ledger.get("schema_version") != SCHEMA_VERSION \
            or ledger.get("prompt_version") != PROMPT_VERSION or ledger.get("native_review") != "OPEN":
        raise ContractError("committed localization ledger schema/prompt/native-review mismatch")
    accepted = ledger.get("accepted")
    if not isinstance(accepted, dict) or set(accepted) != set(LOCALES) \
            or ledger.get("accepted_sha256") != digest(accepted):
        raise ContractError("committed localization ledger locale/checksum mismatch")
    leaves = {leaf.id: leaf for leaf in inventory["leaves"]}
    for accepted_locale, values in accepted.items():
        if not isinstance(values, dict):
            raise ContractError("committed localization ledger locale must contain leaf receipts")
        for leaf_id, receipt in values.items():
            if leaf_id not in leaves or leaves[leaf_id].runtime_support != "builtin_overlay_static_only":
                raise ContractError(f"committed localization ledger unknown/unsupported leaf: {leaf_id}")
            if not isinstance(receipt, dict) or set(receipt) != {"source_sha256", "target_sha256"} \
                    or any(not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for v in receipt.values()):
                raise ContractError(f"committed localization ledger malformed hash: {accepted_locale}:{leaf_id}")
    return {leaf_id: [receipt] for leaf_id, receipt in accepted[locale].items()}


def status(root: Path, inventory: dict[str, Any], locale: str) -> dict[str, Any]:
    documents, event_files = targets(root, locale, inventory)
    groups: dict[str, Counter] = defaultdict(Counter)
    invalid = []
    receipts: dict[str, list[dict[str, str]]] = defaultdict(list, committed_receipts(root, inventory, locale))
    for path in sorted(private_dir(root, locale).glob("*.accepted.json")):
        receipt = read_json(path)
        if not isinstance(receipt, dict) or not isinstance(receipt.get("batch"), dict) \
                or not isinstance(receipt.get("translations"), dict):
            raise ContractError("corrupt accepted receipt")
        if receipt.get("receipt_sha256") != digest({k: v for k, v in receipt.items() if k != "receipt_sha256"}):
            raise ContractError("accepted receipt checksum drift")
        header = receipt.get("batch", {})
        if header.get("locale") != locale or header.get("prompt_version") != PROMPT_VERSION:
            raise ContractError("accepted receipt locale/prompt mismatch")
        for key, value in receipt.get("translations", {}).items():
            if not isinstance(value, dict) or set(value) != {"source_sha256", "target_sha256"} \
                    or any(not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for v in value.values()):
                raise ContractError("corrupt accepted leaf receipt")
            receipts[key].append(value)
    for leaf in inventory["leaves"]:
        counts = groups[leaf.category]
        counts["source"] += 1
        text = target_value(leaf, documents, locale, event_files)
        if text is None:
            counts["missing"] += 1
        else:
            counts["present"] += 1
            errors = translation_errors(leaf, locale, text)
            if errors:
                counts["invalid"] += 1
                invalid.append({"id": leaf.id, "errors": errors})
            else:
                counts["machine_valid"] += 1
                if any(r.get("source_sha256") == leaf.source_sha256 and
                       r.get("target_sha256") == digest(text) for r in receipts.get(leaf.id, [])):
                    counts["receipted_current_source"] += 1
                elif leaf.id in receipts:
                    counts["stale_receipt"] += 1
    return {"locale": locale, "status": "INCOMPLETE", "native_review": "OPEN",
            "groups": {key: dict(value) for key, value in groups.items()}, "invalid": invalid,
            "note": "Existing target presence does not prove source freshness or native acceptance."}


def make_batch(inventory: dict[str, Any], locale: str, selected: list[Leaf], revision: str,
               documents: dict[str, Any], event_files: dict[str, str]) -> list[dict[str, Any]]:
    if not selected or len({leaf.id for leaf in selected}) != len(selected):
        raise ContractError("empty/duplicate selection")
    rows = []
    for leaf in selected:
        value = asdict(leaf)
        value.update({"id": leaf.id, "source_sha256": leaf.source_sha256, "locale": locale,
                      "prompt_version": PROMPT_VERSION,
                      "target_path": target_location(leaf, locale, event_files)[0],
                      "previous_target_sha256": digest(target_value(leaf, documents, locale, event_files))})
        value["path"] = list(leaf.path)
        rows.append(value)
    header = {"kind": "full_game_localization_batch", "schema_version": SCHEMA_VERSION,
              "locale": locale, "source_revision": revision, "prompt_version": PROMPT_VERSION,
              "source_manifest_sha256": inventory["source_manifest_sha256"],
              "selection_sha256": digest(rows), "count": len(rows), "source_language": "ko",
              "native_review": "OPEN"}
    header["batch_id"] = digest(header)
    return [header, *rows]


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows = [loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    if not rows or any(not isinstance(row, dict) for row in rows):
        raise ContractError("JSONL requires object rows and a manifest")
    return rows


def check_batch(inventory: dict[str, Any], batch: list[dict[str, Any]], response: list[dict[str, Any]]) -> dict[str, str]:
    if not batch or not response:
        raise ContractError("empty batch/response")
    header, rows = batch[0], batch[1:]
    if set(header) != {"kind", "schema_version", "locale", "source_revision", "prompt_version",
                       "source_manifest_sha256", "selection_sha256", "count", "source_language",
                       "native_review", "batch_id"} or header.get("kind") != "full_game_localization_batch":
        raise ContractError("invalid manifest shape")
    if not re.fullmatch(r"[0-9a-f]{40}", str(header.get("source_revision", ""))):
        raise ContractError("source revision must be exact Git commit")
    if header != response[0]:
        raise ContractError("response manifest differs from batch")
    unsigned = {k: v for k, v in header.items() if k != "batch_id"}
    if header.get("batch_id") != digest(unsigned) or header.get("selection_sha256") != digest(rows):
        raise ContractError("batch manifest or selection checksum drift")
    if header.get("schema_version") != SCHEMA_VERSION or header.get("prompt_version") != PROMPT_VERSION:
        raise ContractError("stale schema/prompt version")
    if header.get("source_language") != "ko" or header.get("locale") not in LOCALES \
            or header.get("native_review") != "OPEN":
        raise ContractError("wrong source/target locale")
    if header.get("source_manifest_sha256") != inventory["source_manifest_sha256"]:
        raise ContractError("stale source manifest")
    current = {leaf.id: leaf for leaf in inventory["leaves"]}
    ids = [row.get("id") for row in rows]
    if any(not isinstance(identifier, str) for identifier in ids) \
            or len(set(ids)) != len(ids) or header.get("count") != len(rows) or not rows:
        raise ContractError("empty/duplicate/miscounted source batch")
    result = {}
    for row in rows:
        leaf = current.get(row.get("id"))
        if leaf is None or row.get("source_sha256") != leaf.source_sha256:
            raise ContractError("unknown/stale source leaf")
        if set(row) != set(asdict(leaf)) | {"id", "source_sha256", "locale", "prompt_version",
                                          "target_path", "previous_target_sha256"}:
            raise ContractError("source row has extra/gameplay or missing fields")
        for key, value in asdict(leaf).items():
            if key == "path":
                value = list(value)
            if row.get(key) != value:
                raise ContractError(f"source metadata drift: {leaf.id}:{key}")
        if row.get("locale") != header["locale"] or row.get("prompt_version") != PROMPT_VERSION:
            raise ContractError("mixed locale/prompt in source batch")
    for row in response[1:]:
        if set(row) != {"id", "locale", "source_sha256", "prompt_version", "text"}:
            raise ContractError("response has extra/gameplay or missing fields")
        identifier = row["id"]
        if not isinstance(identifier, str) or identifier not in ids or identifier in result:
            raise ContractError("extra/duplicate response ID")
        leaf = current[identifier]
        if (row["locale"], row["source_sha256"], row["prompt_version"]) != (
                header["locale"], leaf.source_sha256, PROMPT_VERSION):
            raise ContractError("response locale/source/prompt binding drift")
        errors = translation_errors(leaf, header["locale"], row["text"])
        if errors:
            raise ContractError(f"{identifier}: " + "; ".join(errors))
        result[identifier] = row["text"]
    if set(result) != set(ids):
        raise ContractError("missing response IDs")
    return result


def merge_selected(inventory: dict[str, Any], batch: list[dict[str, Any]], translations: dict[str, str],
                   documents: dict[str, Any], event_files: dict[str, str], replace_existing: bool = False) -> dict[str, Any]:
    locale = batch[0]["locale"]
    leaves = {leaf.id: leaf for leaf in inventory["leaves"]}
    modified = {}
    allowed: dict[tuple[str, str], set[tuple[Any, ...]]] = defaultdict(set)
    for leaf in leaves.values():
        allowed[(leaf.group, leaf.owner)].add(leaf.path)
    for row in batch[1:]:
        leaf = leaves[row["id"]]
        if leaf.group == "endings" and leaf.path == ("condition",):
            raise ContractError("internal ending metadata cannot be imported as translation")
        if leaf.runtime_support != "builtin_overlay_static_only":
            raise ContractError(f"unsupported runtime/validator contract cannot be accepted: {leaf.runtime_support}")
        before = target_value(leaf, documents, locale, event_files)
        if digest(before) != row["previous_target_sha256"]:
            raise ContractError("target changed since export")
        text = translations[leaf.id]
        if leaf.protected and before != text:
            raise ContractError("public-demo translation is protected")
        if before is not None and before != text and not replace_existing:
            raise ContractError("existing target requires explicit --replace-existing")
        relative, path = target_location(leaf, locale, event_files)
        if row["target_path"] != relative:
            raise ContractError("target path drift")
        if before == text:
            continue
        if relative not in modified:
            modified[relative] = copy.deepcopy(documents.get(relative, [] if leaf.group in {"events", "endings"} else {}))
        target = modified[relative]
        if leaf.group in {"events", "endings"}:
            target_row = next((r for r in target if r["id"] == leaf.owner), None)
            if target_row is None:
                target_row = {"id": leaf.owner}
                target.append(target_row)
            target = target_row
            if path[0] == "choices" and "choices" not in target:
                target["choices"] = [{} for _ in inventory["events"][leaf.owner].get("choices", [])]
        set_at(target, path, text)
    # Validate every changed container after the whole batch, not per leaf.
    # None holes reject partially translated arrays (tags / reader texts).
    for relative, value in modified.items():
        if isinstance(value, list):
            group = "events" if "/events_" in relative else "endings"
            for eid, row in row_index(value, relative).items():
                paths_allowed = allowed[(group, eid)]
                if group == "endings" and "condition" in row:
                    # targets() already verified the historical receipt. A text
                    # merge may preserve this old note, never add or change it.
                    previous = next((r for r in documents.get(relative, []) if r.get("id") == eid), {})
                    if "condition" not in previous or previous["condition"] != row["condition"]:
                        raise ContractError("internal ending metadata changed during merge")
                    paths_allowed = paths_allowed | {("condition",)}
                validate_overlay(row, paths_allowed, inventory[group][eid])
        else:
            if "/catalog_" in relative:
                catalog_paths = {l.path for l in leaves.values() if l.group == "catalog"}
                validate_overlay(value, catalog_paths, inventory["catalog"])
            elif any(not isinstance(text, str) or not text.strip() for text in value.values()):
                raise ContractError("UI values must be nonblank strings")
    return modified


def atomic_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent,
                                     prefix=".localization-", delete=False) as stream:
        temporary = Path(stream.name)
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write("\n")
    os.replace(temporary, path)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("inventory", "export", "check", "import"))
    parser.add_argument("--locale", choices=LOCALES, default="ja")
    parser.add_argument("--group", choices=GROUPS)
    parser.add_argument("--ids", help="comma-separated source root IDs; UI uses the exact Korean key")
    parser.add_argument("--leaf-ids", help="JSON array file of exact collected leaf IDs")
    parser.add_argument("--limit", type=int, default=80)
    parser.add_argument("--batch", type=Path)
    parser.add_argument("--response", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--accept", action="store_true")
    parser.add_argument("--replace-existing", action="store_true")
    parser.add_argument("--include-leaves", action="store_true")
    args = parser.parse_args(argv)
    try:
        inventory = collect()
        if args.command == "inventory":
            output = {"schema_version": SCHEMA_VERSION, "prompt_version": PROMPT_VERSION,
                      "source_counts": inventory["source_counts"],
                      "source_leaf_categories": dict(Counter(l.category for l in inventory["leaves"])),
                      "source_lifecycle_leaves": dict(Counter(l.lifecycle for l in inventory["leaves"])),
                      "source_manifest_sha256": inventory["source_manifest_sha256"],
                      "internal_ending_notes": inventory["internal_ending_notes"],
                      "unsupported": inventory["unsupported"],
                      "unsupported_relationship_display_names": {
                          "occurrences": sum(u["kind"] == "unsupported_relationship_display_name" for u in inventory["unsupported"]),
                          "unique_korean": len({u["ko"] for u in inventory["unsupported"] if u["kind"] == "unsupported_relationship_display_name"}),
                          "scope": "Outside leaf denominator; needs a locale resolver, not gameplay overlay translation."},
                      "target": status(ROOT, inventory, args.locale),
                      "full_game_status": "INCOMPLETE", "human_gate": "OPEN",
                      "coverage_boundary": "Global pair candidates are source-discovered, not proven runtime exposure; unresolved consumers stay unsupported.",
                      "numeric_boundary": "Japanese explicit-digit checks are conservative; written numbers and implicit units need source review and may be reported as unresolved invalid rows."}
            if args.include_leaves:
                output["leaves"] = [{**asdict(l), "id": l.id, "source_sha256": l.source_sha256} for l in inventory["leaves"]]
            if args.output:
                atomic_json(args.output, output)
            else:
                print(json.dumps(output, ensure_ascii=False, indent=2))
            return 0
        documents, event_files = targets(ROOT, args.locale, inventory)
        if args.command == "export":
            if not args.group or not (args.ids or args.leaf_ids):
                raise ContractError("bounded export requires --group and --ids/--leaf-ids")
            ids = set(args.ids.split(",")) if args.ids else set()
            exact = set(read_json(Path(args.leaf_ids))) if args.leaf_ids else set()
            selected = [l for l in inventory["leaves"] if l.group == args.group and (l.owner in ids or l.id in exact)]
            if ids - {l.owner for l in selected} or exact - {l.id for l in selected}:
                raise ContractError("selection contains unknown IDs")
            if args.limit < 1 or len(selected) > args.limit:
                raise ContractError(f"selection has {len(selected)} leaves, limit={args.limit}")
            revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
            batch = make_batch(inventory, args.locale, selected, revision, documents, event_files)
            out = args.output or private_dir(ROOT, args.locale) / (batch[0]["batch_id"] + ".source.jsonl")
            if out.exists():
                raise ContractError("export output already exists; preserve the previous batch")
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text("".join(json.dumps(row, ensure_ascii=False) + "\n" for row in batch), encoding="utf-8")
            print(f"FULL_LOCALIZATION_BATCH_EXPORTED locale={args.locale} leaves={len(selected)} path={out} full_status=INCOMPLETE")
            return 0
        if not args.batch or not args.response:
            raise ContractError("check/import requires --batch and --response")
        batch, response = read_jsonl(args.batch), read_jsonl(args.response)
        if batch[0].get("locale") != args.locale:
            raise ContractError("CLI locale differs from batch")
        accepted = check_batch(inventory, batch, response)
        modified = merge_selected(inventory, batch, accepted, documents, event_files, args.replace_existing)
        if args.command == "import":
            if not args.accept:
                raise ContractError("import requires explicit --accept after Korean-source review")
            for relative in modified:
                path = _safe_path(ROOT, relative)
                current = read_json(path) if path.exists() else None
                if current != documents.get(relative):
                    raise ContractError("target file changed during validation")
            for relative, value in modified.items():
                atomic_json(_safe_path(ROOT, relative), value)
            receipt = {"batch": batch[0], "state": "accepted_machine_validated", "native_review": "OPEN",
                       "translations": {key: {"source_sha256": next(l.source_sha256 for l in inventory["leaves"] if l.id == key),
                                              "target_sha256": digest(text)} for key, text in accepted.items()}}
            receipt["receipt_sha256"] = digest(receipt)
            atomic_json(private_dir(ROOT, args.locale) / (batch[0]["batch_id"] + ".accepted.json"), receipt)
        print(f"FULL_LOCALIZATION_BATCH_VALID locale={args.locale} leaves={len(accepted)} changed_files={len(modified)} action={args.command} full_status=INCOMPLETE human_gate=OPEN")
        return 0
    except (ContractError, OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"FULL_LOCALIZATION_FAIL {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
