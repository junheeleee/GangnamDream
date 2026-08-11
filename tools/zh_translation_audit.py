#!/usr/bin/env python3
"""Region-specific gate for the hidden Simplified/Traditional Chinese demos.

This tool is deliberately an auditor, not a translator.  Skeleton mode proves
the exact 24-week source boundary, validates every Chinese row that already
exists, and reports the absent body/font without treating either as complete.
Strict mode is the future automated claim gate: all demo prose, dynamic copy,
static UI, catalog names, and a project-owned locale font must be complete.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
import struct
import sys
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation
from typing import Any, Iterable, Optional


ROOT = pathlib.Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

import demo_localization_scope as demo_scope  # noqa: E402
from ja_translation_pipeline import (  # noqa: E402
    UiInventory,
    collect_ui_inventory,
)


LANGUAGES = ("zh-CN", "zh-TW")
SCRIPT_VARIANT_DATA_PATH = (
    ROOT / "tools/data/opencc_script_variants_1_3_1.json"
)
SCRIPT_VARIANT_DATA_SHA256 = (
    "6b908ca6f0c78f9ecbdd8784ddc838fddadb00ccdd4c99f984b25922ac4b1f23"
)
SCRIPT_VARIANT_DATA_COUNTS = {"zh-CN": 4093, "zh-TW": 3804}
SCRIPT_VARIANT_LICENSE_PATH = ROOT / "tools/data/LICENSE-OpenCC-2.0.txt"
SCRIPT_VARIANT_LICENSE_SHA256 = (
    "fb531487f666909d487239da6130e2256d8c86f26ec2674ce6aa5763bc7f8c56"
)
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")
KANA = re.compile(r"[\u3040-\u30ff\u31f0-\u31ff\uff66-\uff9f]")
HAN = re.compile(
    r"[\u3400-\u4dbf\u4e00-\u9fff\U00020000-\U0003347f]"
)
PLACEHOLDER = re.compile(
    r"\{[^{}]+\}|%(?:\d+\$)?[-+#0 .\d]*[a-zA-Z]|"
    r"\[/?(?:b|i|u|s|center|right|fill|color(?:=[^\]]+)?|font(?:=[^\]]+)?|"
    r"font_size(?:=[^\]]+)?|url(?:=[^\]]+)?|img(?:=[^\]]+)?)]"
)
NUMBER = re.compile(r"(?<![\d.])[+-]?\d+(?:[,.]\d+)*(?:%)?")
KOREAN_NATIVE_ONES = {
    "하나": 1, "한": 1, "둘": 2, "두": 2, "셋": 3, "세": 3,
    "넷": 4, "네": 4, "다섯": 5, "여섯": 6, "일곱": 7,
    "여덟": 8, "아홉": 9,
}
KOREAN_NATIVE_TENS = {
    "열": 10, "스물": 20, "스무": 20, "서른": 30, "마흔": 40,
    "쉰": 50, "예순": 60, "일흔": 70, "여든": 80, "아흔": 90,
}
KOREAN_NATIVE_FORMS = tuple(sorted(
    {
        *KOREAN_NATIVE_ONES,
        *KOREAN_NATIVE_TENS,
        *(
            tens + ones
            for tens in KOREAN_NATIVE_TENS
            for ones in KOREAN_NATIVE_ONES
        ),
    },
    key=len,
    reverse=True,
))
SOURCE_COUNTER_SUFFIX = (
    r"(?=$|\s|[.,!?…:;\x22\x27)\]}]|"
    r"(?:은|는|이|가|을|를|의|도|만|에|에게|에게서|에서|에는|"
    r"으로|로|과|와|라고|였다|이었다|입니다|이다|인데|뿐이라면|"
    r"뿐입니다|뿐|씩|짜리|째예요|째로|째에야|째|차|분|동안|간|"
    r"안|후|전|부터|까지|쯤|어치|치가|치에|치))"
)
SOURCE_COUNTER_NAMES = (
    r"개월|시간|사람|켤레|세트|문항|문제|문장|걸음|박자|블록|모금|"
    r"년|해|달|월|주|일|분|초|개|명|번|회|층|평|살|세|시|차|"
    r"장|채|대|잔|컵|줄|행|칸|끼|통|자리|뼘"
)
SOURCE_DIGIT_COUNTER = re.compile(
    rf"(?<![\d.])(?P<number>[+-]?\d[\d,]*)\s*"
    rf"(?P<counter>{SOURCE_COUNTER_NAMES}){SOURCE_COUNTER_SUFFIX}"
)
SOURCE_WORD_COUNTER = re.compile(
    r"(?<![가-힣])(?P<number>"
    + "|".join(re.escape(form) for form in KOREAN_NATIVE_FORMS)
    + r"|[일삼사오육칠팔구십백천]|[일이삼사오육칠팔구십백천]{2,})\s+"
    r"(?P<counter>개월|시간|사람|켤레|세트|문항|문제|문장|걸음|"
    r"박자|블록|모금|년|해|달|월|주|일|분|초|개|명|번|회|층|"
    r"평|살|시|장|채|대|잔|컵|줄|행|칸|끼|통|자리|뼘)"
    + SOURCE_COUNTER_SUFFIX
)
SOURCE_COMPACT_SINO_COUNTER = re.compile(
    r"(?<![가-힣])(?P<number>[일이삼사오육칠팔구십백천]{2,})\s*"
    rf"(?P<counter>{SOURCE_COUNTER_NAMES}){SOURCE_COUNTER_SUFFIX}"
)
SOURCE_COMPACT_NATIVE_COUNTER = re.compile(
    rf"(?<![가-힣])(?P<number>한)(?P<counter>번){SOURCE_COUNTER_SUFFIX}"
)
SOURCE_ORDINAL = re.compile(
    r"(?<![가-힣\d])(?P<number>첫|한|둘|두|셋|세|넷|네|다섯|여섯|일곱|여덟|아홉|열|\d+)\s*"
    r"(?:번째|번\s*째|째)"
)
SOURCE_FIRST_UNIT = re.compile(
    r"(?<![가-힣])첫\s+(?P<counter>줄|장|통화|주)"
)
SOURCE_HALF_PYEONG = re.compile(
    r"(?<![\d.])(?P<number>\d+(?:\.\d+)?)\s*평\s*반"
)
SOURCE_TICKET_IDENTIFIER = re.compile(
    r"(?<!\d)(?P<number>\d[\d,]*)\s*번\s*"
    r"(?:번호표|대기표|고객님|창구)"
)
SOURCE_LEXICAL_DAYS = {
    "하루": 1, "이틀": 2, "사흘": 3, "나흘": 4, "닷새": 5,
    "엿새": 6, "이레": 7, "여드레": 8, "아흐레": 9,
    "열흘": 10, "보름": 15,
}
SOURCE_LEXICAL_DAY = re.compile(
    r"(?<![가-힣])(?P<day>"
    + "|".join(SOURCE_LEXICAL_DAYS)
    + r")(?=$|\s|[.,!?…:;\x22\x27)\]}]|(?:은|는|이|가|을|를|의|도|"
    r"만|에|에서|으로|로|과|와|치|짜리|동안|째|간|후|전))"
)
SOURCE_IMPLICIT_ENTITY = re.compile(
    r"(?<![가-힣])(?P<number>둘|셋|넷|다섯|여섯|일곱|여덟|아홉)"
    r"(?=(?:이|가|은|는|도|만(?:의)?|의)?"
    r"(?:\s+(?:다|사이|사이에|모두))?(?:\s|$|[.,!?…]))"
)
SOURCE_BARE_AGE = re.compile(
    r"(?<![가-힣])(?P<number>서른셋|스물일곱)"
    r"(?=$|\s|[.,!?…:;\x22\x27)\]}]|(?:은|는|이|가|을|를|의|도|만|에))"
)
CHINESE_CARDINAL = r"(?:\d[\d,]*|[零〇○一二两兩三四五六七八九十百千]+)"
TARGET_COUNTER_FORMS: tuple[tuple[str, tuple[str, ...]], ...] = (
    ("duration_hour", ("個小時", "个小时", "小時", "小时")),
    ("duration_month", ("個月", "个月")),
    ("calendar_month", ("月",)),
    ("duration_minute", ("分鐘", "分钟")),
    ("clock_minute", ("分",)),
    ("entity", (
        "個人", "个人", "人", "名", "位", "個", "个", "件",
        "條", "条", "張", "张", "輛", "辆", "棟", "栋", "杯",
    )),
    ("sheet", ("張", "张", "枚", "頁", "页")),
    ("building", ("棟", "栋", "幢", "套", "戶", "户")),
    ("vehicle", ("輛", "辆", "台")),
    ("cup", ("杯",)),
    ("line", ("行", "列", "條", "条", "句")),
    ("pair", ("雙", "双", "對", "对")),
    ("cell", ("格", "欄", "栏", "列")),
    ("question", ("題", "题", "道", "個", "个")),
    ("set", ("套", "組", "组")),
    ("meal", ("頓", "顿", "餐")),
    ("message", ("封", "條", "条", "通")),
    ("sip", ("口",)),
    ("step", ("步",)),
    ("slot", ("個", "个", "席", "位", "名額", "名额")),
    ("beat", ("拍", "拍子")),
    ("span", ("拃", "掌", "個", "个")),
    ("stair_step", ("級", "级", "階", "阶")),
    ("landing", ("個", "个", "處", "处")),
    ("clock_hour", ("點", "点", "時", "时")),
    ("occurrence", ("次", "回", "遍", "下")),
    ("week", ("週", "周")),
    ("year", ("年",)),
    ("duration_day", ("天", "日")),
    ("calendar_day", ("日", "號", "号")),
    ("night", ("晚", "夜")),
    ("second", ("秒",)),
    ("floor", ("層", "层", "樓", "楼")),
    ("pyeong", ("坪",)),
    ("age", ("歲", "岁")),
    ("round", ("輪", "轮")),
)
SOURCE_COUNTER_CLASSES = {
    "시": "clock_hour", "시간": "duration_hour", "개": "entity",
    "주": "week", "사람": "entity", "명": "entity",
    "번": "occurrence", "회": "occurrence", "년": "year",
    "달": "duration_month", "월": "calendar_month",
    "개월": "duration_month", "일": "duration_day",
    "분": "duration_minute",
    "초": "second", "층": "floor", "평": "pyeong",
    "살": "age", "세": "age", "차": "round", "해": "year",
    "장": "sheet", "채": "building", "대": "vehicle",
    "잔": "cup", "컵": "cup", "줄": "line", "행": "line",
    "켤레": "pair", "칸": "cell", "문제": "question",
    "문항": "question", "세트": "set", "끼": "meal",
    "통": "message", "모금": "sip", "문장": "line",
    "걸음": "step", "자리": "slot", "박자": "beat",
    "블록": "entity", "뼘": "span",
}

ORDINAL_CONTEXT_CLASSES: tuple[tuple[tuple[str, ...], str], ...] = (
    (("달", "개월"), "duration_month"),
    (("해", "년"), "year"),
    (("주",), "week"),
    ((
        "통화", "전화", "대화", "만남", "방문", "수업", "기회",
        "경고", "제안", "의뢰", "인사", "계산", "확인",
    ), "occurrence"),
    (("믹스커피", "커피"), "cup"),
    (("층계참",), "landing"),
    (("집",), "building"),
    (("칸",), "cell"),
    (("줄", "행"), "line"),
    (("문제", "문항"), "question"),
    (("사진",), "sheet"),
)
DECIMAL_LITERAL = r"[+-]?\d+(?:,\d{3})*(?:\.\d+)?"
SOURCE_EOK_MONEY = re.compile(
    rf"(?<![\d,])(?P<eok>{DECIMAL_LITERAL})\s*억"
    rf"(?:\s*(?P<rest>{DECIMAL_LITERAL})\s*(?P<rest_unit>천만|천|만))?"
    r"(?:\s*원)?"
)
SOURCE_EXPLICIT_MONEY = re.compile(
    rf"(?<![\d,])(?P<number>{DECIMAL_LITERAL})\s*"
    r"(?P<unit>천만|만|천)?\s*원"
)
SOURCE_WORD_MONEY = re.compile(
    r"(?<![가-힣])(?P<number>[일이삼사오육칠팔구십백천]+)\s*"
    r"(?P<unit>억|만)?\s*원"
)
SOURCE_BARE_ONE_MONEY = re.compile(
    r"(?<![가-힣])(?P<unit>억|만)\s*원"
)
SOURCE_COLLOQUIAL_MANWON = re.compile(
    r"(?<![가-힣\d])(?P<context>보증금|월|즉시)\s+"
    r"(?P<number>\d[\d,]*|[일이삼사오육칠팔구십백천]+)(?![\d,])"
)
CHINESE_MONEY_COMPONENT = re.compile(
    rf"(?P<number>{DECIMAL_LITERAL})\s*"
    r"(?P<unit>万亿|萬億|千万|千萬|亿|億|万|萬|千)?"
)
TARGET_WON_MONEY = re.compile(
    rf"(?P<expression>(?:{DECIMAL_LITERAL}\s*"
    r"(?:万亿|萬億|千万|千萬|亿|億|万|萬|千)?\s*)+)"
    r"(?:韩元|韓元)"
)
KOREAN_WON = re.compile(
    r"(?:₩|KRW|원화|"
    r"(?:(?:\d[\d,.]*|%(?:\d+\$)?[-+#0 .\d]*[a-zA-Z]|"
    r"[일이삼사오육칠팔구십백천]+)\s*(?:만|억)?|(?<![가-힣])(?:만|억))\s*원)"
)
KOREAN_UNIT_AMOUNT = re.compile(
    r"(?<![가-힣])(?P<number>\d[\d,.]*)\s*"
    r"(?P<units>천만|천|만|억)"
    r"(?=(?:원)?(?:\s|$|[.,!?…:;\x22\x27)\]}]|"
    r"(?:이면|은|는|이|가|을|를|으로|부터|까지|쯤)))"
)
NON_MONEY_COUNTER = re.compile(
    r"^\s*(?:명|년|개월|달|주|일|시간|분|초|회|번|개|채|대|층|평|"
    r"킬로미터|미터)(?=$|\s|[.,!?…:;\x22\x27)\]}])"
)
WRONG_CURRENCY = re.compile(
    r"[¥￥]|日元|円|人民币|人民幣|新台币|新臺幣|NT\$|"
    r"\b(?:CNY|RMB|JPY|TWD)\b",
    re.IGNORECASE,
)
BARE_YUAN_AMOUNT = re.compile(r"(?:\d|千|万|萬|亿|億)\s*(?:元|圓)")

# Project-locked preferred forms supplement the complete context-unambiguous
# character sets in SCRIPT_VARIANT_DATA_PATH.  Characters with legitimate
# shared uses (for example 台/里/系) stay out of the character gate and are
# handled by phrase rules plus same-revision native review.
COUNTER_SCRIPT_VARIANTS: tuple[tuple[str, str], ...] = (
    ("两", "兩"), ("张", "張"), ("辆", "輛"), ("栋", "棟"),
    ("条", "條"), ("双", "雙"), ("栏", "欄"), ("组", "組"),
    ("顿", "頓"), ("户", "戶"), ("级", "級"), ("阶", "階"),
    ("层", "層"), ("页", "頁"), ("点", "點"), ("钟", "鐘"),
    ("处", "處"),
)
SCRIPT_VARIANTS: tuple[tuple[str, str], ...] = (
    ("汉", "漢"), ("语", "語"), ("钱", "錢"), ("门", "門"),
    ("标", "標"), ("进", "進"), ("问", "問"),
    ("题", "題"), ("国", "國"), ("来", "來"), ("爱", "愛"),
    ("确", "確"), ("楼", "樓"), ("轮", "輪"),
    ("万", "萬"), ("亿", "億"), ("韩", "韓"),
    ("区", "區"), ("体", "體"), ("关", "關"), ("这", "這"),
    ("为", "為"), ("与", "與"), ("个", "個"), ("说", "說"),
    ("时", "時"), ("还", "還"), ("过", "過"), ("会", "會"),
    ("间", "間"), ("买", "買"), ("卖", "賣"), ("学", "學"),
    ("车", "車"), ("电", "電"), ("话", "話"), ("网", "網"),
    ("软", "軟"), ("资", "資"), ("账", "帳"), ("额", "額"),
    ("开", "開"), ("闭", "閉"), ("发", "發"),
    ("现", "現"), ("实", "實"), ("产", "產"), ("业", "業"),
    ("职", "職"), ("员", "員"), ("从", "從"), ("长", "長"),
    ("见", "見"), ("认", "認"), ("选", "選"), ("择", "擇"),
    ("对", "對"), ("达", "達"), ("应", "應"), ("亲", "親"),
    ("们", "們"), ("边", "邊"), ("岁", "歲"), ("号", "號"),
) + COUNTER_SCRIPT_VARIANTS
REGIONAL_PHRASE_VARIANTS: tuple[tuple[str, str], ...] = (
    ("以后", "以後"),
)

REGIONAL_TERMS = {
    "zh-CN": {
        "won": "韩元",
        "district": "江南区",
        "goshiwon": "考试院",
        "jeonse": "全租",
        "monthly_rent": "月租",
        "thousand": "千",
        "ten_thousand": "万",
        "hundred_million": "亿",
        "seoul": "首尔",
        "studio": "单间公寓",
        "villa": "低层公寓",
        "account": ("账户", "存折"),
        "triangle_gimbap": "三角紫菜包饭",
        "pojangmacha": "韩国路边摊",
        "han_river": "汉江",
        "civil_exam": "韩国九级公务员考试",
        "cafe_man": "咖啡馆里的男人",
    },
    "zh-TW": {
        "won": "韓元",
        "district": "江南區",
        "goshiwon": "考試院",
        "jeonse": "全租",
        "monthly_rent": "月租",
        "thousand": "千",
        "ten_thousand": "萬",
        "hundred_million": "億",
        "seoul": "首爾",
        "studio": "套房",
        "villa": "低樓層集合住宅",
        "account": ("帳戶", "存摺"),
        "triangle_gimbap": "三角飯捲",
        "pojangmacha": "韓國路邊攤",
        "han_river": "漢江",
        "civil_exam": "韓國九級公務員考試",
        "cafe_man": "咖啡館裡的男人",
    },
}

# No official Hanja spellings are established for the cast.  Until that human
# decision exists, a Chinese-only invented name may not replace these forms.
NAME_ROMANIZATION = {
    "김민준": "Kim Minjun", "민준": "Minjun",
    "김다은": "Kim Daeun", "다은": "Daeun",
    "한지연": "Han Jiyeon", "지연": "Jiyeon",
    "임상철": "Im Sangchul", "상철": "Sangchul",
    "최재혁": "Choi Jaehyuk", "재혁": "Jaehyuk",
    "강현수": "Kang Hyunsu", "현수": "Hyunsu",
    "박성준": "Park Seongjun", "성준": "Seongjun",
    "김영수": "Kim Youngsu",
    "김 부장": "Manager Kim",
}
AMBIGUOUS_NAME_CONTEXT = {
    "지연": re.compile(r"지연(?:과|와|을|를|에게|한테|이와|이가|의|은|도|씨|아)"),
}
LATIN_EXACT = {
    "강남드림": "GANGNAM DREAM",
    "GANGNAM DREAM": "GANGNAM DREAM",
    "김민준": "Kim Minjun",
    "민준": "Minjun",
    "김다은": "Kim Daeun",
    "다은": "Daeun",
    "한지연": "Han Jiyeon",
    "지연": "Jiyeon",
    "임상철": "Im Sangchul",
    "상철": "Sangchul",
    "최재혁": "Choi Jaehyuk",
    "재혁": "Jaehyuk",
    "강현수": "Kang Hyunsu",
    "현수": "Hyunsu",
    "박성준": "Park Seongjun",
    "성준": "Seongjun",
    "김영수": "Kim Youngsu",
    "김 부장": "Manager Kim",
    "한성전자": "Hanseong Electronics",
    "다온": "Daon",
    "대현차": "Daehyeon Motor",
    "코스피200 ETF": "KOSPI 200 ETF",
    "유튜버": "YouTuber",
    "리츠 ETF": "REIT ETF",
    "포스코": "POSCO",
    "코파일럿": "Copilot",
}
ALLOWED_LATIN_PHRASES = tuple(sorted({
    *LATIN_EXACT.values(),
    *NAME_ROMANIZATION.values(),
    "Kang Hyunsu",
    "GANGNAM DREAM",
}, key=len, reverse=True))
ALLOWED_LATIN_TOKENS = {
    "AI", "AP", "BMW", "CCTV", "CEO", "CPU", "DLC", "ESC", "ETF",
    "Excel", "FPS", "GPU", "Godot", "KOSPI", "KRW", "KTX", "LH",
    "Linux", "MBTI", "NFT", "OFF", "OK", "ON", "OTP", "PDF", "PC",
    "REIT", "SAFE", "SNS", "Steam", "Tab", "UI", "URL", "USB", "VIP",
    "WASD", "Wi-Fi", "Windows", "Daon", "KakaoTalk", "POSCO", "Copilot",
    "YouTuber", "goshiwon", "jeonse", "macOS", "oppa",
}
ENGLISH_PHRASE = re.compile(
    r"\b[A-Za-z][A-Za-z0-9'+.-]*(?:\s+[A-Za-z][A-Za-z0-9'+.-]*)+\b"
)
UNKNOWN_LATIN_TOKEN = re.compile(
    r"(?<![A-Za-z0-9])[A-Za-z][A-Za-z0-9'+.-]{0,}(?![A-Za-z0-9])"
)

FONT_CONSTANTS = {
    "zh-CN": "ZH_CN_FONT_PATH",
    "zh-TW": "ZH_TW_FONT_PATH",
}
FONT_SAMPLES = {
    "zh-CN": (0x6C49, 0x8BED, 0x94B1, 0x95E8, 0x540E, 0x3002),
    "zh-TW": (0x6F22, 0x8A9E, 0x9322, 0x9580, 0x5F8C, 0x3002),
}
DIRECT_BRANCH_EXCLUDED = {"scenes/HoldemClub.gd"}
DIRECT_BRANCH_ALLOWLIST = {
    "autoloads/GameState.gd": {
        "start_new_game": (
            'LocaleManager.is_english() and chosen_name == "김민준"',
        ),
    },
    "scenes/SplashScreen.gd": {
        "_ready": ("BuildInfoScript.apply_window_title",),
        "_select_language": ("BuildInfoScript.apply_window_title",),
    },
    "scenes/MainGame.gd": {
        "_quote_ui": ('return "\\\"%s\\\"" % text if LocaleManager.is_english()',),
        "_open_title_collection": ("if LocaleManager.is_english():",),
    },
    "scenes/ui/GangnamWordmark.gd": {
        "_init": (
            'var rows: Array = ["GANGNAM", "DREAM"] if LocaleManager.is_english()',
        ),
        "_make_letter_row": (
            "var max_spacing := 5 if LocaleManager.is_english() else 8",
        ),
    },
}


@dataclass(frozen=True)
class FontRoute:
    lang: str
    primary: str
    shared_han_jp_first: bool
    covered: int
    required: int
    ready: bool
    diagnostics: tuple[str, ...]


@dataclass(frozen=True)
class MoneyAmount:
    start: int
    end: int
    won: Decimal


@dataclass(frozen=True)
class CounterQuantity:
    start: int
    end: int
    value: Decimal
    kind: str


@dataclass(frozen=True)
class SemanticCount:
    start: int
    end: int
    value: int
    counter_class: str


_STATIC_UI_CACHE: UiInventory | None = None
_SCRIPT_FORBIDDEN_CACHE: dict[str, frozenset[str]] | None = None


def _static_ui_inventory() -> UiInventory:
    global _STATIC_UI_CACHE
    if _STATIC_UI_CACHE is None:
        _STATIC_UI_CACHE = collect_ui_inventory()
    return _STATIC_UI_CACHE


def read_json(path: pathlib.Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def _script_forbidden_sets() -> dict[str, frozenset[str]]:
    """Load a pinned classifier dataset; never convert or rewrite target text."""
    global _SCRIPT_FORBIDDEN_CACHE
    if _SCRIPT_FORBIDDEN_CACHE is not None:
        return _SCRIPT_FORBIDDEN_CACHE
    try:
        raw = SCRIPT_VARIANT_DATA_PATH.read_bytes()
    except OSError as exc:
        raise ValueError(f"script variant data unavailable: {exc}") from exc
    digest = hashlib.sha256(raw).hexdigest()
    if digest != SCRIPT_VARIANT_DATA_SHA256:
        raise ValueError(
            "script variant data SHA-256 mismatch: "
            f"{digest} != {SCRIPT_VARIANT_DATA_SHA256}"
        )
    try:
        license_digest = hashlib.sha256(
            SCRIPT_VARIANT_LICENSE_PATH.read_bytes()
        ).hexdigest()
    except OSError as exc:
        raise ValueError(f"script variant license unavailable: {exc}") from exc
    if license_digest != SCRIPT_VARIANT_LICENSE_SHA256:
        raise ValueError(
            "script variant license SHA-256 mismatch: "
            f"{license_digest} != {SCRIPT_VARIANT_LICENSE_SHA256}"
        )
    try:
        payload = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ValueError(f"script variant data is not valid UTF-8 JSON: {exc}") from exc
    if payload.get("schema_version") != 1:
        raise ValueError("script variant data schema_version must be 1")
    source = payload.get("source", {})
    if source.get("version") != "1.3.1" or source.get("revision") != (
        "2f569603954f1cddfdef7b648e71e1aa0d1f47a3"
    ):
        raise ValueError("script variant data source revision changed")
    forbidden = payload.get("forbidden")
    if not isinstance(forbidden, dict) or set(forbidden) != set(LANGUAGES):
        raise ValueError("script variant data must contain exactly zh-CN and zh-TW")
    decoded: dict[str, frozenset[str]] = {}
    for lang in LANGUAGES:
        characters = forbidden.get(lang)
        if not isinstance(characters, str):
            raise ValueError(f"{lang} script variant set must be a string")
        if "".join(sorted(characters)) != characters or (
            len(set(characters)) != len(characters)
        ):
            raise ValueError(f"{lang} script variant set must be sorted and unique")
        if len(characters) != SCRIPT_VARIANT_DATA_COUNTS[lang]:
            raise ValueError(
                f"{lang} script variant count {len(characters)} != "
                f"{SCRIPT_VARIANT_DATA_COUNTS[lang]}"
            )
        decoded[lang] = frozenset(characters)
    if decoded["zh-CN"] & decoded["zh-TW"]:
        raise ValueError("regional script variant sets overlap")
    _SCRIPT_FORBIDDEN_CACHE = decoded
    return decoded


def _tokens(text: str) -> list[str]:
    return sorted(PLACEHOLDER.findall(text))


def _name_is_used(source: str, korean: str) -> bool:
    contextual = AMBIGUOUS_NAME_CONTEXT.get(korean)
    if contextual is not None:
        return bool(contextual.search(source)) or source.strip() == korean \
            or f"한{korean}" in source
    return korean in source


def _has_unapproved_han_alias(target: str, romanized: str) -> bool:
    """Reject a second, invented Han-character name beside the locked Latin one."""
    latin = re.escape(romanized)
    han = r"[\u3400-\u4dbf\u4e00-\u9fff]{2,4}"
    # A bare space between Latin and Chinese prose is normal typography.  The
    # unbracketed mutation is high-confidence only when the Han run starts with
    # a Korean-cast surname commonly used in invented Hanja spellings.
    surnamed_han = r"[金韓韩林崔姜康朴][\u3400-\u4dbf\u4e00-\u9fff]{1,3}"
    patterns = [
        rf"{latin}\s+{surnamed_han}",
        rf"{surnamed_han}\s+{latin}",
    ]
    for opening, closing in (
        ("(", ")"), ("（", "）"), ("[", "]"), ("［", "］"),
        ("【", "】"), ("《", "》"), ("〈", "〉"), ("「", "」"),
        ("『", "』"),
    ):
        left = re.escape(opening)
        right = re.escape(closing)
        patterns.extend((
            rf"{latin}\s*{left}\s*{han}\s*{right}",
            rf"{left}\s*{han}\s*{right}\s*{latin}",
            rf"{han}\s*{left}\s*{latin}\s*{right}",
            rf"{left}\s*{latin}\s*{right}\s*{han}",
        ))
    return any(re.search(pattern, target) for pattern in patterns)


def _allows_latin_only(source: str, target: str) -> bool:
    expected = LATIN_EXACT.get(source.strip())
    return expected is not None and target.strip() == expected


def _script_errors(lang: str, target: str) -> list[str]:
    errors: list[str] = []
    compatibility = sorted({
        char for char in target
        if 0xF900 <= ord(char) <= 0xFAFF
        or 0x2F800 <= ord(char) <= 0x2FA1F
    })
    if compatibility:
        codepoints = ", ".join(
            f"U+{ord(char):04X}" for char in compatibility
        )
        errors.append(
            "noncanonical CJK compatibility ideograph is forbidden: "
            f"{codepoints}"
        )
    variation_sequences: list[str] = []
    for index in range(1, len(target)):
        selector = ord(target[index])
        if not (
            0xFE00 <= selector <= 0xFE0F
            or 0xE0100 <= selector <= 0xE01EF
        ):
            continue
        base = ord(target[index - 1])
        if not (
            0x3400 <= base <= 0x4DBF
            or 0x4E00 <= base <= 0x9FFF
            or 0xF900 <= base <= 0xFAFF
            or 0x20000 <= base <= 0x3347F
        ):
            continue
        variation_sequences.append(f"U+{base:04X}+U+{selector:04X}")
    if variation_sequences:
        errors.append(
            "noncanonical CJK variation selector is forbidden: "
            + ", ".join(sorted(set(variation_sequences)))
        )
    try:
        forbidden = set(_script_forbidden_sets()[lang])
    except (KeyError, ValueError) as exc:
        errors.append(f"regional script dataset invalid: {exc}")
        return errors
    for simplified, traditional in SCRIPT_VARIANTS:
        forbidden.add(traditional if lang == "zh-CN" else simplified)
    forbidden_phrases = {
        traditional if lang == "zh-CN" else simplified
        for simplified, traditional in REGIONAL_PHRASE_VARIANTS
    }
    found_characters = sorted(set(target) & forbidden)
    found_phrases = sorted(
        phrase for phrase in forbidden_phrases if phrase in target
    )
    if found_characters or found_phrases:
        preview = "".join(found_characters[:12])
        if len(found_characters) > 12:
            preview += f"…(+{len(found_characters) - 12})"
        details = []
        if preview:
            details.append(f"characters={preview!r}")
        if found_phrases:
            details.append(f"phrases={found_phrases!r}")
        errors.append(
            "regional script mismatch: " + ", ".join(details) + " belongs to "
            f"{'zh-TW' if lang == 'zh-CN' else 'zh-CN'} in this gate"
        )
    return errors


def _terminology_errors(lang: str, source: str, target: str) -> list[str]:
    errors: list[str] = []
    terms = REGIONAL_TERMS[lang]
    exact = LATIN_EXACT.get(source.strip())
    if exact is not None and target.strip() != exact:
        errors.append(
            f"exact prepared form mismatch: {target.strip()!r} != {exact!r}"
        )

    if "강남드림" in source and "GANGNAM DREAM" not in target:
        errors.append("game title must remain 'GANGNAM DREAM' until title GO")
    place_source = source.replace("강남드림", "")
    if "강남구" in place_source:
        if terms["district"] not in target:
            errors.append(f"강남구 must use {terms['district']!r}")
    elif "강남" in place_source and "江南" not in target:
        errors.append("강남 place name must retain '江南'")

    if "고시원" in source and terms["goshiwon"] not in target:
        errors.append(
            f"고시원 must use official {terms['goshiwon']!r}; "
            "goshiwon/context explanation may accompany it"
        )
    if "전세" in source and terms["jeonse"] not in target:
        errors.append(
            "전세 must retain the Korean lease concept as '全租'; "
            "jeonse/context explanation may accompany it"
        )
    requirements: tuple[tuple[str, str, str], ...] = (
        ("서울", "seoul", "서울"),
        ("원룸", "studio", "원룸"),
        ("빌라", "villa", "빌라"),
        ("월세", "monthly_rent", "월세"),
        ("삼각김밥", "triangle_gimbap", "삼각김밥"),
        ("포장마차", "pojangmacha", "포장마차"),
        ("한강", "han_river", "한강"),
        ("9급 공무원 시험", "civil_exam", "9급 공무원 시험"),
        ("카페의 남자", "cafe_man", "카페의 남자"),
    )
    for korean, term_key, label in requirements:
        expected = str(terms[term_key])
        if korean in source and expected not in target:
            errors.append(f"{label} must use regional form {expected!r}")
    if "9급" in source and any(
        marker in source for marker in ("기출문제집", "행정직", "공시")
    ) and str(terms["civil_exam"]) not in target:
        errors.append(
            f"Korean grade-9 civil-service context must use "
            f"{terms['civil_exam']!r}"
        )
    if "통장" in source and not any(
        allowed in target for allowed in terms["account"]
    ):
        errors.append(
            f"통장 must preserve a bank account/passbook meaning: {terms['account']!r}"
        )
    if "KTX" in source and "KTX" not in target:
        errors.append("KTX must remain 'KTX'")
    if "카카오톡" in source and "KakaoTalk" not in target:
        errors.append("카카오톡 must remain 'KakaoTalk'")
    if "고시원" in source and any(
        wrong in target
        for wrong in ("补习班", "補習班", "培训班", "培訓班", "学院", "學院")
    ):
        errors.append("고시원 was mistranslated as an academy")
    if "빌라" in source and ("别墅" in target or "別墅" in target):
        errors.append("Korean low-rise 빌라 was mistranslated as a detached villa")
    if "전세" in source:
        if "월세" not in source and "月租" in target:
            errors.append("전세 was mistranslated as monthly rent")
        if "매매" not in source and ("买卖" in target or "買賣" in target):
            errors.append("전세 was mistranslated as a sale")
    if "汉城" in target or "漢城" in target:
        errors.append("obsolete Seoul form 汉城/漢城 is forbidden")
    for korean, romanized in NAME_ROMANIZATION.items():
        if _name_is_used(source, korean) and romanized not in target:
            errors.append(
                f"cast name {korean!r} must retain Romanized form {romanized!r}; "
                "an invented Han-character-only name is not canonical"
            )
        if _name_is_used(source, korean) and _has_unapproved_han_alias(
            target, romanized,
        ):
            errors.append(
                f"cast name {romanized!r} has an unapproved Han-character alias"
            )
    return errors


def _decimal_value(raw: str) -> Decimal | None:
    try:
        return Decimal(raw.replace(",", ""))
    except InvalidOperation:
        return None


def _korean_word_value(raw: str) -> Decimal | None:
    digits = {
        "일": 1, "이": 2, "삼": 3, "사": 4, "오": 5,
        "육": 6, "칠": 7, "팔": 8, "구": 9,
    }
    places = {"십": 10, "백": 100, "천": 1000}
    total = 0
    current = 0
    for char in raw:
        if char in digits:
            current = digits[char]
        elif char in places:
            total += (current or 1) * places[char]
            current = 0
        else:
            return None
    return Decimal(total + current)


def _korean_native_value(raw: str) -> Decimal | None:
    if raw in KOREAN_NATIVE_ONES:
        return Decimal(KOREAN_NATIVE_ONES[raw])
    if raw in KOREAN_NATIVE_TENS:
        return Decimal(KOREAN_NATIVE_TENS[raw])
    for tens, tens_value in KOREAN_NATIVE_TENS.items():
        if not raw.startswith(tens):
            continue
        suffix = raw[len(tens):]
        if suffix in KOREAN_NATIVE_ONES:
            return Decimal(tens_value + KOREAN_NATIVE_ONES[suffix])
    return None


def _source_counter_value(raw: str) -> Decimal | None:
    if raw and raw[0].isdigit():
        return _decimal_value(raw)
    native = _korean_native_value(raw)
    return native if native is not None else _korean_word_value(raw)


def _chinese_cardinal_value(raw: str) -> Decimal | None:
    if raw and raw[0].isdigit():
        return _decimal_value(raw)
    digits = {
        "零": 0, "〇": 0, "○": 0, "一": 1, "二": 2,
        "两": 2, "兩": 2, "三": 3, "四": 4, "五": 5,
        "六": 6, "七": 7, "八": 8, "九": 9,
    }
    places = {"十": 10, "百": 100, "千": 1000}
    if not any(char in places for char in raw):
        if not raw or any(char not in digits for char in raw):
            return None
        return Decimal("".join(str(digits[char]) for char in raw))
    total = 0
    current = 0
    for char in raw:
        if char in digits:
            current = digits[char]
        elif char in places:
            total += (current or 1) * places[char]
            current = 0
        else:
            return None
    return Decimal(total + current)


def _ordinal_kind(source: str, end: int) -> str:
    following = source[end:].lstrip()
    if re.match(r"(?:로\s*(?:찾아|들어|세어)|에야)", following):
        return "ordinal_occurrence"
    for nouns, kind in ORDINAL_CONTEXT_CLASSES:
        if any(following.startswith(noun) for noun in nouns):
            return f"ordinal_{kind}"
    return "ordinal_generic"


def _source_counter_kind(
    source: str, match: re.Match[str], counter: str,
) -> str:
    following = source[match.end():].lstrip()
    if counter == "대" and re.match(r"(?:초|중|후)반", following):
        return "age_decade"
    if counter == "칸":
        preceding = source[max(0, match.start() - 16):match.start()]
        if "계단" in preceding:
            return "stair_step"
    preceding = source[max(0, match.start() - 24):match.start()]
    if counter == "일" and re.search(r"\d+\s*월\s*$", preceding):
        return "calendar_day"
    if counter == "분" and re.search(
        r"(?:\d+|한|두|세|네|다섯|여섯|일곱|여덟|아홉|열)\s*시\s*$",
        preceding,
    ):
        return "clock_minute"
    return SOURCE_COUNTER_CLASSES.get(counter, "")


def _source_counter_quantities(source: str) -> list[CounterQuantity]:
    quantities: list[CounterQuantity] = []
    for match in SOURCE_HALF_PYEONG.finditer(source):
        value = _decimal_value(match.group("number"))
        if value is not None:
            quantities.append(CounterQuantity(
                match.start(), match.end(), value + Decimal("0.5"), "pyeong",
            ))
    for match in SOURCE_TICKET_IDENTIFIER.finditer(source):
        value = _decimal_value(match.group("number"))
        if value is not None:
            quantities.append(CounterQuantity(
                match.start(), match.end(), value, "identifier"
            ))
    ordinal_values = {
        "첫": 1, "한": 1, "둘": 2, "두": 2,
        "셋": 3, "세": 3, "넷": 4, "네": 4,
    }
    for match in SOURCE_ORDINAL.finditer(source):
        if any(
            match.start() < quantity.end and match.end() > quantity.start
            for quantity in quantities
        ):
            continue
        raw = match.group("number")
        value = (
            Decimal(ordinal_values[raw]) if raw in ordinal_values
            else _source_counter_value(raw)
        )
        if value is not None:
            quantities.append(CounterQuantity(
                match.start(), match.end(), value,
                _ordinal_kind(source, match.end()),
            ))
    first_unit_kinds = {
        "줄": "line", "장": "sheet", "통화": "occurrence", "주": "week",
    }
    for match in SOURCE_FIRST_UNIT.finditer(source):
        if any(
            match.start() < quantity.end and match.end() > quantity.start
            for quantity in quantities
        ):
            continue
        quantities.append(CounterQuantity(
            match.start(), match.end(), Decimal(1),
            f"ordinal_{first_unit_kinds[match.group('counter')]}",
        ))
    for pattern in (
        SOURCE_DIGIT_COUNTER, SOURCE_WORD_COUNTER,
        SOURCE_COMPACT_SINO_COUNTER, SOURCE_COMPACT_NATIVE_COUNTER,
    ):
        for match in pattern.finditer(source):
            if any(
                match.start() < quantity.end and match.end() > quantity.start
                for quantity in quantities
            ):
                continue
            value = _source_counter_value(match.group("number"))
            kind = _source_counter_kind(
                source, match, match.group("counter"),
            )
            # `한 일` normally means work that was done, not one day. Korean
            # uses 하루 for the unambiguous native one-day counter.
            if match.group("number") == "한" and match.group("counter") == "일":
                continue
            if value is None or not kind:
                continue
            quantities.append(CounterQuantity(
                match.start(), match.end(), value, kind
            ))
    for match in SOURCE_BARE_AGE.finditer(source):
        if any(
            match.start() < quantity.end and match.end() > quantity.start
            for quantity in quantities
        ):
            continue
        value = _korean_native_value(match.group("number"))
        if value is not None:
            quantities.append(CounterQuantity(
                match.start(), match.end(), value, "age",
            ))
    for match in SOURCE_LEXICAL_DAY.finditer(source):
        if any(
            match.start() < quantity.end and match.end() > quantity.start
            for quantity in quantities
        ):
            continue
        if (
            match.group("day") == "하루"
            and source[max(0, match.start() - 3):match.start()] == "오늘 "
        ):
            # `오늘 하루` is idiomatic emphasis; natural Chinese `今天/今日`
            # already carries the day and must not be forced into `今天一天`.
            continue
        following = source[match.end():].lstrip()
        if re.match(r"째\s*(?:밤|야간|심야)", following):
            kind = "ordinal_night"
        elif re.match(
            r"(?:(?:짜리|연속)\s*)?(?:밤|야간|심야)", following,
        ):
            kind = "night"
        else:
            kind = "duration_day"
        quantities.append(CounterQuantity(
            match.start(), match.end(),
            Decimal(SOURCE_LEXICAL_DAYS[match.group("day")]), kind,
        ))
    for match in SOURCE_IMPLICIT_ENTITY.finditer(source):
        if any(
            match.start() < quantity.end and match.end() > quantity.start
            for quantity in quantities
        ):
            continue
        value = _korean_native_value(match.group("number"))
        if value is None or any(
            quantity.kind == "entity" and quantity.value == value
            for quantity in quantities
        ):
            continue
        quantities.append(CounterQuantity(
            match.start(), match.end(), value, "entity"
        ))
    return sorted(quantities, key=lambda quantity: quantity.start)


def _target_pattern_for_kind(kind: str) -> re.Pattern[str]:
    if kind == "ordinal_generic":
        return re.compile(
            rf"第\s*(?P<number>{CHINESE_CARDINAL})"
        )
    if kind.startswith("ordinal_"):
        base_kind = kind.removeprefix("ordinal_")
        forms = next(
            (forms for candidate_kind, forms in TARGET_COUNTER_FORMS
             if candidate_kind == base_kind),
            (),
        )
        return re.compile(
            rf"第\s*(?P<number>{CHINESE_CARDINAL})\s*(?:"
            + "|".join(
                re.escape(form) for form in sorted(forms, key=len, reverse=True)
            )
            + r")"
        )
    if kind == "age_decade":
        return re.compile(
            rf"(?P<number>{CHINESE_CARDINAL})\s*(?:"
            r"(?:多\s*)?(?:歲|岁)(?:出頭|出头)?|(?:出頭|出头))"
        )
    if kind == "clock_minute":
        return re.compile(
            rf"(?P<number>{CHINESE_CARDINAL})\s*分(?!鐘|钟)"
        )
    if kind == "pyeong":
        return re.compile(
            r"(?P<number>\d+(?:\.\d+)?|"
            r"[零〇○一二两兩三四五六七八九十百千]+)\s*坪(?P<half>半)?"
        )
    if kind == "identifier":
        return re.compile(
            rf"(?P<number>{CHINESE_CARDINAL})\s*(?:號|号)"
            r"(?=\s*(?:號碼|号码|牌|號碼牌|号码牌|客戶|客户|櫃台|柜台))"
        )
    forms = next(
        (forms for candidate_kind, forms in TARGET_COUNTER_FORMS
         if candidate_kind == kind),
        (),
    )
    return re.compile(
        rf"(?<![A-Za-z0-9零〇○一二两兩三四五六七八九十百千])"
        rf"(?P<number>{CHINESE_CARDINAL})\s*(?:"
        + "|".join(re.escape(form) for form in sorted(forms, key=len, reverse=True))
        + r")"
    )


def _match_target_counter_quantities(
    target: str, source_quantities: list[CounterQuantity],
) -> tuple[list[CounterQuantity], list[str]]:
    matched: list[CounterQuantity] = []
    errors: list[str] = []
    cursor = 0
    for expected in source_quantities:
        pattern = _target_pattern_for_kind(expected.kind)
        candidates: list[CounterQuantity] = []
        for match in pattern.finditer(target, cursor):
            value = _chinese_cardinal_value(match.group("number"))
            if value is not None and match.groupdict().get("half"):
                value += Decimal("0.5")
            if value is not None:
                candidates.append(CounterQuantity(
                    match.start(), match.end(), value, expected.kind
                ))
        exact = next(
            (candidate for candidate in candidates
             if candidate.value == expected.value),
            None,
        )
        if exact is None:
            errors.append(
                "counter quantity missing/changed: "
                f"expected ({expected.kind}, {expected.value}), "
                f"target candidates={[(row.kind, row.value) for row in candidates]}"
            )
            continue
        matched.append(exact)
        cursor = exact.end
    return matched, errors


def _unexpected_target_entity_errors(
    target: str, source_quantities: list[CounterQuantity],
    matched: list[CounterQuantity],
) -> list[str]:
    pattern = _target_pattern_for_kind("entity")
    expected_values = [
        row.value for row in source_quantities if row.kind == "entity"
    ]
    errors: list[str] = []
    for match in pattern.finditer(target):
        if any(
            match.start() < row.end and match.end() > row.start
            for row in matched
        ):
            continue
        value = _chinese_cardinal_value(match.group("number"))
        # Chinese naturally introduces a singular classifier where Korean has
        # no overt `one`; only unmatched plural quantities are high-confidence
        # inventions at this automatic layer.
        if value is not None and value > 1 and value not in expected_values:
            errors.append(f"unmatched target entity quantity invented: {value}")
    return errors


def _overlaps(amounts: list[MoneyAmount], start: int, end: int) -> bool:
    return any(start < amount.end and end > amount.start for amount in amounts)


def _source_money_amounts(source: str) -> list[MoneyAmount]:
    amounts: list[MoneyAmount] = []
    for match in SOURCE_EOK_MONEY.finditer(source):
        following = source[match.end():]
        if not following.startswith("원") and NON_MONEY_COUNTER.match(following):
            continue
        eok = _decimal_value(match.group("eok"))
        if eok is None:
            continue
        value = eok * Decimal(100_000_000)
        rest = match.group("rest")
        if rest is not None:
            rest_value = _decimal_value(rest)
            rest_unit = match.group("rest_unit")
            rest_multiplier = {
                "천": Decimal(10_000_000),
                "천만": Decimal(10_000_000),
                "만": Decimal(10_000),
            }[rest_unit]
            if rest_value is not None:
                value += rest_value * rest_multiplier
        amounts.append(MoneyAmount(match.start(), match.end(), value))

    for match in SOURCE_EXPLICIT_MONEY.finditer(source):
        if _overlaps(amounts, match.start(), match.end()):
            continue
        number = _decimal_value(match.group("number"))
        if number is None:
            continue
        multiplier = {
            None: Decimal(1),
            "천": Decimal(1_000),
            "만": Decimal(10_000),
            "천만": Decimal(10_000_000),
        }[match.group("unit")]
        amounts.append(MoneyAmount(
            match.start(), match.end(), number * multiplier
        ))

    for match in SOURCE_WORD_MONEY.finditer(source):
        if _overlaps(amounts, match.start(), match.end()):
            continue
        number = _korean_word_value(match.group("number"))
        if number is None:
            continue
        multiplier = {
            None: Decimal(1),
            "만": Decimal(10_000),
            "억": Decimal(100_000_000),
        }[match.group("unit")]
        amounts.append(MoneyAmount(
            match.start(), match.end(), number * multiplier
        ))

    for match in SOURCE_BARE_ONE_MONEY.finditer(source):
        if _overlaps(amounts, match.start(), match.end()):
            continue
        multiplier = {
            "만": Decimal(10_000),
            "억": Decimal(100_000_000),
        }[match.group("unit")]
        amounts.append(MoneyAmount(
            match.start(), match.end(), multiplier
        ))

    for match in SOURCE_COLLOQUIAL_MANWON.finditer(source):
        if _overlaps(amounts, match.start(), match.end()):
            continue
        raw = match.group("number")
        number = (
            _decimal_value(raw) if raw[0].isdigit()
            else _korean_word_value(raw)
        )
        if number is None:
            continue
        amounts.append(MoneyAmount(
            match.start(), match.end(), number * Decimal(10_000)
        ))

    for match in KOREAN_UNIT_AMOUNT.finditer(source):
        if _overlaps(amounts, match.start(), match.end()):
            continue
        following = source[match.end():]
        if not following.startswith("원") and NON_MONEY_COUNTER.match(following):
            continue
        number = _decimal_value(match.group("number"))
        if number is None:
            continue
        multiplier = {
            "천": Decimal(10_000_000),
            "천만": Decimal(10_000_000),
            "만": Decimal(10_000),
            "억": Decimal(100_000_000),
        }[match.group("units")]
        amounts.append(MoneyAmount(
            match.start(), match.end(), number * multiplier
        ))
    return sorted(amounts, key=lambda amount: amount.start)


def _target_money_amounts(target: str) -> list[MoneyAmount]:
    multipliers = {
        None: Decimal(1),
        "千": Decimal(1_000),
        "万": Decimal(10_000),
        "萬": Decimal(10_000),
        "千万": Decimal(10_000_000),
        "千萬": Decimal(10_000_000),
        "亿": Decimal(100_000_000),
        "億": Decimal(100_000_000),
        "万亿": Decimal(1_000_000_000_000),
        "萬億": Decimal(1_000_000_000_000),
    }
    amounts: list[MoneyAmount] = []
    for match in TARGET_WON_MONEY.finditer(target):
        value = Decimal(0)
        components = list(CHINESE_MONEY_COMPONENT.finditer(match.group("expression")))
        if not components:
            continue
        valid = True
        for component in components:
            number = _decimal_value(component.group("number"))
            if number is None:
                valid = False
                break
            value += number * multipliers[component.group("unit")]
        if valid:
            amounts.append(MoneyAmount(match.start(), match.end(), value))
    return amounts


def _mask_spans(text: str, amounts: Iterable[MoneyAmount]) -> str:
    chars = list(text)
    for amount in amounts:
        chars[amount.start:amount.end] = " " * (amount.end - amount.start)
    return "".join(chars)


def _canonical_number(raw: str) -> str:
    percent = raw.endswith("%")
    value = _decimal_value(raw[:-1] if percent else raw)
    if value is None:
        return raw
    canonical = format(value.normalize(), "f")
    if "." in canonical:
        canonical = canonical.rstrip("0").rstrip(".")
    return canonical + ("%" if percent else "")


def _numeric_errors(source: str, target: str) -> list[str]:
    errors: list[str] = []
    source_amounts = _source_money_amounts(source)
    target_amounts = _target_money_amounts(target)
    source_values = [amount.won for amount in source_amounts]
    target_values = [amount.won for amount in target_amounts]
    if source_values != target_values:
        errors.append(
            f"Korean-won values changed: {source_values} != {target_values}"
        )
    target_label_count = len(re.findall(r"韩元|韓元", target))
    if (source_amounts or target_amounts) and target_label_count != len(target_amounts):
        errors.append(
            f"Korean-won label count/topology mismatch "
            f"{target_label_count} != {len(target_amounts)}"
        )

    source_quantities = _source_counter_quantities(
        _mask_spans(source, source_amounts)
    )
    target_quantities, counter_errors = _match_target_counter_quantities(
        _mask_spans(target, target_amounts), source_quantities
    )
    errors.extend(counter_errors)
    errors.extend(_unexpected_target_entity_errors(
        _mask_spans(target, target_amounts), source_quantities,
        target_quantities,
    ))

    source_rest = _mask_spans(
        _mask_spans(source, source_amounts), source_quantities
    )
    target_rest = _mask_spans(
        _mask_spans(target, target_amounts), target_quantities
    )
    if "9급" in source:
        target_rest = target_rest.replace("九级", "9级").replace("九級", "9級")
    source_numbers = [_canonical_number(value) for value in NUMBER.findall(source_rest)]
    target_numbers = [_canonical_number(value) for value in NUMBER.findall(target_rest)]
    if source_numbers != target_numbers:
        errors.append(
            f"non-money number sequence changed: {source_numbers} != {target_numbers}"
        )
    return errors


def _korean_money_units(source: str) -> set[str]:
    units: set[str] = set()
    for match in KOREAN_UNIT_AMOUNT.finditer(source):
        following = source[match.end():]
        # An explicit 원 is always currency.  Bare Korean large-number shorthand
        # is currency in this game's financial prose unless a concrete counter
        # (years, people, repetitions, floors...) follows it.
        if not following.startswith("원") and NON_MONEY_COUNTER.match(following):
            continue
        units.update(match.group("units"))
    return units


def _money_errors(lang: str, source: str, target: str) -> list[str]:
    errors: list[str] = []
    has_won = bool(KOREAN_WON.search(source) or _source_money_amounts(source))
    expected = REGIONAL_TERMS[lang]["won"]
    wrong_region = REGIONAL_TERMS["zh-TW" if lang == "zh-CN" else "zh-CN"]["won"]
    if WRONG_CURRENCY.search(target):
        errors.append("Korean won was relabeled as yen/yuan/Taiwan dollar")
    currency_scrubbed = target.replace("韩元", "").replace("韓元", "")
    if BARE_YUAN_AMOUNT.search(currency_scrubbed):
        errors.append("numeric 元/圓 amount is forbidden; Korean-won meaning is required")
    if has_won:
        if expected not in target:
            errors.append(f"Korean won amount must use {expected!r}")
        if wrong_region in target:
            errors.append(f"wrong-region Korean won form {wrong_region!r}")
    elif expected in target or wrong_region in target:
        errors.append("translation invented a Korean-won label absent from source")
    return errors


def _untranslated_english_errors(source: str, target: str) -> list[str]:
    scrubbed = PLACEHOLDER.sub(" ", target)
    scrubbed = re.sub(r"https?://\S+|www\.\S+", " ", scrubbed)
    source_tokens = set(re.findall(
        r"(?<![A-Za-z0-9])[A-Za-z][A-Za-z0-9'+./:_-]*(?![A-Za-z0-9])",
        source,
    ))
    for token in sorted(source_tokens, key=len, reverse=True):
        scrubbed = re.sub(
            rf"(?<![A-Za-z0-9]){re.escape(token)}(?![A-Za-z0-9])",
            " ",
            scrubbed,
            flags=re.IGNORECASE,
        )
    for phrase in ALLOWED_LATIN_PHRASES:
        scrubbed = re.sub(re.escape(phrase), " ", scrubbed, flags=re.IGNORECASE)
    for token in sorted(ALLOWED_LATIN_TOKENS, key=len, reverse=True):
        scrubbed = re.sub(
            rf"(?<![A-Za-z0-9]){re.escape(token)}(?![A-Za-z0-9])",
            " ",
            scrubbed,
            flags=re.IGNORECASE,
        )
    match = ENGLISH_PHRASE.search(scrubbed)
    if match:
        return [f"untranslated English phrase remains: {match.group(0)!r}"]
    match = UNKNOWN_LATIN_TOKEN.search(scrubbed)
    if match:
        return [f"untranslated English token remains: {match.group(0)!r}"]
    return []


def validate_text(lang: str, key: str, source: str, target: Any) -> list[str]:
    """Validate one Korean-source Chinese target without generating content."""
    if lang not in LANGUAGES:
        return [f"unsupported Chinese locale {lang!r}"]
    if not isinstance(target, str):
        return [f"target is {type(target).__name__}, expected string"]
    errors: list[str] = []
    if not target.strip():
        errors.append("empty translation")
        return errors
    if HANGUL.search(target):
        errors.append("Hangul remains")
    if KANA.search(target):
        errors.append("Japanese kana remains")
    if _tokens(source) != _tokens(target):
        errors.append("placeholder/BBCode mismatch")
    if source.count("\n") != target.count("\n"):
        errors.append(
            f"newline mismatch {source.count(chr(10))} != {target.count(chr(10))}"
        )
    if source.count("\n\n") != target.count("\n\n"):
        errors.append("paragraph mismatch")
    errors.extend(_numeric_errors(source, target))
    if HANGUL.search(source) and not HAN.search(target) \
            and not _allows_latin_only(source, target):
        errors.append("no Chinese Han glyphs in translated Korean source")
    errors.extend(_script_errors(lang, target))
    errors.extend(_terminology_errors(lang, source, target))
    errors.extend(_money_errors(lang, source, target))
    errors.extend(_untranslated_english_errors(source, target))
    return list(dict.fromkeys(errors))


def _gd_string_constant(source: str, name: str) -> str:
    match = re.search(
        rf'^const\s+{re.escape(name)}\s*:=\s*("(?:\\.|[^"\\])*")\s*$',
        source,
        re.MULTILINE,
    )
    if match is None:
        return ""
    try:
        value = json.loads(match.group(1))
    except json.JSONDecodeError:
        return ""
    return value if isinstance(value, str) else ""


def _project_path(resource_path: str) -> pathlib.Path | None:
    if not resource_path.startswith("res://"):
        return None
    return ROOT / resource_path.removeprefix("res://")


def _cmap_subtables(data: bytes) -> Iterable[tuple[int, int]]:
    if len(data) < 12:
        return
    num_tables = struct.unpack_from(">H", data, 4)[0]
    cmap_offset = -1
    cmap_length = 0
    for index in range(num_tables):
        record = 12 + index * 16
        if record + 16 > len(data):
            return
        tag, _checksum, offset, length = struct.unpack_from(">4sIII", data, record)
        if tag == b"cmap":
            cmap_offset, cmap_length = offset, length
            break
    if cmap_offset < 0 or cmap_offset + 4 > len(data):
        return
    _version, count = struct.unpack_from(">HH", data, cmap_offset)
    for index in range(count):
        record = cmap_offset + 4 + index * 8
        if record + 8 > min(len(data), cmap_offset + cmap_length):
            return
        platform, encoding, relative = struct.unpack_from(">HHI", data, record)
        if platform == 0 or (platform == 3 and encoding in (1, 10)):
            offset = cmap_offset + relative
            if offset + 2 <= len(data):
                yield offset, struct.unpack_from(">H", data, offset)[0]


def _format4_has(data: bytes, offset: int, codepoint: int) -> bool:
    if codepoint > 0xFFFF or offset + 14 > len(data):
        return False
    length, seg_count_x2 = struct.unpack_from(">HH", data, offset + 2)
    end = min(len(data), offset + length)
    seg_count = seg_count_x2 // 2
    end_codes = offset + 14
    start_codes = end_codes + seg_count * 2 + 2
    deltas = start_codes + seg_count * 2
    range_offsets = deltas + seg_count * 2
    if range_offsets + seg_count * 2 > end:
        return False
    for index in range(seg_count):
        segment_end = struct.unpack_from(">H", data, end_codes + index * 2)[0]
        segment_start = struct.unpack_from(">H", data, start_codes + index * 2)[0]
        if segment_start <= codepoint <= segment_end:
            delta = struct.unpack_from(">h", data, deltas + index * 2)[0]
            range_offset_pos = range_offsets + index * 2
            range_offset = struct.unpack_from(">H", data, range_offset_pos)[0]
            if range_offset == 0:
                return (codepoint + delta) % 65536 != 0
            glyph_pos = range_offset_pos + range_offset + 2 * (codepoint - segment_start)
            if glyph_pos + 2 > end:
                return False
            glyph = struct.unpack_from(">H", data, glyph_pos)[0]
            return glyph != 0 and (glyph + delta) % 65536 != 0
        if codepoint < segment_start:
            return False
    return False


def _format12_has(data: bytes, offset: int, codepoint: int) -> bool:
    if offset + 16 > len(data):
        return False
    length, groups = struct.unpack_from(">II", data, offset + 4)[0], \
        struct.unpack_from(">I", data, offset + 12)[0]
    end = min(len(data), offset + length)
    cursor = offset + 16
    for _index in range(groups):
        if cursor + 12 > end:
            return False
        start, finish, glyph = struct.unpack_from(">III", data, cursor)
        if start <= codepoint <= finish:
            return glyph + codepoint - start != 0
        if codepoint < start:
            return False
        cursor += 12
    return False


def _font_coverage(path: pathlib.Path, samples: Iterable[int]) -> tuple[int, str]:
    try:
        data = path.read_bytes()
    except OSError as exc:
        return 0, f"font unreadable: {exc}"
    subtables = list(_cmap_subtables(data))
    if not subtables:
        return 0, "font has no readable Unicode cmap"
    covered = 0
    for codepoint in samples:
        found = False
        for offset, fmt in subtables:
            if fmt == 4 and _format4_has(data, offset, codepoint):
                found = True
                break
            if fmt in (12, 13) and _format12_has(data, offset, codepoint):
                found = True
                break
        covered += int(found)
    return covered, ""


def _font_ledger_bundle(
    font_path: pathlib.Path, ledger_text: str | None = None,
) -> tuple[bool, str]:
    ledger_path = ROOT / "assets/fonts/FONT_LICENSE_LEDGER.md"
    try:
        ledger = ledger_text if ledger_text is not None else ledger_path.read_text(
            encoding="utf-8"
        )
        font_digest = hashlib.sha256(font_path.read_bytes()).hexdigest()
    except OSError as exc:
        return False, f"font ledger bundle unreadable: {exc}"
    row = next(
        (line for line in ledger.splitlines() if f"`{font_path.name}`" in line),
        "",
    )
    if not row or font_digest not in ledger:
        return False, "font full SHA-256 is absent from the font ledger"
    link = re.search(r"\[`([^`]+)`\]\(([^)]+)\)", row)
    if link is None or "OFL" not in link.group(1).upper():
        return False, "font ledger row has no OFL license link"
    license_target = link.group(2)
    license_path = (ledger_path.parent / license_target).resolve()
    try:
        license_path.relative_to(ledger_path.parent.resolve())
    except ValueError:
        return False, "font license link escapes assets/fonts"
    if not license_path.is_file():
        return False, f"linked OFL file is missing: {license_target}"
    try:
        license_bytes = license_path.read_bytes()
    except OSError as exc:
        return False, f"linked OFL file is unreadable: {exc}"
    license_text = license_bytes.decode("utf-8", errors="replace").upper()
    if "SIL OPEN FONT LICENSE" not in license_text or "VERSION 1.1" not in license_text:
        return False, "linked license is not a complete SIL OFL 1.1 copy"
    license_digest = hashlib.sha256(license_bytes).hexdigest()
    integrity_row = re.compile(
        rf"\|\s*`{re.escape(license_path.name)}`\s*\|\s*"
        rf"`{license_digest}`\s*\|"
    )
    if integrity_row.search(ledger) is None:
        return False, "OFL full SHA-256 is absent from license integrity ledger"
    return True, ""


def _locale_font_precedes_jp(source: str, primary_exists: bool) -> bool:
    if not primary_exists:
        return False
    code_without_comments = re.sub(r"(?m)#.*$", "", source)
    attach_match = re.search(
        r"(?ms)^static func attach_locale_fallbacks\(([^\n]*)\).*?"
        r"(?=^static func |\Z)",
        code_without_comments,
    )
    if attach_match is None or "language" not in attach_match.group(1):
        return False
    attach_block = attach_match.group(0)
    getter = re.search(
        r"(?:var\s+(?P<var>[A-Za-z_][A-Za-z0-9_]*)\s*:?=\s*)?"
        r"_get_dedicated_locale_font\(language\)",
        attach_block,
    )
    if getter is None:
        return False
    if getter.group("var"):
        dedicated_append = re.search(
            rf"_append_fallback\(\s*font\s*,\s*"
            rf"{re.escape(getter.group('var'))}\s*\)",
            attach_block[getter.end():],
        )
        dedicated_position = (
            getter.end() + dedicated_append.start()
            if dedicated_append is not None else -1
        )
    else:
        direct_append = re.search(
            r"_append_fallback\(\s*font\s*,\s*"
            r"_get_dedicated_locale_font\(language\)\s*\)",
            attach_block,
        )
        dedicated_position = direct_append.start() if direct_append else -1
    jp_append = re.search(
        r"_append_fallback\(\s*font\s*,\s*_get_jp_font\(\)\s*\)",
        attach_block,
    )
    return dedicated_position >= 0 and (
        jp_append is None or dedicated_position < jp_append.start()
    )


def font_route(
    lang: str, override_primary: str | None = None,
    required_codepoints: Iterable[int] | None = None,
) -> FontRoute:
    source = (ROOT / "autoloads/FontKit.gd").read_text(encoding="utf-8")
    primary = override_primary if override_primary is not None else _gd_string_constant(
        source, FONT_CONSTANTS[lang]
    )
    jp_path = _gd_string_constant(source, "JP_FONT_PATH")
    diagnostics: list[str] = []
    samples = tuple(sorted(set(required_codepoints or FONT_SAMPLES[lang])))
    required = len(samples)
    covered = 0
    project_path = _project_path(primary) if primary else None
    primary_exists = project_path is not None and project_path.is_file()
    if primary and not primary_exists:
        diagnostics.append("dedicated font path is absent or outside res://")
    if primary_exists and project_path is not None:
        covered, cmap_error = _font_coverage(project_path, samples)
        if cmap_error:
            diagnostics.append(cmap_error)

    locale_font_precedes_jp = _locale_font_precedes_jp(
        source, primary_exists
    )
    jp_project_path = _project_path(jp_path)
    shared_han_jp_first = bool(
        jp_project_path is not None and jp_project_path.is_file()
        and not locale_font_precedes_jp
    )
    if primary_exists and not locale_font_precedes_jp:
        diagnostics.append(
            "active-language dedicated Chinese font is not appended before JP"
        )

    ledger_ok = False
    if primary_exists and project_path is not None:
        ledger_ok, ledger_error = _font_ledger_bundle(project_path)
        if not ledger_ok:
            diagnostics.append(ledger_error)

    ready = bool(
        primary_exists and covered == required and ledger_ok
        and not shared_han_jp_first
    )
    return FontRoute(
        lang=lang,
        primary=primary or "missing",
        shared_han_jp_first=shared_han_jp_first,
        covered=covered,
        required=required,
        ready=ready,
        diagnostics=tuple(diagnostics),
    )


def chinese_contract_errors(manifest: dict[str, Any]) -> list[str]:
    ui_contract = manifest.get("ui_semantic_context_blocker")
    inventory = collect_ui_inventory(
        ui_contract if isinstance(ui_contract, dict) else {}
    )
    static_sources = sorted(inventory.legacy_blueprint)
    expected = {
        "source_language": "ko",
        "automatic_script_conversion": False,
        "body_translation": "held_until_explicit_demo_GO",
        "shipping": False,
        "static_ui_source_count": len(static_sources),
        "static_ui_source_keys_sha256": hashlib.sha256(
            "\n".join(static_sources).encode("utf-8")
        ).hexdigest(),
    }
    contract = manifest.get("chinese_preparation_contract")
    if not isinstance(contract, dict):
        return ["manifest: chinese_preparation_contract is missing"]
    errors: list[str] = [f"UI context: {error}" for error in inventory.errors]
    for key, value in expected.items():
        if contract.get(key) != value:
            errors.append(
                f"manifest: chinese_preparation_contract.{key} "
                f"{contract.get(key)!r} != {value!r}"
            )
    regions = contract.get("regions")
    if not isinstance(regions, dict) or set(regions) != set(LANGUAGES):
        errors.append("manifest: Chinese regions must be exactly zh-CN and zh-TW")
        return errors
    for lang in LANGUAGES:
        expected_region = {
            "source_language": "ko",
            "event_overlay": f"content/events_{lang}/",
            "ui_dictionary": f"locale/ui_{lang}.json",
            "catalog_dictionary": f"locale/catalog_{lang}.json",
        }
        region = regions.get(lang)
        if not isinstance(region, dict):
            errors.append(f"manifest: region contract is not an object: {lang}")
            continue
        for key, value in expected_region.items():
            if region.get(key) != value:
                errors.append(
                    f"manifest: {lang}.{key} {region.get(key)!r} != {value!r}"
                )
    return errors


def static_ui_coverage(
    lang: str, runtime: dict[str, Any], strict: bool,
    actual_override: Optional[dict[str, Any]] = None,
) -> tuple[int, int, int, int, list[str]]:
    inventory = _static_ui_inventory()
    legacy_entries = {entry.source: entry for entry in inventory.legacy_entries}
    context_entries = {
        entry.context_id: entry for entry in inventory.planned_context_entries
    }
    expected_legacy = set(inventory.legacy_blueprint)
    expected_context = set(inventory.planned_context_blueprint)
    ui_path = ROOT / "locale" / f"ui_{lang}.json"
    actual = actual_override
    if actual is None:
        actual = read_json(ui_path) if ui_path.is_file() else {}
    errors: list[str] = []
    if not isinstance(actual, dict):
        return 0, len(expected_legacy), 0, len(expected_context), [
            f"{ui_path.relative_to(ROOT)}: expected object"
        ]

    allowed = expected_legacy | expected_context | set(runtime["merged_pairs"])
    unknown = sorted(set(actual) - allowed)
    if unknown:
        errors.append(f"{lang}:ui: unknown source keys {unknown[:8]}")
    legacy_covered = 0
    for source in sorted(expected_legacy):
        if source not in actual:
            continue
        target = actual[source]
        if not isinstance(target, str) or not target.strip():
            errors.append(f"{lang}:ui:{source!r}: empty/non-string translation")
            continue
        legacy_covered += 1
        entry = legacy_entries[source]
        for error in validate_text(lang, entry.key, source, target):
            errors.append(f"{lang}:{entry.key}: {error}")
    context_covered = 0
    for context_id in sorted(expected_context):
        if context_id not in actual:
            continue
        target = actual[context_id]
        if not isinstance(target, str) or not target.strip():
            errors.append(f"{lang}:ui:{context_id!r}: empty/non-string translation")
            continue
        context_covered += 1
        entry = context_entries[context_id]
        for error in validate_text(lang, entry.key, entry.source, target):
            errors.append(f"{lang}:{entry.key}: {error}")
    if strict and legacy_covered != len(expected_legacy):
        errors.append(
            f"{lang}: strict legacy static_ui coverage "
            f"{legacy_covered}/{len(expected_legacy)}"
        )
    if strict and context_covered != len(expected_context):
        errors.append(
            f"{lang}: strict context static_ui coverage "
            f"{context_covered}/{len(expected_context)}"
        )
    return (
        legacy_covered,
        len(expected_legacy),
        context_covered,
        len(expected_context),
        errors,
    )


def required_chinese_codepoints(
    lang: str, runtime: dict[str, Any],
) -> set[int]:
    values: list[str] = []
    overlays, _load_errors = demo_scope.load_overlay_events(lang)
    for leaf in runtime["leaves"]:
        overlay = overlays.get(leaf.event_id)
        if not isinstance(overlay, dict):
            continue
        translated = demo_scope._value_at_tokens(overlay, leaf.tokens)
        if isinstance(translated, str):
            values.append(translated)

    ui_path = ROOT / "locale" / f"ui_{lang}.json"
    ui = read_json(ui_path) if ui_path.is_file() else {}
    if isinstance(ui, dict):
        values.extend(value for value in ui.values() if isinstance(value, str))

    catalog_path = ROOT / "locale" / f"catalog_{lang}.json"
    catalog = read_json(catalog_path) if catalog_path.is_file() else {}
    assets = catalog.get("assets", {}) if isinstance(catalog, dict) else {}
    if isinstance(assets, dict):
        for asset_id in runtime["catalog_asset_ids"]:
            row = assets.get(asset_id)
            if isinstance(row, dict) and isinstance(row.get("name"), str):
                values.append(row["name"])

    codepoints = set(FONT_SAMPLES[lang])
    for value in values:
        for char in value:
            codepoint = ord(char)
            if (
                0x3400 <= codepoint <= 0x4DBF
                or 0x4E00 <= codepoint <= 0x9FFF
                or 0xF900 <= codepoint <= 0xFAFF
                or 0x3000 <= codepoint <= 0x303F
                or 0x3100 <= codepoint <= 0x312F
                or 0xFF01 <= codepoint <= 0xFF60
            ):
                codepoints.add(codepoint)
    return codepoints


def _direct_branch_errors_for_source(
    relative: str, source: str,
) -> list[str]:
    errors: list[str] = []
    current_function = "<top-level>"
    allowed_functions = DIRECT_BRANCH_ALLOWLIST.get(relative, {})
    for line_number, line in enumerate(source.splitlines(), start=1):
        function_match = re.match(
            r"^\s*(?:static\s+)?func\s+([A-Za-z0-9_]+)\s*\(", line
        )
        if function_match is not None:
            current_function = function_match.group(1)
        if "LocaleManager.is_english()" not in line:
            continue
        allowed_fragments = allowed_functions.get(current_function, ())
        if any(fragment in line for fragment in allowed_fragments):
            continue
        errors.append(
            f"{relative}:{line_number}:{current_function}: prepared locale can "
            "enter a direct English branch instead of LocaleManager.ui"
        )
    return errors


def prepared_locale_direct_bypasses() -> tuple[list[str], int]:
    errors: list[str] = []
    for directory in ("autoloads", "scenes", "systems", "ui_components"):
        for path in sorted((ROOT / directory).rglob("*.gd")):
            relative = path.relative_to(ROOT).as_posix()
            if relative in DIRECT_BRANCH_EXCLUDED:
                continue
            errors.extend(_direct_branch_errors_for_source(
                relative, path.read_text(encoding="utf-8")
            ))
    return errors, len(errors)


def chinese_runtime_contract_errors(block: str | None = None) -> list[str]:
    if block is None:
        try:
            block = demo_scope.release_inventory.gd_function_block(
                ROOT / "scenes/StoryMode.gd", "_auto_reading_delay"
            )
        except ValueError as exc:
            return [str(exc)]
    errors: list[str] = []
    code_without_comments = re.sub(r"(?m)#.*$", "", block)
    cjk_route = re.search(
        r"LocaleManager\.language\s+in\s*\[(?P<languages>[^\]]+)\]",
        code_without_comments,
    )
    routed_languages = set(
        re.findall(r'[\x22\x27]([^\x22\x27]+)[\x22\x27]',
                   cjk_route.group("languages"))
    ) if cjk_route is not None else set()
    if not {"zh-CN", "zh-TW"}.issubset(routed_languages):
        errors.append(
            "StoryMode._auto_reading_delay: Chinese prose is not routed through "
            "the CJK character-rate reading budget"
        )
    return errors


def _expect_error(
    failures: list[str], label: str, lang: str, source: str, target: str,
    needle: str,
) -> None:
    errors = validate_text(lang, f"self-test::{label}", source, target)
    if not any(needle in error for error in errors):
        failures.append(f"{label}: expected {needle!r}, got {errors}")


def run_self_test(
    manifest: dict[str, Any], runtime: dict[str, Any],
) -> list[str]:
    failures: list[str] = []
    cases = 0

    for lang, target in (
        ("zh-CN", "在江南，目标是30亿韩元。"),
        ("zh-TW", "在江南，目標是30億韓元。"),
    ):
        cases += 1
        errors = validate_text(lang, "self-test::valid-money", "강남에서 목표는 30억원.", target)
        if errors:
            failures.append(f"valid {lang} sample failed: {errors}")

    mutations = (
        ("hangul", "zh-CN", "강남", "江南 강남", "Hangul remains"),
        ("kana", "zh-CN", "강남", "江南カンナム", "Japanese kana remains"),
        ("latin-prose", "zh-CN", "돈", "Money", "no Chinese Han glyphs"),
        ("cn-script", "zh-CN", "30억원", "30億韓元", "regional script mismatch"),
        ("tw-script", "zh-TW", "30억원", "30亿韩元", "regional script mismatch"),
        ("yuan", "zh-CN", "30억원", "30亿元人民币", "relabeled as yen/yuan"),
        ("placeholder", "zh-CN", "{name}의 돈", "他的钱", "placeholder/BBCode"),
        ("newline", "zh-CN", "첫 줄\n둘째 줄", "第一行 第二行", "newline mismatch"),
        ("invented-name", "zh-CN", "김민준", "金敏俊", "Romanized form"),
        ("invented-youngsu", "zh-CN", "김영수", "金永洙", "Kim Youngsu"),
        ("invented-manager-kim", "zh-TW", "김 부장", "金部長", "Manager Kim"),
        ("title", "zh-CN", "강남드림", "江南梦", "GANGNAM DREAM"),
        ("goshiwon", "zh-CN", "고시원", "补习班", "考试院"),
        ("jeonse", "zh-TW", "전세", "月租", "全租"),
        (
            "english-sentence", "zh-CN", "번역되지 않은 문장",
            "这是 untranslated English sentence", "untranslated English phrase",
        ),
        (
            "english-token", "zh-CN", "돈", "这是 Money",
            "untranslated English token",
        ),
        ("cn-biaoti", "zh-CN", "목표", "目標", "regional script mismatch"),
        ("tw-biaoti", "zh-TW", "목표", "目标", "regional script mismatch"),
        (
            "cn-full-script-map", "zh-CN", "꽃이 아름답다", "花朵很鮮豔",
            "regional script mismatch",
        ),
        (
            "tw-full-script-map", "zh-TW", "꽃이 아름답다", "花朵很鲜艳",
            "regional script mismatch",
        ),
        (
            "cn-compatibility-ideograph", "zh-CN", "차", "車",
            "CJK compatibility ideograph",
        ),
        (
            "tw-compatibility-supplement", "zh-TW", "사람", "\U0002F800",
            "CJK compatibility ideograph",
        ),
        (
            "cn-cjk-ivs", "zh-CN", "차", "车\U000E0100",
            "CJK variation selector",
        ),
        (
            "tw-cjk-vs1", "zh-TW", "차", "車\uFE00",
            "CJK variation selector",
        ),
        (
            "english-title-exact", "zh-TW", "GANGNAM DREAM", "江南之夢",
            "exact prepared form mismatch",
        ),
        (
            "name-alias-exact", "zh-CN", "김민준", "Kim Minjun（金敏俊）",
            "exact prepared form mismatch",
        ),
        (
            "name-alias-prose", "zh-TW", "김민준이 왔다.",
            "Kim Minjun（金敏俊）來了。", "unapproved Han-character alias",
        ),
        (
            "name-alias-spaced", "zh-CN", "김민준이 왔다.",
            "Kim Minjun 金敏俊来了。", "unapproved Han-character alias",
        ),
        (
            "name-alias-prefix", "zh-CN", "김민준이 왔다.",
            "金敏俊（Kim Minjun）来了。", "unapproved Han-character alias",
        ),
        (
            "name-alias-corner", "zh-CN", "김민준이 왔다.",
            "Kim Minjun【金敏俊】来了。", "unapproved Han-character alias",
        ),
        (
            "name-alias-corner-prefix", "zh-TW", "김민준이 왔다.",
            "【金敏俊】Kim Minjun來了。", "unapproved Han-character alias",
        ),
        (
            "ordinal-month-unit", "zh-CN", "일곱 번째 달",
            "第七次", "counter quantity missing/changed",
        ),
        (
            "ordinal-landing-unit", "zh-CN", "세 번째 층계참",
            "第三轮", "counter quantity missing/changed",
        ),
        (
            "ordinal-call-unit", "zh-CN", "두 번째 통화",
            "第二个月", "counter quantity missing/changed",
        ),
        (
            "ordinal-coffee-unit", "zh-CN", "두 번째 믹스커피",
            "第二年混合咖啡", "counter quantity missing/changed",
        ),
        (
            "building-counter-value", "zh-CN", "건물 두 채",
            "三栋楼", "counter quantity missing/changed",
        ),
        (
            "sheet-counter-value", "zh-CN", "재고표 두 장",
            "三张库存表", "counter quantity missing/changed",
        ),
        (
            "shoe-pair-value", "zh-CN", "구두 세 켤레",
            "九双皮鞋", "counter quantity missing/changed",
        ),
        (
            "line-counter-value", "zh-TW", "두 줄",
            "九行", "counter quantity missing/changed",
        ),
        (
            "native-year-value", "zh-CN", "여섯 해",
            "五年", "counter quantity missing/changed",
        ),
        (
            "single-sino-minute", "zh-CN", "팔 분",
            "九分钟", "counter quantity missing/changed",
        ),
        (
            "compact-sino-minute", "zh-CN", "십이분",
            "九分钟", "counter quantity missing/changed",
        ),
        (
            "second-week-value", "zh-CN", "6월 둘째 주",
            "6月第三周", "counter quantity missing/changed",
        ),
        (
            "compact-occurrence", "zh-CN", "한번만",
            "只两次", "counter quantity missing/changed",
        ),
        (
            "bare-age-thirty-three", "zh-CN", "서른셋.",
            "32岁。", "counter quantity missing/changed",
        ),
        (
            "bare-age-twenty-seven", "zh-CN", "스물일곱의 겨울",
            "28岁那年的冬天", "counter quantity missing/changed",
        ),
        (
            "colloquial-monthly-pay", "zh-CN", "월 220이면",
            "月薪220韩元的话", "Korean-won values changed",
        ),
        (
            "colloquial-instant-pay", "zh-CN", "즉시 200.",
            "立即支付200韩元。", "Korean-won values changed",
        ),
        (
            "colloquial-housing-money", "zh-CN",
            "보증금 천에 월 오십오.",
            "押金1000韩元，月租55韩元。", "Korean-won values changed",
        ),
        (
            "age-decade-not-vehicle", "zh-CN", "30대 초반",
            "30辆车", "counter quantity missing/changed",
        ),
        (
            "ordinal-verb-route", "zh-CN", "세 번째로 찾아간 밤",
            "第三栋楼的夜晚", "counter quantity missing/changed",
        ),
        (
            "ordinal-suffix-route", "zh-CN", "세 번째에야 맞았다",
            "第三个月才对", "counter quantity missing/changed",
        ),
        (
            "stair-counter-unit", "zh-CN", "계단을 두 칸씩",
            "每次走两个格子", "counter quantity missing/changed",
        ),
        (
            "calendar-month-unit", "zh-CN", "6월",
            "6个月", "counter quantity missing/changed",
        ),
        (
            "duration-month-unit", "zh-CN", "여섯 달",
            "六月", "counter quantity missing/changed",
        ),
        (
            "first-line-ordinal", "zh-CN", "첫 줄",
            "一行", "counter quantity missing/changed",
        ),
        (
            "first-sheet-ordinal", "zh-CN", "첫 장",
            "一张", "counter quantity missing/changed",
        ),
        (
            "first-call-ordinal", "zh-CN", "첫 통화",
            "一次通话", "counter quantity missing/changed",
        ),
        (
            "first-week-ordinal", "zh-CN", "첫 주",
            "一周", "counter quantity missing/changed",
        ),
        (
            "sentence-counter-value", "zh-CN", "두 문장",
            "三句", "counter quantity missing/changed",
        ),
        (
            "step-counter-value", "zh-CN", "한 걸음",
            "两步", "counter quantity missing/changed",
        ),
        (
            "slot-counter-value", "zh-CN", "한 자리",
            "两个名额", "counter quantity missing/changed",
        ),
        (
            "beat-counter-value", "zh-CN", "한 박자",
            "两拍", "counter quantity missing/changed",
        ),
        (
            "block-counter-value", "zh-CN", "한 블록",
            "两个街区", "counter quantity missing/changed",
        ),
        (
            "span-counter-value", "zh-CN", "한 뼘",
            "两拃", "counter quantity missing/changed",
        ),
        (
            "landing-not-vehicle", "zh-CN", "세 번째 층계참",
            "第三辆车", "counter quantity missing/changed",
        ),
        (
            "calendar-day-not-duration", "zh-CN", "6월 17일",
            "6月17天", "counter quantity missing/changed",
        ),
        (
            "clock-minute-not-duration", "zh-CN", "오후 4시 26분",
            "下午4点26分钟", "counter quantity missing/changed",
        ),
        (
            "half-pyeong-value", "zh-CN", "1평 반",
            "1坪", "counter quantity missing/changed",
        ),
        (
            "night-not-day", "zh-CN", "사흘 밤",
            "三天", "counter quantity missing/changed",
        ),
        (
            "night-shift-not-day", "zh-CN", "엿새 심야",
            "六天", "counter quantity missing/changed",
        ),
        (
            "ordinal-night-not-duration", "zh-CN", "나흘째 밤",
            "四夜", "counter quantity missing/changed",
        ),
        (
            "night-attributive-not-day", "zh-CN", "엿새짜리 심야",
            "六天", "counter quantity missing/changed",
        ),
        (
            "night-consecutive-not-day", "zh-CN", "사흘 연속 심야 상하차",
            "三天夜间装卸", "counter quantity missing/changed",
        ),
        (
            "catalog-invented", "zh-CN", "한성전자", "韩星电子",
            "exact prepared form mismatch",
        ),
        (
            "implicit-30eok", "zh-CN", "5년. 목표는 30억.",
            "5年。目标是30亿元人民币。", "relabeled as yen/yuan",
        ),
        (
            "implicit-5cheon", "zh-CN", "현금 5천이면 됩니다.",
            "现金5千元就可以。", "numeric 元/圓 amount",
        ),
        (
            "implicit-5eok-yen", "zh-TW", "5억", "5億日元",
            "relabeled as yen/yuan",
        ),
        (
            "implicit-5eok-circle", "zh-TW", "5억", "5億圓",
            "numeric 元/圓 amount",
        ),
        (
            "money-multiplied", "zh-CN", "5억", "5万亿韩元",
            "Korean-won values changed",
        ),
        (
            "money-multiplied-manwon", "zh-CN", "50만원", "50万亿韩元",
            "Korean-won values changed",
        ),
        (
            "money-swapped", "zh-CN", "3억 5천", "3千韩元，5亿韩元",
            "Korean-won values changed",
        ),
        (
            "money-duplicate-label", "zh-CN", "30억원", "30亿韩元韩元",
            "label count/topology mismatch",
        ),
        (
            "word-money-wrong", "zh-CN", "삼천만원", "1韩元",
            "Korean-won values changed",
        ),
        (
            "grade-changed", "zh-CN", "9급 기출문제집",
            "中国公务员八级历年真题集", "grade-9 civil-service context",
        ),
        (
            "native-hour-changed", "zh-CN", "여섯 시", "九点",
            "counter quantity missing/changed",
        ),
        (
            "native-item-changed", "zh-TW", "다섯 개", "九個",
            "counter quantity missing/changed",
        ),
        (
            "native-week-changed", "zh-CN", "세 주", "九周",
            "counter quantity missing/changed",
        ),
        (
            "native-people-changed", "zh-TW", "두 사람", "九人",
            "counter quantity missing/changed",
        ),
        (
            "invented-counter", "zh-CN", "사람이 왔다", "九个人来了",
            "unmatched target entity quantity",
        ),
        (
            "mixed-cn-common", "zh-CN", "나중에 묻는다", "以後再问",
            "regional script mismatch",
        ),
        (
            "mixed-tw-common", "zh-TW", "나중에 묻는다", "以后再問",
            "regional script mismatch",
        ),
        (
            "signed-percent", "zh-CN", "성공률 -26%", "成功率26%",
            "non-money number sequence changed",
        ),
        (
            "signed-stat", "zh-TW", "건강 -3", "健康3",
            "non-money number sequence changed",
        ),
        (
            "lexical-day-inflected", "zh-CN", "보름이 지났다", "九天过去了",
            "counter quantity missing/changed",
        ),
        (
            "inflected-entity", "zh-TW", "다섯 개가 남았다", "九個留下來了",
            "counter quantity missing/changed",
        ),
        (
            "inflected-minute", "zh-CN", "사십 분에 끝났다", "九分钟结束",
            "counter quantity missing/changed",
        ),
    )
    for label, lang, source, target, needle in mutations:
        cases += 1
        _expect_error(failures, label, lang, source, target, needle)

    for simplified, traditional in COUNTER_SCRIPT_VARIANTS:
        cases += 2
        if not _script_errors("zh-CN", traditional):
            failures.append(
                f"zh-CN accepted Traditional classifier/time form {traditional!r}"
            )
        if not _script_errors("zh-TW", simplified):
            failures.append(
                f"zh-TW accepted Simplified classifier/time form {simplified!r}"
            )

    cases += 1
    try:
        regional_sets = _script_forbidden_sets()
        if {lang: len(regional_sets[lang]) for lang in LANGUAGES} != (
            SCRIPT_VARIANT_DATA_COUNTS
        ):
            failures.append("complete regional script dataset counts changed")
        if not {"鮮", "豔"}.issubset(regional_sets["zh-CN"]):
            failures.append("Traditional full-map sentinels are missing")
        if not {"鲜", "艳"}.issubset(regional_sets["zh-TW"]):
            failures.append("Simplified full-map sentinels are missing")
    except ValueError as exc:
        failures.append(f"regional script dataset failed integrity check: {exc}")

    cases += 1
    if validate_text("zh-CN", "self-test::roman-name", "김민준", "Kim Minjun"):
        failures.append("canonical Romanized cast name was rejected")
    cases += 1
    if validate_text("zh-TW", "self-test::title-ok", "강남드림", "GANGNAM DREAM"):
        failures.append("held canonical game title was rejected")
    cases += 1
    if validate_text("zh-CN", "self-test::district", "강남구", "江南区"):
        failures.append("valid Simplified district form was rejected")
    cases += 1
    if validate_text("zh-TW", "self-test::district", "강남구", "江南區"):
        failures.append("valid Traditional district form was rejected")
    cases += 1
    if validate_text(
        "zh-CN", "self-test::latin-brand", "김민준은 KTX를 탔다.",
        "Kim Minjun乘坐了KTX。",
    ):
        failures.append("canonical cast name and one official Latin brand were rejected")
    for lang, target in (
        ("zh-CN", "Kim Minjun 来了。"),
        ("zh-TW", "Kim Minjun 來了。"),
    ):
        cases += 1
        if validate_text(lang, "self-test::latin-spacing", "김민준이 왔다.", target):
            failures.append(f"normal Latin/Chinese spacing was rejected for {lang}")

    cases += 1
    if validate_text(
        "zh-TW", "self-test::shared-script-context",
        "왕비가 간섭했다.", "皇后干涉了。",
    ):
        failures.append("valid shared-form Traditional context was rejected")

    valid_semantic_rows = (
        ("zh-CN", "9,000원", "9000韩元"),
        ("zh-TW", "500,000원", "50萬韓元"),
        ("zh-CN", "3억 5천", "3亿5000万韩元"),
        ("zh-TW", "3억 5천", "3.5億韓元"),
        ("zh-CN", "5억 년", "5亿年"),
        ("zh-CN", "삼천만원", "3000万韩元"),
        ("zh-TW", "둘이 만원이 안 된다", "兩人合計不到1萬韓元"),
        ("zh-CN", "일곱 번째 달", "第七个月"),
        ("zh-CN", "세 번째 층계참", "第三个楼梯平台"),
        ("zh-CN", "두 번째 통화", "第二次通话"),
        ("zh-CN", "두 번째 믹스커피", "第二杯混合咖啡"),
        ("zh-CN", "건물 두 채", "两栋楼"),
        ("zh-CN", "재고표 두 장", "两张库存表"),
        ("zh-CN", "구두 세 켤레", "三双皮鞋"),
        ("zh-TW", "두 줄", "兩行"),
        ("zh-TW", "검은 세단 한 대", "一輛黑色轎車"),
        ("zh-TW", "커피 한 잔", "一杯咖啡"),
        ("zh-CN", "여섯 해", "六年"),
        ("zh-CN", "팔 분", "八分钟"),
        ("zh-CN", "삼 분", "三分钟"),
        ("zh-CN", "십이분", "十二分钟"),
        ("zh-CN", "6월 둘째 주", "6月第二周"),
        ("zh-CN", "한번만", "只一次"),
        ("zh-CN", "서른셋.", "33岁。"),
        ("zh-CN", "스물일곱의 겨울", "27岁那年的冬天"),
        ("zh-CN", "월 220이면", "月薪220万韩元的话"),
        ("zh-CN", "즉시 200.", "立即支付200万韩元。"),
        (
            "zh-CN", "보증금 천에 월 오십오.",
            "押金1000万韩元，月租55万韩元。",
        ),
        (
            "zh-CN", "둘이 왔고 둘이 남았다.",
            "两个人来了，然后留了下来。",
        ),
        ("zh-CN", "30대 초반", "三十多岁"),
        ("zh-CN", "세 번째로 찾아간 밤", "第三次去的那晚"),
        ("zh-CN", "세 번째에야 맞았다", "到第三次才对"),
        ("zh-CN", "계단을 두 칸씩", "每次走两级台阶"),
        ("zh-CN", "아파트 한 채", "一套公寓"),
        ("zh-TW", "네 번째 집 앞", "第四戶人家門前"),
        ("zh-CN", "6월", "6月"),
        ("zh-CN", "여섯 달", "六个月"),
        ("zh-CN", "첫 줄", "第一行"),
        ("zh-CN", "첫 장", "第一张"),
        ("zh-CN", "첫 통화", "第一次通话"),
        ("zh-CN", "첫 주", "第一周"),
        ("zh-CN", "두 문장", "两句"),
        ("zh-CN", "한 걸음", "一步"),
        ("zh-CN", "한 자리", "一个名额"),
        ("zh-CN", "한 박자", "一拍"),
        ("zh-CN", "한 블록", "一个街区"),
        ("zh-CN", "한 뼘", "一拃"),
        ("zh-TW", "한번 연락해 봐라", "聯絡一下看看"),
        ("zh-CN", "6월 17일", "6月17日"),
        ("zh-TW", "오후 4시 26분", "下午4點26分"),
        ("zh-CN", "1평 반", "1.5坪"),
        ("zh-TW", "1평 반", "一坪半"),
        ("zh-CN", "사흘 밤", "三夜"),
        ("zh-TW", "엿새 심야", "六晚"),
        ("zh-CN", "나흘째 밤", "第四晚"),
        ("zh-CN", "엿새짜리 심야", "六夜"),
        ("zh-TW", "하루짜리 심야", "一夜"),
        ("zh-CN", "엿새짜리 야간조", "六晚夜班"),
        ("zh-CN", "사흘 연속 심야 상하차", "连续三夜装卸货物"),
        (
            "zh-CN", "오늘 하루를 두 문장으로 답했다",
            "用两句话回答了今天过得如何",
        ),
        (
            "zh-CN", "9급 행정직 기출문제집",
            "韩国九级公务员考试历年真题集",
        ),
        (
            "zh-TW", "9급 행정직 기출문제집",
            "韓國九級公務員考試歷屆試題集",
        ),
        ("zh-CN", "LB/RB로 이동", "按LB/RB移动"),
        ("zh-TW", "010-XXXX-XXXX", "010-XXXX-XXXX"),
        ("zh-CN", "D-pad 또는 Enter", "使用D-pad或Enter"),
        ("zh-CN", "3층", "三楼"),
        ("zh-TW", "3일", "三天"),
        ("zh-CN", "2개", "两个"),
        ("zh-TW", "9시", "九點"),
        ("zh-CN", "6년", "六年"),
        ("zh-CN", "두 사람", "两个人"),
        ("zh-CN", "하루", "一天"),
        ("zh-TW", "사흘", "三天"),
        ("zh-CN", "보름", "十五天"),
        ("zh-CN", "지난 1차 면접 결과", "第一轮面试结果"),
        ("zh-TW", "147번 번호표", "147號號碼牌"),
        ("zh-CN", "세 번째 층계참", "第三个楼梯平台"),
        ("zh-TW", "두 번째 통화", "第二次通話"),
        ("zh-CN", "둘 사이", "两个人之间"),
        ("zh-CN", "모르는 사람이 왔다", "来了一个陌生人"),
        ("zh-TW", "문제가 생겼다", "出現了一個問題"),
        ("zh-CN", "조금 피곤했다", "有一点累"),
        ("zh-TW", "아주 고마웠다", "十分感謝"),
        ("zh-CN", "잠시 말이 없었다", "一时无言"),
        ("zh-CN", "두 사람이 왔다", "两个人来了"),
        ("zh-TW", "다섯 개가 남았다", "五個留下來了"),
        ("zh-CN", "세 달이 지났다", "三个月过去了"),
        ("zh-TW", "백칠십구 개뿐", "一百七十九個而已"),
        ("zh-CN", "두 번은 확인했다", "确认了两次"),
        ("zh-TW", "사십 분에 끝났다", "四十分鐘結束"),
        ("zh-CN", "하루에 한 번", "一天一次"),
        ("zh-TW", "나흘째", "第四天"),
        ("zh-CN", "엿새짜리 일", "六天的工作"),
        ("zh-TW", "손님 셋이 왔다", "三位客人來了"),
    )
    for lang, source, target in valid_semantic_rows:
        cases += 1
        row_errors = validate_text(lang, "self-test::semantic", source, target)
        if row_errors:
            failures.append(
                f"valid semantic row failed {lang} {source!r}: {row_errors}"
            )

    cases += 1
    direct_fixture = """
func _quote_ui(text: String) -> String:
    return \"\\\"%s\\\"\" % text if LocaleManager.is_english() else text
func _future_surface() -> String:
    return \"English\" if LocaleManager.is_english() else \"한국어\"
"""
    direct_fixture_errors = _direct_branch_errors_for_source(
        "scenes/MainGame.gd", direct_fixture
    )
    if len(direct_fixture_errors) != 1 \
            or "_future_surface" not in direct_fixture_errors[0]:
        failures.append(
            "function-scoped direct-English allowlist mutation escaped: "
            f"{direct_fixture_errors}"
        )

    cases += 1
    if chinese_runtime_contract_errors(
        'func _auto_reading_delay():\n\tif LocaleManager.language in ["ko", "ja"]:\n\t\tpass\n'
    ) == []:
        failures.append("Chinese AUTO reading-rate omission was not rejected")
    if chinese_runtime_contract_errors(
        'func _auto_reading_delay():\n'
        '\t# TODO zh-CN zh-TW\n'
        '\tvar note = "zh-CN zh-TW"\n'
        '\tif LocaleManager.language in ["ko", "ja"]:\n\t\tpass\n'
    ) == []:
        failures.append("dead Chinese AUTO marker was accepted as a live route")
    if chinese_runtime_contract_errors(
        'func _auto_reading_delay():\n\tif LocaleManager.language in ["ko", "ja", "zh-CN", "zh-TW"]:\n\t\tpass\n'
    ):
        failures.append("complete Chinese AUTO reading-rate fixture was rejected")

    cases += 1
    good_font_route = """
static func attach_locale_fallbacks(font: FontFile, language: String) -> void:
    var locale_font := _get_dedicated_locale_font(language)
    _append_fallback(font, locale_font)
    _append_fallback(font, _get_jp_font())
"""
    bad_font_route = """
static func attach_locale_fallbacks(font: FontFile, language: String) -> void:
    var locale_font := _get_dedicated_locale_font(language)
    _append_fallback(font, _get_jp_font())
    _append_fallback(font, locale_font)
"""
    if not _locale_font_precedes_jp(good_font_route, True) \
            or _locale_font_precedes_jp(bad_font_route, True):
        failures.append("dedicated Chinese font append order mutation escaped")

    cases += 1
    changed = json.loads(json.dumps(manifest, ensure_ascii=False))
    changed["chinese_preparation_contract"]["automatic_script_conversion"] = True
    if not chinese_contract_errors(changed):
        failures.append("automatic CN/TW conversion mutation was not rejected")

    cases += 1
    changed = json.loads(json.dumps(manifest, ensure_ascii=False))
    changed["chinese_preparation_contract"]["static_ui_source_count"] -= 1
    if not chinese_contract_errors(changed):
        failures.append("static UI source-count mutation was not rejected")

    cases += 1
    changed = json.loads(json.dumps(manifest, ensure_ascii=False))
    next(
        row for row in changed["ui_semantic_context_blocker"]["context_registry"]
        if row.get("id") == "ui.credit.standard_grade"
    )["allowed_en"] = ["Normal"]
    if not chinese_contract_errors(changed):
        failures.append("context registry English mutation was not rejected")

    cases += 1
    changed = json.loads(json.dumps(manifest, ensure_ascii=False))
    changed["ui_semantic_context_blocker"]["collision_partition"][
        "format_equivalent"
    ].pop("고시원", None)
    if not chinese_contract_errors(changed):
        failures.append("107-key collision partition mutation was not rejected")

    cases += 1
    for lang in LANGUAGES:
        (
            legacy_covered,
            legacy_total,
            context_covered,
            context_total,
            skeleton_errors,
        ) = static_ui_coverage(lang, runtime, False, {})
        if legacy_covered != 0 or legacy_total != 2730 \
                or context_covered != 0 or context_total != 30 \
                or skeleton_errors:
            failures.append(
                f"empty {lang} two-layer skeleton was rejected: "
                f"legacy={legacy_covered}/{legacy_total} "
                f"context={context_covered}/{context_total} "
                f"errors={skeleton_errors}"
            )
        *_coverage, strict_errors = static_ui_coverage(lang, runtime, True, {})
        if not any("strict legacy static_ui coverage" in error for error in strict_errors):
            failures.append(f"empty {lang} strict legacy UI mutation escaped")
        if not any("strict context static_ui coverage 0/30" in error
                   for error in strict_errors):
            failures.append(f"empty {lang} strict context UI mutation escaped")

    cases += 1
    *_coverage, unknown_errors = static_ui_coverage(
        "zh-CN", runtime, False, {"ui.unknown_context": "未知"}
    )
    if not any("unknown source keys" in error for error in unknown_errors):
        failures.append("unknown Chinese context dictionary key was accepted")

    cases += 1
    blocked = font_route("zh-CN", override_primary="")
    if blocked.ready or not blocked.shared_han_jp_first or blocked.covered != 0:
        failures.append(f"empty Chinese font route was not blocked: {blocked}")

    cases += 1
    jp_resource = _gd_string_constant(
        (ROOT / "autoloads/FontKit.gd").read_text(encoding="utf-8"),
        "JP_FONT_PATH",
    )
    weak_route = font_route("zh-CN", override_primary=jp_resource)
    if weak_route.ready:
        failures.append("a font file without an active-locale pre-JP route was accepted")

    cases += 1
    test_font = ROOT / "assets/fonts/Pretendard-Regular.ttf"
    digest = hashlib.sha256(test_font.read_bytes()).hexdigest()
    fake_ledger = (
        f"| `{test_font.name}` | Test | 1 | Copyright | "
        f"[`OFL-Missing.txt`](OFL-Missing.txt) | test | `{digest}` |\n"
    )
    ledger_ok, _ledger_error = _font_ledger_bundle(test_font, fake_ledger)
    if ledger_ok:
        failures.append("font row without a real hashed OFL copy was accepted")

    cases += 1
    actual_sources = [leaf.source for leaf in runtime["leaves"]]
    actual_sources.extend(runtime["merged_pairs"])
    implicit = [
        source for source in actual_sources
        if _korean_money_units(source) and not KOREAN_WON.search(source)
    ]
    for required_source in ("30억", "5억", "5천"):
        if not any(required_source in source for source in implicit):
            failures.append(
                f"actual demo implicit-won source was not classified: {required_source}"
            )
    expected_implicit_values = {
        "cafe_bluff_01::description": [
            Decimal(500_000_000), Decimal(350_000_000), Decimal(100_000_000),
        ],
        "cafe_bluff_01::choices::[0]::result_text": [Decimal(200_000_000)],
        "cafe_bluff_caught::description": [
            Decimal(200_000_000), Decimal(500_000_000),
            Decimal(350_000_000), Decimal(100_000_000), Decimal(50_000_000),
        ],
        "story_prologue_goal::description": [Decimal(3_000_000_000)],
        "story_prologue_goal::choices::[0]::result_text": [
            Decimal(3_000_000_000)
        ],
        "story_prologue_goal::choices::[1]::result_text": [
            Decimal(3_000_000_000)
        ],
        "story_prologue_goal::choices::[2]::result_text": [
            Decimal(3_000_000_000)
        ],
    }
    actual_implicit_values = {
        leaf.path: [amount.won for amount in _source_money_amounts(leaf.source)]
        for leaf in runtime["leaves"]
        if _korean_money_units(leaf.source) and not KOREAN_WON.search(leaf.source)
    }
    if actual_implicit_values != expected_implicit_values:
        failures.append(
            "actual demo implicit-won value fixture changed: "
            f"{actual_implicit_values}"
        )

    cases += 1
    if not (ROOT / "locale/ui_zh-CN.json").is_file() \
            or not (ROOT / "locale/ui_zh-TW.json").is_file():
        failures.append("independent Chinese UI dictionaries are missing")

    if not failures:
        print(f"ZH_TRANSLATION_SELF_TEST_OK cases={cases}")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lang", choices=("all",) + LANGUAGES, default="all")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    manifest = read_json(demo_scope.MANIFEST_PATH)
    observed, runtime, errors = demo_scope.build_scope()
    errors.extend(demo_scope.compare_contract(
        manifest.get("source_contract"), observed
    ))
    errors.extend(demo_scope.boundary_errors(runtime["event_ids"], manifest))
    errors.extend(chinese_contract_errors(manifest))
    route_errors, _narrow_bypasses = demo_scope.route_errors()
    errors.extend(route_errors)
    direct_errors, bypasses = prepared_locale_direct_bypasses()
    runtime_errors = chinese_runtime_contract_errors()
    if args.strict:
        errors.extend(direct_errors)
        errors.extend(runtime_errors)

    shipping = demo_scope.shipping_languages()
    if shipping != manifest.get("shipping_languages"):
        errors.append(
            f"shipping languages {shipping} != {manifest.get('shipping_languages')}"
        )
    exposed = sorted(set(shipping) & set(LANGUAGES))
    if exposed:
        errors.append(f"Chinese prepared languages exposed: {exposed}")

    languages = LANGUAGES if args.lang == "all" else (args.lang,)
    for lang in languages:
        result, coverage_errors = demo_scope.language_coverage(
            lang, runtime, args.strict
        )
        errors.extend(coverage_errors)
        (
            ui_legacy_covered,
            ui_legacy_total,
            ui_context_covered,
            ui_context_total,
            ui_errors,
        ) = static_ui_coverage(
            lang, runtime, args.strict
        )
        errors.extend(ui_errors)
        route = font_route(
            lang, required_codepoints=required_chinese_codepoints(lang, runtime)
        )
        if args.strict and not route.ready:
            details = "; ".join(route.diagnostics) or "dedicated route missing"
            errors.append(f"{lang}: strict font readiness blocked ({details})")
        print(
            "ZH_DEMO_PREP "
            f"lang={lang} events={result['events']}/{result['total_events']} "
            f"strings={result['event_strings']}/{result['total_event_strings']} "
            f"ui_legacy={ui_legacy_covered}/{ui_legacy_total} "
            f"ui_context={ui_context_covered}/{ui_context_total} "
            f"context_plan={_static_ui_inventory().stats['migrated_context_ids']}/"
            f"{_static_ui_inventory().stats['planned_context_ids']} "
            f"dynamic={result['dynamic']}/{result['total_dynamic']} "
            f"catalog={result['catalog']}/{result['total_catalog']} "
            f"font={'ready' if route.ready else 'blocked'} "
            f"direct_english_bypass={bypasses} shipping=0"
        )
        print(
            "ZH_FONT_ROUTE "
            f"lang={lang} primary={route.primary} "
            f"shared_han_jp_first={int(route.shared_han_jp_first)} "
            f"glyphs={route.covered}/{route.required} "
            f"status={'ready' if route.ready else 'blocked'}"
        )

    if args.strict:
        configured_paths = {
            lang: font_route(lang).primary for lang in LANGUAGES
        }
        if configured_paths["zh-CN"] != "missing" and \
                configured_paths["zh-CN"] == configured_paths["zh-TW"]:
            errors.append(
                "zh-CN and zh-TW reuse one undifferentiated primary font path"
            )

    if args.self_test:
        errors.extend(run_self_test(manifest, runtime))
    if errors:
        print(f"ZH_TRANSLATION_AUDIT_FAIL errors={len(errors)}")
        for error in errors[:240]:
            print(f"  {error}")
        if len(errors) > 240:
            print(f"  ... {len(errors) - 240} more")
        return 1
    print(
        "ZH_TRANSLATION_AUDIT_OK "
        f"mode={'strict' if args.strict else 'skeleton'}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
