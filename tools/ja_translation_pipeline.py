#!/usr/bin/env python3
"""Generate the Japanese beta overlays directly from the Korean source canon.

The generator talks to a local Ollama model, validates every returned string, and
stores a source-hash cache under .git so interrupted runs can resume without
checking generated model state into the repository. Runtime overlays remain
text-only; gameplay data is never copied into a locale file.
"""

from __future__ import annotations

import argparse
import bisect
import hashlib
import json
import os
import pathlib
import re
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any, Iterable, Optional


ROOT = pathlib.Path(__file__).resolve().parents[1]


def git_private_path(filename: str) -> pathlib.Path:
    marker = ROOT / ".git"
    if marker.is_dir():
        return marker / filename
    if marker.is_file():
        line = marker.read_text(encoding="utf-8").strip()
        if line.startswith("gitdir:"):
            git_dir = pathlib.Path(line.split(":", 1)[1].strip())
            if not git_dir.is_absolute():
                git_dir = (ROOT / git_dir).resolve()
            return git_dir / filename
    return marker / filename


CACHE_PATH = git_private_path("codex-ja-translation-cache.json")
OLLAMA_URL = "http://127.0.0.1:11434/api/chat"
DEFAULT_MODEL = "qwen3.6:35b-a3b-mxfp8"
PROMPT_VERSION = "ja-demo-scope-2026-08-04.1"
REVIEW_VERSION = "ja-source-proof-2026-08-04.1"
EVENT_TEXT_FIELDS = (
    "title",
    "description",
    "description_orthodox",
    "description_unorthodox",
    "description_low_mental",
    "description_long_gosiwon",
)
EVENT_DICT_FIELDS = (
    "description_if_known",
    "description_memory_if_known",
    "description_if_moral",
)
CHOICE_TEXT_FIELDS = ("text", "result_text", "bridge_summary")
CHOICE_DICT_FIELDS = ("text_if_moral",)
ENDING_TEXT_FIELDS = (
    "title",
    "subtitle",
    "description",
    "detailed_description",
    "epilogue",
    "condition",
)
ENDING_DICT_FIELDS = ("description_if_known",)

CATALOG_SOURCES = {
    "assets": ("content/assets.json", ("name", "description", "tags")),
    "jobs": ("content/jobs.json", ("name", "description")),
    "items": ("content/items.json", ("name", "description")),
    "achievements": (
        "content/meta/achievements.json",
        ("name", "description", "hint"),
    ),
    "clues": ("content/meta/clues.json", ("title", "text")),
    "thoughts": (
        "content/meta/thoughts.json",
        ("title", "description", "conclusion"),
    ),
    "news": ("content/news_templates.json", ("headline", "topics")),
}

RUNTIME_DIRS = ("autoloads", "scenes", "systems", "ui_components")
UI_PAIR = re.compile(
    r'(?:\b_tr|LocaleManager\.ui)\(\s*'
    r'("(?:\\.|[^"\\])*")\s*,\s*'
    r'("(?:\\.|[^"\\])*")',
    re.DOTALL,
)
UI_CONTEXT_PAIR = re.compile(
    r'LocaleManager\.ui_context\s*\(\s*'
    r'("(?:\\.|[^"\\])*")\s*,\s*'
    r'("(?:\\.|[^"\\])*")\s*,\s*'
    r'("(?:\\.|[^"\\])*")',
    re.DOTALL,
)
RAW_UI_CONTEXT_CALL = re.compile(r"LocaleManager\.ui_context\s*\(")
GD_FUNCTION = re.compile(
    r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z0-9_]+)\s*\("
)
UI_CONTEXT_ID = re.compile(r"^ui\.[a-z0-9]+(?:[._][a-z0-9]+)*$")
UI_CONTEXT_MANIFEST_PATH = ROOT / "content/meta/demo_localization_scope.json"
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")
JAPANESE = re.compile(r"[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff]")
PLACEHOLDER = re.compile(
    r"\{[^{}]+\}|%(?:\d+\$)?[-+#0 .\d]*[a-zA-Z]|"
    r"\[/?(?:b|i|u|s|center|right|fill|color(?:=[^\]]+)?|font(?:=[^\]]+)?|"
    r"font_size(?:=[^\]]+)?|url(?:=[^\]]+)?|img(?:=[^\]]+)?)]"
)
YEN_AMOUNT = re.compile(r"(?:\d|万|億)\s*円|[¥￥]")
BAD_TERMS = ("ダエン", "ジヨンヌ", "お兄さん", "ヴィラ", "カンナムド")
EXACT_TRANSLATIONS = {
    "GANGNAM DREAM": "GANGNAM DREAM",
    "강남드림": "カンナム・ドリーム",
    "강남": "カンナム",
    "김민준": "キム・ミンジュン",
    "민준": "ミンジュン",
    "김다은": "キム・ダウン",
    "다은": "ダウン",
    "한지연": "ハン・ジヨン",
    "지연": "ジヨン",
    "임상철": "イム・サンチョル",
    "상철": "サンチョル",
    "최재혁": "チェ・ジェヒョク",
    "재혁": "ジェヒョク",
    "강현수": "カン・ヒョンス",
    "현수": "ヒョンス",
    "박성준": "パク・ソンジュン",
    "성준": "ソンジュン",
    "한성전자": "ハンソン電子",
    "다온": "ダオン",
    "대현차": "テヒョン自動車",
    "코스피200 ETF": "KOSPI 200 ETF",
    "유튜버": "YouTuber",
    "엔코어": "エンコア",
    "코어코인": "コアコイン",
    "노바코인": "ノヴァコイン",
    "밈코인": "ミームコイン",
    "리츠 ETF": "REIT ETF",
    "저변동": "低ボラティリティ",
    "중변동": "中ボラティリティ",
    "고변동": "高ボラティリティ",
    "극고변동": "超高ボラティリティ",
    "분기배당": "四半期配当",
    "월배당": "毎月配当",
    "무배당": "無配当",
    "SK하이닉스": "SKハイニックス",
    "LG에너지솔루션": "LGエナジーソリューション",
    "포스코": "POSCO",
    "코파일럿": "Copilot",
    "도박장": "カジノ",
    "더위가 기승이다. 땀 흘리는 것도 시간이고, 시간이 곧 돈이었다.": (
        "暑さが猛威を振るっている。汗をかくのも時間の浪費で、時間はそのまま金だった。"
    ),
    "슬롯 꽝 -%s": "スロット：はずれ -%s",
    '"민준씨, 지금 몇 신 줄 알아요? …나야 일이지만." 말은 그렇게 하면서, 다은의 목소리엔 웃음기가 섞여 있었다.': (
        "『ミンジュンさん、今何時だと思ってるんですか？……私は仕事中ですけど』。"
        "そう言いながら、ダウンの声には笑いが混じっていた。"
    ),
    "레버리지 잠금 — 투자감각 30 필요 (현재 %d)": (
        "レバレッジはロック中 — 投資感覚30が必要（現在%d）"
    ),
    "다시 시작한다면, 다은을 처음부터 놓치지 않을 수 있을지 모른다...": (
        "やり直せるなら、今度は最初からダウンを手放さずに済むかもしれない……"
    ),
    "강남은 왔지만, 화면은 닫힌다.": "カンナムにはたどり着いた。だが、画面は閉じる。",
    "최재혁의 방식으로 강남에 입성했다. 거울을 자주 피하게 됐다.": (
        "チェ・ジェヒョクのやり方でカンナムにたどり着いた。鏡を避けることが増えた。"
    ),
    "임상철은 「강남이 뭐라고. 살아 있으면 된 거야」라고 했다. 처음 듣는 부드러운 목소리였다.": (
        "イム・サンチョルは『カンナムが何だっていうんだ。生きてさえいればいい』と"
        "言った。初めて聞く、柔らかな声だった。"
    ),
    "바닥이었을 때 현수에게 전화했다. 그는 그냥 들어줬다. 말 없이 들어주는 사람이 그때 필요했다.": (
        "どん底にいたとき、ヒョンスに電話した。彼はただ聞いてくれた。あのとき必要だった"
        "のは、黙って話を聞いてくれる人だった。"
    ),
    "VIP 인맥 해금. 사회성 3배 상승, 대형 관계 이벤트 접근 가능.": (
        "VIP人脈を解放。社交性が3倍に上昇し、大型の人間関係イベントにアクセス可能。"
    ),
    "딜 시작": "ディール開始",
    "딜 시작  |  베팅 %s": "ディール開始  |  ベット %s",
    "탄력 받은 한 주": "勢いに乗った一週間",
    "3개월 %+.1f%%": "3か月 %+.1f%%",
    "출근길에 본 얼굴이 기억났다. 잔액은 그다음이었다.": (
        "通勤途中に見かけた顔を思い出した。残高のことは、そのあとだった。"
    ),
    "흑자에 자산 성장까지. 좋은 한 달이었습니다.": (
        "黒字で、資産まで増えた。いい1か月でした。"
    ),
    "마포 면접 이후 다음 지원을 이어가세요.": "麻浦での面接後も、次の応募を続けましょう。",
    "카지노가 장기적으로 가져가는 수익 비율. 바카라 뱅커 1.06%, 블랙잭 기본전략 0.5%, 룰렛 2.70%. 오래 할수록 이 비율만큼 잃는 게 수학적 법칙이다.": (
        "カジノ側が長期的に得る利益率。バカラのバンカーは1.06%、ブラックジャックの"
        "基本戦略は0.5%、ルーレットは2.70%。長く遊ぶほど、この割合に近い分だけ失うのが"
        "数学的な法則だ。"
    ),
}

SYSTEM_PROMPT = """You are the senior Japanese localization editor for a Korean
commercial interactive drama. Translate ONLY from the supplied Korean source;
do not use an English intermediate. Write natural contemporary Japanese for
adult players, preserving every concrete fact, image, emotional beat, ambiguity,
and the restrained literary density. Never summarize or embellish.

CANON:
- 강남드림=カンナム・ドリーム, 강남=カンナム, 김민준/민준=キム・ミンジュン/ミンジュン,
  김다은/다은=キム・ダウン/ダウン, 한지연/지연=ハン・ジヨン/ジヨン,
  임상철/상철=イム・サンチョル/サンチョル, 최재혁/재혁=チェ・ジェヒョク/ジェヒョク,
  강현수/현수=カン・ヒョンス/ヒョンス, 박성준/성준=パク・ソンジュン/ソンジュン.
- Daeun always addresses Minjun as ミンジュンさん and keeps polite, warm です・ます speech.
- Jiyeon uses オッパ; before romance she is polite, after confirmed romance she may use natural
  plain speech. Never translate 오빠 as お兄さん.
- Minjun is basically polite to both women. Avoid macho anime speech.
- 고시원=コシウォン (first explanatory exposure may say 韓国の簡易個室型住宅「コシウォン」),
  전세=チョンセ, 빌라=低層集合住宅, 삼각김밥=三角キンパ, 포장마차=ポジャンマチャ,
  남산타워=Nソウルタワー, 정선 카지노=チョンソン・カジノ, 창원=チャンウォン,
  국밥=クッパ, 수신음/통화 연결음=呼び出し音.
- Fictional assets are fixed: 한성전자=ハンソン電子, 다온=ダオン, 대현차=テヒョン自動車,
  엔코어=エンコア, 코어코인=コアコイン, 노바코인=ノヴァコイン, 밈코인=ミームコイン.
  Keep KOSPI, ETF, SAFE, REIT in Latin letters. 변동성=ボラティリティ, not 変動性.
- Money remains Korean won: 원=ウォン, 만원=万ウォン, 억원=億ウォン. Never use yen/円/¥.
- UI labels: 히든=シークレット. Do not create mixed forms such as ヒIDDEN.
- Preserve placeholders and bracket tokens byte-for-byte. Preserve the exact newline count and
  paragraph structure. Do not leave any Hangul.

Return one JSON object only: {"translations":[{"id":"the exact input id","text":"Japanese"}]}.
Return every input id exactly once and no additional ids."""

REVIEW_SYSTEM_PROMPT = SYSTEM_PROMPT + """

This is a SOURCE-ACCURACY PROOFREAD, not a fresh stylistic rewrite. Each row contains
the Korean source and a Japanese draft. Compare them clause by clause. Correct every
wrong agent, proper noun, number, time, place, object, causal relation, and polarity
(especially rise/fall, gain/loss, before/after, acceptance/refusal). Restore omissions
and remove additions. Preserve good Japanese when it is accurate. Return the corrected
Japanese. For this proofread task, ignore the translation output schema above.
Return only rows that actually require correction, as one JSON object:
{"corrections":[{"id":"exact input id","text":"corrected Japanese"}]}.
Omit accurate drafts. Never invent an id."""


@dataclass(frozen=True)
class Entry:
    key: str
    source: str
    context: str
    context_id: str = ""

    @property
    def source_hash(self) -> str:
        payload = f"{PROMPT_VERSION}\0{self.source}"
        if self.context_id:
            payload += f"\0{self.context_id}\0{self.context}"
        return hashlib.sha256(payload.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class UiCall:
    path: str
    function: str
    line: int
    api: str
    korean: str
    english: str
    context_id: str = ""


@dataclass(frozen=True)
class UiInventory:
    calls: tuple[UiCall, ...]
    legacy_entries: tuple[Entry, ...]
    legacy_blueprint: dict[str, Any]
    planned_context_entries: tuple[Entry, ...]
    planned_context_blueprint: dict[str, Any]
    observed_context_entries: tuple[Entry, ...]
    observed_context_blueprint: dict[str, Any]
    errors: tuple[str, ...]
    stats: dict[str, int]

    @property
    def entries(self) -> list[Entry]:
        return [*self.legacy_entries, *self.observed_context_entries]

    @property
    def blueprint(self) -> dict[str, Any]:
        return {**self.legacy_blueprint, **self.observed_context_blueprint}


def read_json(path: pathlib.Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def read_ui_context_contract() -> dict[str, Any]:
    manifest = read_json(UI_CONTEXT_MANIFEST_PATH)
    contract = manifest.get("ui_semantic_context_blocker")
    return contract if isinstance(contract, dict) else {}


def write_json(path: pathlib.Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8") as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    temporary.replace(path)


def decode_gd_string(literal: str) -> str:
    return json.loads(literal)


def string_entry(key: str, value: Any, context: str, entries: list[Entry]) -> None:
    if isinstance(value, str) and value.strip():
        entries.append(Entry(key, value, context))


def collect_events(
    event_ids: Optional[set[str]] = None,
) -> tuple[list[Entry], dict[str, Any]]:
    entries: list[Entry] = []
    blueprint: dict[str, Any] = {}
    for path in sorted((ROOT / "content/events").glob("*.json")):
        rows = read_json(path)
        output_rows: list[dict[str, Any]] = []
        for row in rows:
            event_id = str(row.get("id", ""))
            if event_ids is not None and event_id not in event_ids:
                continue
            overlay: dict[str, Any] = {"id": event_id}
            title = str(row.get("title", event_id))
            context = f"event {event_id} / {title}"
            for field in EVENT_TEXT_FIELDS:
                if isinstance(row.get(field), str) and row[field].strip():
                    key = f"event::{path.name}::{event_id}::{field}"
                    string_entry(key, row[field], f"{context} / {field}", entries)
                    overlay[field] = {"$entry": key}
            for field in EVENT_DICT_FIELDS:
                value = row.get(field)
                if isinstance(value, dict):
                    translated: dict[str, Any] = {}
                    for variant_key, text in value.items():
                        if not isinstance(text, str) or not text.strip():
                            continue
                        key = f"event::{path.name}::{event_id}::{field}::{variant_key}"
                        string_entry(key, text, f"{context} / {field} / {variant_key}", entries)
                        translated[str(variant_key)] = {"$entry": key}
                    if translated:
                        overlay[field] = translated
            choices: list[dict[str, Any]] = []
            for index, choice in enumerate(row.get("choices", [])):
                translated_choice: dict[str, Any] = {}
                if isinstance(choice, dict):
                    for field in CHOICE_TEXT_FIELDS:
                        if isinstance(choice.get(field), str) and choice[field].strip():
                            key = f"event::{path.name}::{event_id}::choice::{index}::{field}"
                            string_entry(
                                key,
                                choice[field],
                                f"{context} / choice {index} / {field}",
                                entries,
                            )
                            translated_choice[field] = {"$entry": key}
                    for field in CHOICE_DICT_FIELDS:
                        value = choice.get(field)
                        if isinstance(value, dict):
                            translated: dict[str, Any] = {}
                            for variant_key, text in value.items():
                                if not isinstance(text, str) or not text.strip():
                                    continue
                                key = (
                                    f"event::{path.name}::{event_id}::choice::{index}::"
                                    f"{field}::{variant_key}"
                                )
                                string_entry(
                                    key,
                                    text,
                                    f"{context} / choice {index} / {field} / {variant_key}",
                                    entries,
                                )
                                translated[str(variant_key)] = {"$entry": key}
                            if translated:
                                translated_choice[field] = translated
                choices.append(translated_choice)
            if choices:
                overlay["choices"] = choices
            output_rows.append(overlay)
        if output_rows or event_ids is None:
            blueprint[path.name] = output_rows
    return entries, blueprint


def collect_demo() -> tuple[list[Entry], dict[str, Any]]:
    """Collect only the locked 24-week body and mergeable dynamic surfaces."""
    import demo_localization_scope as demo_scope

    observed, runtime, errors = demo_scope.build_scope()
    manifest = read_json(ROOT / "content/meta/demo_localization_scope.json")
    errors.extend(demo_scope.compare_contract(
        manifest.get("source_contract"), observed
    ))
    errors.extend(demo_scope.boundary_errors(runtime["event_ids"], manifest))
    if errors:
        raise ValueError(
            "demo localization source contract is not clean: "
            + "; ".join(errors[:20])
        )

    entries, event_blueprint = collect_events(set(runtime["event_ids"]))
    if len(entries) != observed["event_text_count"]:
        raise ValueError(
            "demo event collector drift: "
            f"{len(entries)} != {observed['event_text_count']}"
        )

    pair_contexts: dict[str, list[str]] = {}
    for pair in runtime["pairs"]:
        pair_contexts.setdefault(pair.korean, []).append(pair.source_id)
    ui_blueprint: dict[str, Any] = {}
    for korean in sorted(runtime["merged_pairs"]):
        key = f"demo-ui::{hashlib.sha1(korean.encode()).hexdigest()[:12]}"
        context = "24-week dynamic UI / " + ", ".join(
            sorted(pair_contexts.get(korean, []))[:4]
        )
        entries.append(Entry(key, korean, context))
        ui_blueprint[korean] = {"$entry": key}

    catalog_blueprint: dict[str, Any] = {"assets": {}}
    for asset_id in runtime["catalog_asset_ids"]:
        source = runtime["catalog_asset_names"].get(asset_id, "")
        key = f"demo-catalog::assets::{asset_id}::name"
        entries.append(Entry(
            key, source, f"24-week market asset / {asset_id} / name"
        ))
        catalog_blueprint["assets"][asset_id] = {
            "name": {"$entry": key}
        }

    expected = (
        observed["event_text_count"]
        + observed["dynamic_unique_keys"]
        + len(observed["catalog_asset_name_ids"])
    )
    if len(entries) != expected:
        raise ValueError(f"demo collector total drift: {len(entries)} != {expected}")
    return entries, {
        "events": event_blueprint,
        "ui": ui_blueprint,
        "catalog": catalog_blueprint,
    }


def collect_endings() -> tuple[list[Entry], list[dict[str, Any]]]:
    entries: list[Entry] = []
    output_rows: list[dict[str, Any]] = []
    for row in read_json(ROOT / "content/endings.json"):
        ending_id = str(row.get("id", ""))
        overlay: dict[str, Any] = {"id": ending_id}
        context = f"ending {ending_id} / {row.get('title', ending_id)}"
        for field in ENDING_TEXT_FIELDS:
            if isinstance(row.get(field), str):
                key = f"ending::{ending_id}::{field}"
                string_entry(key, row[field], f"{context} / {field}", entries)
                overlay[field] = {"$entry": key}
        for field in ENDING_DICT_FIELDS:
            value = row.get(field)
            if isinstance(value, dict):
                translated: dict[str, Any] = {}
                for variant_key, text in value.items():
                    key = f"ending::{ending_id}::{field}::{variant_key}"
                    string_entry(key, text, f"{context} / {field} / {variant_key}", entries)
                    translated[str(variant_key)] = {"$entry": key}
                overlay[field] = translated
        output_rows.append(overlay)
    return entries, output_rows


def parse_ui_calls(relative_path: str, source: str) -> tuple[list[UiCall], list[str]]:
    """Read literal legacy/context UI calls and attach a stable function owner."""
    functions = [(match.start(), match.group(1)) for match in GD_FUNCTION.finditer(source)]
    function_offsets = [offset for offset, _name in functions]
    parsed_context_offsets: set[int] = set()
    calls: list[UiCall] = []
    errors: list[str] = []

    def owner(offset: int) -> str:
        index = bisect.bisect_right(function_offsets, offset) - 1
        return functions[index][1] if index >= 0 else "<module>"

    for match in UI_PAIR.finditer(source):
        try:
            korean = decode_gd_string(match.group(1))
            english = decode_gd_string(match.group(2))
        except (ValueError, json.JSONDecodeError) as exc:
            errors.append(f"{relative_path}: invalid legacy UI literal ({exc})")
            continue
        if not korean.strip():
            errors.append(f"{relative_path}: empty Korean legacy UI key")
            continue
        calls.append(UiCall(
            path=relative_path,
            function=owner(match.start()),
            line=source.count("\n", 0, match.start()) + 1,
            api="legacy",
            korean=korean,
            english=english,
        ))

    for match in UI_CONTEXT_PAIR.finditer(source):
        parsed_context_offsets.add(match.start())
        try:
            context_id = decode_gd_string(match.group(1))
            korean = decode_gd_string(match.group(2))
            english = decode_gd_string(match.group(3))
        except (ValueError, json.JSONDecodeError) as exc:
            errors.append(f"{relative_path}: invalid context UI literal ({exc})")
            continue
        if not context_id.strip() or not korean.strip():
            errors.append(f"{relative_path}: empty context ID or Korean UI key")
            continue
        calls.append(UiCall(
            path=relative_path,
            function=owner(match.start()),
            line=source.count("\n", 0, match.start()) + 1,
            api="context",
            context_id=context_id,
            korean=korean,
            english=english,
        ))

    raw_context_offsets = {match.start() for match in RAW_UI_CONTEXT_CALL.finditer(source)}
    for offset in sorted(raw_context_offsets - parsed_context_offsets):
        line = source.count("\n", 0, offset) + 1
        errors.append(
            f"{relative_path}:{line}: ui_context requires three literal string arguments"
        )
    return sorted(calls, key=lambda call: call.line), errors


def _ui_format_signature(text: str) -> str:
    return "".join(character for character in text.casefold() if character.isalnum())


def _ui_contract_rows(
    contract: dict[str, Any], errors: list[str],
) -> tuple[dict[str, dict[str, set[str]]], dict[str, Any]]:
    raw_partition = contract.get("collision_partition")
    categories = ("format_equivalent", "shared_translation", "context_split")
    partition: dict[str, dict[str, set[str]]] = {}
    if not isinstance(raw_partition, dict) or set(raw_partition) != set(categories):
        errors.append("manifest: collision_partition must contain exactly three categories")
        raw_partition = {}
    for category in categories:
        raw_rows = raw_partition.get(category, {})
        parsed: dict[str, set[str]] = {}
        if not isinstance(raw_rows, dict):
            errors.append(f"manifest: collision_partition.{category} must be an object")
            raw_rows = {}
        for korean, english_rows in raw_rows.items():
            if not isinstance(korean, str) or not korean.strip():
                errors.append(f"manifest: {category} contains an empty/non-string Korean key")
                continue
            if not isinstance(english_rows, list) or not english_rows:
                errors.append(f"manifest: {category}.{korean!r} needs English variants")
                continue
            if not all(isinstance(value, str) and value for value in english_rows):
                errors.append(f"manifest: {category}.{korean!r} has invalid English variants")
                continue
            if len(set(english_rows)) != len(english_rows):
                errors.append(f"manifest: {category}.{korean!r} repeats an English variant")
            parsed[korean] = set(english_rows)
        partition[category] = parsed
    raw_registry = contract.get("context_registry")
    registry: dict[str, Any] = {}
    if not isinstance(raw_registry, list):
        errors.append("manifest: context_registry must be an array")
        raw_registry = []
    for index, row in enumerate(raw_registry):
        if not isinstance(row, dict) or not isinstance(row.get("id"), str):
            errors.append(f"manifest: context_registry[{index}] is malformed")
            continue
        context_id = row["id"]
        if context_id in registry:
            errors.append(f"manifest: duplicate context ID {context_id!r}")
            continue
        registry[context_id] = row
    return partition, registry


def validate_ui_context_contract(
    calls: list[UiCall] | tuple[UiCall, ...],
    contract: Optional[dict[str, Any]] = None,
) -> tuple[list[str], dict[str, int]]:
    """Validate the immutable 107-key plan separately from observed migration."""
    if contract is None:
        contract = read_ui_context_contract()
    errors: list[str] = []
    if contract.get("schema_version") != 1:
        errors.append("manifest: ui semantic context schema_version must be 1")

    legacy_calls = [call for call in calls if call.api == "legacy"]
    context_calls = [call for call in calls if call.api == "context"]
    source_keys = {call.korean for call in calls}
    source_key_hash = hashlib.sha256(
        "\n".join(sorted(source_keys)).encode("utf-8")
    ).hexdigest()
    variants: dict[str, set[str]] = {}
    for call in calls:
        variants.setdefault(call.korean, set()).add(call.english)
    collisions = {key: values for key, values in variants.items() if len(values) > 1}

    baseline_calls = contract.get("legacy_pair_call_occurrences")
    if baseline_calls != len(calls):
        errors.append(
            f"manifest: source pair calls {baseline_calls!r} != observed {len(calls)}"
        )
    if contract.get("legacy_korean_source_keys") != len(source_keys):
        errors.append(
            "manifest: legacy Korean source key count "
            f"{contract.get('legacy_korean_source_keys')!r} != {len(source_keys)}"
        )
    if contract.get("legacy_korean_source_keys_sha256") != source_key_hash:
        errors.append(
            "manifest: legacy Korean source key SHA-256 mismatch "
            f"{source_key_hash}"
        )
    if contract.get("multi_english_korean_keys") != len(collisions):
        errors.append(
            f"manifest: multi-English key count is {len(collisions)}, expected "
            f"{contract.get('multi_english_korean_keys')!r}"
        )

    partition, registry = _ui_contract_rows(contract, errors)
    category_fields = {
        "format_equivalent": "format_equivalent_keys",
        "shared_translation": "shared_translation_keys",
        "context_split": "context_split_korean_keys",
    }
    declared_union: set[str] = set()
    for category, field in category_fields.items():
        rows = partition.get(category, {})
        if contract.get(field) != len(rows):
            errors.append(
                f"manifest: {field} {contract.get(field)!r} != {len(rows)}"
            )
        overlap = declared_union & set(rows)
        if overlap:
            errors.append(f"manifest: collision partition overlap {sorted(overlap)[:8]}")
        declared_union.update(rows)
        for korean, expected_english in rows.items():
            actual_english = collisions.get(korean)
            if actual_english != expected_english:
                errors.append(
                    f"manifest: {category}.{korean!r} variants "
                    f"{sorted(expected_english)!r} != observed "
                    f"{sorted(actual_english or set())!r}"
                )
    missing = set(collisions) - declared_union
    stale = declared_union - set(collisions)
    if missing or stale:
        errors.append(
            f"manifest: collision partition mismatch missing={sorted(missing)[:8]} "
            f"stale={sorted(stale)[:8]}"
        )
    for korean, english_rows in partition.get("format_equivalent", {}).items():
        if len({_ui_format_signature(value) for value in english_rows}) != 1:
            errors.append(f"manifest: formatting-only row is semantic: {korean!r}")
    for korean, english_rows in partition.get("shared_translation", {}).items():
        if len({_ui_format_signature(value) for value in english_rows}) == 1:
            errors.append(f"manifest: semantic allowlist row is formatting-only: {korean!r}")

    planned_ids = contract.get("planned_context_ids")
    if planned_ids != len(registry):
        errors.append(f"manifest: planned context IDs {planned_ids!r} != {len(registry)}")
    selectors: dict[tuple[str, str, str, str], tuple[str, int]] = {}
    registry_totals: dict[str, int] = {}
    registry_korean: set[str] = set()
    for context_id, row in registry.items():
        if not isinstance(context_id, str) or not UI_CONTEXT_ID.fullmatch(context_id):
            errors.append(f"manifest: invalid context ID {context_id!r}")
            continue
        if not isinstance(row, dict):
            errors.append(f"manifest: context row {context_id!r} must be an object")
            continue
        korean = row.get("ko")
        allowed_english = row.get("allowed_en")
        callsites = row.get("callsites")
        if not isinstance(korean, str) or not korean:
            errors.append(f"manifest: {context_id} has invalid ko")
            continue
        registry_korean.add(korean)
        if not isinstance(allowed_english, list) or not allowed_english \
                or not all(isinstance(value, str) and value for value in allowed_english):
            errors.append(f"manifest: {context_id} has invalid allowed_en")
            allowed_english = []
        if len(set(allowed_english)) != len(allowed_english):
            errors.append(f"manifest: {context_id} repeats allowed_en")
        if not isinstance(callsites, list) or not callsites:
            errors.append(f"manifest: {context_id} needs callsites")
            callsites = []
        row_total = 0
        callsite_english: set[str] = set()
        for index, callsite in enumerate(callsites):
            if not isinstance(callsite, dict):
                errors.append(f"manifest: {context_id}.callsites[{index}] is invalid")
                continue
            path = callsite.get("path")
            function = callsite.get("function")
            english = callsite.get("en")
            count = callsite.get("count")
            if not isinstance(path, str) or not isinstance(function, str) \
                    or not isinstance(english, str) or not isinstance(count, int) \
                    or isinstance(count, bool) or count <= 0:
                errors.append(f"manifest: {context_id}.callsites[{index}] is malformed")
                continue
            selector = (path, function, korean, english)
            if selector in selectors:
                errors.append(f"manifest: duplicate context callsite selector {selector!r}")
            else:
                selectors[selector] = (context_id, count)
            row_total += count
            callsite_english.add(english)
        if set(allowed_english) != callsite_english:
            errors.append(
                f"manifest: {context_id} allowed_en does not equal callsite English"
            )
        registry_totals[context_id] = row_total
    split_keys = set(partition.get("context_split", {}))
    if registry_korean != split_keys:
        errors.append(
            "manifest: context registry Korean keys do not equal context_split "
            f"missing={sorted(split_keys-registry_korean)[:8]} "
            f"extra={sorted(registry_korean-split_keys)[:8]}"
        )
    if source_keys & set(registry):
        errors.append("manifest: context ID collides with a legacy source key")

    planned_calls = sum(registry_totals.values())
    if contract.get("planned_context_callsite_migrations") != planned_calls:
        errors.append(
            "manifest: planned context callsites "
            f"{contract.get('planned_context_callsite_migrations')!r} != {planned_calls}"
        )
    completed_legacy = contract.get("post_migration_legacy_pair_call_occurrences")
    if isinstance(baseline_calls, int) and completed_legacy != baseline_calls - planned_calls:
        errors.append(
            f"manifest: post-migration legacy calls {completed_legacy!r} != "
            f"{baseline_calls-planned_calls}"
        )

    combined_counts: dict[tuple[str, str, str, str], int] = {}
    context_counts: dict[tuple[str, str, str, str], int] = {}
    migrated_by_id: dict[str, int] = {}
    for call in calls:
        selector = (call.path, call.function, call.korean, call.english)
        combined_counts[selector] = combined_counts.get(selector, 0) + 1
        if call.api != "context":
            continue
        context_counts[selector] = context_counts.get(selector, 0) + 1
        expected = selectors.get(selector)
        if expected is None:
            errors.append(
                f"source: unknown context call {call.path}:{call.line} "
                f"{call.context_id!r}/{call.korean!r}/{call.english!r}"
            )
            continue
        expected_id, _expected_count = expected
        if call.context_id != expected_id:
            errors.append(
                f"source: {call.path}:{call.line} context ID {call.context_id!r} "
                f"!= {expected_id!r}"
            )
            continue
        migrated_by_id[expected_id] = migrated_by_id.get(expected_id, 0) + 1
    for selector, (context_id, expected_count) in selectors.items():
        if combined_counts.get(selector, 0) != expected_count:
            errors.append(
                f"source: planned selector {selector!r} count "
                f"{combined_counts.get(selector, 0)} != {expected_count}"
            )
        migrated = context_counts.get(selector, 0)
        if migrated not in (0, expected_count):
            errors.append(
                f"source: partial selector migration {selector!r} "
                f"{migrated}/{expected_count}"
            )
    for context_id, expected_count in registry_totals.items():
        migrated = migrated_by_id.get(context_id, 0)
        if migrated not in (0, expected_count):
            errors.append(
                f"source: partial context ID migration {context_id} "
                f"{migrated}/{expected_count}"
            )

    migrated_ids = sum(1 for value in migrated_by_id.values() if value)
    implemented = contract.get("implemented")
    if not isinstance(implemented, bool):
        errors.append("manifest: implemented must be boolean")
    elif implemented:
        if len(context_calls) != planned_calls \
                or len(legacy_calls) != completed_legacy \
                or migrated_ids != len(registry):
            errors.append(
                "source: implemented context migration is incomplete "
                f"legacy={len(legacy_calls)}/{completed_legacy} "
                f"context={len(context_calls)}/{planned_calls} "
                f"ids={migrated_ids}/{len(registry)}"
            )
    elif len(legacy_calls) != baseline_calls or context_calls or migrated_ids:
        errors.append(
            "source: implemented=false requires the untouched 0/37 state "
            f"legacy={len(legacy_calls)}/{baseline_calls} "
            f"context={len(context_calls)}/0 ids={migrated_ids}/0"
        )
    stats = {
        "legacy_calls": len(legacy_calls),
        "context_calls": len(context_calls),
        "source_calls": len(calls),
        "legacy_keys": len(source_keys),
        "collision_keys": len(collisions),
        "format_equivalent": len(partition.get("format_equivalent", {})),
        "shared_translation": len(partition.get("shared_translation", {})),
        "context_split": len(partition.get("context_split", {})),
        "planned_context_ids": len(registry),
        "planned_context_calls": planned_calls,
        "migrated_context_ids": migrated_ids,
        "implemented": int(implemented is True),
    }
    return errors, stats


def build_ui_context_layers(
    calls: Iterable[UiCall], contract: dict[str, Any],
) -> tuple[
    tuple[Entry, ...], dict[str, Any], tuple[Entry, ...], dict[str, Any]
]:
    """Build all 30 planned rows, then the observed subset used for generation."""
    call_rows = tuple(calls)
    _partition, registry = _ui_contract_rows(contract, [])
    planned_context_entries: list[Entry] = []
    planned_context_blueprint: dict[str, Any] = {}
    for context_id in sorted(registry):
        row = registry[context_id]
        korean = row.get("ko")
        allowed_english = row.get("allowed_en")
        callsites = row.get("callsites")
        if not isinstance(korean, str) or not isinstance(allowed_english, list) \
                or not isinstance(callsites, list):
            continue
        english = sorted(value for value in allowed_english if isinstance(value, str))
        owners = sorted({
            f"{callsite.get('path')}::{callsite.get('function')}"
            for callsite in callsites if isinstance(callsite, dict)
        })
        key = f"ui::context::{context_id}"
        context = (
            f"UI context {context_id} / EN {' | '.join(english)} / "
            + ", ".join(owners)
        )
        planned_context_entries.append(Entry(key, korean, context, context_id))
        planned_context_blueprint[context_id] = {"$entry": key}

    planned_by_id = {
        entry.context_id: entry for entry in planned_context_entries
    }
    observed_ids = {
        call.context_id for call in call_rows if call.api == "context"
    }
    observed_context_entries = [
        planned_by_id[context_id]
        for context_id in sorted(observed_ids)
        if context_id in planned_by_id
    ]
    observed_context_blueprint = {
        entry.context_id: {"$entry": entry.key}
        for entry in observed_context_entries
    }
    return (
        tuple(planned_context_entries),
        planned_context_blueprint,
        tuple(observed_context_entries),
        observed_context_blueprint,
    )


def collect_ui_inventory(
    contract: Optional[dict[str, Any]] = None,
) -> UiInventory:
    effective_contract = contract if contract is not None else read_ui_context_contract()
    calls: list[UiCall] = []
    errors: list[str] = []
    for directory in RUNTIME_DIRS:
        for path in sorted((ROOT / directory).rglob("*.gd")):
            relative_path = str(path.relative_to(ROOT))
            parsed, parse_errors = parse_ui_calls(
                relative_path, path.read_text(encoding="utf-8")
            )
            calls.extend(parsed)
            errors.extend(parse_errors)
    calls.sort(key=lambda call: (call.path, call.line, call.api))
    contract_errors, stats = validate_ui_context_contract(calls, effective_contract)
    errors.extend(contract_errors)

    legacy_locations: dict[str, set[str]] = {}
    for call in calls:
        legacy_locations.setdefault(call.korean, set()).add(
            f"{call.path}:{call.line}"
        )

    legacy_entries: list[Entry] = []
    legacy_blueprint: dict[str, Any] = {}
    for index, korean in enumerate(sorted(legacy_locations)):
        key = f"ui::{index:04d}::{hashlib.sha1(korean.encode()).hexdigest()[:12]}"
        context = "UI / " + ", ".join(sorted(legacy_locations[korean])[:4])
        legacy_entries.append(Entry(key, korean, context))
        legacy_blueprint[korean] = {"$entry": key}

    (
        planned_context_entries,
        planned_context_blueprint,
        observed_context_entries,
        observed_context_blueprint,
    ) = build_ui_context_layers(calls, effective_contract)

    return UiInventory(
        calls=tuple(calls),
        legacy_entries=tuple(legacy_entries),
        legacy_blueprint=legacy_blueprint,
        planned_context_entries=planned_context_entries,
        planned_context_blueprint=planned_context_blueprint,
        observed_context_entries=observed_context_entries,
        observed_context_blueprint=observed_context_blueprint,
        errors=tuple(errors),
        stats=stats,
    )


def collect_ui() -> tuple[list[Entry], dict[str, Any]]:
    inventory = collect_ui_inventory()
    return inventory.entries, inventory.blueprint


def premature_context_dictionary_keys(
    actual_keys: Iterable[str], inventory: UiInventory,
) -> list[str]:
    if inventory.stats.get("implemented"):
        return []
    return sorted(set(actual_keys) & set(inventory.planned_context_blueprint))


def collect_catalog() -> tuple[list[Entry], dict[str, Any]]:
    entries: list[Entry] = []
    blueprint: dict[str, Any] = {section: {} for section in CATALOG_SOURCES}
    for section, (relative_path, fields) in CATALOG_SOURCES.items():
        for row in read_json(ROOT / relative_path):
            row_id = str(row.get("id", ""))
            output: dict[str, Any] = {}
            for field in fields:
                value = row.get(field)
                if isinstance(value, str):
                    key = f"catalog::{section}::{row_id}::{field}"
                    string_entry(key, value, f"catalog {section} / {row_id} / {field}", entries)
                    output[field] = {"$entry": key}
                elif isinstance(value, list):
                    translated: list[Any] = []
                    for index, text in enumerate(value):
                        key = f"catalog::{section}::{row_id}::{field}::{index}"
                        string_entry(
                            key,
                            text,
                            f"catalog {section} / {row_id} / {field} {index}",
                            entries,
                        )
                        translated.append({"$entry": key})
                    output[field] = translated
            blueprint[section][row_id] = output
    return entries, blueprint


def load_cache() -> dict[str, dict[str, str]]:
    if not CACHE_PATH.exists():
        return {}
    try:
        value = read_json(CACHE_PATH)
    except (OSError, json.JSONDecodeError):
        return {}
    return value if isinstance(value, dict) else {}


def save_cache(cache: dict[str, dict[str, str]]) -> None:
    write_json(CACHE_PATH, cache)


def tokens(text: str) -> list[str]:
    return sorted(PLACEHOLDER.findall(text))


def repair_single_placeholder(entry: Entry, translated: str) -> str:
    """Restore an unambiguous one-token model typo without rewriting prose."""
    source_tokens = PLACEHOLDER.findall(entry.source)
    translated_tokens = PLACEHOLDER.findall(translated)
    if (
        len(source_tokens) == 1
        and len(translated_tokens) == 1
        and source_tokens[0] != translated_tokens[0]
    ):
        return translated.replace(translated_tokens[0], source_tokens[0], 1)
    return translated


def normalize_translation_for_entry(entry: Entry, translated: str) -> str:
    """Apply source-bounded terminology repairs that cannot change unrelated text."""
    translated = repair_single_placeholder(entry, translated)
    if "도박" in entry.source:
        translated = translated.replace("ギャンリング", "ギャンブル")
    if "트리플" in entry.source:
        translated = translated.replace("トライフル", "トリプル")
        translated = translated.replace("トライプル", "トリプル")
        translated = translated.replace("スリーカード", "トリプル")
    if "해금" in entry.source:
        translated = translated.replace("解除", "解放")
    if "강남드림" not in entry.source:
        translated = translated.replace("カンナム・ドリーム", "カンナム")
    if "입성" in entry.source:
        translated = translated.replace("カンナム入城", "カンナム入り")
    return translated


def exact_translation_for_entry(entry: Entry) -> Optional[str]:
    """Legacy source canon must not erase the meaning of a context-specific row."""
    if entry.context_id:
        return None
    return EXACT_TRANSLATIONS.get(entry.source)


def validate_translation(entry: Entry, translated: Any) -> list[str]:
    errors: list[str] = []
    if not isinstance(translated, str) or not translated.strip():
        return ["translation is empty or not a string"]
    if HANGUL.search(translated):
        remains = sorted(set(re.findall(r"[가-힣]+", translated)))
        errors.append(f"Hangul remains {remains[:8]}")
    if (
        exact_translation_for_entry(entry) is None
        and HANGUL.search(entry.source)
        and not JAPANESE.search(translated)
    ):
        errors.append("no Japanese glyphs in translated Korean source")
    if tokens(entry.source) != tokens(translated):
        errors.append(f"placeholder mismatch {tokens(entry.source)} != {tokens(translated)}")
    if entry.key.startswith("ui::"):
        if entry.source.count("\n") != translated.count("\n"):
            errors.append(
                f"newline mismatch {entry.source.count(chr(10))} != {translated.count(chr(10))}"
            )
    elif entry.source.count("\n\n") != translated.count("\n\n"):
        errors.append(
            f"paragraph mismatch {entry.source.count(chr(10)+chr(10))} != "
            f"{translated.count(chr(10)+chr(10))}"
        )
    if YEN_AMOUNT.search(translated):
        errors.append("Korean won was converted to yen")
    for term in BAD_TERMS:
        if term in translated:
            errors.append(f"forbidden term {term}")
    if len(entry.source) >= 100 and len(translated) < len(entry.source) * 0.42:
        errors.append("translation is suspiciously abbreviated")
    return errors


def parse_response(content: str) -> dict[str, str]:
    parsed = json.loads(content)
    rows = parsed.get("translations", []) if isinstance(parsed, dict) else []
    if not isinstance(rows, list):
        raise ValueError("translations is not an array")
    result: dict[str, str] = {}
    for row in rows:
        if not isinstance(row, dict) or not isinstance(row.get("id"), str):
            raise ValueError("translation row is malformed")
        value = row.get("text")
        result[row["id"]] = normalize_translation_text(value) if isinstance(value, str) else value
    return result


def normalize_translation_text(text: str) -> str:
    """Repair bounded model artifacts whose intended Japanese is unambiguous."""
    text = text.replace("クッパ（豚骨スープ）", "クッパ")
    text = text.replace("コスピ", "KOSPI")
    text = text.replace("ヒIDDEN", "シークレット")
    text = text.replace("ヒデン", "シークレット")
    return text


def request_translation(
    model: str,
    entries: list[Entry],
    correction: str = "",
    drafts: Optional[dict[str, str]] = None,
) -> dict[str, str]:
    rows = []
    for entry in entries:
        row = {"id": entry.key, "context": entry.context, "source_ko": entry.source}
        if drafts is not None:
            row["draft_ja"] = drafts[entry.key]
        rows.append(row)
    user_prompt = (
        "Translate every row below. "
        + (f"Correct these previous validation failures: {correction}\n" if correction else "")
        + json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
    )
    payload = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": REVIEW_SYSTEM_PROMPT if drafts is not None else SYSTEM_PROMPT,
            },
            {"role": "user", "content": user_prompt},
        ],
        "stream": False,
        "format": "json",
        "think": False,
        "options": {
            "temperature": 0.05,
            "top_p": 0.7,
            "num_ctx": 65536,
            "num_predict": 8192,
        },
    }
    request = urllib.request.Request(
        OLLAMA_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=1800) as response:
        body = json.loads(response.read().decode("utf-8"))
    content = body.get("message", {}).get("content", "")
    return parse_response(content)


def request_review(
    model: str,
    entries: list[Entry],
    drafts: dict[str, str],
    correction: str = "",
) -> dict[str, str]:
    rows = [
        {
            "id": entry.key,
            "context": entry.context,
            "source_ko": entry.source,
            "draft_ja": drafts[entry.key],
        }
        for entry in entries
    ]
    user_prompt = (
        "Audit every Korean source against its Japanese draft. Return corrections only. "
        + (f"Fix this response error: {correction}\n" if correction else "")
        + json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
    )
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": REVIEW_SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt},
        ],
        "stream": False,
        "format": "json",
        "think": False,
        "options": {
            "temperature": 0.0,
            "top_p": 0.7,
            "num_ctx": 65536,
            "num_predict": 4096,
        },
    }
    request = urllib.request.Request(
        OLLAMA_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=1800) as response:
        body = json.loads(response.read().decode("utf-8"))
    content = body.get("message", {}).get("content", "")
    parsed = json.loads(content)
    rows = parsed.get("corrections", []) if isinstance(parsed, dict) else []
    if not isinstance(rows, list):
        raise ValueError("corrections is not an array")
    result: dict[str, str] = {}
    for row in rows:
        if not isinstance(row, dict) or not isinstance(row.get("id"), str):
            raise ValueError("correction row is malformed")
        value = row.get("text")
        result[row["id"]] = normalize_translation_text(value) if isinstance(value, str) else value
    return result


def review_batch(
    model: str,
    entries: list[Entry],
    drafts: dict[str, str],
    depth: int = 0,
) -> dict[str, str]:
    correction = ""
    for attempt in range(1, 4):
        try:
            changes = request_review(model, entries, drafts, correction)
            expected = {entry.key for entry in entries}
            extra = sorted(set(changes) - expected)
            if extra:
                raise ValueError(f"review invented ids {extra[:5]}")
            result: dict[str, str] = {}
            failures: list[str] = []
            ignored = 0
            for entry in entries:
                text = changes.get(entry.key, drafts[entry.key])
                text = normalize_translation_for_entry(entry, text)
                errors = validate_translation(entry, text)
                if errors and entry.key in changes:
                    # A reviewer suggestion must never degrade a structurally valid
                    # draft (the most common bad suggestion reintroduces Hangul).
                    text = drafts[entry.key]
                    errors = validate_translation(entry, text)
                    ignored += 1
                if errors:
                    failures.extend(f"{entry.key}: {error}" for error in errors)
                else:
                    result[entry.key] = text
            if failures:
                raise ValueError("; ".join(failures[:20]))
            if ignored:
                print(
                    f"  review ignored_invalid={ignored} rows={len(entries)}",
                    flush=True,
                )
            return result
        except (OSError, ValueError, json.JSONDecodeError, urllib.error.URLError) as exc:
            correction = str(exc)[:2000]
            print(
                f"  review retry {attempt}/3 depth={depth} rows={len(entries)} "
                f"reason={correction}",
                flush=True,
            )
            if attempt < 3:
                time.sleep(1.0)
    if len(entries) == 1:
        raise RuntimeError(f"Could not review {entries[0].key}: {correction}")
    middle = len(entries) // 2
    print(
        f"  review split depth={depth} rows={len(entries)} -> {middle}+{len(entries)-middle}",
        flush=True,
    )
    result = review_batch(model, entries[:middle], drafts, depth + 1)
    result.update(review_batch(model, entries[middle:], drafts, depth + 1))
    return result


def translate_batch(
    model: str,
    entries: list[Entry],
    depth: int = 0,
    drafts: Optional[dict[str, str]] = None,
) -> dict[str, str]:
    accepted: dict[str, str] = {}
    pending = entries
    correction = ""
    for attempt in range(1, 4):
        try:
            result = request_translation(model, pending, correction, drafts)
            expected = {entry.key for entry in pending}
            extra = sorted(set(result) - expected)
            if extra:
                raise ValueError(f"id mismatch extra={extra[:5]}")
            failures: list[str] = []
            failed_entries: list[Entry] = []
            for entry in pending:
                if entry.key not in result:
                    failed_entries.append(entry)
                    failures.append(f"{entry.key}: missing output id")
                    continue
                result[entry.key] = normalize_translation_for_entry(entry, result[entry.key])
                errors = validate_translation(entry, result[entry.key])
                if errors:
                    failed_entries.append(entry)
                    failures.extend(f"{entry.key}: {error}" for error in errors)
                else:
                    accepted[entry.key] = result[entry.key]
            if not failed_entries:
                return accepted
            pending = failed_entries
            correction = "; ".join(failures[:20])
            print(
                f"  selective retry {attempt}/3 depth={depth} failed={len(pending)} "
                f"accepted={len(accepted)} reason={correction}",
                flush=True,
            )
            if attempt < 3:
                time.sleep(1.0)
        except (OSError, ValueError, json.JSONDecodeError, urllib.error.URLError) as exc:
            correction = str(exc)[:2000]
            print(
                f"  retry {attempt}/3 depth={depth} rows={len(pending)} reason={correction}",
                flush=True,
            )
            if attempt < 3:
                time.sleep(1.0)
    if len(pending) == 1:
        raise RuntimeError(f"Could not translate {pending[0].key}: {correction}")
    middle = len(pending) // 2
    print(
        f"  split depth={depth} rows={len(pending)} -> {middle}+{len(pending)-middle}",
        flush=True,
    )
    accepted.update(translate_batch(model, pending[:middle], depth + 1, drafts))
    accepted.update(translate_batch(model, pending[middle:], depth + 1, drafts))
    return accepted


def batches(entries: list[Entry], max_chars: int) -> Iterable[list[Entry]]:
    batch: list[Entry] = []
    char_count = 0
    for entry in entries:
        cost = len(entry.source) + len(entry.context) + len(entry.key)
        if batch and char_count + cost > max_chars:
            yield batch
            batch = []
            char_count = 0
        batch.append(entry)
        char_count += cost
    if batch:
        yield batch


def resolve_blueprint(value: Any, translated: dict[str, str]) -> Any:
    if isinstance(value, dict):
        if set(value) == {"$entry"}:
            return translated[value["$entry"]]
        return {key: resolve_blueprint(child, translated) for key, child in value.items()}
    if isinstance(value, list):
        return [resolve_blueprint(child, translated) for child in value]
    return value


def merge_event_rows(
    existing_rows: list[dict[str, Any]],
    translated_rows: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """Replace selected IDs without deleting rows outside the demo wave."""
    replacements = {
        str(row.get("id", "")): row for row in translated_rows
    }
    merged_rows: list[dict[str, Any]] = []
    seen: set[str] = set()
    for row in existing_rows:
        event_id = str(row.get("id", ""))
        merged_rows.append(replacements.get(event_id, row))
        seen.add(event_id)
    for row in translated_rows:
        event_id = str(row.get("id", ""))
        if event_id not in seen:
            merged_rows.append(row)
            seen.add(event_id)
    return merged_rows


def body_authorization_error(
    scope: str, allow_demo_body: bool, allow_full_body: bool,
) -> str:
    if scope == "demo" and not allow_demo_body:
        return "demo_text_freeze_required"
    if scope == "all" or scope in {"events", "endings", "catalog"}:
        if not allow_full_body:
            return "full_game_GO_required"
    return ""


def write_scope(scope: str, blueprint: Any, translated: dict[str, str]) -> None:
    resolved = resolve_blueprint(blueprint, translated)
    if scope == "demo":
        output_dir = ROOT / "content/events_ja"
        for filename, translated_rows in resolved["events"].items():
            path = output_dir / filename
            existing_rows = read_json(path) if path.is_file() else []
            write_json(path, merge_event_rows(existing_rows, translated_rows))

        ui_path = ROOT / "locale/ui_ja.json"
        current_ui = read_json(ui_path)
        current_ui.update(resolved["ui"])
        write_json(ui_path, {
            key: current_ui[key] for key in sorted(current_ui)
        })

        catalog_path = ROOT / "locale/catalog_ja.json"
        current_catalog = read_json(catalog_path)
        if not isinstance(current_catalog, dict):
            current_catalog = {}
        assets = current_catalog.setdefault("assets", {})
        if not isinstance(assets, dict):
            raise ValueError("locale/catalog_ja.json assets must be an object")
        for asset_id, fields in resolved["catalog"]["assets"].items():
            row = assets.setdefault(asset_id, {})
            if not isinstance(row, dict):
                raise ValueError(f"catalog assets.{asset_id} must be an object")
            row.update(fields)
        write_json(catalog_path, current_catalog)
    elif scope == "events":
        output_dir = ROOT / "content/events_ja"
        for stale in output_dir.glob("*.json"):
            stale.unlink()
        for filename, rows in resolved.items():
            write_json(output_dir / filename, rows)
    elif scope == "endings":
        write_json(ROOT / "content/endings_ja.json", resolved)
    elif scope == "ui":
        write_json(ROOT / "locale/ui_ja.json", resolved)
    elif scope == "catalog":
        write_json(ROOT / "locale/catalog_ja.json", resolved)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--scope",
        choices=("all", "demo", "events", "endings", "ui", "catalog"),
        default="ui",
    )
    parser.add_argument(
        "--allow-body",
        action="store_true",
        help="Unlock only the 24-week demo body after its approved source text is final.",
    )
    parser.add_argument(
        "--allow-full-body",
        action="store_true",
        help="Unlock full 1,603-event/35-ending/catalog generation only after a separate full-game GO.",
    )
    parser.add_argument(
        "--inventory",
        action="store_true",
        help="Print the selected collector scope without translating or writing.",
    )
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--batch-chars", type=int, default=9000)
    parser.add_argument("--limit-batches", type=int, default=0)
    args = parser.parse_args()

    if args.self_test:
        entries, _blueprint = collect_demo()
        failures: list[str] = []
        cases = 6
        manifest = read_json(ROOT / "content/meta/demo_localization_scope.json")
        contract = manifest.get("source_contract", {})
        expected_entries = (
            int(contract.get("event_text_count", -1))
            + int(contract.get("dynamic_unique_keys", -1))
            + len(contract.get("catalog_asset_name_ids", []))
        )
        if len(entries) != expected_entries:
            failures.append(f"demo collector returned {len(entries)} entries")
        merged = merge_event_rows(
            [{"id": "outside", "title": "keep"}, {"id": "inside", "title": "old"}],
            [{"id": "inside", "title": "new"}, {"id": "added", "title": "new"}],
        )
        if merged != [
            {"id": "outside", "title": "keep"},
            {"id": "inside", "title": "new"},
            {"id": "added", "title": "new"},
        ]:
            failures.append("demo event merge deleted, duplicated, or reordered rows")
        if body_authorization_error("demo", False, False) != "demo_text_freeze_required":
            failures.append("demo body opened before the source-text freeze")
        if body_authorization_error("events", True, False) != "full_game_GO_required":
            failures.append("demo text freeze opened full event generation")
        if body_authorization_error("all", True, False) != "full_game_GO_required":
            failures.append("demo text freeze opened the full all-scope generation")
        if body_authorization_error("demo", True, False):
            failures.append("text-frozen demo scope remained locked")
        cases += 1
        short_entry = Entry("self-test-short", "돈", "pipeline self-test")
        if not any(
            "no Japanese glyphs" in error
            for error in validate_translation(short_entry, "Money")
        ):
            failures.append("generator accepted English-only short Korean text")
        cases += 1
        exact_latin = {
            "유튜버": "YouTuber",
            "코스피200 ETF": "KOSPI 200 ETF",
            "리츠 ETF": "REIT ETF",
            "포스코": "POSCO",
            "코파일럿": "Copilot",
        }
        for source, target in exact_latin.items():
            entry = Entry(f"self-test-exact::{source}", source, "pipeline self-test")
            if EXACT_TRANSLATIONS.get(source) != target \
                    or validate_translation(entry, target):
                failures.append(f"canonical Latin exact mapping failed: {source}")
        cases += 1
        ui_inventory = collect_ui_inventory()
        failures.extend(
            f"actual UI contract: {error}" for error in ui_inventory.errors
        )
        if len(ui_inventory.entries) != 2730 \
                or len(ui_inventory.planned_context_entries) != 30 \
                or ui_inventory.observed_context_entries:
            failures.append(
                "planned/observed UI inventory separation failed: "
                f"actual={len(ui_inventory.entries)} "
                f"planned={len(ui_inventory.planned_context_entries)} "
                f"observed={len(ui_inventory.observed_context_entries)}"
            )
        cases += 1
        if premature_context_dictionary_keys(
            {"ui.credit.standard_grade"}, ui_inventory
        ) != ["ui.credit.standard_grade"]:
            failures.append("premature planned Japanese context row was not rejected")
        cases += 1
        fixture_calls, fixture_errors = parse_ui_calls(
            "scenes/SelfTest.gd",
            'func fixture():\n'
            '\t_tr("기록", "Log")\n'
            '\tLocaleManager.ui("생활", "Living")\n'
            '\tLocaleManager.ui_context("ui.navigation.archive", "기록", "Archive")\n',
        )
        if fixture_errors or [call.api for call in fixture_calls] != [
            "legacy", "legacy", "context"
        ] or fixture_calls[-1].function != "fixture":
            failures.append(
                f"dual UI API collector failed: calls={fixture_calls} errors={fixture_errors}"
            )
        cases += 1
        legacy_exact = Entry("ui::legacy", "도박장", "legacy UI")
        context_exact = Entry(
            "ui::context::ui.gambling.venues_title",
            "도박장",
            "Gambling venues title",
            "ui.gambling.venues_title",
        )
        if exact_translation_for_entry(legacy_exact) != "カジノ" \
                or exact_translation_for_entry(context_exact) is not None:
            failures.append("legacy exact translation leaked into a context row")
        if context_exact.source_hash == Entry(
            "ui::context::ui.gambling.other",
            "도박장",
            "Gambling venues title",
            "ui.gambling.other",
        ).source_hash:
            failures.append("context cache hash omitted the stable context ID")

        ui_contract = manifest.get("ui_semantic_context_blocker", {})
        selector_ids = {
            (
                callsite["path"],
                callsite["function"],
                row["ko"],
                callsite["en"],
            ): row["id"]
            for row in ui_contract.get("context_registry", [])
            for callsite in row.get("callsites", [])
        }
        completed_calls = [
            UiCall(
                call.path,
                call.function,
                call.line,
                "context",
                call.korean,
                call.english,
                selector_ids[(call.path, call.function, call.korean, call.english)],
            ) if (call.path, call.function, call.korean, call.english) in selector_ids
            else call
            for call in ui_inventory.calls
        ]
        completed_contract = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        completed_contract["implemented"] = True
        cases += 1
        completed_errors, completed_stats = validate_ui_context_contract(
            completed_calls, completed_contract
        )
        if completed_errors or completed_stats.get("context_calls") != 37:
            failures.append(
                "completed 37-call migration fixture failed: "
                f"stats={completed_stats} errors={completed_errors}"
            )
        (
            completed_planned_entries,
            _completed_planned_blueprint,
            completed_observed_entries,
            _completed_observed_blueprint,
        ) = build_ui_context_layers(completed_calls, completed_contract)
        if len(completed_planned_entries) != 30 \
                or len(completed_observed_entries) != 30:
            failures.append(
                "completed generation did not select exactly 30 observed rows: "
                f"planned={len(completed_planned_entries)} "
                f"observed={len(completed_observed_entries)}"
            )

        single_id_calls = list(ui_inventory.calls)
        single_selector = (
            "autoloads/GameState.gd",
            "get_credit_grade_label",
            "보통",
            "Standard",
        )
        for index, call in enumerate(single_id_calls):
            if (call.path, call.function, call.korean, call.english) == single_selector:
                single_id_calls[index] = UiCall(
                    call.path,
                    call.function,
                    call.line,
                    "context",
                    call.korean,
                    call.english,
                    "ui.credit.standard_grade",
                )
                break
        cases += 1
        single_errors, single_stats = validate_ui_context_contract(
            single_id_calls, ui_contract
        )
        if single_stats.get("context_calls") != 1 \
                or single_stats.get("migrated_context_ids") != 1 \
                or not any("implemented=false" in error for error in single_errors):
            failures.append(
                "whole one-call ID migration escaped planned state: "
                f"stats={single_stats} errors={single_errors}"
            )

        partial_calls = list(ui_inventory.calls)
        partial_selector = (
            "scenes/MainGame.gd",
            "_core_loop_v2_completion_view_model",
            "기록 없음",
            "NOT RECORDED",
        )
        for index, call in enumerate(partial_calls):
            if (call.path, call.function, call.korean, call.english) == partial_selector:
                partial_calls[index] = UiCall(
                    call.path,
                    call.function,
                    call.line,
                    "context",
                    call.korean,
                    call.english,
                    "ui.completion.unrecorded_value",
                )
                break
        cases += 1
        partial_errors, _partial_stats = validate_ui_context_contract(
            partial_calls, ui_contract
        )
        if not any("partial" in error for error in partial_errors):
            failures.append("partial context ID migration was not rejected")

        mutation_cases: list[tuple[str, dict[str, Any]]] = []
        changed = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        changed["collision_partition"]["format_equivalent"].pop("고시원", None)
        mutation_cases.append(("partition deletion", changed))
        changed = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        changed["collision_partition"]["shared_translation"]["건강"] = [
            "BODY", "HEALTH", "Health"
        ]
        mutation_cases.append(("partition overlap", changed))
        changed = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        next(
            row for row in changed["context_registry"]
            if row.get("id") == "ui.credit.standard_grade"
        )["allowed_en"] = ["Normal"]
        mutation_cases.append(("context English", changed))
        changed = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        next(
            row for row in changed["context_registry"]
            if row.get("id") == "ui.credit.standard_grade"
        )["callsites"][0]["count"] += 1
        mutation_cases.append(("context count", changed))
        changed = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        changed["context_registry"].append(changed["context_registry"][0].copy())
        mutation_cases.append(("duplicate context ID", changed))
        for label, changed_contract in mutation_cases:
            cases += 1
            mutation_errors, _stats = validate_ui_context_contract(
                ui_inventory.calls, changed_contract
            )
            if not mutation_errors:
                failures.append(f"{label} mutation was not rejected")
        if failures:
            print(
                f"JA_TRANSLATE_SELF_TEST_FAIL cases={cases} "
                f"errors={len(failures)}"
            )
            for failure in failures:
                print(f"  {failure}")
            return 1
        print(
            "JA_TRANSLATE_SELF_TEST_OK "
            f"cases={cases} entries={expected_entries} merge=non_destructive "
            f"ui={ui_inventory.stats.get('legacy_keys', 0)} "
            f"context={ui_inventory.stats.get('context_calls', 0)}/"
            f"{ui_inventory.stats.get('planned_context_calls', 0)}"
        )
        return 0

    authorization_error = body_authorization_error(
        args.scope, args.allow_body, args.allow_full_body
    )
    if authorization_error == "demo_text_freeze_required" and not args.inventory:
        print(
            "BODY_TRANSLATION_HELD scope="
            f"{args.scope} reason=demo_text_freeze_required "
            "hint=use_--allow-body_only_after_the_approved_24-week_source_text_is_final",
            file=sys.stderr,
        )
        return 2
    if authorization_error == "full_game_GO_required" and not args.inventory:
        print(
            "BODY_TRANSLATION_HELD scope="
            f"{args.scope} reason=full_game_GO_required "
            "hint=demo_GO_only_allows_--scope_demo",
            file=sys.stderr,
        )
        return 2

    collectors = {
        "demo": collect_demo,
        "events": collect_events,
        "endings": collect_endings,
        "ui": collect_ui,
        "catalog": collect_catalog,
    }
    scopes = ("events", "endings", "ui", "catalog") \
        if args.scope == "all" else (args.scope,)
    if args.inventory:
        for scope in scopes:
            if scope == "ui":
                ui_inventory = collect_ui_inventory()
                if ui_inventory.errors:
                    print(
                        f"JA_TRANSLATE_INVENTORY_FAIL scope=ui "
                        f"errors={len(ui_inventory.errors)}"
                    )
                    for error in ui_inventory.errors:
                        print(f"  {error}")
                    return 1
                entries, _blueprint = ui_inventory.entries, ui_inventory.blueprint
            else:
                entries, _blueprint = collectors[scope]()
            if scope == "demo":
                event_count = sum(
                    1 for entry in entries if entry.key.startswith("event::")
                )
                dynamic_count = sum(
                    1 for entry in entries if entry.key.startswith("demo-ui::")
                )
                catalog_count = sum(
                    1 for entry in entries
                    if entry.key.startswith("demo-catalog::")
                )
                print(
                    "JA_TRANSLATE_INVENTORY scope=demo "
                    f"entries={len(entries)} events={event_count} "
                    f"dynamic={dynamic_count} catalog={catalog_count} endings=0"
                )
            elif scope == "ui":
                stats = ui_inventory.stats
                print(
                    "JA_TRANSLATE_INVENTORY scope=ui "
                    f"entries={len(entries)} legacy_keys={stats['legacy_keys']} "
                    f"legacy_calls={stats['legacy_calls']} "
                    f"context_ids={stats['migrated_context_ids']}/"
                    f"{stats['planned_context_ids']} context_calls="
                    f"{stats['context_calls']}/{stats['planned_context_calls']} "
                    "partition="
                    f"{stats['format_equivalent']}+{stats['shared_translation']}+"
                    f"{stats['context_split']}"
                )
            else:
                print(
                    f"JA_TRANSLATE_INVENTORY scope={scope} entries={len(entries)}"
                )
        return 0
    cache = load_cache()
    for scope in scopes:
        if scope == "ui":
            ui_inventory = collect_ui_inventory()
            if ui_inventory.errors:
                print(f"UI_CONTEXT_CONTRACT_FAIL errors={len(ui_inventory.errors)}")
                for error in ui_inventory.errors:
                    print(f"  {error}")
                return 1
            entries, blueprint = ui_inventory.entries, ui_inventory.blueprint
        else:
            entries, blueprint = collectors[scope]()
        drafts: dict[str, str] = {}
        translated: dict[str, str] = {}
        missing_drafts: list[Entry] = []
        missing_review: list[Entry] = []
        for entry in entries:
            exact = exact_translation_for_entry(entry)
            if exact is not None:
                translated[entry.key] = exact
                drafts[entry.key] = exact
                cache[entry.key] = {
                    "source_hash": entry.source_hash,
                    "draft_text": exact,
                    "text": exact,
                    "review_version": "exact",
                }
                continue
            cached = cache.get(entry.key, {})
            cached_matches = cached.get("source_hash") == entry.source_hash
            draft = cached.get("draft_text", cached.get("text")) if cached_matches else None
            final = cached.get("text") if cached_matches else None
            if isinstance(draft, str):
                draft = normalize_translation_for_entry(entry, draft)
            if isinstance(final, str):
                final = normalize_translation_for_entry(entry, final)
            if isinstance(draft, str) and not validate_translation(entry, draft):
                drafts[entry.key] = draft
                if (
                    cached.get("review_version") == REVIEW_VERSION
                    and isinstance(final, str)
                    and not validate_translation(entry, final)
                ):
                    translated[entry.key] = final
                else:
                    missing_review.append(entry)
            else:
                missing_drafts.append(entry)
        pending_batches = list(batches(missing_drafts, max(500, args.batch_chars)))
        if args.limit_batches > 0:
            pending_batches = pending_batches[: args.limit_batches]
        print(
            f"JA_TRANSLATE scope={scope} entries={len(entries)} final={len(translated)} "
            f"drafts={len(drafts)} missing_drafts={len(missing_drafts)} "
            f"draft_batches={len(pending_batches)}",
            flush=True,
        )
        for index, batch in enumerate(pending_batches, start=1):
            started = time.monotonic()
            result = translate_batch(args.model, batch)
            drafts.update(result)
            missing_review.extend(batch)
            for entry in batch:
                cache[entry.key] = {
                    "source_hash": entry.source_hash,
                    "draft_text": result[entry.key],
                }
            save_cache(cache)
            elapsed = time.monotonic() - started
            print(
                f"  batch {index}/{len(pending_batches)} rows={len(batch)} "
                f"seconds={elapsed:.1f} cache={len(cache)}",
                flush=True,
            )
        unresolved_drafts = [entry.key for entry in entries if entry.key not in drafts]
        if unresolved_drafts:
            print(
                f"JA_TRANSLATE_PARTIAL scope={scope} unresolved={len(unresolved_drafts)} "
                f"(rerun without --limit-batches)",
                flush=True,
            )
            continue
        review_keys = {row.key for row in missing_review}
        review_entries = [
            entry for entry in entries
            if entry.key not in translated and entry.key in review_keys
        ]
        review_batches = list(batches(review_entries, max(500, args.batch_chars)))
        print(
            f"JA_REVIEW scope={scope} pending={len(review_entries)} batches={len(review_batches)}",
            flush=True,
        )
        for index, batch in enumerate(review_batches, start=1):
            started = time.monotonic()
            result = review_batch(args.model, batch, drafts)
            translated.update(result)
            for entry in batch:
                cache[entry.key] = {
                    "source_hash": entry.source_hash,
                    "draft_text": drafts[entry.key],
                    "text": result[entry.key],
                    "review_version": REVIEW_VERSION,
                }
            save_cache(cache)
            elapsed = time.monotonic() - started
            print(
                f"  review {index}/{len(review_batches)} rows={len(batch)} "
                f"seconds={elapsed:.1f} cache={len(cache)}",
                flush=True,
            )
        unresolved = [entry.key for entry in entries if entry.key not in translated]
        if unresolved:
            print(f"JA_REVIEW_PARTIAL scope={scope} unresolved={len(unresolved)}", flush=True)
            continue
        write_scope(scope, blueprint, translated)
        print(f"JA_TRANSLATE_WRITTEN scope={scope} entries={len(entries)}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
