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
    # `_planner_copy` is a stable literal-pair reader whose third argument only
    # selects explicit English; its Korean branch still reaches LocaleManager.ui.
    r'(?:\b_tr|LocaleManager\.ui|\b_planner_copy)\(\s*'
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
RAW_UI_FORMAT_CALL = re.compile(r"LocaleManager\.ui_format\s*\(")
RAW_WHOLE_WON_CALL = re.compile(r"LocaleManager\.format_whole_won\s*\(")
UI_PAIR_CALL_START = re.compile(
    r"(?<![A-Za-z0-9_])(?:LocaleManager\.ui(?![_A-Za-z0-9])|_tr)\s*\("
)
UI_FORMAT_CALL_START = re.compile(r"LocaleManager\.ui_format\s*\(")
GD_STRING_LITERAL = re.compile(r'"(?:\\.|[^"\\])*"', re.DOTALL)
GD_FUNCTION = re.compile(
    r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z0-9_]+)\s*\("
)
UI_CONTEXT_ID = re.compile(r"^ui\.[a-z0-9]+(?:[._][a-z0-9]+)*$")
UI_CONTEXT_MANIFEST_PATH = ROOT / "content/meta/demo_localization_scope.json"
ORDER96_HISTORICAL_UI_BASELINE = {
    "legacy_pair_call_occurrences": 3254,
    "post_migration_legacy_pair_call_occurrences": 3217,
    "legacy_korean_source_keys": 2730,
    "legacy_korean_source_keys_sha256": (
        "b67df90ba814deeac78db1b1bc4836d16596b6b93521e97a34427ae3b2bcb222"
    ),
}
ORDER96_HISTORICAL_CONTEXT_CALLS = 37
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")
JAPANESE = re.compile(r"[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff]")
PLACEHOLDER = re.compile(
    r"\{[^{}]+\}|%(?:\d+\$)?[-+#0 .\d]*[a-zA-Z]|"
    r"\[/?(?:b|i|u|s|center|right|fill|color(?:=[^\]]+)?|font(?:=[^\]]+)?|"
    r"font_size(?:=[^\]]+)?|url(?:=[^\]]+)?|img(?:=[^\]]+)?)]"
)
UI_PRINTF_MAX_WIDTH = 64
UI_PRINTF_MAX_PRECISION = 12
UI_PRINTF_CONVERSIONS = frozenset("scdoxXfv")
UI_PRINTF_POSITIVE_CONVERSIONS = frozenset("doxXf")
UI_PRINTF_PRECISION_CONVERSIONS = frozenset("fv")
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
    format_template: bool = False

    @property
    def source_hash(self) -> str:
        payload = f"{PROMPT_VERSION}\0{self.source}"
        if self.context_id:
            payload += f"\0{self.context_id}\0{self.context}"
        if self.format_template:
            payload += "\0ui_format"
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
class UiParameterizedObservation:
    path: str
    function: str
    line: int
    state: str
    korean: str | tuple[str, ...]
    english: str | tuple[str, ...]


@dataclass(frozen=True)
class UiFormatArgumentShape:
    path: str
    function: str
    line: int
    korean: str
    english: str
    ko_args: str
    en_args: str


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
    stats: dict[str, Any]

    @property
    def entries(self) -> list[Entry]:
        return [*self.legacy_entries, *self.observed_context_entries]

    @property
    def blueprint(self) -> dict[str, Any]:
        return {**self.legacy_blueprint, **self.observed_context_blueprint}


def read_json(path: pathlib.Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def duplicate_json_object_keys_from_text(text: str) -> list[str]:
    duplicates: list[str] = []

    def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        output: dict[str, Any] = {}
        for key, value in pairs:
            if key in output:
                duplicates.append(key)
            output[key] = value
        return output

    json.loads(text, object_pairs_hook=unique_object)
    return sorted(set(duplicates))


def duplicate_json_object_keys(path: pathlib.Path) -> list[str]:
    return duplicate_json_object_keys_from_text(path.read_text(encoding="utf-8"))


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


def _balanced_call_body(source: str, start: int) -> tuple[str, int]:
    """Return one GDScript call body and the byte after its closing paren."""
    opening = source.find("(", start)
    if opening < 0:
        raise ValueError("call has no opening parenthesis")
    depth = 0
    in_string = False
    escaped = False
    in_comment = False
    for index in range(opening, len(source)):
        character = source[index]
        if in_comment:
            if character == "\n":
                in_comment = False
            continue
        if in_string:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == '"':
                in_string = False
            continue
        if character == "#":
            in_comment = True
        elif character == '"':
            in_string = True
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                return source[opening + 1:index], index + 1
    raise ValueError("unterminated GDScript call")


def _split_gd_arguments(body: str) -> list[str]:
    arguments: list[str] = []
    start = 0
    depths = {"(": 0, "[": 0, "{": 0}
    closers = {")": "(", "]": "[", "}": "{"}
    in_string = False
    escaped = False
    in_comment = False
    for index, character in enumerate(body):
        if in_comment:
            if character == "\n":
                in_comment = False
            continue
        if in_string:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == '"':
                in_string = False
            continue
        if character == "#":
            in_comment = True
        elif character == '"':
            in_string = True
        elif character in depths:
            depths[character] += 1
        elif character in closers:
            depths[closers[character]] -= 1
        elif character == "," and not any(depths.values()):
            arguments.append(body[start:index].strip())
            start = index + 1
    arguments.append(body[start:].strip())
    return arguments


def _expression_literals_and_percent_ops(
    expression: str,
) -> tuple[list[tuple[int, int, int, str]], list[tuple[int, int]]]:
    """Lex string literals and real `%` operators, excluding literal `%` text."""
    literals: list[tuple[int, int, int, str]] = []
    operators: list[tuple[int, int]] = []
    depth = 0
    index = 0
    in_comment = False
    while index < len(expression):
        character = expression[index]
        if in_comment:
            if character == "\n":
                in_comment = False
            index += 1
            continue
        if character == "#":
            in_comment = True
            index += 1
            continue
        if character == '"':
            start = index
            index += 1
            escaped = False
            while index < len(expression):
                if escaped:
                    escaped = False
                elif expression[index] == "\\":
                    escaped = True
                elif expression[index] == '"':
                    index += 1
                    break
                index += 1
            raw = expression[start:index]
            try:
                value = decode_gd_string(raw)
            except (ValueError, json.JSONDecodeError):
                value = raw[1:-1]
            literals.append((start, index, depth, value))
            continue
        if character in "([{":
            depth += 1
        elif character in ")]}":
            depth -= 1
        elif character == "%":
            operators.append((index, depth))
        index += 1
    return literals, operators


def _outer_printf_template(expression: str) -> str | None:
    literals, operators = _expression_literals_and_percent_ops(expression)
    if not operators:
        return None
    operator, _depth = min(operators, key=lambda item: (item[1], item[0]))
    preceding = [literal for literal in literals if literal[1] <= operator]
    if not preceding:
        return None
    return max(preceding, key=lambda literal: literal[1])[3]


def _has_condition_outside_strings(expression: str) -> bool:
    stripped = GD_STRING_LITERAL.sub('""', expression)
    stripped = re.sub(r"(?m)#.*$", "", stripped)
    return re.search(r"\bif\b", stripped) is not None


def _all_string_literals(expression: str) -> tuple[str, ...]:
    literals, _operators = _expression_literals_and_percent_ops(expression)
    return tuple(literal[3] for literal in literals)


def _ui_template_signature(template: str) -> list[str]:
    return PLACEHOLDER.findall(template)


def _normalize_gd_expression(expression: str) -> str:
    """Remove layout/comments while preserving bytes inside string literals."""
    output: list[str] = []
    index = 0
    in_comment = False
    while index < len(expression):
        character = expression[index]
        if in_comment:
            if character == "\n":
                in_comment = False
            index += 1
            continue
        if character == "#":
            in_comment = True
            index += 1
            continue
        if character == '"':
            start = index
            index += 1
            escaped = False
            while index < len(expression):
                if escaped:
                    escaped = False
                elif expression[index] == "\\":
                    escaped = True
                elif expression[index] == '"':
                    index += 1
                    break
                index += 1
            output.append(expression[start:index])
            continue
        if not character.isspace() and character != "\\":
            output.append(character)
        index += 1
    return "".join(output)


def _function_owner(
    functions: list[tuple[int, str]], offset: int,
) -> str:
    function_offsets = [position for position, _name in functions]
    index = bisect.bisect_right(function_offsets, offset) - 1
    return functions[index][1] if index >= 0 else "<module>"


def collect_ui_parameterized_observations() -> tuple[
    list[UiParameterizedObservation], list[str]
]:
    """Collect the locked preformat disposition set and later registered rows.

    The original defect set consists of 53 pair calls containing a real `%`
    operator and two conditional template calls that already format after
    lookup. During migration, `ui_format` replaces only the 47 migrate rows;
    two already-safe lookup-before-format calls are registered separately when
    their target and explicit-English argument provenance diverges.
    `format_whole_won` replaces only the two local money owners.
    """
    observations: list[UiParameterizedObservation] = []
    errors: list[str] = []
    for directory in RUNTIME_DIRS:
        for path in sorted((ROOT / directory).rglob("*.gd")):
            relative_path = str(path.relative_to(ROOT))
            source = path.read_text(encoding="utf-8")
            functions = [
                (match.start(), match.group(1))
                for match in GD_FUNCTION.finditer(source)
            ]
            for match in UI_PAIR_CALL_START.finditer(source):
                try:
                    body, end = _balanced_call_body(source, match.start())
                except ValueError as exc:
                    errors.append(f"{relative_path}: malformed UI pair call: {exc}")
                    continue
                arguments = _split_gd_arguments(body)
                if len(arguments) < 2:
                    continue
                korean_literals, korean_ops = (
                    _expression_literals_and_percent_ops(arguments[0])
                )
                english_literals, english_ops = (
                    _expression_literals_and_percent_ops(arguments[1])
                )
                function = _function_owner(functions, match.start())
                line = source.count("\n", 0, match.start()) + 1
                if korean_ops or english_ops:
                    korean = _outer_printf_template(arguments[0])
                    english = _outer_printf_template(arguments[1])
                    if korean is None or english is None:
                        errors.append(
                            f"{relative_path}:{line}: preformat pair lacks two "
                            "literal templates"
                        )
                        continue
                    observations.append(UiParameterizedObservation(
                        relative_path, function, line, "preformat", korean, english
                    ))
                    continue
                suffix = source[end:end + 96]
                if _has_condition_outside_strings(arguments[0]) \
                        and _has_condition_outside_strings(arguments[1]) \
                        and re.match(r"\s*\.format\s*\(", suffix):
                    observations.append(UiParameterizedObservation(
                        relative_path,
                        function,
                        line,
                        "branch_selected",
                        tuple(literal[3] for literal in korean_literals),
                        tuple(literal[3] for literal in english_literals),
                    ))

            for match in UI_FORMAT_CALL_START.finditer(source):
                try:
                    body, _end = _balanced_call_body(source, match.start())
                except ValueError as exc:
                    errors.append(f"{relative_path}: malformed ui_format call: {exc}")
                    continue
                arguments = _split_gd_arguments(body)
                if len(arguments) != 4:
                    line = source.count("\n", 0, match.start()) + 1
                    errors.append(
                        f"{relative_path}:{line}: ui_format requires exactly four arguments"
                    )
                    continue
                try:
                    korean = decode_gd_string(arguments[0])
                    english = decode_gd_string(arguments[1])
                except (ValueError, json.JSONDecodeError):
                    line = source.count("\n", 0, match.start()) + 1
                    errors.append(
                        f"{relative_path}:{line}: ui_format requires two literal templates"
                    )
                    continue
                observations.append(UiParameterizedObservation(
                    relative_path,
                    _function_owner(functions, match.start()),
                    source.count("\n", 0, match.start()) + 1,
                    "migrated",
                    korean,
                    english,
                ))

            for match in RAW_WHOLE_WON_CALL.finditer(source):
                observations.append(UiParameterizedObservation(
                    relative_path,
                    _function_owner(functions, match.start()),
                    source.count("\n", 0, match.start()) + 1,
                    "money_migrated",
                    "",
                    "",
                ))
    observations.sort(key=lambda row: (
        row.path, row.function, row.line, row.state,
    ))
    return observations, errors


def collect_ui_format_argument_shapes() -> tuple[
    list[UiFormatArgumentShape], list[str]
]:
    shapes: list[UiFormatArgumentShape] = []
    errors: list[str] = []
    for directory in RUNTIME_DIRS:
        for path in sorted((ROOT / directory).rglob("*.gd")):
            relative_path = str(path.relative_to(ROOT))
            source = path.read_text(encoding="utf-8")
            functions = [
                (match.start(), match.group(1))
                for match in GD_FUNCTION.finditer(source)
            ]
            for match in UI_FORMAT_CALL_START.finditer(source):
                line = source.count("\n", 0, match.start()) + 1
                try:
                    body, _end = _balanced_call_body(source, match.start())
                    arguments = _split_gd_arguments(body)
                    if len(arguments) != 4:
                        raise ValueError("requires exactly four arguments")
                    korean = decode_gd_string(arguments[0])
                    english = decode_gd_string(arguments[1])
                except (ValueError, json.JSONDecodeError) as exc:
                    errors.append(
                        f"{relative_path}:{line}: cannot collect ui_format "
                        f"argument provenance ({exc})"
                    )
                    continue
                shapes.append(UiFormatArgumentShape(
                    relative_path,
                    _function_owner(functions, match.start()),
                    line,
                    korean,
                    english,
                    _normalize_gd_expression(arguments[2]),
                    _normalize_gd_expression(arguments[3]),
                ))
    shapes.sort(key=lambda row: (row.path, row.function, row.line))
    return shapes, errors


def parse_ui_calls(relative_path: str, source: str) -> tuple[list[UiCall], list[str]]:
    """Read literal legacy/context/format UI calls with stable function owners."""
    functions = [(match.start(), match.group(1)) for match in GD_FUNCTION.finditer(source)]
    function_offsets = [offset for offset, _name in functions]
    parsed_context_offsets: set[int] = set()
    parsed_format_offsets: set[int] = set()
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

    for match in UI_FORMAT_CALL_START.finditer(source):
        parsed_format_offsets.add(match.start())
        try:
            body, _end = _balanced_call_body(source, match.start())
        except ValueError as exc:
            errors.append(f"{relative_path}: malformed ui_format call ({exc})")
            continue
        arguments = _split_gd_arguments(body)
        line = source.count("\n", 0, match.start()) + 1
        if len(arguments) != 4:
            errors.append(
                f"{relative_path}:{line}: ui_format requires exactly four arguments"
            )
            continue
        try:
            korean = decode_gd_string(arguments[0])
            english = decode_gd_string(arguments[1])
        except (ValueError, json.JSONDecodeError) as exc:
            errors.append(
                f"{relative_path}:{line}: ui_format requires two literal templates ({exc})"
            )
            continue
        if not korean.strip():
            errors.append(f"{relative_path}:{line}: empty Korean format template")
            continue
        calls.append(UiCall(
            path=relative_path,
            function=owner(match.start()),
            line=line,
            api="format",
            korean=korean,
            english=english,
        ))

    # A conditional expression can still choose a stable literal template
    # before lookup. Expand each reachable literal pair into the translation
    # inventory even though the source contains one runtime call.
    for match in UI_PAIR_CALL_START.finditer(source):
        try:
            body, end = _balanced_call_body(source, match.start())
        except ValueError:
            continue
        arguments = _split_gd_arguments(body)
        if len(arguments) < 2 \
                or not _has_condition_outside_strings(arguments[0]) \
                or not _has_condition_outside_strings(arguments[1]) \
                or not re.match(r"\s*\.format\s*\(", source[end:end + 96]):
            continue
        korean_variants = _all_string_literals(arguments[0])
        english_variants = _all_string_literals(arguments[1])
        line = source.count("\n", 0, match.start()) + 1
        if len(korean_variants) != len(english_variants) \
                or len(korean_variants) < 2:
            errors.append(
                f"{relative_path}:{line}: branch-selected UI variants must "
                "form aligned literal KO/EN pairs"
            )
            continue
        for korean, english in zip(korean_variants, english_variants):
            calls.append(UiCall(
                path=relative_path,
                function=owner(match.start()),
                line=line,
                api="branch",
                korean=korean,
                english=english,
            ))

    raw_context_offsets = {match.start() for match in RAW_UI_CONTEXT_CALL.finditer(source)}
    for offset in sorted(raw_context_offsets - parsed_context_offsets):
        line = source.count("\n", 0, offset) + 1
        errors.append(
            f"{relative_path}:{line}: ui_context requires three literal string arguments"
        )
    raw_format_offsets = {match.start() for match in RAW_UI_FORMAT_CALL.finditer(source)}
    for offset in sorted(raw_format_offsets - parsed_format_offsets):
        line = source.count("\n", 0, offset) + 1
        errors.append(
            f"{relative_path}:{line}: ui_format requires four arguments with "
            "literal Korean/English templates"
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


def _candidate_selector(
    path: str, function: str, korean: str | tuple[str, ...] | list[str],
    english: str | tuple[str, ...] | list[str],
) -> tuple[str, str, str, str]:
    def encode(value: str | tuple[str, ...] | list[str]) -> str:
        if isinstance(value, str):
            return value
        return json.dumps(list(value), ensure_ascii=False, separators=(",", ":"))
    return path, function, encode(korean), encode(english)


def validate_ui_parameterized_contract(
    contract: dict[str, Any],
    calls: Iterable[UiCall],
    source_keys: set[str],
    observations: Optional[list[UiParameterizedObservation]] = None,
) -> tuple[list[str], dict[str, Any]]:
    """Prove the exact disposition registry and an atomic phase."""
    errors: list[str] = []
    if contract.get("schema_version") != 2:
        errors.append("manifest: UI parameterized template schema_version must be 2")
    raw_registry = contract.get("candidate_registry")
    if not isinstance(raw_registry, list):
        errors.append("manifest: parameterized candidate_registry must be an array")
        raw_registry = []

    allowed_dispositions = {
        "migrate", "dynamic_pair_reader", "branch_selected_literal",
        "locale_money_formatter",
    }
    allowed_batches = {"A", "B", "preserve"}
    required_row_keys = {
        "disposition", "batch", "path", "function", "ko", "en",
        "ko_signature", "en_signature", "ko_newlines", "en_newlines",
        "count",
    }
    registry: dict[tuple[str, str, str, str], dict[str, Any]] = {}
    disposition_counts: dict[str, int] = {
        disposition: 0 for disposition in allowed_dispositions
    }
    migration_distribution: dict[str, int] = {}
    migrate_templates: set[str] = set()
    nonbaseline_templates: set[str] = set()
    branch_variant_templates: set[str] = set()
    branch_variant_occurrences = 0
    for index, raw_row in enumerate(raw_registry):
        if not isinstance(raw_row, dict):
            errors.append(f"manifest: candidate_registry[{index}] must be an object")
            continue
        disposition = raw_row.get("disposition")
        expected_keys = set(required_row_keys)
        if disposition == "migrate":
            expected_keys.add("baseline_legacy_key")
        if set(raw_row) != expected_keys:
            errors.append(
                f"manifest: candidate_registry[{index}] fields "
                f"{sorted(raw_row)} != {sorted(expected_keys)}"
            )
        batch = raw_row.get("batch")
        path = raw_row.get("path")
        function = raw_row.get("function")
        korean = raw_row.get("ko")
        english = raw_row.get("en")
        count = raw_row.get("count")
        if disposition not in allowed_dispositions:
            errors.append(
                f"manifest: candidate_registry[{index}] invalid disposition"
            )
            continue
        expected_batch = "preserve" if disposition in {
            "dynamic_pair_reader", "branch_selected_literal"
        } else ("A" if path in {"scenes/StartMenu.gd", "scenes/StoryMode.gd"}
                else "B")
        if batch not in allowed_batches or batch != expected_batch:
            errors.append(
                f"manifest: candidate_registry[{index}] batch {batch!r} "
                f"!= {expected_batch!r}"
            )
        if not isinstance(path, str) or not path.endswith(".gd") \
                or not isinstance(function, str) or not function:
            errors.append(f"manifest: candidate_registry[{index}] owner is malformed")
            continue
        if not isinstance(count, int) or isinstance(count, bool) or count <= 0:
            errors.append(f"manifest: candidate_registry[{index}] count is malformed")
            continue
        branch_row = disposition == "branch_selected_literal"
        if branch_row:
            valid_templates = (
                isinstance(korean, list) and isinstance(english, list)
                and len(korean) == len(english) and len(korean) >= 2
                and all(isinstance(value, str) and value for value in korean)
                and all(isinstance(value, str) and value for value in english)
            )
            korean_rows = korean if isinstance(korean, list) else []
            english_rows = english if isinstance(english, list) else []
        else:
            valid_templates = (
                isinstance(korean, str) and bool(korean)
                and isinstance(english, str) and bool(english)
            )
            korean_rows = [korean] if isinstance(korean, str) else []
            english_rows = [english] if isinstance(english, str) else []
        if not valid_templates:
            errors.append(
                f"manifest: candidate_registry[{index}] KO/EN templates are malformed"
            )
            continue
        actual_ko_signature: Any = [
            _ui_template_signature(value) for value in korean_rows
        ]
        actual_en_signature: Any = [
            _ui_template_signature(value) for value in english_rows
        ]
        actual_ko_newlines: Any = [value.count("\n") for value in korean_rows]
        actual_en_newlines: Any = [value.count("\n") for value in english_rows]
        if not branch_row:
            actual_ko_signature = actual_ko_signature[0]
            actual_en_signature = actual_en_signature[0]
            actual_ko_newlines = actual_ko_newlines[0]
            actual_en_newlines = actual_en_newlines[0]
        if raw_row.get("ko_signature") != actual_ko_signature \
                or raw_row.get("en_signature") != actual_en_signature:
            errors.append(
                f"manifest: candidate_registry[{index}] placeholder signature is stale"
            )
        if raw_row.get("ko_newlines") != actual_ko_newlines \
                or raw_row.get("en_newlines") != actual_en_newlines:
            errors.append(
                f"manifest: candidate_registry[{index}] newline signature is stale"
            )
        selector = _candidate_selector(path, function, korean, english)
        if selector in registry:
            errors.append(f"manifest: duplicate parameterized selector {selector!r}")
        else:
            registry[selector] = raw_row
        disposition_counts[disposition] += count
        if disposition == "migrate":
            migration_distribution[path] = migration_distribution.get(path, 0) + count
            assert isinstance(korean, str)
            migrate_templates.add(korean)
            baseline_key = raw_row.get("baseline_legacy_key")
            if not isinstance(baseline_key, bool):
                errors.append(
                    f"manifest: candidate_registry[{index}] baseline_legacy_key "
                    "must be boolean"
                )
            elif not baseline_key:
                nonbaseline_templates.add(korean)
        elif disposition == "branch_selected_literal":
            branch_variant_templates.update(korean_rows)
            branch_variant_occurrences += len(korean_rows) * count

    declared_counts = {
        "migrate": contract.get("migrate_lookup_before_format_calls"),
        "dynamic_pair_reader": contract.get("dynamic_pair_readers"),
        "branch_selected_literal": contract.get("branch_selected_literals"),
        "locale_money_formatter": contract.get("locale_money_formatters"),
    }
    for disposition, actual_count in disposition_counts.items():
        if declared_counts.get(disposition) != actual_count:
            errors.append(
                f"manifest: {disposition} count {declared_counts.get(disposition)!r} "
                f"!= registry {actual_count}"
            )
    if contract.get("raw_candidate_expressions") != sum(disposition_counts.values()):
        errors.append(
            "manifest: raw candidate count does not equal registry dispositions"
        )
    if contract.get("callsite_distribution") != dict(sorted(migration_distribution.items())):
        errors.append("manifest: parameterized callsite_distribution is stale")
    if contract.get("migrated_templates") != len(migrate_templates):
        errors.append("manifest: migrated template count is stale")
    if contract.get("new_legacy_key_candidates") != len(nonbaseline_templates):
        errors.append("manifest: new legacy template count is stale")
    if contract.get("branch_legacy_variant_keys") != len(branch_variant_templates) \
            or contract.get("branch_legacy_variant_occurrences") \
            != branch_variant_occurrences:
        errors.append("manifest: branch legacy variant inventory is stale")
    expected_money_owners = sorted(
        f"{row['path']}::{row['function']}"
        for row in raw_registry if isinstance(row, dict)
        and row.get("disposition") == "locale_money_formatter"
    )
    if contract.get("locale_money_formatter_owners") != expected_money_owners:
        errors.append("manifest: locale money formatter owners are stale")
    registry_hash = hashlib.sha256(json.dumps(
        raw_registry, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")).hexdigest()
    if contract.get("candidate_registry_sha256") != registry_hash:
        errors.append(
            f"manifest: candidate registry SHA-256 mismatch {registry_hash}"
        )

    raw_existing_provenance = contract.get(
        "existing_lookup_before_format_provenance"
    )
    if not isinstance(raw_existing_provenance, list):
        errors.append(
            "manifest: existing_lookup_before_format_provenance must be an array"
        )
        raw_existing_provenance = []
    existing_provenance_required = {
        "batch", "path", "function", "ko", "en", "ko_signature",
        "en_signature", "ko_newlines", "en_newlines", "baseline_legacy_key",
        "ko_args", "en_args", "count",
    }
    existing_provenance_registry: dict[
        tuple[str, str, str, str, str, str], dict[str, Any]
    ] = {}
    existing_provenance_templates: dict[
        tuple[str, str, str, str], dict[str, Any]
    ] = {}
    existing_provenance_total = 0
    for index, row in enumerate(raw_existing_provenance):
        if not isinstance(row, dict):
            errors.append(
                "manifest: existing_lookup_before_format_provenance"
                f"[{index}] must be an object"
            )
            continue
        if set(row) != existing_provenance_required:
            errors.append(
                "manifest: existing_lookup_before_format_provenance"
                f"[{index}] fields are stale"
            )
        batch = row.get("batch")
        path = row.get("path")
        function = row.get("function")
        korean = row.get("ko")
        english = row.get("en")
        ko_args = row.get("ko_args")
        en_args = row.get("en_args")
        count = row.get("count")
        if batch != "B" or not all(isinstance(value, str) and value
                for value in (
                    path, function, korean, english, ko_args, en_args,
                )) or not isinstance(count, int) or isinstance(count, bool) \
                or count <= 0 or row.get("baseline_legacy_key") is not True:
            errors.append(
                "manifest: existing_lookup_before_format_provenance"
                f"[{index}] is malformed"
            )
            continue
        if ko_args == en_args:
            errors.append(
                "manifest: existing lookup-before-format provenance does not "
                "describe distinct target/English arguments"
            )
        template_selector = _candidate_selector(
            path, function, korean, english
        )
        if template_selector in registry:
            errors.append(
                "manifest: existing lookup-before-format row overlaps the parameterized "
                f"registry {template_selector!r}"
            )
        if template_selector in existing_provenance_templates:
            errors.append(
                "manifest: duplicate existing lookup-before-format template "
                f"{template_selector!r}"
            )
        else:
            existing_provenance_templates[template_selector] = row
        selector = path, function, korean, english, ko_args, en_args
        if selector in existing_provenance_registry:
            errors.append(
                "manifest: duplicate existing lookup-before-format provenance "
                f"{selector!r}"
            )
        else:
            existing_provenance_registry[selector] = row
        existing_provenance_total += count
        if row.get("ko_signature") != _ui_template_signature(korean) \
                or row.get("en_signature") != _ui_template_signature(english) \
                or row.get("ko_newlines") != korean.count("\n") \
                or row.get("en_newlines") != english.count("\n"):
            errors.append(
                "manifest: existing_lookup_before_format_provenance"
                f"[{index}] signature is stale"
            )
    if contract.get("existing_lookup_before_format_calls") \
            != existing_provenance_total:
        errors.append(
            "manifest: existing lookup-before-format migration count is stale"
        )
    existing_provenance_hash = hashlib.sha256(json.dumps(
        raw_existing_provenance, ensure_ascii=False, sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")).hexdigest()
    if contract.get("existing_lookup_before_format_provenance_sha256") \
            != existing_provenance_hash:
        errors.append(
            "manifest: existing lookup-before-format provenance SHA-256 mismatch "
            f"{existing_provenance_hash}"
        )

    raw_supplemental = contract.get("localized_argument_registry")
    if not isinstance(raw_supplemental, list):
        errors.append("manifest: localized_argument_registry must be an array")
        raw_supplemental = []
    supplemental_registry: dict[
        tuple[str, str, str, str], dict[str, Any]
    ] = {}
    supplemental_required = {
        "batch", "path", "function", "parent_ko", "parent_en",
        "argument_index", "ko", "en", "ko_signature", "en_signature",
        "ko_newlines", "en_newlines", "baseline_legacy_key", "count",
    }
    supplemental_total = 0
    supplemental_keys: set[str] = set()
    for index, row in enumerate(raw_supplemental):
        if not isinstance(row, dict):
            errors.append(
                f"manifest: localized_argument_registry[{index}] must be an object"
            )
            continue
        if set(row) != supplemental_required:
            errors.append(
                f"manifest: localized_argument_registry[{index}] fields are stale"
            )
        path = row.get("path")
        function = row.get("function")
        korean = row.get("ko")
        english = row.get("en")
        count = row.get("count")
        if row.get("batch") != "B" or not isinstance(path, str) \
                or not isinstance(function, str) or not isinstance(korean, str) \
                or not korean or not isinstance(english, str) or not english \
                or not isinstance(count, int) or isinstance(count, bool) \
                or count <= 0 or row.get("baseline_legacy_key") is not False:
            errors.append(
                f"manifest: localized_argument_registry[{index}] is malformed"
            )
            continue
        selector = path, function, korean, english
        if selector in supplemental_registry:
            errors.append(f"manifest: duplicate localized argument {selector!r}")
        else:
            supplemental_registry[selector] = row
        supplemental_total += count
        supplemental_keys.add(korean)
        if row.get("ko_signature") != _ui_template_signature(korean) \
                or row.get("en_signature") != _ui_template_signature(english) \
                or row.get("ko_newlines") != korean.count("\n") \
                or row.get("en_newlines") != english.count("\n"):
            errors.append(
                f"manifest: localized_argument_registry[{index}] signature is stale"
            )
        parent_selector = _candidate_selector(
            path, function, row.get("parent_ko", ""), row.get("parent_en", "")
        )
        parent = registry.get(parent_selector)
        argument_index = row.get("argument_index")
        if parent is None or parent.get("disposition") != "migrate" \
                or parent.get("batch") != "B" \
                or not isinstance(argument_index, int) \
                or isinstance(argument_index, bool) or argument_index < 0 \
                or argument_index >= len(parent.get("ko_signature", [])):
            errors.append(
                f"manifest: localized_argument_registry[{index}] parent is stale"
            )
    if contract.get("localized_argument_calls") != supplemental_total:
        errors.append("manifest: localized argument call count is stale")
    if contract.get("localized_argument_legacy_keys") != len(supplemental_keys):
        errors.append("manifest: localized argument key count is stale")
    supplemental_hash = hashlib.sha256(json.dumps(
        raw_supplemental, ensure_ascii=False, sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")).hexdigest()
    if contract.get("localized_argument_registry_sha256") != supplemental_hash:
        errors.append(
            f"manifest: localized argument registry SHA-256 mismatch "
            f"{supplemental_hash}"
        )

    raw_split_literals = contract.get("migrated_branch_literal_registry")
    if not isinstance(raw_split_literals, list):
        errors.append("manifest: migrated_branch_literal_registry must be an array")
        raw_split_literals = []
    split_literal_required = {
        "batch", "path", "function", "parent_ko", "parent_en", "ko", "en",
        "ko_signature", "en_signature", "ko_newlines", "en_newlines",
        "baseline_legacy_key", "count",
    }
    split_literal_registry: dict[
        tuple[str, str, str, str], dict[str, Any]
    ] = {}
    split_literal_total = 0
    split_literal_keys: set[str] = set()
    for index, row in enumerate(raw_split_literals):
        if not isinstance(row, dict):
            errors.append(
                f"manifest: migrated_branch_literal_registry[{index}] "
                "must be an object"
            )
            continue
        if set(row) != split_literal_required:
            errors.append(
                f"manifest: migrated_branch_literal_registry[{index}] "
                "fields are stale"
            )
        path = row.get("path")
        function = row.get("function")
        korean = row.get("ko")
        english = row.get("en")
        count = row.get("count")
        if row.get("batch") != "B" or not isinstance(path, str) \
                or not isinstance(function, str) or not isinstance(korean, str) \
                or not korean or not isinstance(english, str) or not english \
                or not isinstance(count, int) or isinstance(count, bool) \
                or count <= 0 or row.get("baseline_legacy_key") is not False:
            errors.append(
                f"manifest: migrated_branch_literal_registry[{index}] is malformed"
            )
            continue
        selector = path, function, korean, english
        if selector in split_literal_registry:
            errors.append(f"manifest: duplicate migrated branch literal {selector!r}")
        else:
            split_literal_registry[selector] = row
        split_literal_total += count
        split_literal_keys.add(korean)
        if row.get("ko_signature") != _ui_template_signature(korean) \
                or row.get("en_signature") != _ui_template_signature(english) \
                or row.get("ko_newlines") != korean.count("\n") \
                or row.get("en_newlines") != english.count("\n"):
            errors.append(
                f"manifest: migrated_branch_literal_registry[{index}] "
                "signature is stale"
            )
        parent = registry.get(_candidate_selector(
            path, function, row.get("parent_ko", ""), row.get("parent_en", "")
        ))
        if parent is None or parent.get("disposition") != "migrate" \
                or parent.get("batch") != "B":
            errors.append(
                f"manifest: migrated_branch_literal_registry[{index}] "
                "parent is stale"
            )
    if contract.get("migrated_branch_literal_calls") != split_literal_total:
        errors.append("manifest: migrated branch literal call count is stale")
    if contract.get("migrated_branch_literal_keys") != len(split_literal_keys):
        errors.append("manifest: migrated branch literal key count is stale")
    split_literal_hash = hashlib.sha256(json.dumps(
        raw_split_literals, ensure_ascii=False, sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")).hexdigest()
    if contract.get("migrated_branch_literal_registry_sha256") \
            != split_literal_hash:
        errors.append(
            "manifest: migrated branch literal registry SHA-256 mismatch "
            f"{split_literal_hash}"
        )

    raw_provenance = contract.get("argument_provenance_registry")
    if not isinstance(raw_provenance, list):
        errors.append("manifest: argument_provenance_registry must be an array")
        raw_provenance = []
    provenance_required = {
        "batch", "path", "function", "ko", "en", "ko_args", "en_args",
        "count",
    }
    provenance_registry: dict[
        tuple[str, str, str, str, str, str], dict[str, Any]
    ] = {}
    provenance_total = 0
    for index, row in enumerate(raw_provenance):
        if not isinstance(row, dict):
            errors.append(
                f"manifest: argument_provenance_registry[{index}] must be an object"
            )
            continue
        if set(row) != provenance_required:
            errors.append(
                f"manifest: argument_provenance_registry[{index}] fields are stale"
            )
        batch = row.get("batch")
        path = row.get("path")
        function = row.get("function")
        korean = row.get("ko")
        english = row.get("en")
        ko_args = row.get("ko_args")
        en_args = row.get("en_args")
        count = row.get("count")
        if batch not in {"A", "B"} or not all(isinstance(value, str) and value
                for value in (
                    path, function, korean, english, ko_args, en_args,
                )) or not isinstance(count, int) or isinstance(count, bool) \
                or count <= 0:
            errors.append(
                f"manifest: argument_provenance_registry[{index}] is malformed"
            )
            continue
        if ko_args == en_args:
            errors.append(
                f"manifest: argument_provenance_registry[{index}] does not "
                "describe a distinct KO/EN argument path"
            )
        selector = path, function, korean, english, ko_args, en_args
        if selector in provenance_registry:
            errors.append(f"manifest: duplicate argument provenance {selector!r}")
        else:
            provenance_registry[selector] = row
        provenance_total += count
        parent = registry.get(_candidate_selector(
            path, function, korean, english
        ))
        if parent is None or parent.get("disposition") != "migrate" \
                or parent.get("batch") != batch:
            errors.append(
                f"manifest: argument_provenance_registry[{index}] parent is stale"
            )
    if contract.get("argument_provenance_calls") != provenance_total:
        errors.append("manifest: argument provenance call count is stale")
    provenance_hash = hashlib.sha256(json.dumps(
        raw_provenance, ensure_ascii=False, sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")).hexdigest()
    if contract.get("argument_provenance_registry_sha256") != provenance_hash:
        errors.append(
            f"manifest: argument provenance registry SHA-256 mismatch "
            f"{provenance_hash}"
        )

    if observations is None:
        observations, observation_errors = collect_ui_parameterized_observations()
        errors.extend(observation_errors)
    observation_counts: dict[
        tuple[str, tuple[str, str, str, str]], int
    ] = {}
    money_migrated_counts: dict[tuple[str, str], int] = {}
    for observation in observations:
        if observation.state == "money_migrated":
            owner = observation.path, observation.function
            money_migrated_counts[owner] = money_migrated_counts.get(owner, 0) + 1
            continue
        selector = _candidate_selector(
            observation.path, observation.function,
            observation.korean, observation.english,
        )
        key = observation.state, selector
        observation_counts[key] = observation_counts.get(key, 0) + 1

    known_observation_keys: set[tuple[str, tuple[str, str, str, str]]] = set()
    migrated_selectors: set[tuple[str, str, str, str]] = set()
    money_migrated_total = 0
    for selector, row in registry.items():
        disposition = row["disposition"]
        expected_count = int(row["count"])
        if disposition == "migrate":
            legacy = observation_counts.get(("preformat", selector), 0)
            migrated = observation_counts.get(("migrated", selector), 0)
            known_observation_keys.update({
                ("preformat", selector), ("migrated", selector),
            })
            if legacy + migrated != expected_count:
                errors.append(
                    f"source: parameterized selector {selector!r} count "
                    f"{legacy + migrated} != {expected_count}"
                )
            if legacy and migrated:
                errors.append(
                    f"source: partial parameterized selector migration {selector!r} "
                    f"legacy={legacy} migrated={migrated}"
                )
            if migrated == expected_count:
                migrated_selectors.add(selector)
        elif disposition == "dynamic_pair_reader":
            actual = observation_counts.get(("preformat", selector), 0)
            known_observation_keys.add(("preformat", selector))
            if actual != expected_count:
                errors.append(
                    f"source: dynamic pair reader {selector!r} count "
                    f"{actual} != {expected_count}"
                )
        elif disposition == "branch_selected_literal":
            actual = observation_counts.get(("branch_selected", selector), 0)
            known_observation_keys.add(("branch_selected", selector))
            if actual != expected_count:
                errors.append(
                    f"source: branch-selected literal {selector!r} count "
                    f"{actual} != {expected_count}"
                )
        else:
            legacy = observation_counts.get(("preformat", selector), 0)
            known_observation_keys.add(("preformat", selector))
            owner = row["path"], row["function"]
            migrated = money_migrated_counts.get(owner, 0)
            money_migrated_total += migrated
            if legacy + migrated != expected_count:
                errors.append(
                    f"source: locale money owner {owner!r} count "
                    f"{legacy + migrated} != {expected_count}"
                )
            if legacy and migrated:
                errors.append(f"source: partial locale money migration {owner!r}")

    observed_existing_templates = 0
    for selector, row in existing_provenance_templates.items():
        key = "migrated", selector
        known_observation_keys.add(key)
        actual = observation_counts.get(key, 0)
        observed_existing_templates += actual
        if actual not in (0, row["count"]):
            errors.append(
                f"source: partial existing lookup-before-format migration "
                f"{selector!r} {actual}/{row['count']}"
            )

    for key, count in sorted(observation_counts.items(), key=str):
        if count and key not in known_observation_keys:
            errors.append(f"source: extra/unclassified parameterized row {key!r} x{count}")
    money_owners = {
        (row["path"], row["function"])
        for row in raw_registry if isinstance(row, dict)
        and row.get("disposition") == "locale_money_formatter"
    }
    for owner, count in sorted(money_migrated_counts.items()):
        if owner not in money_owners:
            errors.append(f"source: extra locale money formatter call {owner!r} x{count}")

    phase_selectors = {
        "baseline": set(),
        "batch_a": {
            selector for selector, row in registry.items()
            if row.get("disposition") == "migrate" and row.get("batch") == "A"
        },
        "batch_b": {
            selector for selector, row in registry.items()
            if row.get("disposition") == "migrate" and row.get("batch") == "B"
        },
        "final": {
            selector for selector, row in registry.items()
            if row.get("disposition") == "migrate"
        },
    }
    observed_phase = "invalid_partial"
    for phase_name, expected_selectors in phase_selectors.items():
        if migrated_selectors == expected_selectors:
            observed_phase = phase_name
            break
    if observed_phase == "invalid_partial":
        errors.append(
            "source: parameterized migration is not an atomic baseline/Batch A/"
            "Batch B/final phase"
        )
    expected_existing_templates = (
        existing_provenance_total
        if observed_phase in {"batch_b", "final"} else 0
    )
    if observed_existing_templates != expected_existing_templates:
        errors.append(
            f"source: phase {observed_phase} existing lookup-before-format "
            f"migrations {observed_existing_templates} "
            f"!= {expected_existing_templates}"
        )

    format_shapes, format_shape_errors = collect_ui_format_argument_shapes()
    errors.extend(format_shape_errors)
    observed_provenance: dict[
        tuple[str, str, str, str, str, str], int
    ] = {}
    observed_existing_provenance: dict[
        tuple[str, str, str, str, str, str], int
    ] = {}
    for shape in format_shapes:
        if shape.ko_args == shape.en_args:
            continue
        selector = (
            shape.path, shape.function, shape.korean, shape.english,
            shape.ko_args, shape.en_args,
        )
        if selector in existing_provenance_registry:
            observed_existing_provenance[selector] = (
                observed_existing_provenance.get(selector, 0) + 1
            )
            continue
        observed_provenance[selector] = observed_provenance.get(selector, 0) + 1
    expected_provenance_total = 0
    active_batches = {
        "baseline": set(), "batch_a": {"A"}, "batch_b": {"B"},
        "final": {"A", "B"},
    }.get(observed_phase, set())
    for selector, row in provenance_registry.items():
        expected_count = row["count"] if row["batch"] in active_batches else 0
        expected_provenance_total += expected_count
        actual = observed_provenance.get(selector, 0)
        if actual != expected_count:
            errors.append(
                f"source: argument provenance {selector!r} count "
                f"{actual} != {expected_count}"
            )
    for selector, count in sorted(observed_provenance.items()):
        if selector not in provenance_registry:
            errors.append(
                f"source: extra/unclassified argument provenance "
                f"{selector!r} x{count}"
            )
    if sum(observed_provenance.values()) != expected_provenance_total:
        errors.append(
            "source: argument provenance phase total is stale"
        )
    expected_existing_provenance_total = 0
    for selector, row in existing_provenance_registry.items():
        expected_count = row["count"] if row["batch"] in active_batches else 0
        expected_existing_provenance_total += expected_count
        actual = observed_existing_provenance.get(selector, 0)
        if actual != expected_count:
            errors.append(
                f"source: existing lookup-before-format provenance "
                f"{selector!r} count {actual} != {expected_count}"
            )
    for selector, count in sorted(observed_existing_provenance.items()):
        if selector not in existing_provenance_registry:
            errors.append(
                "source: extra existing lookup-before-format provenance "
                f"{selector!r} x{count}"
            )
    if sum(observed_existing_provenance.values()) \
            != expected_existing_provenance_total:
        errors.append(
            "source: existing lookup-before-format provenance phase total is stale"
        )
    expected_money_migrations = 2 if observed_phase in {"batch_b", "final"} else 0
    if money_migrated_total != expected_money_migrations:
        errors.append(
            f"source: phase {observed_phase} money migrations "
            f"{money_migrated_total} != {expected_money_migrations}"
        )

    call_rows = tuple(calls)
    supplemental_counts: dict[tuple[str, str, str, str], int] = {}
    for call in call_rows:
        if call.api != "legacy":
            continue
        selector = call.path, call.function, call.korean, call.english
        if selector in supplemental_registry:
            supplemental_counts[selector] = supplemental_counts.get(selector, 0) + 1
    observed_supplemental = sum(supplemental_counts.values())
    for selector, row in supplemental_registry.items():
        actual = supplemental_counts.get(selector, 0)
        if actual not in (0, row["count"]):
            errors.append(
                f"source: partial localized argument {selector!r} "
                f"{actual}/{row['count']}"
            )
    expected_supplemental = (
        supplemental_total if observed_phase in {"batch_b", "final"} else 0
    )
    if observed_supplemental != expected_supplemental:
        errors.append(
            f"source: phase {observed_phase} localized arguments "
            f"{observed_supplemental} != {expected_supplemental}"
        )
    split_literal_counts: dict[tuple[str, str, str, str], int] = {}
    for call in call_rows:
        if call.api != "legacy":
            continue
        selector = call.path, call.function, call.korean, call.english
        if selector in split_literal_registry:
            split_literal_counts[selector] = split_literal_counts.get(selector, 0) + 1
    observed_split_literals = sum(split_literal_counts.values())
    for selector, row in split_literal_registry.items():
        actual = split_literal_counts.get(selector, 0)
        if actual not in (0, row["count"]):
            errors.append(
                f"source: partial migrated branch literal {selector!r} "
                f"{actual}/{row['count']}"
            )
    expected_split_literals = (
        split_literal_total if observed_phase in {"batch_b", "final"} else 0
    )
    if observed_split_literals != expected_split_literals:
        errors.append(
            f"source: phase {observed_phase} migrated branch literals "
            f"{observed_split_literals} != {expected_split_literals}"
        )
    legacy_calls = [call for call in call_rows if call.api in {"legacy", "format"}]
    legacy_calls.extend(call for call in call_rows if call.api == "branch")
    context_calls = [call for call in call_rows if call.api == "context"]
    phase_contracts = contract.get("source_inventory_phases")
    if not isinstance(phase_contracts, dict) or set(phase_contracts) != set(phase_selectors):
        errors.append(
            "manifest: source_inventory_phases must contain baseline, batch_a, "
            "batch_b, and final"
        )
        phase_contracts = {}
    expected_phase = phase_contracts.get(observed_phase, {})
    if not isinstance(expected_phase, dict):
        errors.append(f"manifest: source inventory phase {observed_phase} is malformed")
        expected_phase = {}
    actual_inventory = {
        "migrated_calls": sum(
            int(registry[selector]["count"]) for selector in migrated_selectors
        ),
        "existing_lookup_before_format_migrations": observed_existing_templates,
        "money_formatter_migrations": money_migrated_total,
        "localized_argument_calls": observed_supplemental,
        "migrated_branch_literal_calls": observed_split_literals,
        "total_ui_call_occurrences": len(call_rows),
        "legacy_pair_call_occurrences": len(legacy_calls),
        "context_call_occurrences": len(context_calls),
        "legacy_korean_source_keys": len(source_keys),
        "legacy_korean_source_keys_sha256": hashlib.sha256(
            "\n".join(sorted(source_keys)).encode("utf-8")
        ).hexdigest(),
    }
    if expected_phase != actual_inventory:
        errors.append(
            f"manifest: {observed_phase} source inventory {expected_phase!r} "
            f"!= observed {actual_inventory!r}"
        )
    return errors, {
        **actual_inventory,
        "observed_phase": observed_phase,
        "registry_rows": len(registry),
        "raw_candidates": sum(disposition_counts.values()),
        "migrate_calls": disposition_counts["migrate"],
        "migrated_templates": len(migrate_templates),
        "new_templates": len(nonbaseline_templates),
        "branch_variant_keys": len(branch_variant_templates),
        "localized_argument_keys": len(supplemental_keys),
        "migrated_branch_literal_keys": len(split_literal_keys),
        "argument_provenance_calls": sum(observed_provenance.values()),
        "existing_lookup_before_format_provenance_calls": sum(
            observed_existing_provenance.values()
        ),
    }


def validate_ui_context_contract(
    calls: list[UiCall] | tuple[UiCall, ...],
    contract: Optional[dict[str, Any]] = None,
    parameter_contract: Optional[dict[str, Any]] = None,
) -> tuple[list[str], dict[str, int]]:
    """Validate the immutable 107-key plan separately from observed migration."""
    if contract is None:
        contract = read_ui_context_contract()
    if parameter_contract is None:
        manifest = read_json(UI_CONTEXT_MANIFEST_PATH)
        raw_parameter_contract = manifest.get("ui_parameterized_template_plan")
        parameter_contract = (
            raw_parameter_contract if isinstance(raw_parameter_contract, dict) else {}
        )
    errors: list[str] = []
    if contract.get("schema_version") != 1:
        errors.append("manifest: ui semantic context schema_version must be 1")

    legacy_api_calls = [call for call in calls if call.api == "legacy"]
    branch_calls = [call for call in calls if call.api == "branch"]
    format_calls = [call for call in calls if call.api == "format"]
    legacy_calls = [*legacy_api_calls, *branch_calls, *format_calls]
    context_calls = [call for call in calls if call.api == "context"]
    source_keys = {call.korean for call in calls}
    variants: dict[str, set[str]] = {}
    for call in calls:
        variants.setdefault(call.korean, set()).add(call.english)
    collisions = {key: values for key, values in variants.items() if len(values) > 1}

    historical_baseline = {
        key: contract.get(key) for key in ORDER96_HISTORICAL_UI_BASELINE
    }
    if historical_baseline != ORDER96_HISTORICAL_UI_BASELINE:
        errors.append(
            "manifest: ORDER-96 historical UI baseline drifted "
            f"{historical_baseline!r}"
        )
    current_snapshot = contract.get("current_source_snapshot")
    snapshot_fields = set(ORDER96_HISTORICAL_UI_BASELINE)
    if not isinstance(current_snapshot, dict) \
            or set(current_snapshot) != snapshot_fields:
        errors.append(
            "manifest: current_source_snapshot must contain exactly the "
            "four legacy inventory fields"
        )
        current_snapshot = {}
    baseline_calls = current_snapshot.get("legacy_pair_call_occurrences")
    supplemental_rows = parameter_contract.get(
        "localized_argument_registry", []
    )
    split_literal_rows = parameter_contract.get(
        "migrated_branch_literal_registry", []
    )
    existing_format_rows = parameter_contract.get(
        "existing_lookup_before_format_provenance", []
    )
    supplemental_selectors = {
        (
            row.get("path"), row.get("function"),
            row.get("ko"), row.get("en"),
        )
        for row in supplemental_rows if isinstance(row, dict)
    }
    supplemental_calls = [
        call for call in legacy_api_calls
        if (call.path, call.function, call.korean, call.english)
        in supplemental_selectors
    ]
    split_literal_selectors = {
        (
            row.get("path"), row.get("function"),
            row.get("ko"), row.get("en"),
        )
        for row in split_literal_rows if isinstance(row, dict)
    }
    split_literal_calls = [
        call for call in legacy_api_calls
        if (call.path, call.function, call.korean, call.english)
        in split_literal_selectors
    ]
    existing_format_selectors = {
        (
            row.get("path"), row.get("function"),
            row.get("ko"), row.get("en"),
        )
        for row in existing_format_rows if isinstance(row, dict)
    }
    existing_format_calls = [
        call for call in format_calls
        if (call.path, call.function, call.korean, call.english)
        in existing_format_selectors
    ]
    observed_baseline_calls = (
        len(calls) - len(format_calls) + len(existing_format_calls)
        - len(branch_calls)
        - len(supplemental_calls) - len(split_literal_calls)
    )
    if baseline_calls != observed_baseline_calls:
        errors.append(
            "manifest: baseline source pair calls "
            f"{baseline_calls!r} != observed {observed_baseline_calls}"
        )
    nonbaseline_templates = {
        row.get("ko") for row in parameter_contract.get("candidate_registry", [])
        if isinstance(row, dict) and row.get("disposition") == "migrate"
        and row.get("baseline_legacy_key") is False
        and isinstance(row.get("ko"), str)
    }
    branch_templates = {
        value for row in parameter_contract.get("candidate_registry", [])
        if isinstance(row, dict)
        and row.get("disposition") == "branch_selected_literal"
        and isinstance(row.get("ko"), list)
        for value in row["ko"] if isinstance(value, str)
    }
    supplemental_templates = {
        row.get("ko") for row in supplemental_rows if isinstance(row, dict)
        and isinstance(row.get("ko"), str)
    }
    split_literal_templates = {
        row.get("ko") for row in split_literal_rows if isinstance(row, dict)
        and isinstance(row.get("ko"), str)
    }
    baseline_source_keys = (
        source_keys - nonbaseline_templates - branch_templates
        - supplemental_templates - split_literal_templates
    )
    current_source_key_count = current_snapshot.get("legacy_korean_source_keys")
    if current_source_key_count != len(baseline_source_keys):
        errors.append(
            "manifest: current legacy Korean source key count "
            f"{current_source_key_count!r} != "
            f"{len(baseline_source_keys)}"
        )
    baseline_source_key_hash = hashlib.sha256(
        "\n".join(sorted(baseline_source_keys)).encode("utf-8")
    ).hexdigest()
    current_source_key_hash = current_snapshot.get(
        "legacy_korean_source_keys_sha256"
    )
    if current_source_key_hash != baseline_source_key_hash:
        errors.append(
            "manifest: current legacy Korean source key SHA-256 mismatch "
            f"{baseline_source_key_hash}"
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
    historical_completed_legacy = contract.get(
        "post_migration_legacy_pair_call_occurrences"
    )
    historical_baseline_calls = contract.get("legacy_pair_call_occurrences")
    if isinstance(historical_baseline_calls, int) \
            and historical_completed_legacy \
            != historical_baseline_calls - ORDER96_HISTORICAL_CONTEXT_CALLS:
        errors.append(
            "manifest: historical post-migration legacy calls "
            f"{historical_completed_legacy!r} != "
            f"{historical_baseline_calls-ORDER96_HISTORICAL_CONTEXT_CALLS}"
        )
    completed_legacy = current_snapshot.get(
        "post_migration_legacy_pair_call_occurrences"
    )
    if isinstance(baseline_calls, int) and completed_legacy != baseline_calls - planned_calls:
        errors.append(
            f"manifest: current post-migration legacy calls {completed_legacy!r} != "
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
                or len(legacy_api_calls) + len(existing_format_calls) \
                - len(supplemental_calls) \
                - len(split_literal_calls) \
                != completed_legacy \
                or migrated_ids != len(registry):
            errors.append(
                "source: implemented context migration is incomplete "
                f"legacy={len(legacy_api_calls) + len(existing_format_calls) - len(supplemental_calls) - len(split_literal_calls)}/"
                f"{completed_legacy} "
                f"context={len(context_calls)}/{planned_calls} "
                f"ids={migrated_ids}/{len(registry)}"
            )
    elif len(legacy_api_calls) + len(existing_format_calls) \
            - len(supplemental_calls) \
            - len(split_literal_calls) != baseline_calls \
            or context_calls or migrated_ids:
        errors.append(
            f"source: implemented=false requires the untouched 0/{planned_calls} state "
            f"legacy={len(legacy_api_calls) + len(existing_format_calls) - len(supplemental_calls) - len(split_literal_calls)}/"
            f"{baseline_calls} "
            f"context={len(context_calls)}/0 ids={migrated_ids}/0"
        )
    stats = {
        "legacy_calls": len(legacy_calls),
        "legacy_api_calls": len(legacy_api_calls),
        "format_calls": len(format_calls),
        "branch_variant_calls": len(branch_calls),
        "localized_argument_calls": len(supplemental_calls),
        "migrated_branch_literal_calls": len(split_literal_calls),
        "existing_lookup_before_format_calls": len(existing_format_calls),
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
    """Build all planned rows, then the observed subset used for generation."""
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
    manifest = read_json(UI_CONTEXT_MANIFEST_PATH)
    effective_contract = contract if contract is not None else (
        manifest.get("ui_semantic_context_blocker", {})
    )
    parameter_contract = manifest.get("ui_parameterized_template_plan", {})
    if not isinstance(effective_contract, dict):
        effective_contract = {}
    if not isinstance(parameter_contract, dict):
        parameter_contract = {}
    calls: list[UiCall] = []
    errors: list[str] = []
    japanese_ui_path = ROOT / "locale/ui_ja.json"
    if japanese_ui_path.is_file():
        duplicate_keys = duplicate_json_object_keys(japanese_ui_path)
        if duplicate_keys:
            errors.append(
                "locale/ui_ja.json: duplicate raw JSON keys "
                f"{duplicate_keys[:12]}"
            )
    for directory in RUNTIME_DIRS:
        for path in sorted((ROOT / directory).rglob("*.gd")):
            relative_path = str(path.relative_to(ROOT))
            parsed, parse_errors = parse_ui_calls(
                relative_path, path.read_text(encoding="utf-8")
            )
            calls.extend(parsed)
            errors.extend(parse_errors)
    calls.sort(key=lambda call: (call.path, call.line, call.api))
    source_keys = {call.korean for call in calls}
    parameter_errors, parameter_stats = validate_ui_parameterized_contract(
        parameter_contract, calls, source_keys
    )
    contract_errors, stats = validate_ui_context_contract(
        calls, effective_contract, parameter_contract
    )
    errors.extend(parameter_errors)
    errors.extend(contract_errors)
    stats.update({
        f"parameter_{key}": value for key, value in parameter_stats.items()
    })

    legacy_locations: dict[str, set[str]] = {}
    formatted_templates = {
        call.korean for call in calls if call.api == "format"
    }
    for call in calls:
        legacy_locations.setdefault(call.korean, set()).add(
            f"{call.path}:{call.line}"
        )

    legacy_entries: list[Entry] = []
    legacy_blueprint: dict[str, Any] = {}
    for index, korean in enumerate(sorted(legacy_locations)):
        key = f"ui::{index:04d}::{hashlib.sha1(korean.encode()).hexdigest()[:12]}"
        context = "UI / " + ", ".join(sorted(legacy_locations[korean])[:4])
        legacy_entries.append(Entry(
            key,
            korean,
            context,
            format_template=korean in formatted_templates,
        ))
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


def parse_ui_printf_contract(text: str) -> tuple[list[str], list[str]]:
    """Mirror LocaleManager's strict printf grammar and semantic contract."""
    contract: list[str] = []
    index = 0
    while index < len(text):
        if text[index] != "%":
            index += 1
            continue
        if index + 1 < len(text) and text[index + 1] == "%":
            index += 2
            continue
        start = index
        index += 1
        alignment = ""
        if index < len(text) and text[index] in "+-":
            alignment = text[index]
            index += 1
        width_start = index
        while index < len(text) and "0" <= text[index] <= "9":
            index += 1
        width = text[width_start:index]
        if width and int(width) > UI_PRINTF_MAX_WIDTH:
            return contract, [
                f"width exceeds {UI_PRINTF_MAX_WIDTH} at character {start}"
            ]
        has_precision = index < len(text) and text[index] == "."
        precision = ""
        if has_precision:
            index += 1
            precision_start = index
            while index < len(text) and "0" <= text[index] <= "9":
                index += 1
            precision = str(int(text[precision_start:index] or "0"))
            if int(precision) > UI_PRINTF_MAX_PRECISION:
                return contract, [
                    f"precision exceeds {UI_PRINTF_MAX_PRECISION} "
                    f"at character {start}"
                ]
        if index >= len(text) or not (
            "A" <= text[index] <= "Z" or "a" <= text[index] <= "z"
        ):
            return contract, [f"invalid percent sequence at character {start}"]
        conversion = text[index]
        if conversion not in UI_PRINTF_CONVERSIONS:
            return contract, [f"unsupported conversion %{conversion}"]
        if alignment == "+" and conversion not in UI_PRINTF_POSITIVE_CONVERSIONS:
            return contract, [f"+ modifier is invalid for %{conversion}"]
        if alignment == "-" and not width:
            return contract, [f"- modifier requires a width for %{conversion}"]
        if has_precision and conversion not in UI_PRINTF_PRECISION_CONVERSIONS:
            return contract, [f"precision is invalid for %{conversion}"]
        explicit_positive = "+" if alignment == "+" else ""
        contract.append(
            f"{conversion}|{explicit_positive}|{precision}"
        )
        index += 1
    return contract, []


def ui_printf_contract(text: str) -> list[str]:
    """Return LocaleManager's semantic contract; use the parser for validity."""
    contract, _errors = parse_ui_printf_contract(text)
    return contract


def non_printf_tokens(text: str) -> list[str]:
    return sorted(
        token for token in PLACEHOLDER.findall(text)
        if not token.startswith("%")
    )


def ui_placeholder_errors(source: str, translated: str) -> list[str]:
    errors: list[str] = []
    source_printf, source_syntax_errors = parse_ui_printf_contract(source)
    target_printf, target_syntax_errors = parse_ui_printf_contract(translated)
    errors.extend(
        f"source printf contract invalid: {error}"
        for error in source_syntax_errors
    )
    errors.extend(
        f"target printf contract invalid: {error}"
        for error in target_syntax_errors
    )
    if source_printf != target_printf:
        errors.append(
            f"printf contract mismatch {source_printf} != {target_printf}"
        )
    source_other = non_printf_tokens(source)
    target_other = non_printf_tokens(translated)
    if source_other != target_other:
        errors.append(
            f"placeholder mismatch {source_other} != {target_other}"
        )
    return errors


def repair_single_placeholder(entry: Entry, translated: str) -> str:
    """Restore an unambiguous one-token model typo without rewriting prose."""
    source_tokens = PLACEHOLDER.findall(entry.source)
    translated_tokens = PLACEHOLDER.findall(translated)
    allowed_ui_width_change = (
        entry.format_template
        and len(source_tokens) == 1
        and len(translated_tokens) == 1
        and source_tokens[0].startswith("%")
        and translated_tokens[0].startswith("%")
        and ui_printf_contract(source_tokens[0])
            == ui_printf_contract(translated_tokens[0])
    )
    if (
        len(source_tokens) == 1
        and len(translated_tokens) == 1
        and source_tokens[0] != translated_tokens[0]
        and not allowed_ui_width_change
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
    if entry.format_template:
        errors.extend(ui_placeholder_errors(entry.source, translated))
    elif tokens(entry.source) != tokens(translated):
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
        help="Unlock full packaged event/ending/catalog generation, including shipping and author-only events, only after a separate full-game GO.",
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
        duplicate_fixture = duplicate_json_object_keys_from_text(
            '{"보통":"普通","nested":{"진실":"真実","진실":"真実"},'
            '"보통":"標準"}'
        )
        if duplicate_fixture != ["보통", "진실"]:
            failures.append(
                f"raw JSON duplicate-key guard failed: {duplicate_fixture}"
            )
        cases += 1
        width_entry = Entry(
            "ui::self-test-width", "번호 %d", "pipeline self-test",
            format_template=True,
        )
        width_target = "番号 %02d"
        if validate_translation(width_entry, width_target) \
                or normalize_translation_for_entry(
                    width_entry, width_target
                ) != width_target:
            failures.append(
                "UI printf width/zero-padding-only difference was rejected or rewritten"
            )
        cases += 1
        alignment_target = "番号 %-5d"
        if validate_translation(width_entry, alignment_target) \
                or normalize_translation_for_entry(
                    width_entry, alignment_target
                ) != alignment_target:
            failures.append(
                "UI printf valid width/alignment difference was rejected or rewritten"
            )
        cases += 1
        valid_ui_contracts = {
            "%s": ["s||"],
            "%c": ["c||"],
            "%+05d": ["d|+|"],
            "%+05o": ["o|+|"],
            "%+05x": ["x|+|"],
            "%+05X": ["X|+|"],
            "%+64.12f": ["f|+|12"],
            "%.2v": ["v||2"],
            "%% · %02d": ["d||"],
        }
        for template, expected_contract in valid_ui_contracts.items():
            observed_contract, syntax_errors = parse_ui_printf_contract(template)
            if syntax_errors or observed_contract != expected_contract:
                failures.append(
                    "UI printf valid grammar mismatch: "
                    f"{template!r} -> {observed_contract!r} / {syntax_errors!r}"
                )
        cases += len(valid_ui_contracts)
        malformed_ui_targets = [
            "番号 %-d",
            "番号 %65d",
            "番号 %999d",
            "番号 %1$d",
            "番号 %#d",
            "番号 % d",
            "番号 %*d",
            "番号 %i",
            "番号 %--10d",
            "番号 %",
            "番号 %🦊",
            "番号 %.2d",
            "番号 %+s",
            "番号 %+v",
            "番号 %.13f",
        ]
        for malformed_target in malformed_ui_targets:
            if not any(
                "printf contract invalid" in error
                for error in validate_translation(width_entry, malformed_target)
            ):
                failures.append(
                    "UI printf malformed target was accepted: "
                    f"{malformed_target!r}"
                )
        cases += len(malformed_ui_targets)
        precision_bound_entry = Entry(
            "ui::self-test-precision-bound", "비율 %.2f", "pipeline self-test",
            format_template=True,
        )
        for malformed_target in ["比率 %.99f", "比率 %999.2f"]:
            if not any(
                "printf contract invalid" in error
                for error in validate_translation(
                    precision_bound_entry, malformed_target
                )
            ):
                failures.append(
                    "UI printf precision/width bound was accepted: "
                    f"{malformed_target!r}"
                )
        cases += 2
        precision_entry = Entry(
            "ui::self-test-precision", "비율 %.2f", "pipeline self-test",
            format_template=True,
        )
        if not any(
            "printf contract mismatch" in error
            for error in validate_translation(precision_entry, "比率 %.1f")
        ):
            failures.append("UI printf precision drift was accepted")
        cases += 1
        default_precision_entry = Entry(
            "ui::self-test-default-precision", "비율 %f", "pipeline self-test",
            format_template=True,
        )
        if not any(
            "printf contract mismatch" in error
            for error in validate_translation(default_precision_entry, "比率 %.f")
        ):
            failures.append("UI printf explicit zero precision matched no precision")
        cases += 1
        zero_precision_entry = Entry(
            "ui::self-test-zero-precision", "비율 %.f", "pipeline self-test",
            format_template=True,
        )
        if validate_translation(zero_precision_entry, "比率 %.0f"):
            failures.append("UI printf equivalent zero precision was rejected")
        cases += 1
        sign_entry = Entry(
            "ui::self-test-sign", "변화 %d", "pipeline self-test",
            format_template=True,
        )
        if not any(
            "printf contract mismatch" in error
            for error in validate_translation(sign_entry, "変化 %+05d")
        ):
            failures.append("UI printf explicit-sign drift was accepted")
        cases += 1
        order_entry = Entry(
            "ui::self-test-order", "순서 %d · %s", "pipeline self-test",
            format_template=True,
        )
        if not any(
            "printf contract mismatch" in error
            for error in validate_translation(order_entry, "順序 %s・%02d")
        ):
            failures.append("UI printf conversion order drift was accepted")
        cases += 1
        ui_inventory = collect_ui_inventory()
        failures.extend(
            f"actual UI contract: {error}" for error in ui_inventory.errors
        )
        formatted_ui_entries = sum(
            1 for entry in ui_inventory.legacy_entries
            if entry.format_template
        )
        if formatted_ui_entries != 44:
            failures.append(
                "actual UI formatted-template tagging drifted: "
                f"{formatted_ui_entries} != 44"
            )
        cases += 1
        implementation_complete = bool(ui_inventory.stats.get("implemented"))
        expected_observed_context = 29 if implementation_complete else 0
        parameter_phase = str(
            ui_inventory.stats.get("parameter_observed_phase", "")
        )
        parameter_contract = manifest.get("ui_parameterized_template_plan", {})
        phase_inventory = parameter_contract.get(
            "source_inventory_phases", {}
        ).get(parameter_phase, {})
        expected_legacy_entries = int(
            phase_inventory.get("legacy_korean_source_keys", -1)
        )
        if len(ui_inventory.entries) != expected_legacy_entries \
                + expected_observed_context \
                or len(ui_inventory.planned_context_entries) != 29 \
                or len(ui_inventory.observed_context_entries) \
                != expected_observed_context:
            failures.append(
                "planned/observed UI inventory separation failed: "
                f"actual={len(ui_inventory.entries)} "
                f"planned={len(ui_inventory.planned_context_entries)} "
                f"observed={len(ui_inventory.observed_context_entries)}"
            )
        cases += 1
        exact_parameter_stats = {
            "source_calls": 3320,
            "legacy_calls": 3286,
            "format_calls": 50,
            "parameter_raw_candidates": 56,
            "parameter_migrate_calls": 48,
            "parameter_existing_lookup_before_format_migrations": 2,
            "parameter_argument_provenance_calls": 15,
            "parameter_existing_lookup_before_format_provenance_calls": 2,
        }
        stale_parameter_stats = {
            key: (ui_inventory.stats.get(key), expected)
            for key, expected in exact_parameter_stats.items()
            if ui_inventory.stats.get(key) != expected
        }
        if stale_parameter_stats:
            failures.append(
                "final parameterized inventory drifted: "
                f"{stale_parameter_stats}"
            )
        cases += 1
        expected_premature = [] if implementation_complete \
            else ["ui.credit.standard_grade"]
        if premature_context_dictionary_keys(
            {"ui.credit.standard_grade"}, ui_inventory
        ) != expected_premature:
            failures.append(
                "Japanese context row phase guard did not match implementation state"
            )
        cases += 1
        fixture_calls, fixture_errors = parse_ui_calls(
            "scenes/SelfTest.gd",
            'func fixture():\n'
            '\t_tr("기록", "Log")\n'
            '\tLocaleManager.ui("생활", "Living")\n'
            '\tLocaleManager.ui_context("ui.navigation.archive", "기록", "Archive")\n'
            '\tLocaleManager.ui_format("%d주", "%d wk", 1, 1)\n',
        )
        if fixture_errors or [call.api for call in fixture_calls] != [
            "legacy", "legacy", "context", "format"
        ] or fixture_calls[-1].function != "fixture":
            failures.append(
                f"three UI API collector failed: calls={fixture_calls} "
                f"errors={fixture_errors}"
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
            completed_calls, completed_contract, parameter_contract
        )
        if completed_errors or completed_stats.get("context_calls") != 34:
            failures.append(
                "completed 34-call migration fixture failed: "
                f"stats={completed_stats} errors={completed_errors}"
            )
        (
            completed_planned_entries,
            _completed_planned_blueprint,
            completed_observed_entries,
            _completed_observed_blueprint,
        ) = build_ui_context_layers(completed_calls, completed_contract)
        if len(completed_planned_entries) != 29 \
                or len(completed_observed_entries) != 29:
            failures.append(
                "completed generation did not select exactly 29 observed rows: "
                f"planned={len(completed_planned_entries)} "
                f"observed={len(completed_observed_entries)}"
            )

        untouched_context_calls = [
            UiCall(
                call.path,
                call.function,
                call.line,
                "legacy",
                call.korean,
                call.english,
            ) if call.api == "context" else call
            for call in ui_inventory.calls
        ]
        untouched_context_contract = json.loads(json.dumps(
            ui_contract, ensure_ascii=False
        ))
        untouched_context_contract["implemented"] = False
        cases += 1
        untouched_errors, untouched_stats = validate_ui_context_contract(
            untouched_context_calls,
            untouched_context_contract,
            parameter_contract,
        )
        if untouched_errors \
                or untouched_stats.get("context_calls") != 0 \
                or untouched_stats.get("migrated_context_ids") != 0:
            failures.append(
                "untouched context baseline fixture failed after supplemental "
                "format conversion: "
                f"stats={untouched_stats} errors={untouched_errors}"
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
                    "legacy" if implementation_complete else "context",
                    call.korean,
                    call.english,
                    "" if implementation_complete else "ui.credit.standard_grade",
                )
                break
        cases += 1
        single_errors, single_stats = validate_ui_context_contract(
            single_id_calls, ui_contract
        )
        expected_single_contexts = 33 if implementation_complete else 1
        expected_single_ids = 28 if implementation_complete else 1
        expected_single_error = (
            "implemented context migration is incomplete"
            if implementation_complete else
            "implemented=false"
        )
        if single_stats.get("context_calls") != expected_single_contexts \
                or single_stats.get("migrated_context_ids") != expected_single_ids \
                or not any(expected_single_error in error
                           for error in single_errors):
            failures.append(
                "whole one-call ID phase mutation escaped: "
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
                    "legacy" if implementation_complete else "context",
                    call.korean,
                    call.english,
                    "" if implementation_complete else
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
        changed = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        changed["current_source_snapshot"][
            "legacy_pair_call_occurrences"
        ] += 1
        mutation_cases.append(("current source snapshot", changed))
        changed = json.loads(json.dumps(ui_contract, ensure_ascii=False))
        changed["legacy_korean_source_keys"] += 1
        mutation_cases.append(("ORDER-96 historical baseline", changed))
        for label, changed_contract in mutation_cases:
            cases += 1
            mutation_errors, _stats = validate_ui_context_contract(
                ui_inventory.calls, changed_contract
            )
            if not mutation_errors:
                failures.append(f"{label} mutation was not rejected")

        parameter_observations, observation_errors = (
            collect_ui_parameterized_observations()
        )
        if observation_errors:
            failures.append(
                f"parameterized observation fixture failed: {observation_errors}"
            )
        parameter_source_keys = {call.korean for call in ui_inventory.calls}

        cases += 1
        changed_parameter = json.loads(json.dumps(
            parameter_contract, ensure_ascii=False
        ))
        changed_parameter["candidate_registry"].pop()
        missing_errors, _missing_stats = validate_ui_parameterized_contract(
            changed_parameter, ui_inventory.calls, parameter_source_keys,
            parameter_observations,
        )
        if not any(
            "extra/unclassified" in error or "count" in error
            for error in missing_errors
        ):
            failures.append("missing parameterized registry row was not rejected")

        cases += 1
        changed_parameter = json.loads(json.dumps(
            parameter_contract, ensure_ascii=False
        ))
        changed_parameter["candidate_registry"].append(
            dict(changed_parameter["candidate_registry"][0])
        )
        extra_errors, _extra_stats = validate_ui_parameterized_contract(
            changed_parameter, ui_inventory.calls, parameter_source_keys,
            parameter_observations,
        )
        if not any("duplicate parameterized selector" in error
                   for error in extra_errors):
            failures.append("extra parameterized registry row was not rejected")

        cases += 1
        changed_parameter = json.loads(json.dumps(
            parameter_contract, ensure_ascii=False
        ))
        first_migrate = next(
            row for row in changed_parameter["candidate_registry"]
            if row.get("disposition") == "migrate"
        )
        first_migrate["ko"] += " stale"
        stale_errors, _stale_stats = validate_ui_parameterized_contract(
            changed_parameter, ui_inventory.calls, parameter_source_keys,
            parameter_observations,
        )
        if not any("stale" in error or "parameterized selector" in error
                   for error in stale_errors):
            failures.append("stale parameterized registry row was not rejected")

        cases += 1
        split_row = next(
            row for row in parameter_contract["candidate_registry"]
            if row.get("disposition") == "migrate" and row.get("count") == 2
        )
        split_selector = _candidate_selector(
            split_row["path"], split_row["function"],
            split_row["ko"], split_row["en"],
        )
        split_observations = list(parameter_observations)
        for index, observation in enumerate(split_observations):
            if observation.state in {"preformat", "migrated"} \
                    and _candidate_selector(
                observation.path, observation.function,
                observation.korean, observation.english,
            ) == split_selector:
                split_observations[index] = UiParameterizedObservation(
                    observation.path, observation.function, observation.line,
                    "preformat" if observation.state == "migrated" \
                    else "migrated",
                    observation.korean, observation.english,
                )
                break
        partial_errors, _partial_stats = validate_ui_parameterized_contract(
            parameter_contract, ui_inventory.calls, parameter_source_keys,
            split_observations,
        )
        if not any("partial parameterized selector" in error
                   for error in partial_errors):
            failures.append("partial parameterized selector was not rejected")

        cases += 1
        unknown_observations = [*parameter_observations,
            UiParameterizedObservation(
                "scenes/SelfTest.gd", "fixture", 1, "preformat",
                "알 수 없음 %d", "Unknown %d",
            )]
        unknown_errors, _unknown_stats = validate_ui_parameterized_contract(
            parameter_contract, ui_inventory.calls, parameter_source_keys,
            unknown_observations,
        )
        if not any("extra/unclassified parameterized row" in error
                   for error in unknown_errors):
            failures.append("unknown parameterized source row was not rejected")

        cases += 1
        changed_parameter = json.loads(json.dumps(
            parameter_contract, ensure_ascii=False
        ))
        changed_parameter["argument_provenance_registry"].pop()
        missing_provenance_errors, _missing_provenance_stats = (
            validate_ui_parameterized_contract(
                changed_parameter, ui_inventory.calls, parameter_source_keys,
                parameter_observations,
            )
        )
        if not any("extra/unclassified argument provenance" in error
                   for error in missing_provenance_errors):
            failures.append("missing argument provenance row was not rejected")

        cases += 1
        changed_parameter = json.loads(json.dumps(
            parameter_contract, ensure_ascii=False
        ))
        changed_parameter["argument_provenance_registry"][0]["en_args"] += \
            "_stale"
        stale_provenance_errors, _stale_provenance_stats = (
            validate_ui_parameterized_contract(
                changed_parameter, ui_inventory.calls, parameter_source_keys,
                parameter_observations,
            )
        )
        if not any("argument provenance" in error
                   for error in stale_provenance_errors):
            failures.append("stale argument provenance row was not rejected")

        cases += 1
        changed_parameter = json.loads(json.dumps(
            parameter_contract, ensure_ascii=False
        ))
        changed_parameter["existing_lookup_before_format_provenance"].pop()
        missing_existing_errors, _missing_existing_stats = (
            validate_ui_parameterized_contract(
                changed_parameter, ui_inventory.calls, parameter_source_keys,
                parameter_observations,
            )
        )
        if not any("extra/unclassified parameterized row" in error
                   for error in missing_existing_errors):
            failures.append(
                "missing existing lookup-before-format provenance was not rejected"
            )

        cases += 1
        changed_parameter = json.loads(json.dumps(
            parameter_contract, ensure_ascii=False
        ))
        changed_parameter["existing_lookup_before_format_provenance"][0][
            "en_args"
        ] += "_stale"
        stale_existing_errors, _stale_existing_stats = (
            validate_ui_parameterized_contract(
                changed_parameter, ui_inventory.calls, parameter_source_keys,
                parameter_observations,
            )
        )
        if not any("existing lookup-before-format provenance" in error
                   for error in stale_existing_errors):
            failures.append(
                "stale existing lookup-before-format provenance was not rejected"
            )
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
                    f"format_calls={stats['format_calls']} "
                    "supplemental_format_calls="
                    f"{stats['parameter_existing_lookup_before_format_provenance_calls']} "
                    "argument_provenance="
                    f"{stats['parameter_argument_provenance_calls']} "
                    f"parameter_phase={stats['parameter_observed_phase']} "
                    f"parameter_registry={stats['parameter_raw_candidates']} "
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
