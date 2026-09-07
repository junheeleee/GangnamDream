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
import unicodedata
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
    duplicate_json_object_keys,
    duplicate_json_object_keys_from_text,
)


LANGUAGES = ("zh-CN", "zh-TW")
EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS = 37
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
    r"(?=$|\s|[.,!?…:;\x22\x27”’」』)\]}]|"
    r"(?:은|는|이|가|을|를|의|도|만|에|에게|에게서|에서|에는|"
    r"으로|로|과|와|라고|였다|였고|이었다|입니다|이다|인데|뿐이라면|"
    r"뿐입니다|뿐|씩|짜리|째예요|째로|째에야|째|차|분|동안|간|"
    r"안|후|전|부터|까지|쯤|어치|치가|치에|치))"
)
SOURCE_COUNTER_NAMES = (
    r"개월|시간|사람|켤레|세트|문항|문제|문장|글자|제목|걸음|박자|블록|모금|"
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
    r"(?P<counter>개월|시간|사람|켤레|세트|문항|문제|문장|글자|제목|걸음|"
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
SOURCE_NATIVE_THREE_MONTH = re.compile(
    rf"(?<![가-힣])(?P<number>석)\s+(?P<counter>달)(?:{SOURCE_COUNTER_SUFFIX}|(?=마다))"
)
SOURCE_FINANCIAL_TIER = re.compile(
    rf"(?<![가-힣\d])(?P<number>[12])금융{SOURCE_COUNTER_SUFFIX}"
)
SOURCE_PRINT_RUN = re.compile(
    rf"(?<![가-힣])초판\s+(?P<number>\d[\d,]*)\s*(?P<unit>만)?\s*부{SOURCE_COUNTER_SUFFIX}"
)
SOURCE_IM_SURNAME = re.compile(r"(?<![가-힣])임(?:씨|가|\s+모)(?=$|[\s.,!?…\x22\x27”’]|[은는이가의를와도]|라고|라는|라며)")
SOURCE_KIM_SURNAME = re.compile(r"(?<![가-힣])김씨(?=$|[\s.,!?…\x22\x27”’]|[은는이가의를와도]|라고|라는|라며|요)")
SOURCE_HAN_CHAIRMAN = re.compile(r"(?<![가-힣])누군가는\s+한\s+회장의\s+딸\s+결혼식(?=$|[에\s.,!?…])")
# Han is a source-bound surname here. Chinese may touch it directly, but
# another Unicode word character, underscore, or combining accent may not.
TARGET_HAN_SURNAME = re.compile(
    r"(?<![^\W\u3400-\u4dbf\u4e00-\u9fff])"
    r"Han(?![^\W\u3400-\u4dbf\u4e00-\u9fff])"
)


def _han_surname_matches(target: str) -> list[re.Match]:
    return [match for match in TARGET_HAN_SURNAME.finditer(target) if not any(
        unicodedata.category(char).startswith('M')
        for char in target[max(0, match.start() - 1):match.start()] + target[match.end():match.end() + 1]
    )]


def _bounded_latin_matches(target: str, prepared: str) -> list[re.Match]:
    """Chinese prose may touch a name; Unicode word extensions may not."""
    pattern = re.compile(
        r"(?<![^\W\u3400-\u4dbf\u4e00-\u9fff])" + re.escape(prepared)
        + r"(?![^\W\u3400-\u4dbf\u4e00-\u9fff])"
    )
    return [match for match in pattern.finditer(target) if not any(
        unicodedata.category(char).startswith('M')
        for char in target[max(0, match.start() - 1):match.start()] + target[match.end():match.end() + 1]
    )]
SOURCE_ORDINAL = re.compile(
    r"(?<![가-힣\d])(?P<number>첫|" + "|".join(map(re.escape, KOREAN_NATIVE_FORMS)) + r"|\d+)\s*"
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
    r"(?:\s+(?:다|사이|사이에|모두))?(?:\s|$|[.,!?…])|이었다(?=$|[\s.,!?…]))"
)
SOURCE_TWO_PARENTS = re.compile(r"(?<![가-힣])두\s+부모(?=[를의\s])")
SOURCE_PORTION = re.compile(r"(?<![\d가-힣])(?P<number>\d+)인분")
SOURCE_TWO_NAMES = re.compile(r"(?<![가-힣])두\s+이름(?=$|[.\s은을이])")
# This observed creator ending explicitly establishes audience counts, then
# refers back to them. Bare large numbers elsewhere remain money by default.
SOURCE_CREATOR_AUDIENCE = re.compile(
    r"댓글 알림이 멈추지 않았다\.\s+"
    r"(?P<first>\d+만)이었다\.\s+구독자 (?P<subscribers>\d+만)\.\s+"
    r"처음 영상을 올리던 날, 조회수 \d+이었다\.\s+"
    r"그게 부끄럽지 않았다\. 그냥 찍고 싶었으니까\.\s+"
    r"그게 (?P<earlier>\d+만)이 됐고, (?P<later>\d+만)이 됐고, 지금 여기까지 왔다\."
)
SOURCE_BARE_AGE = re.compile(
    r"(?<![가-힣])(?P<number>서른셋|스물일곱)"
    r"(?=$|\s|[.,!?…:;\x22\x27)\]}]|(?:은|는|이|가|을|를|의|도|만|에))"
)
SOURCE_RETIREMENT_AGE = re.compile(
    r"(?<![가-힣])(?:서른여덟(?=의 아침)|쉰(?=\s+전에\s+일을))"
)
# These catalogue constructions were observed in the Korean source. Their
# written numbers are not vehicle counts, bank balances or invented entities.
SOURCE_CATALOG_AGE = re.compile(r"(?<![가-힣])스물(?=에 억대 계약)")
SOURCE_NAME_CHARACTERS = re.compile(r"(?<=이름 )석 자(?=가 브랜드다)")
SOURCE_REUNION_PAIR = re.compile(r"(?<=다시 만난 밤, )둘(?=이서 찍었다)")
CATALOG_YOUNG_ADULT_SOURCES = frozenset({
    "2030 직장인", "2030 투자자", "2030 집주인", "2030 세대",
    "2030 창업 열풍 — '{topic}처럼 나도 유니콘' 꿈꾸는 세대 급증",
    "청년 창업 지원금 {topic} 확대 — '취업 대신 창업' 선택하는 2030 급증",
})
CHINESE_CARDINAL = r"(?:\d[\d,]*|[零〇○一二两兩三四五六七八九十百千]+)"
NUMERIC_PREFIX_CHARACTERS = "0-9零〇○一二两兩三四五六七八九十百千萬万億亿兆数數點点.＋+−﹣－負负-"
SPENDING_SCENE_COUNTER_KINDS = frozenset({
    "asset_age_decade", "monthly_balance_once", "beer_can_count",
    "lottery_match_count", "lottery_prize_rank", "gym_card_months",
    "gym_approx_months", "first_luck", "price_gap_pair",
})
WORK_SCENE_COUNTER_KINDS = frozenset({
    "work_cup_range", "coworker_count", "subscription_count", "study_daily_hours",
    "exam_countdown", "tuition_month", "never_course_days", "job_company_focus",
    "read_mark_over_count", "job_posting_count",
})
LIFE_SCENE_COUNTER_KINDS = WORK_SCENE_COUNTER_KINDS | SPENDING_SCENE_COUNTER_KINDS | frozenset({
    "remaining_four_month", "job_posting_count", "egg_count", "task_count",
    "rental_home_ordinal", "mirror_glance", "gangnam_attempt",
    "university_year", "restaurant_per_person", "underground_exit",
    "microwave_duration", "screen_time_duration", "chicken_open_hours",
    "monthly_headache_frequency",
})
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
    ("box", ("只箱子", "個箱子", "个箱子", "箱子", "箱")),
    ("room", ("間臥室", "间卧室", "間房間", "间房间", "個房間", "个房间", "間房", "间房")),
    ("chair", ("把椅子", "張椅子", "张椅子", "個椅子", "个椅子", "把空椅子", "張空椅子", "张空椅子")),
    ("table_seat", ("人餐桌", "人座餐桌", "個座位的餐桌", "个座位的餐桌")),
    ("portion", ("人份",)),
    ("name_count", ("個名字", "个名字")),
    ("share", ("股", "單位", "单位")),
    ("parent_pair", ("位長輩", "位长辈", "位父母")),
    ("concept_pair", ("者", "邊", "边")),
    ("character", ("個字", "个字", "字")),
    ("heading", ("個標題", "个标题", "標題", "标题")),
    ("sheet", ("張", "张", "枚", "頁", "页")),
    ("document_sheet", ("張", "张", "枚", "頁", "页", "份產權登記文件", "份产权登记文件", "份文件", "紙文件", "纸文件")),
    ("building", ("棟", "栋", "幢", "套", "戶", "户")),
    ("vehicle", ("輛", "辆", "台")),
    ("cup", ("只杯子", "個杯子", "个杯子", "杯")),
    ("line", ("小行", "行", "列", "條", "条", "句")),
    ("pair", ("雙", "双", "對", "对")),
    ("cell", ("格", "欄", "栏", "列")),
    ("occupied_space", ("格", "欄", "栏", "列", "處", "处", "塊地方", "块地方")),
    ("question", ("題", "题", "道", "個", "个")),
    ("set", ("套", "組", "组")),
    ("meal", ("頓", "顿", "餐")),
    ("message", ("封", "條", "条", "則", "则", "通")),
    ("sip", ("口",)),
    ("step", ("步",)),
    ("slot", ("個", "个", "席", "位", "名額", "名额")),
    ("beat", ("拍", "拍子")),
    ("span", ("拃", "掌", "個手掌寬", "个手掌宽", "個手掌", "个手掌")),
    ("stair_step", ("級", "级", "階", "阶")),
    ("landing", ("個", "个", "處", "处")),
    ("clock_hour", ("點", "点", "時", "时")),
    ("occurrence", ("次", "回", "遍", "下")),
    ("look_occurrence", ("次", "回", "遍", "下", "眼")),
    ("ring_occurrence", ("次", "回", "聲", "声")),
    ("week", ("週", "周")),
    ("year", ("年",)),
    ("duration_day", ("天", "日", "整天")),
    ("calendar_day", ("日", "號", "号")),
    ("night", ("個夜晚", "个夜晚", "晚", "夜")),
    ("run_occurrence", ("次", "回", "輪", "轮")),
    ("alternative_count", ("種結果", "种结果", "種", "种", "個", "个")),
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
    "글자": "character", "제목": "heading",
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
# Observed 2억 5천8백만원 and 1천8백만원 are one amount each,
# not an eok amount followed by an unrelated hundred-man amount.
SOURCE_MIXED_MANWON = re.compile(
    r"(?<![A-Za-z가-힣\d,.])(?:(?P<eok>[+-]?\d+)\s*억\s*)?"
    r"(?P<thousand>[+-]?\d+)\s*천\s*(?P<hundred>\d+)\s*백\s*만원"
)
SOURCE_EOK_MONEY = re.compile(
    rf"(?<![\d,])(?P<eok>{DECIMAL_LITERAL})\s*억"
    rf"(?:\s*(?P<rest>{DECIMAL_LITERAL})\s*(?P<rest_unit>천만|천|만))?"
    r"(?:\s*원)?"
)
SOURCE_EXPLICIT_MONEY = re.compile(
    rf"(?<![A-Za-z\d,])(?P<number>{DECIMAL_LITERAL})\s*"
    r"(?P<unit>조|천만|백만|만|천)?\s*원(?!문|본)"
)
SOURCE_WORD_MONEY = re.compile(
    r"(?<![가-힣])(?!사원증|구원자)(?P<number>[일이삼사오육칠팔구십백천]+)\s*"
    r"(?P<unit>억|만)?\s*원(?!문|본)"
)
SOURCE_BARE_ONE_MONEY = re.compile(
    r"(?<![가-힣])(?P<unit>억|만)\s*원"
)
SOURCE_COLLOQUIAL_MANWON = re.compile(
    r"(?<![가-힣\d])(?P<context>보증금|월|즉시|건당)\s+"
    r"(?P<number>\d[\d,]*|[일이삼사오육칠팔구십백천]+)(?![\d,])"
)
CHINESE_MONEY_COMPONENT = re.compile(
    rf"(?P<number>{DECIMAL_LITERAL})\s*"
    r"(?P<unit>万亿|萬億|千万|千萬|兆|亿|億|万|萬|千)?"
)
TARGET_WON_MONEY = re.compile(
    rf"(?P<expression>(?:{DECIMAL_LITERAL}\s*"
    r"(?:万亿|萬億|千万|千萬|兆|亿|億|万|萬|千)?\s*)+)"
    r"(?:韩元|韓元)"
)
KOREAN_WON = re.compile(
    r"(?:₩|KRW|원화|"
    r"(?:(?:(?<![A-Za-z\d,])\d[\d,.]*|%(?:\d+\$)?[-+#0 .\d]*[a-zA-Z]|"
    r"(?<![가-힣])(?!사원증|구원자)[일이삼사오육칠팔구십백천]+)\s*(?:백만|만|억)?|"
    r"(?<![가-힣])(?:만|억))\s*원(?!문|본))"
)
SOURCE_RHETORICAL_WON = re.compile(r"(?<![가-힣])어떤\s+원화도")
TARGET_RHETORICAL_WON = re.compile(r"(?:每一|任何)(?:韩元|韓元)")
# Approximate financial magnitudes remain approximate; never turn a hundreds-
# of-millions contract or several-trillion deal into a made-up exact amount.
CATALOG_APPROXIMATE_WON = (
    (re.compile(r"(?<![가-힣])몇백만원"), re.compile(r"[幾几數数]百[萬万](?:韩元|韓元)")),
    (re.compile(r"(?<=예단만 )수천만"), re.compile(r"[幾几數数]千[萬万](?:韩元|韓元)")),
    (re.compile(r"(?<![가-힣])억대(?= 계약)"), re.compile(r"(?:上[亿億]|[数數][亿億])(?:韩元|韓元)")),
    (re.compile(r"(?<![가-힣])수백억(?= EXIT)"), re.compile(r"[数數]百[亿億](?:韩元|韓元)")),
    (re.compile(r"(?<![가-힣])수조원(?= 빅딜)"), re.compile(r"[数數](?:万亿|萬億|兆)(?:韩元|韓元)")),
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
    ("处", "處"), ("则", "則"),
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
# Taiwan MOE lists 群 as the standard A03225 and 羣 as its variant:
# https://dict.variants.moe.edu.tw/dictView.jsp?ID=34744&la=0
# MOE also records 峰 as standard A01119 (峯 is a variant), including 尖峰:
# https://dict.variants.moe.edu.tw/dictView.jsp?ID=12299&la=1
# https://dict.concised.moe.edu.tw/dictView.jsp?ID=22746&la=0&powerMode=0
# Keep the original OpenCC dataset and its integrity hash unchanged.
ZH_TW_SHARED_SCRIPT_CHARACTERS = frozenset({"床", "群", "峰"})

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
# Fictional business names are allowed only when their Korean source term is
# present. Keep them out of ALLOWED_LATIN_PHRASES so unrelated translations
# cannot use this exception to smuggle an otherwise-untranslated Latin token.
SOURCE_SCOPED_LATIN_TERMS = {
    "한빛유통": "Hanbit 流通",
    "한PD건설": {"zh-CN": "HanPD 建设", "zh-TW": "HanPD 建設"},
    "박상진": "Park Sangjin",
    "태호": "Taeho",
    "이민서": "Lee Minseo",
    "민서": "Minseo",
    "엔코어": "Encore",
    "한강제일금융": {"zh-CN": "汉江第一金融", "zh-TW": "漢江第一金融"},
    "코어코인": "Corecoin",
    "노바코인": "Novacoin",
}
# Taiwan App is a natural option, not a mandatory replacement for 應用程式.
SOURCE_OPTIONAL_LATIN_TERMS = {
    "앱": "App", "유튜브": "YouTube", "성심병원": "Seongsim",
    "링크드인": "LinkedIn", "인스타": "Instagram", "인스타그램": "Instagram",
    "슬랙": "Slack",
}
# Only observed relationship prose licenses these otherwise-unknown names.
# In particular, financial 지수 must never license the friend's name Jisu.
RELATIONSHIP_SOURCE_NAMES = (
    (re.compile(r"(?<![가-힣])김대리(?=$|\s|와|에게|는)"), "Kim"),
    (re.compile(r"(?<![가-힣])박(?: 씨|과장)(?=$|[\s.,!?…]|[은는이가을를의])"), "Park"),
    (re.compile(r"(?<![가-힣])(?:친구 지수(?=에게서\s)|지수가 안겼다|지수는 같은 말을 반복했고|지수가 연락해왔을 때)"), "Jisu"),
    (re.compile(r"(?<![가-힣])준혁이(?=$|\s|[가도는]|에게)"), "Junhyeok"),
    (re.compile(r"(?<![가-힣])친구 재훈이(?=$|\s|[가도는]|에게)"), "Jaehun"),
)
# Optional brand spellings for exact Korean catalogue leaves, not a global
# English allowlist. Chinese brand names remain valid; prose must still be
# translated. Multiword names and their case are matched as whole tokens.
CATALOG_LATIN_ALIASES = {
    "LG에너지솔루션": ("LG Energy Solution",),
    "구글": ("Google",), "구글 코리아": ("Google",),
    "구글 TPU": ("Google TPU",),
    "아마존": ("Amazon",), "아마존 AWS": ("Amazon AWS",),
    "아마존 커스텀 칩": ("Amazon",),
    "메타": ("Meta",), "메타 코리아": ("Meta",), "메타 라마": ("Meta Llama",),
    "오르카": ("Orca",), "오르카 AI 서버 메모리": ("Orca",),
    "삼성 가우스2": ("Samsung Gauss 2", "Gauss 2"),
    "삼성 가우스": ("Samsung Gauss", "Gauss"),
    "삼성 AI 시설": ("Samsung",),
    "하이퍼클로바X2": ("HyperCLOVA X2",), "클로드 4": ("Claude 4",),
    "클로드": ("Claude",), "제미나이": ("Gemini",),
    "제미나이 울트라": ("Gemini Ultra",),
    "코파일럿 엔터프라이즈": ("Copilot Enterprise",),
    "깃허브 이력서": ("GitHub",), "솔라나": ("Solana",),
    "리플": ("XRP", "Ripple"), "에이다": ("ADA", "Cardano"),
    "아발란체": ("Avalanche",), "셀트리온": ("Celltrion",), "볼턴": ("Bolton",),
    "성원아파트": ("Seongwon",), "잠실 한빛단지": ("Hanbit",),
    "개포 그린단지": ("Green",), "목동 한빛타운": ("Hanbit Town",),
    "상계 그린타운": ("Green Town",), "압구정 리버타운": ("River Town",),
    "잠실 파크타운": ("Park Town",),
    "네이버": ("NAVER",), "네이버 데이터센터": ("NAVER",),
    "네이버 HyperCLOVA": ("NAVER HyperCLOVA",),
    "업비트": ("Upbit",), "업비트 거래량": ("Upbit",),
    "빗썸": ("Bithumb",), "빗썸 시세": ("Bithumb",),
    "코인원": ("Coinone",), "코빗": ("Korbit",), "카카오뱅크": ("KakaoBank",),
    "에코프로": ("EcoPro",), "코스피": ("KOSPI",), "코스닥": ("KOSDAQ",),
    "코스닥 바이오주": ("KOSDAQ",), "팔란티어": ("Palantir",),
    "스노우플레이크": ("Snowflake",), "크라우드스트라이크": ("CrowdStrike",),
    "리비안": ("Rivian",), "버크셔헤서웨이": ("Berkshire Hathaway",),
    "쿠팡": ("Coupang",), "배달의민족": ("Baemin", "Baedal Minjok"),
    "토스": ("Toss",), "토스 이승건": ("Toss", "Lee Seunggun", "Lee Seunggeon"),
    "SK이노베이션": ("SK Innovation",), "POSCO홀딩스": ("POSCO Holdings",),
    "한화에어로스페이스": ("Hanwha Aerospace",), "넷플릭스": ("Netflix",),
    "한화솔루션": ("Hanwha Solutions",), "삼성SDI": ("Samsung SDI",),
    "두산에너빌리티": ("Doosan Enerbility",),
    "당근마켓": ("Karrot", "Danggeun Market"), "야놀자": ("Yanolja",),
    "컬리": ("Kurly",), "크래프톤": ("Krafton",), "쏘카": ("Socar",),
    "직방": ("Zigbang",), "라이트코인": ("Litecoin",),
    "코어코인캐시": ("Corecoin Cash",), "이캐시": ("eCash",),
    "모네로": ("Monero",), "지캐시": ("Zcash",), "대시": ("Dash",),
    "삼성바이오로직스": ("Samsung Biologics",), "다온페이": ("Daon Pay",),
    "미스트랄AI": ("Mistral AI",), "다온 KoGPT": ("Daon KoGPT",),
    "코난테크놀로지": ("Konan Technology",), "한진칼": ("Hanjin KAL",),
    "포스코DX": ("POSCO DX",), "인텔": ("Intel",), "보잉": ("Boeing",),
    "우버": ("Uber",), "트위터(X)": ("Twitter（X）", "Twitter(X)"),
    "킨텍스": ("KINTEX",), "리셋 클럽": ("Reset Club",), "피벗 커뮤니티": ("Pivot",),
    "앱테크·짠테크 열풍 — {topic} 소소한 절약으로 종잣돈 모으기": ("App",),
    "삼성·SK의 {topic} 공급 계약 — 수조원 빅딜 성사 임박": ("Samsung",),
    "{topic} 재테크 유튜버 우후죽순 — '구독자 100만 = 연봉 10억' 신드롬": ("YouTube",),
}
CATALOG_LATIN_ONLY = {
    source: forms for source, forms in CATALOG_LATIN_ALIASES.items()
    if source not in {
        "구글 코리아", "메타 코리아", "아마존 커스텀 칩", "오르카 AI 서버 메모리",
        "삼성 AI 시설", "깃허브 이력서", "성원아파트", "잠실 한빛단지",
        "개포 그린단지", "목동 한빛타운", "상계 그린타운", "압구정 리버타운",
        "잠실 파크타운", "네이버 데이터센터", "업비트 거래량", "빗썸 시세",
        "코스닥 바이오주", "토스 이승건", "피벗 커뮤니티",
        "앱테크·짠테크 열풍 — {topic} 소소한 절약으로 종잣돈 모으기",
        "삼성·SK의 {topic} 공급 계약 — 수조원 빅딜 성사 임박",
        "{topic} 재테크 유튜버 우후죽순 — '구독자 100만 = 연봉 10억' 신드롬",
    }
}
CATALOG_LATIN_ONLY["삼성 가우스2"] = ("Samsung Gauss 2",)
CATALOG_LATIN_ONLY["삼성 가우스"] = ("Samsung Gauss",)


def catalog_latin_only(source: str, target: str) -> bool:
    """Only complete source names, never a brand token stripped of its prose."""
    return target.strip() in CATALOG_LATIN_ONLY.get(source.strip(), ())
SOURCE_APP_TERM = re.compile(
    r"(?<![가-힣])(?:배달)?앱(?=$|[\s.,!?…]|(?:을|이|은|에|에서|으로|의|만|도)(?=$|[\s.,!?…]))"
)
SOURCE_XRAY_TERM = re.compile(r"(?<![가-힣])엑스레이(?=$|[\s.,!?…]|[의를은가이을](?=$|[\s.,!?…]))")
# Exact Korean service/course nouns, independently verified from their owners:
# https://www.incruit.com/  https://www.jobkorea.co.kr/
# https://oapi.saramin.co.kr/  https://www.python.org/
WORK_SOURCE_BRANDS = (
    (re.compile(r"(?<![가-힣])인크루트(?= 앱을 다시 설치했다(?:$|[.\s]))"), "Incruit"),
    (re.compile(r"(?<![가-힣])잡코리아와 사람인을 번갈아 새로고침하고 있다\."), "JobKorea"),
    (re.compile(r"(?<![가-힣])잡코리아와 사람인을 번갈아 새로고침하고 있다\."), "Saramin"),
    (re.compile(r"(?<![가-힣])파이썬(?= 입문[,\s.])"), "Python"),
)
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


def _has_unapproved_han_alias(
    target: str, romanized: str, *, single_character_surname: bool = False,
) -> bool:
    """Reject a second, invented Han-character name beside the locked Latin one."""
    latin = re.escape(romanized)
    if romanized == 'Kim Daeun':
        # The observed document label is a quoted Latin value after a verb,
        # not a two-character Han alias named 填著 beside Kim Daeun.
        target = re.sub(r'(R3\s+最後一頁)填著(?=「Kim Daeun」)', r'\1：', target)
        target = re.sub(r'登記簿上(?=「Kim Daeun」)', '登記簿：', target)
        target = re.sub(r'(?<=「Kim Daeun」)的三個(?:韓文)?字', '：三個字', target)
    if romanized == 'Han Jiyeon':
        # 所認識的 modifies the quoted source name; it is not a Hanja alias.
        target = re.sub(r'所[認认][識识]的(?=「Han Jiyeon」)', '：', target)
    # Only the source-bound 임씨 -> Im case has a one-character surname
    # alias. Keep the existing full-name/prose boundary for other cast names.
    han = r"[\u3400-\u4dbf\u4e00-\u9fff]" + ("{1,4}" if single_character_surname else "{2,4}")
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
        if romanized == 'Han Jiyeon':
            patterns.append(rf"「{latin}」\s*{left}\s*{han}\s*{right}")
    return any(re.search(pattern, target) for pattern in patterns)


def _allows_latin_only(source: str, target: str, *, catalog: bool = False) -> bool:
    expected = LATIN_EXACT.get(source.strip())
    if expected is not None and target.strip() == expected:
        return True
    prepared = SOURCE_SCOPED_LATIN_TERMS.get(source.strip())
    return (isinstance(prepared, str) and target.strip() == prepared) or \
        (catalog and catalog_latin_only(source, target))


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
    if lang == "zh-TW":
        # OpenCC's variant table classifies 床 as Simplified-only, although 床
        # is also the standard Taiwan character. Remove only this reviewed
        # shared character; every other Simplified sentinel remains forbidden.
        forbidden.difference_update(ZH_TW_SHARED_SCRIPT_CHARACTERS)
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


def _source_scoped_term_present(source: str, korean: str) -> bool:
    if korean in {"링크드인", "인스타", "인스타그램", "슬랙"}:
        return bool(re.search(
            rf"(?<![가-힣]){re.escape(korean)}(?=$|[\s.,!?…]|"
            r"(?:에서|[은는이가의을를와도에])(?=$|[\s.,!?…\x22\x27”’]))",
            source,
        ))
    if korean in {"이민서", "민서"}:
        # A cast name at a Korean word boundary, never 이민서류 or a word
        # ending in 민서. A short source name cannot license an added surname.
        return bool(re.search(
            rf"(?<![가-힣]){re.escape(korean)}(?=$|[\s.,!?…\x22\x27”’]|[은는이가의을를와도]|입니다|라고|에게|한테|씨)",
            source,
        ))
    return korean in source


def _terminology_errors(lang: str, source: str, target: str) -> list[str]:
    errors: list[str] = []
    for pattern, romanized in RELATIONSHIP_SOURCE_NAMES:
        if pattern.search(source):
            if not _bounded_latin_matches(target, romanized):
                errors.append(f"source-bound relationship name requires {romanized!r}")
            elif _has_unapproved_han_alias(target, romanized, single_character_surname=True):
                errors.append(f"source-bound relationship name {romanized!r} has an unapproved Han alias")
    if source.strip() == "첫 억" and not re.match(r"(?:首(?:個|个|次)?|第一(?:個|个)?)", target.strip()):
        errors.append("first-hundred-million title lost its first ordinal")
    terms = REGIONAL_TERMS[lang]
    exact = LATIN_EXACT.get(source.strip())
    if exact is not None and target.strip() != exact:
        errors.append(
            f"exact prepared form mismatch: {target.strip()!r} != {exact!r}"
        )

    for korean, expected in SOURCE_SCOPED_LATIN_TERMS.items():
        if not _source_scoped_term_present(source, korean):
            continue
        if isinstance(expected, dict):
            expected = expected[lang]
        if expected not in target:
            errors.append(
                f"{korean} must use canonical prepared form {expected!r}"
            )
        elif source.strip() == korean and target.strip() != expected:
            errors.append(
                f"exact prepared form mismatch: {target.strip()!r} != "
                f"{expected!r}"
            )
        if korean in {"박상진", "태호", "이민서", "민서"} and _has_unapproved_han_alias(
            target, expected, single_character_surname=True,
        ):
            errors.append(f"cast name {expected!r} has an unapproved Han-character alias")

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
    academy_target = target
    if "저 고시원 나가요" in source and "낮에는 회계 취업반에 다니고" in source \
            and re.search(r"搬出(?:考试院|考試院)(?:了)?[。！？.!?」”]", target):
        # Moving out of a goshiwon and attending an accounting employment
        # course are different actions in this scene. Only the latter owns
        # the training-class words; calling the residence a school still fails.
        academy_target = re.sub(
            r"(?:^|[。！？.!?\n，,；;])\s*(?:白天|日間)(?:上|去|到|在|參加|参加|就讀|就读|\s)*"
            r"(?:會計|会计)(?:就業|就业)(?:培訓|培训)(?:班|課程|课程)(?=[，,。；;！？.!?\n]|$)",
            "", academy_target,
        )
    if "고시원" in source and any(
        wrong in academy_target
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
    if SOURCE_IM_SURNAME.search(source) and not re.search(
        r"(?<![A-Za-z0-9])Im(?![A-Za-z0-9])", target,
    ):
        errors.append("source surname 임씨 must retain Romanized form 'Im'")
    if SOURCE_IM_SURNAME.search(source) and _has_unapproved_han_alias(
        target, "Im", single_character_surname=True,
    ):
        errors.append("source surname 'Im' has an unapproved Han-character alias")
    if SOURCE_HAN_CHAIRMAN.search(source):
        if not _han_surname_matches(target):
            errors.append("source surname 한 회장 must retain Romanized form 'Han'")
        if _has_unapproved_han_alias(target, "Han", single_character_surname=True):
            errors.append("source surname 'Han' has an unapproved Han-character alias")
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
    if raw == "석":
        return Decimal(3)
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
    if following.startswith("집을 계약한다."):
        return "rental_home_ordinal"
    if re.match(r"장(?=$|[\s.,!?…]|[은는이가의를와도]|에는|에서)", following):
        return "ordinal_sheet"  # A page, never the prefix of 장면 (scene).
    if re.match(r"(?:전화|통화)(?=$|[\s.,!?…]|[은는이가의를와도])", following):
        return "ordinal_call"
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
    preceding = source[max(0, match.start() - 120):match.start()]
    if counter == "개" and preceding.endswith("불필요한 구독 서비스 ") and following.startswith("를 해지했다."):
        return "subscription_count"
    if counter == "개" and preceding.endswith("공고 ") and following.startswith("를 열었다가 닫았다."):
        return "job_posting_count"
    if counter == "개" and preceding.endswith("읽은 표시가 ") and following.startswith("를 넘어가고 있었다."):
        return "read_mark_over_count"
    if counter == "시" and preceding.endswith("직진하면 ") and following.startswith("치킨 반반 "):
        return "chicken_open_hours"
    if counter == "개" and re.match(r"\.(?:\s|$)", following):
        for noun, kind in (("공고", "job_posting_count"), ("달걀", "egg_count"), ("과제", "task_count")):
            if re.search(rf"(?<![가-힣]){noun}\s+$", preceding):
                return kind
    if counter == "번" and preceding.endswith("룸미러로 ") and following.startswith("보더니 말을 걸었다."):
        return "mirror_glance"
    if counter == "번" and preceding.endswith("강남 ") and following.startswith("가보겠다고 했는데."):
        return "gangnam_attempt"
    if counter == "번" and preceding.endswith("지하 ") and following == "출구":
        return "underground_exit"
    if counter == "달" and preceding.endswith("생각해보니 ") and following.startswith("이 넘었다"):
        return "duration_month_over"
    if counter == "번" and preceding.endswith("부재중 ") and re.match(r"\.(?:\s|$)", following):
        return "missed_call"
    if counter == "차" and (
        following.startswith("까지 갔다. 팀장님이 노래방에서")
        or following.startswith("에서 가볍게 마시고")
    ):
        return "outing_round"
    if counter == "번" and preceding.endswith("강남역 ") and following.startswith("출구"):
        return "station_exit"
    if counter == "번" and preceding.endswith("신호가 ") and following.startswith("울리다가 끊겼다"):
        return "ring_occurrence"
    if counter == "번" and preceding.endswith("밥 ") and following.startswith(("사.", "먹자고 했다.")):
        return "meal_invitation"
    if counter == "분" and following.startswith("47초짜리였다"):
        return "video_duration_minute"
    if counter == "개" and preceding.endswith("공기밥 "):
        return "rice_bowl"
    if counter == "번" and preceding.endswith("종이컵을 ") and following.startswith("보고도 묻지 않았다"):
        return "look_occurrence"
    if counter == "대" and following.startswith("의 아버지"):
        return "age_decade_unspecified"
    if counter == "모금" and preceding.endswith("국물을 ") and following.startswith("마시더니 물었다"):
        return "soup_sip"
    if counter == "모금" and preceding.endswith("차를 ") and following.startswith("마시고 물었다"):
        return "tea_sip"
    if counter == "칸" and re.search(r"조명을\s+$", preceding) and following.startswith("낮췄다"):
        return "brightness_level"
    if counter == "줄" and following.startswith("뒤에는 현수가") and "신랑석" in preceding:
        return "seat_row"
    if counter == "문장" and match.group("number") == "한" \
            and re.search(r"도도하게 들리려\s+$", preceding):
        return ""  # An attempted tone, not a counted sentence.
    if counter == "번" and re.search(r"캔 안에서 작은 금속 소리가\s+$", preceding) \
            and following.startswith("났고"):
        return "can_sound_occurrence"
    if counter == "장" and re.search(r"(?<![가-힣])유리\s+$", preceding) \
            and following.startswith("두께의"):
        return "glass_pane"
    if counter == "장" and re.search(r"꽃잎(?:이 내렸고,)?\s+$", preceding) \
            and following.startswith("이 그녀 머리에 앉았다"):
        return "petal_count"
    if counter == "번" and re.search(r"다은이 하늘을 보기 직전 \{name\}을\s+$", preceding) \
            and following.startswith("돌아봤다"):
        return "turned_look_count"
    if counter == "번" and (
        (re.search(r"영수증을\s+$", preceding) and following.startswith("보더니"))
        or (re.search(r"빈손을\s+$", preceding) and following.startswith("내려다본 뒤"))
        or (re.search(r"그 사이로 눈이\s+$", preceding) and following.startswith("흘겼다"))
    ):
        return "turned_look_count"
    if counter == "번" and re.search(r"5년치를\s+$", preceding) \
            and following.startswith("에 웃어버리는"):
        return "laughter_once"
    if counter == "번" and re.search(r"그 바다에는\s+$", preceding) \
            and following.startswith("도 들어가 본 적 없는"):
        return "never_sea_entry"
    if counter == "개" and re.search(r"회의\s+$", preceding) and following.startswith("째야"):
        return "ordinal_meeting"
    if counter == "개" and re.search(r"작은 캔커피\s+$", preceding):
        return "small_coffee_can"
    if source == "2차전지주" and counter == "차":
        return "secondary_battery"
    if source == "2차 창업자 네트워크" and counter == "차":
        return "second_startup"
    if counter == "달" and match.group("number") == "한" and re.match(
        r"에\s+(?:한\s+번(?:$|[\s.,!?…])|일요일\s+하나)", following,
    ):
        # A monthly frequency, not an arbitrary one-month deadline/duration.
        return "monthly_frequency"
    if counter == "달" and match.group("number") == "한" and re.search(r"다음\s+$", preceding) \
            and not re.match(r"반(?=$|\s|[.,!?…]|[은는이가을를의도에])", following):
        return "next_month"
    if counter == "달" and match.group("number") == "석" and following.startswith("마다"):
        return "repeated_month_interval"
    if counter == "사람" and match.group("number") == "한" and re.search(
        r"(?:기다리게|망하게|만나겠다고|못|말을)\s+$", preceding,
    ):
        # 기다리게 한 사람 is a causative relative clause, not one person.
        # Counting it consumes a later actual person and skips the first week.
        return ""
    if counter == "시간" and ((match.group("number") == "한" and re.search(
        r"선택을\s+버티게\s+$", preceding,
    )) or (match.group('number') == '둘' and re.search(r'비워\s+$', preceding))):
        return ""  # 버티게 한 시간 is enabling time, not an hour.
    if counter == "번" and match.group("number") == "한" and re.match(
        r"도\s*찍히지\s*않은", following,
    ):
        return "never_occurrence"
    if counter == "번" and match.group("number") == "한" \
            and following.startswith('도 마시지 않았다') and re.search(r'커피를\s+$', preceding):
        return 'never_drink_occurrence'
    if counter == "번" and match.group("number") == "한" \
            and following.startswith("도 뒤척이지 않은") and re.search(r"밤새\s+$", preceding):
        return "never_toss_turn"
    if counter == "걸음" and following.startswith("씩 멀어졌다") \
            and re.search(r"소음이 두 사람에게서\s+$", preceding):
        return "receding_step"
    if counter == '번' and match.group('number') == '한' and following.startswith('위에서 아래로 읽고') \
            and re.search(r'다시\s+$', preceding):
        return 'read_again'
    if counter == '번' and match.group('number') == '한' and following.startswith('도 비켜 가지 않았다') \
            and re.search(r'네 주를\s+$', preceding):
        return 'never_skip_week'
    if counter == '번' and match.group('number') == '한' and following.startswith('도 안 했던 말') \
            and re.search(r'평생\s+$', preceding):
        return 'never_utterance'
    if counter == "문장" and match.group("number") == "한" and re.search(r"그\s+$", preceding):
        return "referenced_sentence"
    if counter == "줄" and match.group("number") == "한" and re.match(r"씩 (?:맞췄다|확인했다|적었다)", following):
        return "per_line"
    if counter == "줄" and following.startswith("을 긋고"):
        return "drawn_line"
    if counter == "줄" and following.startswith("로 지우고"):
        return "strike_line_count"
    if counter == "번" and re.search(r"검은 줄을\s+$", preceding) \
            and following.startswith("그었다"):
        return "strike_occurrence"
    if counter == "번" and re.search(r"냉장고가\s+$", preceding) \
            and following.startswith("돌아가는 동안"):
        return "appliance_cycle"
    if counter == "분" and (following.startswith("이 만난 것으로")
            or following.startswith("은 내가 대답하기도 전에")
            or following.startswith("모두의 자리가")
            or following.startswith("으로 보세요")):
        return "honorific_people"
    if counter == "장" and following.startswith("의 마지막 상환확인"):
        return "chapter_reference"
    if counter == "채" and match.group("number") == "한" \
            and re.search(r"화면을 아래로\s+$", preceding):
        return ""  # 화면을 아래로 한 채 is a state, not one building.
    if counter == "번" and (
        re.search(r"(?:자기 명의|이름만으로|접수본에)\s+$", preceding)
        and re.match(r"(?:을 접수|과 날짜|을 차례로)", following)
    ):
        return "receipt_identifier"
    if counter == "번" and re.search(r"신호가\s+$", preceding) and following.startswith("갔다") \
            and "번호를 눌렀다" in source:
        return "ring_occurrence"
    if counter == "번" and re.search(r"침대 난간이\s+$", preceding) and following.startswith("울렸다"):
        return "sound_occurrence"
    if counter == "글자" and re.search(r"전송되지 않은\s+$", preceding):
        return "unsent_character"
    if counter == "자리" and (re.search(r"확인받을\s+$", preceding) or source.startswith("놓친 두 자리의 비용")):
        return "reopened_slot"
    if counter == "자리" and re.search(r"가족 쪽\s+$", preceding) and following.startswith("는 지켰지만"):
        return "family_commitment"
    if counter == "달" and re.search(r"착한\s+$", preceding) and following.startswith("로 만들지"):
        return "judged_month"
    if counter == "번" and re.search(r"통화\s+$", preceding) and following.startswith("으로 의료 경과"):
        return "phone_occurrence"
    if counter == "주" and (
        re.search(r"첫 매수는 ETF\s+$", preceding)
        or re.search(r"첫 매수는 ETF 한 주였다\.\s*그\s+$", preceding)
    ):
        return "share"
    if counter == "개" and re.search(r"(?:박스|상자)\s*$", preceding):
        return "box"
    if counter == '개' and re.search(r'영상\s+$', preceding):
        return 'video_clip_count'
    if counter == '개' and re.search(r'관찰할 시각\s+$', preceding):
        return 'observation_time_count'
    if counter == '개' and following.startswith('의 현재 동작'):
        return 'current_action_count'
    if counter == '개' and re.search(r'컵라면\s+$', preceding):
        return 'cup_noodles_count'
    if counter == "개" and re.search(r"(?<![가-힣])방\s*$", preceding):
        return "room"
    if counter == "개" and re.search(r"(?<![가-힣])의자\s*$", preceding):
        return "chair"
    if counter == "자리" and re.match(r"식탁", following):
        return "table_seat"
    if counter == "장" and re.search(r"(?<![가-힣])(?:등기|서류)\s*$", preceding):
        return "document_sheet"
    if counter == "장" and re.search(r"그\s+$", preceding):
        return "referenced_sheet"
    if counter == "대" and re.match(r"(?:초|중|후)반", following):
        return "age_decade"
    if counter == "대" and re.search(r"열차\s*$", preceding):
        return "train_vehicle"
    if counter == "번" and match.group("number") == "한" and re.search(r"밥\s+$", preceding) \
            and following.startswith("먹어요"):
        return "meal_invitation"
    if counter == "번" and match.group("number") == "한" and following.startswith("만나보실래요"):
        return "meeting_invitation"
    if counter == "번" and match.group("number") == "한" and re.search(r"말을\s+$", preceding) \
            and following.startswith("더 붙이지 않았다"):
        return "utterance_occurrence"
    if counter == "번" and re.search(r"숨[을이]\s+$", preceding) \
            and re.match(r"(?:고른|길게|삼키고)", following):
        return "breath_occurrence"
    if counter == "개" and following.startswith("의 도착 기록"):
        return "arrival_record"
    if counter == "통" and re.search(r"전화\s+$", preceding) \
            and re.match(r"을 걸었다", following):
        return "phone_call"
    if counter == "줄" and re.search(r"등록 이력\s+$", preceding):
        return "registry_line"
    if counter == "번" and following.startswith("걸린 의심"):
        return "once_condition"
    if counter == "번" and following.startswith("겹쳐 보였다"):
        return "visual_overlap"
    if counter == "자리" and following.startswith("와 연도, 지방법원 코드"):
        return "case_number_digits"
    if counter == "잔" and match.group("number") == "한" and re.search(r"커피\s+$", preceding):
        return "coffee_cup"
    if counter == "장" and following.startswith("넘게 찍었어요"):
        return "sheet_over"
    if counter == "글자" and match.group("number") == "한" and following.startswith("씩 읽었다"):
        return "per_character"
    if counter == "대" and re.match(r"(?:직장인|패닉바이어|사회초년생)(?:$|[\s.,])", following):
        return "age_decade"
    if counter == "번" and re.match(r"런을 완료했다", following):
        return "run_occurrence"
    if counter == "칸":
        if re.search(r"사다리는\s+$", preceding) and following.startswith("씩 밟아야"):
            return "ladder_step"
        if re.search(r"책상\s*위에는[^.\n]*$", preceding) and re.match(
            r"씩\s*자리를\s*차지", following,
        ):
            # Physical desk occupancy, never a table/calendar cell in general.
            return "occupied_space"
        preceding = source[max(0, match.start() - 16):match.start()]
        if "계단" in preceding:
            return "stair_step"
    preceding = source[max(0, match.start() - 120):match.start()]
    if counter in {"번", "회"} and re.match(
        r"(?:보고|보았다|봤다|본다|본 뒤)(?=$|[\s.,])", following,
    ):
        return "look_occurrence"
    if counter in {"번", "회"} and re.match(
        r"만에\s*받았다(?:\.|$|\s)", following,
    ) and re.search(
        r"아버지의\s+연락처를\s+눌렀다\.\s*아버지는\s+$",
        preceding,
    ):
        # Only this adjacent, same-person call/answer construction owns the
        # inferred ringing. A prior call plus 서류는/서류를 받았다 does not.
        return "ring_occurrence"
    preceding = source[max(0, match.start() - 24):match.start()]
    if counter in {"번", "회"} and re.search(
        r"(?:수신음|통화\s*연결음|호출음|벨소리)(?:이|가)?\s*$", preceding,
    ):
        # Sound classifiers are valid for ringing, not arbitrary repetitions.
        return "ring_occurrence"
    if counter == "번" and re.search(r"신호가\s*$", preceding) \
            and following.startswith("울리고 아버지가 받았다") \
            and "아버지 번호를 눌렀다." in source[:match.start()]:
        return "ring_occurrence"  # An actual dial/ring/answer sequence.
    if counter == "일" and re.search(r"\d+\s*월\s*$", preceding):
        return "calendar_day"
    if counter == "분" and re.search(
        r"(?:\d+|한|두|세|네|다섯|여섯|일곱|여덟|아홉|열)\s*시\s*$",
        preceding,
    ):
        return "clock_minute"
    return SOURCE_COUNTER_CLASSES.get(counter, "")


def _source_audience_quantities(source: str) -> list[CounterQuantity]:
    quantities: list[CounterQuantity] = []
    for match in re.finditer(r"(?<=구독자 )(?P<number>\d+)만(?= = 연봉)", source):
        quantities.append(CounterQuantity(match.start(), match.end(),
                                          Decimal(match.group("number")) * 10_000, "subscriber_count"))
    for match in SOURCE_CREATOR_AUDIENCE.finditer(source):
        for group in ("first", "subscribers", "earlier", "later"):
            quantities.append(CounterQuantity(
                match.start(group), match.end(group),
                Decimal(match.group(group)[:-1]) * 10_000,
                "subscriber_count" if group == "subscribers" else "audience_count",
            ))
    return quantities


def _source_counter_quantities(source: str) -> list[CounterQuantity]:
    quantities: list[CounterQuantity] = []
    quantities.extend(_source_audience_quantities(source))
    # These relationship-scene quantities are approximate or honorific, never
    # exact ages/repetitions or clock minutes. Own their complete expression.
    for pattern, value, kind in (
        (r"(?<![가-힣])두어\s+번" + SOURCE_COUNTER_SUFFIX, 2, "approximate_occurrence"),
        (r"(?<![가-힣])서른\s+몇(?=의 연애)", 30, "approximate_age"),
        (r"(?<![가-힣])서른을\s+넘긴(?= 두 사람)", 30, "age_over"),
        (r"(?<=온도가 )반\s+도쯤", "0.5", "degree"),
        (r"(?<![가-힣])서른일곱(?=의 겨울)", 37, "age"),
        (r"(?<![가-힣])백\s+명(?=보다)", 100, "comparison_people"),
        (r"(?<![가-힣])두\s+집(?=\s+사이)", 2, "household_pair"),
        (r"(?<![가-힣])두\s+글자(?=들)", 2, "character"),
        (r"(?<![가-힣\d])5성급(?= 호텔)", 5, "hotel_star_rating"),
        (r"(?<=놀이기구는 )(?:아직 )?두 개(?=밖에 못 탔다)", 2, "amusement_ride_count"),
        (r"(?<=내년엔 )1박(?=으로 와요)", 1, "stay_night"),
        (r"(?<=졸업 )10주년(?= 동창회)", 10, "graduation_anniversary"),
        (r"(?<![가-힣\d])1인당(?=\s)", 1, "per_person_bill"),
        (r"(?<=자기소개서 )세 군데(?=를 고쳤다)", 3, "resume_edit_place"),
        (r"(?<![가-힣])두 이야기(?=는, 그 지점에서)", 2, "story_pair"),
        (r"(?<=끝까지 )넉 달(?=이 남아 있었다\.)", 4, "remaining_four_month"),
        (r"(?<=대학교 )2학년(?= 때 쓴 것 같다\.)", 2, "university_year"),
        # Money is masked before counter matching; the restaurant clause
        # still binds this singular per-person price, not arbitrary 1인.
        (r"(?<=식당\. )1인(?=\s)", 1, "restaurant_per_person"),
        # Own each complete compound duration: a later correct seconds/minutes
        # count may not cover a changed component in the observed display.
        (r"(?<=전자레인지 )1분 30초(?=\.)", 90, "microwave_duration"),
        (r"(?<=스크린 타임 알림이 떴다\. 하루 )7시간 48분(?=\.)", 468, "screen_time_duration"),
        (r"(?<=스트레스성 편두통\. )한 달에 한두 번(?=은 온다\.)", 1, "monthly_headache_frequency"),
        (r"^한두 잔(?=만 하고 일찍 빠진다$)", 1, "work_cup_range"),
        (r"(?<=세 발짝 뒤에서 )두 동료(?=가 멈칫했다\.)", 2, "coworker_count"),
        (r"(?<=오늘부터 )하루 3시간(?= 공부한다$)", 3, "study_daily_hours"),
        (r"(?<=^자격증 시험 )D-14$", 14, "exam_countdown"),
        (r"(?<=수강료는 )한 달(?=\s)", 1, "tuition_month"),
        (r"30일을 한 번도 해본 적이 없다는(?= 게 마음에 걸린다\.)", 30, "never_course_days"),
        (r"^한 곳(?=에 집중해서 자소서를 다듬는다$)", 1, "job_company_focus"),
        (r"(?<![가-힣\d])30대(?= 자산관리)", 30, "asset_age_decade"),
        (r"한 달에 한 번씩(?= 이런다\.)", 1, "monthly_balance_once"),
        (r"(?<=편의점에서 캔맥주 )두 개(?=를 샀다$)", 2, "beer_can_count"),
        (r"(?<=\.\.\.)3개(?= 일치\.)", 3, "lottery_match_count"),
        (r"(?<=3개 일치\. )5등(?=\.)", 5, "lottery_prize_rank"),
        (r"^3개월권(?=\s+\. 등록할 때 결심이 단단했다\.)", 3, "gym_card_months"),
        (r"^한 달 반쯤(?= 갔다\. 기간이 지났을 때)", "1.5", "gym_approx_months"),
        (r"(?<=서울에서의 )첫 번째(?= 행운이었다\.)", 1, "first_luck"),
        (r"(?<=\. )둘(?= 사이에\s+이 있었다\.)", 2, "price_gap_pair"),
    ):
        for match in re.finditer(pattern, source):
            if kind == "price_gap_pair" and not re.search(r"\s{2,}\. \s{2,}\. $", source[:match.start()]):
                continue  # Exactly two preceding masked prices, not arbitrary people.
            if (kind == "per_person_bill" or kind in LIFE_SCENE_COUNTER_KINDS) and _has_numeric_sign_prefix(source, match.start()):
                continue  # Never mask the unsigned tail of a signed/fractional source count.
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(value), kind))
    if "삼각김밥" in source:
        for match in re.finditer(r"(?<!\d)1\s*\+\s*1(?!\d)", source):
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(1), "one_plus_one_offer"))
    for match in re.finditer(r"일요일\s+하나(?=$|[\s.,]|[를가는도])", source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal(1), "sunday_count"))
    # Observed year-four noun counts carry their own objects: three notices
    # are not three people, and two promises are not two clock hours.
    noun_kinds = {"약속": "promise_count", "기록": "record_count", "빈칸": "blank_cell_count",
                  "알림": "notice_count", "창구": "counter_window_count", "시각": "time_point_count", "곳": "place_count",
                  "연락창": "contact_window_count", "대상": "contact_target_count", "마감": "deadline_count", "발행처": "issuer_count", "갈래": "branch_count", "버전": "version_count",
                  "화면": "screen_count", "말풍선": "speech_bubble_count", "첨부파일": "attachment_count", "전송 버튼": "send_button_count", "주소": "address_count",
                  "숫자": "number_count", "출처": "source_count", "날짜": "date_count", "표지": "cover_count", "의자": "chair",
                  "물건": "object_count", "결과": "result_count", "장부": "ledger_count", "뜻": "meaning_count", "문": "door_count", "도시": "city_count"}
    for match in re.finditer(
        r"(?<![가-힣])(?P<number>한|두|세)\s+(?P<noun>약속|기록|빈칸|알림|창구|시각|곳|연락창|대상|마감|발행처|갈래|버전|화면|말풍선|첨부파일|전송 버튼|주소|숫자|출처|날짜|표지|의자|물건|결과|장부|뜻|문|도시)"
        r"(?=$|[\s.,!?…]|[은는이가의을를도와과만에]|이었다|였다)", source,
    ):
        if any(match.start() < q.end and match.end() > q.start for q in quantities):
            continue
        if match.group("noun") == "곳" and re.search(r"주소\s+$", source[:match.start()]):
            continue  # The existing address_count contract owns 주소 두 곳.
        if match.group("noun") == "약속" and match.group("number") == "한" \
                and re.search(r"(?:기로|누구에게도|사람에게)\s+$", source[:match.start()]):
            continue  # A promise made/agreed upon, not the number one.
        if match.group("noun") == "시각" and match.group("number") == "한" \
                and re.search(r"(?:연락하기로|만나기로)\s+$", source[:match.start()]):
            continue  # 연락하기로 한 시각 하나 has a relative clause plus one.
        kind = noun_kinds[match.group("noun")]
        if match.group("noun") == "곳":
            if "약속 한 곳에는 완료 시각" in source:
                kind = "appointment_place"
            elif source[match.end():].startswith("을 다시 열 수") or (
                source[match.end():].startswith("을 취소했다는") and "병동 통화" in source
            ):
                kind = "commitment_place"
        quantities.append(CounterQuantity(match.start(), match.end(),
            Decimal(_korean_native_value(match.group("number"))), kind))
    if "세 약속" in source:
        for match in re.finditer(r"(?<![가-힣])셋(?=을 망칠)", source):
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(3), "entity"))
    if "세 알림" in source:
        for match in re.finditer(r"(?<=나머지 )둘(?=에는)", source):
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(2), "remaining_notice"))
    for match in re.finditer(r'(?<![가-힣])셋(?=을 모두 캐물으면)', source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal(3), 'question_set'))
    for match in re.finditer(
        r"하나(?=를 쓰는 순간 다른 둘)|(?<=하나를 쓰는 순간 다른 )둘(?=은 빈 줄에서)|셋(?=을 모두 고른 척하면)", source,
    ):
        quantities.append(CounterQuantity(match.start(), match.end(),
            Decimal(_korean_native_value(match.group())), "signature_option_count"))
    if '칼이 도마에 닿았다. 하나, 둘.' in source:
        for match in re.finditer(r'(?<=닿았다\. )하나(?=, 둘\.)|(?<=하나, )둘(?=\.)', source):
            quantities.append(CounterQuantity(match.start(), match.end(),
                Decimal(_korean_native_value(match.group())), 'counted_beat_sequence'))
    for match in re.finditer(r"(?<=보호자 )1순위(?= 연락처)", source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal(1), "contact_priority"))
    for match in re.finditer(r"(?<![\d가-힣])(?P<number>\d+)킬로(?= 뛰다)", source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal(match.group("number")), "running_distance"))
    for match in re.finditer(r"(?<![가-힣])반\s+년(?= 만에 러닝화를)", source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal("0.5"), "year"))
    for pattern, kind in ((r"(?<![가-힣])두 종이" + SOURCE_COUNTER_SUFFIX, "sheet"), (r"(?<=주소 )두 곳", "address_count")):
        for match in re.finditer(pattern, source):
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(2), kind))
    for match in re.finditer(r"(?<![가-힣])둘(?=이서 찍은 것)", source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal(2), "entity"))
    for pattern, kind in (
        (r"(?<![가-힣])두 창(?=을 닫지 못한)", "window_count"),
        (r"(?<![가-힣])두 가지(?=가 동시에 사실)", "parallel_fact"),
        (r"(?<![가-힣])두 사실(?=을 같은 줄에)", "parallel_fact"),
        (r"(?<![가-힣])두 파일(?=[이을의])", "file_count"),
        (r"(?<=따로 알고 있던 )두 세계(?=가)", "world_count"),
    ):
        for match in re.finditer(pattern, source):
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(2), kind))
    for match in re.finditer(r"(?<=기소된 사례가 )(?P<number>\d+)건", source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal(match.group("number")), "legal_case_count"))
    if "총자산 화면과 대화 목록" in source:
        # Both referents occur in this source. Do not deduplicate them: one
        # correct later pair must not conceal a changed earlier quantity.
        for match in re.finditer(r"(?<![가-힣])둘(?= 다 올해의 기록|을 따로 관리)", source):
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(2), "record_pair"))
    for pattern, number, kind in (
        (SOURCE_CATALOG_AGE, 20, "age"),
        (SOURCE_NAME_CHARACTERS, 3, "character"),
        (SOURCE_REUNION_PAIR, 2, "photo_pair"),
    ):
        for match in pattern.finditer(source):
            quantities.append(CounterQuantity(match.start(), match.end(), Decimal(number), kind))
    if source in CATALOG_YOUNG_ADULT_SOURCES:
        start = source.index("2030")
        quantities.append(CounterQuantity(start, start + 4, Decimal(2030), "young_adult_group"))
    if source == "1인 가구":
        quantities.append(CounterQuantity(0, len(source), Decimal(1), "single_household"))
    for match in re.finditer(r"주(?P<number>4)일제(?= 의무화| 도입 기업 늘자)", source):
        quantities.append(CounterQuantity(match.start(), match.end(), Decimal(4), "workweek_days"))
    for match in SOURCE_RETIREMENT_AGE.finditer(source):
        quantities.append(CounterQuantity(
            match.start(), match.end(), Decimal(_korean_native_value(match.group(0))), "age",
        ))
    for match in SOURCE_PORTION.finditer(source):
        quantities.append(CounterQuantity(
            match.start(), match.end(), Decimal(match.group("number")), "portion",
        ))
    for match in SOURCE_TWO_NAMES.finditer(source):
        quantities.append(CounterQuantity(
            match.start(), match.end(), Decimal(2),
            "name_column_count" if re.match(r"\s+칸", source[match.end():]) else "name_count",
        ))
    for match in SOURCE_TWO_PARENTS.finditer(source):
        quantities.append(CounterQuantity(
            match.start(), match.end(), Decimal(2), "parent_pair",
        ))
    for match in SOURCE_PRINT_RUN.finditer(source):
        value = _decimal_value(match.group("number"))
        if value is not None:
            quantities.append(CounterQuantity(
                match.start("number"), match.end(),
                value * (10_000 if match.group("unit") else 1), "print_copy",
            ))
    for match in SOURCE_FINANCIAL_TIER.finditer(source):
        quantities.append(CounterQuantity(
            match.start(), match.end(), Decimal(match.group("number")),
            "financial_tier",
        ))
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
            kind = _ordinal_kind(source, match.end())
            if kind in LIFE_SCENE_COUNTER_KINDS and _has_numeric_sign_prefix(source, match.start()):
                continue
            quantities.append(CounterQuantity(
                match.start(), match.end(), value,
                kind,
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
        SOURCE_NATIVE_THREE_MONTH,
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
            if kind in LIFE_SCENE_COUNTER_KINDS and _has_numeric_sign_prefix(source, match.start()):
                continue
            end = match.end()
            # The story corpus contains 1년 반 and 두 달 반. Half a period
            # belongs to that duration, not an ignorable adjective after it.
            if kind in {"year", "duration_month"}:
                half = re.match(r"\s*반(?=$|\s|[.,!?…]|[은는이가을를의도에])", source[end:])
                if half:
                    value += Decimal("0.5")
                    end += half.end()
            quantities.append(CounterQuantity(
                match.start(), end, value, kind
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
        if match.group("day") == "하루" and re.match(r"\s+200통의 전화\.", source[match.end():]):
            kind = "daily_frequency"
        if match.group("day") == "하루" and re.search(r"현수의\s+$", source[:match.start()]) \
                and source[match.end():].startswith("를 정하던 시간표"):
            kind = "daily_frequency"
        if match.group("day") == "하루" and source.startswith("{topic} 하루 만에 +22% 폭등"):
            kind = "single_market_day"
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
        if match.group("number") == "둘" and re.search(r"감춰\s+$", source[:match.start()]) \
                and source[match.end():].startswith(" 수 있었던 체면"):
            continue  # 감춰 둘 is an auxiliary verb, not two hidden things.
        if match.group('number') == '둘' and re.search(r'비워\s+$', source[:match.start()]) \
                and source[match.end():].startswith(' 시간을'):
            continue  # 비워 둘 시간 is time to leave free, not two hours/entities.
        if match.group('number') == '둘' and re.search(r'남겨\s+$', source[:match.start()]) \
                and source[match.end():].startswith(' 현금'):
            continue  # 남겨 둘 현금 is retained cash, not two entities.
        if match.group('number') == '둘' and re.search(r'자기 원장에만\s+$', source[:match.start()]) \
                and source[match.end():].startswith(' 수 있었다'):
            continue  # 자기 원장에만 둘 수 is storage, not a second count.
        value = _korean_native_value(match.group("number"))
        kind = "concept_pair" if (
            match.group("number") == "둘"
            and re.search(r"그\s+$", source[:match.start()])
            and re.match(r"의\s+경계", source[match.end():])
        ) else "entity"
        if re.search(r'매물\s+$', source[:match.start()]) and source[match.end():].startswith(' 가운데'):
            kind = 'property_listing_count'
        if match.group("number") == "둘" and re.match(r' 중 하나(?:다|였다)', source[match.end():]):
            kind = "alternative_count"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 남겨 둔 채 이름만"):
            kind = "retained_pair"
        if match.group("number") == "둘" and source[match.end():].startswith("이 합의한 날짜"):
            kind = "agreement_parties"
        if match.group('number') == '둘' and source[match.end():].startswith(' 다.') \
                and re.search(r'고맙다\. 그리고 미안했다\.\s*$', source[:match.start()]):
            kind = 'statement_pair'
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 챙기겠다는 말은 선택이 아니었다"):
            kind = "concept_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 열지 않"):
            kind = "openable_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 사실의 절반"):
            kind = "concept_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 된다고 쓰지 않았다"):
            kind = "concept_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 지울 수 없는 사실"):
            kind = "immutable_fact_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 중 하나를 지우지 않은") \
                and "안도와 아쉬움" in source[:match.start()]:
            kind = "feeling_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 할 수는 없었다"):
            kind = "action_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다인지 알 수 없다") \
                and "일 얘기인지, 인생 얘기인지" in source[:match.start()]:
            kind = "topic_pair"
        if match.group("number") == "둘" and source[match.end():].startswith(" 다 하지 못하면 그 연락"):
            kind = "action_pair"
        if match.group("number") == "셋" and source[match.end():].startswith(" 다 통화를 끊지 않고"):
            kind = "call_action_count"
        if "손가락을 접었다. 하나, 둘, 셋." in source and match.group("number") in {"둘", "셋"} \
                and re.search(r"하나, (?:둘, )?$", source[:match.start()]):
            kind = "finger_sequence"
        if match.group("number") == "둘" and source == "둘만 놓인 국":
            kind = "soup_count"
        if match.group("number") == "셋" and source[match.end():].startswith("은 한 사람이었다"):
            kind = "concept_pair"
        if value is None or any(
            quantity.kind == kind and quantity.value == value
            for quantity in quantities
        ):
            continue
        quantities.append(CounterQuantity(
            match.start(), match.end(), value, kind
        ))
    return sorted(quantities, key=lambda quantity: quantity.start)


def _target_pattern_for_kind(kind: str) -> re.Pattern[str]:
    if kind == "asset_age_decade":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?P<spend_unit>多[歲岁年]|[歲岁]|年|[輛辆])")
    if kind == "monthly_balance_once":
        return re.compile(rf"(?P<period>每(?:{CHINESE_CARDINAL})?[個个]?(?:月|年|週|周|天|日|小時|小时|分鐘|分钟|秒))(?:都)?(?P<negative>不)?[會会](?:這樣|这样)(?P<number>{CHINESE_CARDINAL})(?P<spend_unit>次|天|年)")
    if kind == "beer_can_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?P<spend_unit>罐|瓶|杯|箱)啤酒")
    if kind == "lottery_match_count":
        return re.compile(rf"(?P<lotto_match>對中|对中|中了|沒中|没中)(?P<number>{CHINESE_CARDINAL})(?P<spend_unit>[個个]|年|天)")
    if kind == "lottery_prize_rank":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?P<spend_unit>等[獎奖]|[獎奖]|年|次)")
    if kind == "gym_card_months":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?P<spend_unit>[個个]月|年|天|小時|小时)(?:卡)?")
    if kind == "gym_approx_months":
        return re.compile(rf"(?P<approx>大約|大约|約|约)?(?P<number>{CHINESE_CARDINAL})[個个](?P<spend_unit>半月|月半|半天|月|年)")
    if kind == "first_luck":
        return re.compile(rf"第(?P<number>{CHINESE_CARDINAL})份幸[運运]")
    if kind == "price_gap_pair":
        return re.compile(rf"(?:這|这)?(?P<number>{CHINESE_CARDINAL})[個个][數数]之[間间]|(?P<pair>中[間间])")
    counted_nouns = {
        "remaining_four_month": r"[個个]月",
        "job_posting_count": r"(?:[則则條条]|[個个])(?:職缺|招聘信息|招聘資訊|招聘公告|徵才公告)",
        "egg_count": r"[顆颗個个](?:放了很久的|放很久的|陳舊的|陈旧的)?(?:雞蛋|鸡蛋|蛋)(?=\s*(?:$|[，。！？、：；,.!?;:」』）)]))",
        "task_count": r"[項项個个](?:總是做不完的|总是做不完的|總沒完成的|总没完成的)?(?:作業|作业|任務|任务)",
        "mirror_glance": r"眼",
        "underground_exit": r"[號号]出口",
        "chicken_open_hours": r"(?:小時|小时)[營营][業业]的炸[雞鸡]店",
        "graduation_anniversary": r"[周週]年",
        "resume_edit_place": r"(?:個|个)地方|[處处]",
        "station_exit": r"[號号]\s*出口",
        "topic_pair": r"者",
        "outing_round": r"[場场攤摊]",
        "story_pair": r"(?:個|个)(?:故事|人生故事)",
        "rice_bowl": r"碗(?:米|白)?[飯饭]",
        "age_decade_unspecified": r"(?:多|來|来|幾|几)[歲岁]",
        "missed_call": r"(?:通|次)未接[來来][電电]",
        "promise_count": r"(?:個|个|項|项|次)?(?:約定|约定|承諾|承诺)",
        "record_count": r"(?:份|筆|笔|項|项|條|条|個|个)?(?:獨自一人的|独自一人的)?(?:紀錄|記錄|记录)",
        "blank_cell_count": r"(?:個|个)?(?:空格|空白格|空白欄|空白栏)",
        "notice_count": r"(?:則|则|條|条|個|个)?(?:通知|提醒)",
        "counter_window_count": r"(?:個|个)?(?:窗口|櫃檯|柜台)",
        "time_point_count": r"(?:個|个)?(?:沒有結果的|没有结果的)?(?:時間|时间|時刻|时刻)",
        "place_count": r"(?:處|处|個地方|个地方)",
        "family_commitment": r"(?:處|处|個位置|个位置|席|個|个)",
        "judged_month": r"(?:個|个)(?:做了好事的)?(?:月份|月)",
        "contact_window_count": r"(?:個|个)(?:聯絡|联络)(?:視窗|视窗|窗口)",
        "contact_target_count": r"(?:個|个)對象|(?:個|个)对象",
        "deadline_count": r"(?:個|个)(?:期限|截止時間|截止时间)",
        "issuer_count": r"(?:個|个)(?:出具方|發出通知的單位|发出通知的单位)",
        "remaining_notice": r"(?:個|个|項|项)",
        "appointment_place": r"(?:處|处|個約定|个约定|個|个)(?!人|小時|小时)",
        "commitment_place": r"(?:處|处|邊|边)",
        "reopened_slot": r"(?:處|处|個位置|个位置)",
        "drawn_line": r"(?:道線|道线|行|條線|条线)",
        "honorific_people": r"(?:位|個人|个人)",
        "unsent_character": r"(?:個|个)(?:尚未發出|尚未发出|還沒傳出|还没传出|未傳出|未传出)的字",
        "action_pair": r"(?:邊|边|者|個|个|項|项|件事|件)",
        "branch_count": r"(?:個|个)(?:方向|分支)|(?:條|条)路|[邊边](?![人位年月日天元度]|公里|小時|小时)",
        "seat_row": r"排(?![人位年月日天元度]|公里|小時|小时)",
        "brightness_level": r"[檔档格](?![人位年月日天元度]|公里|小時|小时)",
        "comparison_people": r"(?:個人|个人|人|位|名)(?![年月日天元度]|公里|小時|小时)",
        "household_pair": r"(?:(?:個|个)?家|(?:戶|户)(?:人家)?)(?![具電电居年月日天元度]|公里|小時|小时)",
        "hotel_star_rating": r"星[級级](?![人位年月日天元度]|公里|小時|小时)",
        "call_action_count": r"(?:樣|样|個|个|項|项|件事)",
        "sound_occurrence": r"(?:聲|声|下|次)",
        "can_sound_occurrence": r"(?:聲|声|下|次)",
        "glass_pane": r"[片塊块張张]\s*玻璃",
        "amusement_ride_count": r"[個个項项]",
        "petal_count": r"[片瓣張张]",
        "turned_look_count": r"(?:眼|次|回|遍|下)",
        "small_coffee_can": r"(?:小)?罐|[個个](?:小)?罐[裝装]咖啡",
        "stay_night": r"(?:晚|夜)",
        "immutable_fact_pair": r"(?:者|邊|边|件事)",
        "soup_count": r"(?:碗|份)湯|(?:碗|份)汤",
        "version_count": r"(?:個|个)?版本",
        "screen_count": r"(?:個|个)?(?:螢幕|屏幕|畫面|画面)",
        "speech_bubble_count": r"(?:個|个)?(?:訊息|消息)?(?:氣泡|气泡|泡泡|對話框|对话框)",
        "attachment_count": r"(?:個|个|份)?(?:附件|附加檔案)",
        "send_button_count": r"(?:個|个)?(?:傳送|发送|發送)(?:按鈕|按钮|鍵|键)",
        "property_listing_count": r"(?:套|間|间|個|个|筆|笔)?\s*(?:價位的?|价位的?)?(?:房源|待售物件|物件)",
        "number_count": r"(?:個|个)?數字|(?:個|个)?数字",
        "source_count": r"(?:個|个)?來源|(?:個|个)?来源",
        "video_clip_count": r"(?:段|部|個|个)(?:拿水瓶時手發抖的|拿水瓶时手发抖的|拿水瓶时手抖的|手抖的?|手發抖的)?(?:影片|視頻|视频)",
        "observation_time_count": r"(?:個|个)(?:需要觀察的|需要观察的)?(?:時間|时间|時刻|时刻)",
        "question_set": r"(?:個問題|个问题|件事|(?:個|个)(?=都追[問问]))",
        "date_count": r"(?:個|个)?日期",
        "current_action_count": r"(?:種|种|個|个)(?:此刻可以做的|此刻能做的|現在就能做的|现在就能做的|當下的|当前的)?(?:操作|動作|动作|行動|行动)",
        "statement_pair": r"(?:樣|样|句|者)(?=\s*(?:都|[，。,、：:]|$))",
        "cover_count": r"(?:個|个|張|张|份)?封面",
        "name_column_count": r"(?:個|个)?(?:姓名欄|姓名栏|名字欄|名字栏)",
        "sunday_count": r"(?:個|个)?(?:星期|禮拜|礼拜|週|周)(?:日|天|7)",
        "object_count": r"(?:件|個|个|樣|样)(?:物品|物件|東西|东西)",
        "result_count": r"(?:個|个|份|項|项)?結果|(?:個|个|份|項|项)?结果",
        "ledger_count": r"(?:本|份)?(?:帳冊|账册|帳本|账本|帳|账)",
        "meaning_count": r"(?:種|种|個|个)(?:意思|含義|含义)",
        "signature_option_count": r"(?:種|种|項|项|個|个)(?=\s*(?:的瞬間|的瞬间|就|都|全|簽名|签名|選擇|选择|[，。,、：:]|$))",
        "door_count": r"(?:扇|道|個|个)(?:一再比較的|重新比較著的|重新比较着的)?[門门]",
        "retained_pair": r"(?:邊|边|者|樣|样|個|个)(?=都|全|[，。,、：:]|$)",
        "strike_line_count": r"(?:道|條|条)[線线]",
        "strike_occurrence": r"次|(?:道|條|条)(?:黑)?[線线]",
        "appliance_cycle": r"(?:輪|轮|次)",
        "city_count": r"(?:座|個|个)?(?:不同)?城市",
        "receding_step": r"步",
        "cup_noodles_count": r"(?:碗|杯|個|个)(?:杯麵|杯面|方便麵|方便面)?",
    }
    if kind in counted_nouns:
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:{counted_nouns[kind]})")
    if kind in {"per_person_bill", "restaurant_per_person"}:
        return re.compile(rf"(?P<once>每人)|(?P<number>{CHINESE_CARDINAL})人(?:各|分攤|分摊)")
    if kind == "university_year":
        return re.compile(rf"大[學学](?P<number>{CHINESE_CARDINAL})年[級级]")
    if kind == "rental_home_ordinal":
        return re.compile(rf"第(?P<number>{CHINESE_CARDINAL})(?:(?:套|[間间])房(?=\s*(?:$|[，。！？、：；,.!?;:」』）)]|的(?:租[約约]|合同)))|[間间]的租[約约])")
    if kind == "gangnam_attempt":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})次|[闖闯](?P<once>一)[闖闯]")
    if kind == "work_cup_range":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?:[~～至到-](?P<upper>{CHINESE_CARDINAL}))?(?P<work_unit>杯|罐|瓶|年)")
    if kind == "coworker_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})[位名個个]?同事")
    if kind == "subscription_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})[項项個个](?:不必要的)?(?:訂閱|订阅)服[務务]")
    if kind == "study_daily_hours":
        return re.compile(rf"(?P<period>每(?:{CHINESE_CARDINAL})?[個个]?(?:天|日|週|周|月|年|小時|小时|分鐘|分钟|秒))(?:學|学|讀|读|學習|学习)(?P<number>{CHINESE_CARDINAL})(?P<work_unit>[個个]?(?:小時|小时|分鐘|分钟|年))")
    if kind == "exam_countdown":
        return re.compile(rf"(?:倒[數数]|倒[計计][時时])(?P<number>{CHINESE_CARDINAL})(?P<work_unit>天|日|年|小時|小时)|D-(?P<countdown>{CHINESE_CARDINAL})")
    if kind == "tuition_month":
        return re.compile(rf"每(?P<number>{CHINESE_CARDINAL})?[個个]?(?P<work_unit>月|年|週|周|天|日|小時|小时|分鐘|分钟|秒)")
    if kind == "never_course_days":
        return re.compile(rf"(?:(?P<number>{CHINESE_CARDINAL})次(?:也|都)?(?P<negative>沒|没|未|已|曾|有|不)?(?:堅持滿|坚持满)|(?P<once>從沒|从没|從未|从未|曾經|曾经|從有|从有)(?:連續|连续)?做[滿满])(?P<course_days>{CHINESE_CARDINAL})(?P<work_unit>天|日|年)")
    if kind == "job_company_focus":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})家(?:公司)?")
    if kind == "read_mark_over_count":
        return re.compile(rf"(?P<read_prefix>(?:已讀|已读|未讀|未读|已發|已发)(?:標記|标记|數|数)?(?:已經|已经)?(?:超過|超过|達到|达到|不足))(?P<number>{CHINESE_CARDINAL})(?:[個个])?")
    if kind == "microwave_duration":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})分(?:鐘|钟)?\s*(?P<seconds>{CHINESE_CARDINAL})秒(?:鐘|钟)?")
    if kind == "screen_time_duration":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?:小時|小时)\s*(?P<minutes>{CHINESE_CARDINAL})分(?:鐘|钟)?")
    if kind == "monthly_headache_frequency":
        return re.compile(rf"每[個个]?月(?:總會發作|总会发作)?(?:(?P<number>一[兩两])|(?P<range_start>{CHINESE_CARDINAL})\s*[~～至到-]\s*(?P<range_end>{CHINESE_CARDINAL}))次")
    if kind == "duration_month_over":
        return re.compile(rf"超[過过](?P<over_month>{CHINESE_CARDINAL})(?:個|个)?月|(?P<number>{CHINESE_CARDINAL})(?:個|个)?多月")
    if kind == "video_duration_minute":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?:分鐘|分钟|分(?={CHINESE_CARDINAL}秒))")
    if kind in {"soup_sip", "tea_sip"}:
        beverage = r"[湯汤]" if kind == "soup_sip" else "茶"
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})口{beverage}|(?P<once>喝了口{beverage})")
    if kind == 'ordinal_meeting':
        return re.compile(rf'第(?P<number>{CHINESE_CARDINAL})(?:場|场|個|个)\s*(?:會議|会议|會|会)')
    if kind == 'laughter_once':
        return re.compile(rf'(?P<number>{CHINESE_CARDINAL})\s*次(?=笑)')
    if kind == 'never_sea_entry':
        return re.compile(rf'(?P<number>{CHINESE_CARDINAL})次(?:也|都)(?:沒|没|沒有|没有)下[過过](?:這|这|那)片海|(?P<once>(?:從來沒(?:有)?|从来没(?:有)?|從未|从未)下[過过](?:這|这|那)片海)')
    if kind == 'counted_beat_sequence':
        return re.compile(rf'(?<=[。,.、，])\s*(?P<number>{CHINESE_CARDINAL})(?=[。,、，])')
    if kind == 'character':
        return re.compile(rf'(?P<number>{CHINESE_CARDINAL})\s*(?:個|个)?(?:韓文|韩文)?字')
    if kind == 'agreement_parties':
        return re.compile(rf'(?P<pair>雙方|双方)|(?P<number>{CHINESE_CARDINAL})(?:個人|个人|人|方)')
    if kind == "approximate_occurrence":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?:(?:[、，,]\s*[三3]|三)(?:次|回)|(?:次|回)左右)(?!元|方)")
    if kind == "approximate_age":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?:幾|几|多|來|来)[歲岁]")
    if kind == "age_over":
        return re.compile(
            rf"(?:(?:年[過过]|[過过]了)(?P<over_age>{CHINESE_CARDINAL})(?:[歲岁])?"
            rf"|(?P<number>{CHINESE_CARDINAL})(?:[歲岁])?(?:出頭|出头|開外|开外|以上))"
        )
    if kind == "degree":
        return re.compile(rf"(?P<number>半|\d+(?:\.\d+)?|{CHINESE_CARDINAL})度")
    if kind == "never_toss_turn":
        return re.compile(
            rf"(?P<number>{CHINESE_CARDINAL})次(?:也|都)?(?:沒有|没有|沒|没)(?:翻過身|翻过身|翻身)"
            r"|(?P<never_toss>(?:一整夜|整夜)(?:都)?(?:沒有|没有|沒|没)(?:翻過身|翻过身|翻身))"
            rf"|(?:一整夜|整夜)(?:都)?(?:沒有|没有|沒|没)翻[過过](?P<toss_number>{CHINESE_CARDINAL})次身"
        )
    if kind == "one_plus_one_offer":
        # The public TW line explains the literal offer immediately afterward:
        # 1+1活動，買一送一. This is one promotion, not two purchases.
        return re.compile(r"(?P<number>1\s*[+＋]\s*1(?:\s*(?:活動|活动)?[，,]\s*[買买][一1][送贈赠][一1])?|[買买][一1][送贈赠][一1])(?![\d零〇一二两兩三四五六七八九十百千萬万億亿兆元圓圆人位歲岁天年米度])")
    if kind == 'read_again':
        return re.compile(rf'(?P<number>{CHINESE_CARDINAL})\s*(?:次|遍)|(?P<once>再次|再度)(?=由上往下)')
    if kind == 'never_skip_week':
        return re.compile(rf'(?P<number>{CHINESE_CARDINAL})\s*次(?:也|都)?(?:沒|没|沒有|没有)漏[過过]|(?:沒有|没有)漏[過过](?P<after>{CHINESE_CARDINAL})次|(?P<once>沒有漏過任何一週)')
    if kind == 'never_utterance':
        return re.compile(rf'(?P<number>{CHINESE_CARDINAL})次(?:也|都)?(?:沒|没|沒有|没有)[說说][過过]|(?P<once>[從从](?:沒|没|未)[說说][過过])')
    if kind == "chapter_reference":
        return re.compile(rf"第\s*(?P<number>{CHINESE_CARDINAL})\s*章")
    if kind == 'never_drink_occurrence':
        return re.compile(rf'(?P<number>{CHINESE_CARDINAL})\s*(?:口|次)(?:冷咖啡|咖啡)?(?:也|都)?(?:沒|没|沒有|没有)喝')
    if kind == "receipt_identifier":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*[號号](?!碼|码|人|分鐘|分钟|次)")
    if kind == "finger_sequence":
        return re.compile(rf"(?<=[、，,])\s*(?P<number>{CHINESE_CARDINAL})(?=[、，,。])")
    if kind == "contact_priority":
        return re.compile(rf"第(?P<number>{CHINESE_CARDINAL})[順顺]位")
    if kind == "feeling_pair":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})(?:者|邊|边)|(?P<either_side>任何一[邊边])")
    if kind == "per_line":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*行|(?P<per_line>逐行)")
    if kind == "phone_occurrence":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:通|次)(?:電話|电话|通話|通话)")
    if kind == "case_number_digits":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:位|碼|码)")
    if kind == "registry_line":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:筆|笔|條|条|行)")
    if kind == "once_condition":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:次|回)|(?P<once_condition>一旦)")
    if kind == "visual_overlap":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:次|回|瞬|下)")
    if kind == "ladder_step":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:級|级|階|阶|格)")
    if kind == "window_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:個|个)?(?:視窗|窗口)")
    if kind == "parallel_fact":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:件事|個事實|个事实|項事實|项事实)")
    if kind == "file_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:個|个|份)?(?:檔案|文件)")
    if kind == "world_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:個|个)?世界")
    if kind == "record_pair":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:樣|样|邊|边|者|個|个|份)")
    if kind == "running_distance":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:公里|千米)")
    if kind == "referenced_sheet":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL}|那|這|这)\s*(?:張|张|頁|页|枚)")
    if kind == "phone_call":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL}|那|這|这)\s*通")
    if kind == "arrival_record":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:筆|笔|項|项|個|个|條|条)")
    if kind == "openable_pair":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:樣|样|個|个|件|份)")
    if kind == "breath_occurrence":
        return re.compile(rf"(?:(?P<number>{CHINESE_CARDINAL})\s*口|(?P<one_breath>[緩缓]了口))[氣气]")
    if kind == "ordinal_night":
        return re.compile(rf"第\s*(?P<number>{CHINESE_CARDINAL})\s*(?:天夜[裡里]|(?:個|个)(?:晚上|夜晚)|晚|夜)")
    if kind == "ordinal_sheet":
        return re.compile(rf"第\s*(?P<number>{CHINESE_CARDINAL})\s*(?:張|张|枚|頁|页)|(?P<first_sheet>首頁|首页)")
    if kind == "address_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:個|个|處|处)地址")
    if kind == "per_character":
        return re.compile(rf"(?P<per_character>逐字)|(?P<number>{CHINESE_CARDINAL})\s*(?:個|个)?字")
    if kind == "meeting_invitation":
        return re.compile(rf"[見见](?P<number>{CHINESE_CARDINAL})面|(?P<one_meeting>[見见][見见]看|[見见][個个]面)")
    if kind == "utterance_occurrence":
        return re.compile(rf"(?:再添|再加|再補|再补|再[說说])上?(?P<number>{CHINESE_CARDINAL})(?:句|次)")
    if kind == "coffee_cup":
        return re.compile(rf"(?:(?P<number>{CHINESE_CARDINAL})\s*杯|(?P<one_cup>[請请喝這这那]杯))咖啡")
    if kind == "sheet_over":
        return re.compile(rf"(?:超[過过]|不止)(?P<number>{CHINESE_CARDINAL})\s*[張张]")
    if kind == "legal_case_count":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:起|件|個|个)(?:案例|案件)?")
    if kind == "meal_invitation":
        return re.compile(rf"吃\s*(?:(?P<number>{CHINESE_CARDINAL})\s*(?:頓|顿|餐)|(?P<one_meal>個|个|頓|顿))\s*[飯饭]")
    if kind == "next_month":
        return re.compile(r"(?P<next_month>下(?P<number>一)?(?:個|个)月|接下[來来]的?一(?:個|个)月)")
    if kind == "train_vehicle":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:班列[車车]|列[車车]|班火[車车]|列火[車车]|班地[鐵铁]|[輛辆]列[車车])")
    if kind == "cell":
        modifiers = r"(?:灰色|空白|留[給给]人和身[體体]的|[掙挣][錢钱]安排的)?"
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?:(?:個|个){modifiers}格子|(?:個|个)?空[欄栏]|(?:個|个)[欄栏]位|格|欄|栏|列)")
    if kind in {"year", "duration_month"}:
        number = rf"(?:\d+(?:\.\d+)?|{CHINESE_CARDINAL})"
        unit = r"整?年\s*(?P<half>半)?" if kind == "year" else \
            r"(?:個|个)\s*(?:(?P<half_before>半)\s*月|月\s*(?P<half>半)?)"
        half_year = r"|(?P<half_year>半)\s*年" if kind == "year" else ""
        return re.compile(rf"(?<![{NUMERIC_PREFIX_CHARACTERS}])(?:(?P<number>{number})\s*{unit}{half_year})")
    if kind == "young_adult_group":
        return re.compile(r"(?P<number>二三十|20[、，,・/]\s*30)\s*(?:多)?[歲岁]")
    if kind == "single_household":
        return re.compile(rf"(?P<number>單|单|独|獨|{CHINESE_CARDINAL})\s*(?:人家戶|人家庭|人住戶|人住户|人家庭|居)")
    if kind == "secondary_battery":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*次[電电]池")
    if kind == "second_startup":
        return re.compile(rf"第?(?P<number>{CHINESE_CARDINAL})\s*次[創创][業业]")
    if kind == "workweek_days":
        return re.compile(rf"每(?:周|週)(?:工作)?\s*(?P<number>{CHINESE_CARDINAL})\s*天(?:工作制|制)?")
    if kind == "single_market_day":
        return re.compile(rf"(?P<number>單|单|{CHINESE_CARDINAL})\s*(?:日|天)")
    if kind == "photo_pair":
        return re.compile(rf"(?P<number>雙|双|{CHINESE_CARDINAL})\s*(?:個人|个人|人照|人合照)")
    if kind == "daily_frequency":
        return re.compile(rf"(?:(?P<daily>每天|每日)|(?P<number>{CHINESE_CARDINAL})\s*天)")
    if kind == "share":
        return re.compile(
            rf"(?P<number>{CHINESE_CARDINAL})\s*(?:股|單位|单位|份(?=\s*ETF|[，,。]))"
        )
    if kind in {"audience_count", "subscriber_count"}:
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL})\s*(?P<large_unit>萬|万)")
    if kind == "referenced_sentence":
        return re.compile(rf"(?P<number>{CHINESE_CARDINAL}|那|這|这)\s*句(?:話|话)?")
    if kind == "never_occurrence":
        return re.compile(
            rf"(?:(?P<number>{CHINESE_CARDINAL})\s*次(?:也|都)?(?:沒有|没有|沒|没|未)"
            r"|(?P<never>從未(?!來)|从未(?!来)|從來沒有|从来没有))"
        )
    if kind == "parent_pair":
        return re.compile(
            rf"(?:(?P<number>{CHINESE_CARDINAL})\s*(?:位長輩|位长辈|位父母)"
            r"|(?P<named_parents>父[親亲](?:和|與|与)\s*Daeun\s*的母[親亲]))"
        )
    if kind == "monthly_frequency":
        return re.compile(
            rf"(?:(?P<monthly>每(?:個|个)?月)|(?P<number>{CHINESE_CARDINAL})\s*(?:個月|个月))"
        )
    if kind == "repeated_month_interval":
        return re.compile(rf"每(?:隔)?\s*(?P<number>{CHINESE_CARDINAL})\s*(?:個月|个月)")
    if kind == "financial_tier":
        return re.compile(rf"第\s*(?P<number>{CHINESE_CARDINAL})\s*金融圈")
    if kind == "print_copy":
        return re.compile(
            rf"(?<![A-Za-z0-9零〇○一二两兩三四五六七八九十百千萬万億亿])"
            rf"(?P<number>{CHINESE_CARDINAL})\s*(?P<large_unit>萬|万)?\s*(?:冊|册|本)"
        )
    if kind == "ordinal_call":
        return re.compile(
            rf"第\s*(?P<number>{CHINESE_CARDINAL})\s*(?:次|通\s*(?:電話|电话))"
        )
    if kind == "ordinal_line":
        return re.compile(
            rf"(?:第\s*(?P<number>{CHINESE_CARDINAL})\s*(?:行|列|條|条|句)"
            rf"|(?<![第0-9零〇○一二两兩三四五六七八九十百千])(?P<first_line>首行))"
        )
    if kind == "meal":
        # 那頓飯 refers to one previously mentioned meal. Do not generalize
        # demonstratives to amounts or unrelated source counters.
        return re.compile(
            rf"(?<![A-Za-z0-9零〇○一二两兩三四五六七八九十百千])"
            rf"(?P<number>{CHINESE_CARDINAL}|那|這|这)\s*(?:頓|顿|餐)"
            r"|(?P<one_meal>吃\s*[頓顿][飯饭])"
        )
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


def _spending_quantity_valid(kind: str, match: re.Match[str], target: str) -> bool:
    before, after = target[:match.start()], target[match.end():]
    if re.search(r"(?:不到|不足|超過|超过|至少|至多|最多|最少|大約|大约|約|约|並非|并非|不是|不|沒有|没有)\s*$", before):
        return False
    if re.match(r"\s*(?:[%％倍萬万億亿兆]|以上|以下|左右|以內|以内|以外|多|半)", after):
        return False
    end = bool(re.match(r"\s*(?:$|[，。！？、；,.!?;」』）)])", after))
    if kind == "asset_age_decade":
        return match.group("spend_unit") in {"多歲", "多岁"} and bool(re.match(r"(?:如何管理資產|如何管理资产|的資產管理|的资产管理)", after))
    if kind == "monthly_balance_once":
        return not match.group("negative") and match.group("period") in {"每月", "每個月", "每个月", "每一個月", "每一个月"} and match.group("spend_unit") == "次" and end
    if kind == "beer_can_count":
        return match.group("spend_unit") == "罐" and bool(re.search(r"[買买]了$", before)) and end
    if kind == "lottery_match_count":
        return match.group("lotto_match") in {"對中", "对中", "中了"} and match.group("spend_unit") in {"個", "个"} and end
    if kind == "lottery_prize_rank":
        return match.group("spend_unit") in {"等獎", "等奖", "獎", "奖"} and end
    if kind == "gym_card_months":
        return match.group("spend_unit") in {"個月", "个月"} and not before.strip() and end
    if kind == "gym_approx_months":
        return bool(match.group("approx")) and match.group("spend_unit") in {"半月", "月半"} and bool(re.search(r"去了$", before)) and end
    if kind == "first_luck":
        return bool(re.search(r"在首[爾尔]的$", before)) and end
    if kind == "price_gap_pair":
        return bool(re.search(r"\s{2,}[。.]\s*\s{2,}[。.]\s*$", before) and re.match(r"[，,]?\s*差[了着著]", after))
    return False


def _work_quantity_valid(kind: str, match: re.Match[str], target: str) -> bool:
    before, after = target[:match.start()], target[match.end():]
    if re.search(r"(?:不到|不足|超過|超过|至少|至多|最多|最少|大約|大约|約|约|並非|并非|不是|不|沒有|没有)\s*$", before):
        return False
    if re.match(r"\s*(?:[%％倍萬万億亿兆]|以上|以下|左右|以內|以内|以外|多|半)", after):
        return False
    if kind == "coworker_count":
        return bool(re.match(r"\s*(?:$|[，。！？、；,.!?;]|停|頓|顿)", after))
    if kind == "job_posting_count":
        return bool(re.match(r"\s*(?:$|[，。！？、；,.!?;]|讓|让|引起)", after))
    if kind == "subscription_count":
        return bool(re.search(r"取消(?:了)?\s*$", before) and re.match(r"\s*(?:$|[，。！？、；,.!?;])", after))
    if kind == "job_company_focus":
        return bool(re.search(r"(?:專注|专注|鎖定|锁定)\s*$", before) and re.match(r"\s*(?:$|[，。！？、；,.!?;])", after))
    if kind == "study_daily_hours":
        return match.group("period") in {"每天", "每日", "每一天", "每1天"} and match.group("work_unit") in {"小時", "小时", "個小時", "个小时"} and bool(re.match(r"\s*(?:$|[，。！？、；,.!?;])", after))
    if kind == "exam_countdown":
        return bool((match.group("countdown") or match.group("work_unit") in {"天", "日"}) and re.match(r"\s*(?:$|[，。！？、；,.!?;])", after))
    if kind == "tuition_month":
        return match.group("work_unit") == "月" and (not match.group("number") or _chinese_cardinal_value(match.group("number")) == 1) and bool(re.search(r"[學学][費费]\s*$", before) or re.match(r"\s*[學学][費费]", after))
    if kind == "never_course_days":
        negative = match.group("negative") in {"沒", "没", "未"} and _chinese_cardinal_value(match.group("number") or "") == 1
        negative = negative or match.group("once") in {"從沒", "从没", "從未", "从未"}
        return negative and match.group("work_unit") in {"天", "日"} and bool(re.match(r"\s*(?:$|[，。！？、；,.!?;])", after))
    if kind == "work_cup_range":
        return match.group("work_unit") == "杯" and bool(re.search(r"喝\s*$", before)) and bool(re.match(r"\s*(?:$|[，。！？、；,.!?;])", after))
    if kind == "read_mark_over_count":
        return bool(re.match(r"已[讀读]", match.group("read_prefix")) and match.group("read_prefix").endswith(("超過", "超过")) and re.match(r"\s*(?:了)?(?:$|[，。！？、；,.!?;])", after))
    return True


def _match_target_counter_quantities(
    target: str, source_quantities: list[CounterQuantity],
) -> tuple[list[CounterQuantity], list[str]]:
    matched: list[CounterQuantity] = []
    errors: list[str] = []
    cursor = 0
    for expected in source_quantities:
        pattern = _target_pattern_for_kind(expected.kind)
        candidates: list[CounterQuantity] = []
        # Chinese may reorder a count around its page/person complement:
        # attachments, strike-throughs, and this sound-receding image.
        search_start = 0 if expected.kind in {'attachment_count', 'strike_line_count', 'receding_step', 'laughter_once'} else cursor
        for match in pattern.finditer(target, search_start):
            if any(match.start() < row.end and match.end() > row.start for row in matched):
                continue
            if expected.kind in WORK_SCENE_COUNTER_KINDS and not _work_quantity_valid(expected.kind, match, target):
                continue
            if expected.kind in SPENDING_SCENE_COUNTER_KINDS and not _spending_quantity_valid(expected.kind, match, target):
                continue
            if expected.kind in LIFE_SCENE_COUNTER_KINDS:
                number_start = match.start("number") if match.group("number") else match.start()
                if expected.kind == "exam_countdown":
                    number_start = match.start()  # 倒數 is countdown, not a 數-prefix quantity.
                if _has_numeric_sign_prefix(target, match.start()) or _has_numeric_sign_prefix(target, number_start):
                    continue
                if re.match(r"(?:[秒歲岁米年月日天元度人位]|公里|小時|小时|分鐘|分钟|韓元|韩元)", target[match.end():].lstrip()):
                    continue
                if expected.kind in {"chicken_open_hours", "monthly_headache_frequency"} and re.search(
                    r"(?:並非|并非|不是|不再|不曾|不|未|沒|没)\s*$", target[:match.start()],
                ):
                    continue
                if expected.kind in {"microwave_duration", "screen_time_duration", "chicken_open_hours", "monthly_headache_frequency"} and re.match(
                    r"(?:[%％‰‱倍千萬万億亿兆]|以上|以下|左右|上下|以內|以内|以外)", target[match.end():].lstrip(),
                ):
                    continue
                if expected.kind in {"microwave_duration", "screen_time_duration", "chicken_open_hours"} and not re.match(
                    r"\s*(?:$|[，。！？、：；,.!?;:」』）)]|的)", target[match.end():],
                ):
                    # These observed complete display/store phrases may not
                    # consume only the prefix of 秒殺, 分貝/分錢, or 店員/店長.
                    continue
                if expected.kind == "monthly_headache_frequency" and re.search(
                    r"(?:至少|至多|最多|最少|大約|大约|約|约)\s*$", target[:match.start()],
                ):
                    continue
                if expected.kind in {"remaining_four_month", "microwave_duration", "screen_time_duration"} and (
                    re.search(r"(?:不到|不滿|不满|不足|少於|少于|超過|超过|超出|至少|至多|最多|最少|不止|不只|大約|大约|約|约|將近|将近|近|差不多|沒有|没有)\s*$", target[:match.start()])
                    or re.match(r"(?:以上|以下|以內|以内|以外|左右|上下|多|餘|余|半)", target[match.end():].lstrip())
                ):
                    continue
                if expected.kind == "mirror_glance" and not re.search(
                    r"(?:後照鏡|後視鏡|后视镜)(?:裡|里)?看(?:了)?\s*$", target[max(0, match.start() - 24):match.start()],
                ):
                    continue
                if expected.kind == "gangnam_attempt" and not re.search(
                    r"江南(?:[闖闯])?\s*$", target[max(0, match.start() - 12):match.start()],
                ):
                    continue
            if expected.kind == 'laughter_once' and not (
                re.search(r'(?:5|五)年(?:的份|份的笑)\s*$', target[max(0, match.start() - 20):match.start()])
                or re.match(r'笑[盡尽](?:了)?(?:5|五)年', target[match.end():])
            ):
                continue  # The five-year laughter, not an earlier 每一次.
            if expected.kind == 'never_sea_entry' and re.search(
                r'(?:不是|並非|并非|不|非)\s*$', target[:match.start()],
            ):
                continue
            if expected.kind == 'duration_month_over' and re.search(
                r'(?:不|未|沒|没|沒有|没有|不曾|並非|并非|不到|少於|少于)\s*$', target[:match.start()],
            ):
                continue
            if expected.kind in {'duration_month_over', 'missed_call'} and re.match(
                r"(?:[秒歲岁米年月日天元度人位]|公里|小時|小时|分鐘|分钟|韓元|韩元)",
                target[match.end():].lstrip(),
            ):
                continue
            if expected.kind in {"seat_row", "brightness_level", "comparison_people", "household_pair", "branch_count", "hotel_star_rating", "can_sound_occurrence", "glass_pane", "amusement_ride_count", "petal_count", "turned_look_count", "laughter_once", "small_coffee_can", "stay_night", "ordinal_meeting", "never_sea_entry", "graduation_anniversary", "per_person_bill", "resume_edit_place", "station_exit", "topic_pair", "video_duration_minute", "outing_round", "story_pair", "rice_bowl", "age_decade_unspecified"} \
                    and re.match(r"(?:[秒歲岁米年月日天元度人位]|公里|小時|小时|分鐘|分钟|韓元|韩元)", target[match.end():].lstrip()):
                continue
            if expected.kind in {"age_over", "approximate_age", "degree"} and re.match(
                r"(?:天|年|小時|小时|分鐘|分钟|秒|人|位|韓元|韩元|元|圓|圆|公里|米|度|角)",
                target[match.end():].lstrip(),
            ):
                continue
            if expected.kind in {"remaining_notice", "family_commitment", "action_pair", "call_action_count", "appointment_place", "question_set"} \
                    and re.search(r"[個个項项]$", match.group()) and re.match(
                        r"(?:人|位|小時|小时|分鐘|分钟|秒|年|月|日|週|周|天|韓元|韩元|元|公里|米)",
                        target[match.end():].lstrip(),
                    ):
                # A referential classifier is not permission to substitute a
                # person, duration, distance or money unit for the source object.
                continue
            if expected.kind in {
                "young_adult_group", "single_household", "secondary_battery", "second_startup",
                "workweek_days", "single_market_day", "photo_pair", "age",
                "year", "duration_month", "duration_day",
                "cell", "train_vehicle", "coffee_cup", "legal_case_count", "sheet_over",
                "meeting_invitation", "per_character", "address_count", "utterance_occurrence",
                "next_month", "meal_invitation",
                "concept_pair",
                "arrival_record", "openable_pair", "breath_occurrence", "ordinal_sheet", "ordinal_night",
                "running_distance", "referenced_sheet",
                "phone_call", "cup", "file_count", "world_count", "record_pair",
                "promise_count", "record_count", "blank_cell_count", "notice_count", "counter_window_count",
                "time_point_count", "place_count", "family_commitment", "judged_month", "per_line", "phone_occurrence",
                "contact_window_count", "contact_target_count", "deadline_count", "issuer_count", "remaining_notice",
                "appointment_place", "commitment_place", "reopened_slot", "drawn_line", "honorific_people", "unsent_character", "action_pair", "soup_count",
                "branch_count", "call_action_count", "finger_sequence", "sound_occurrence", "contact_priority", "feeling_pair", "immutable_fact_pair",
                "chapter_reference", "receipt_identifier", "version_count", "screen_count", "speech_bubble_count",
                "attachment_count", "send_button_count", "property_listing_count", "never_drink_occurrence",
                "number_count", "source_count", "video_clip_count", "observation_time_count", "question_set", "date_count", "counted_beat_sequence", "character",
                "current_action_count", "read_again", "never_skip_week", "statement_pair", "cover_count", "cup_noodles_count", "never_utterance", "name_column_count", "chair", "sheet", "sunday_count",
                "object_count", "result_count", "ledger_count", "meaning_count", "signature_option_count",
                "door_count", "retained_pair", "strike_line_count", "strike_occurrence", "meal", "appliance_cycle", "agreement_parties", "city_count",
                "approximate_occurrence", "approximate_age", "age_over", "degree", "one_plus_one_offer", "span",
                "never_toss_turn", "receding_step", "ring_occurrence",
                "seat_row", "brightness_level", "comparison_people", "household_pair", "hotel_star_rating",
                "can_sound_occurrence", "glass_pane", "amusement_ride_count",
                "graduation_anniversary", "per_person_bill",
                "resume_edit_place", "station_exit", "topic_pair", "video_duration_minute",
                "outing_round",
                "story_pair",
                "rice_bowl", "age_decade_unspecified",
                "duration_month_over", "missed_call",
                "soup_sip", "tea_sip",
                "petal_count", "turned_look_count",
                "laughter_once", "small_coffee_can", "stay_night", "ordinal_meeting", "never_sea_entry",
                "case_number_digits", "registry_line", "once_condition", "visual_overlap", "ladder_step", "window_count", "parallel_fact",
            } and re.search(rf"[{NUMERIC_PREFIX_CHARACTERS}]\s*$", target[:match.start()]):
                # 再點一杯 is the observed ordering verb, not a decimal prefix.
                # Negative counts and 十點兩個杯子 must still be rejected.
                if not (expected.kind == "cup" and re.search(r"再[點点]\s*$", target[:match.start()])):
                    continue
            if expected.kind == "share" and match.group(0).endswith("份") and re.match(
                r"\s*ETF\s*(?:的\s*)?(?:文件|報告|报告|合同|合約|合约|契約|契约|資料|资料|說明|说明|表格)",
                target[match.end():],
            ):
                continue
            if expected.kind == "share" and match.group(0).endswith("份") \
                    and not re.match(r"\s*ETF\b", target[match.end():]):
                # A bare referential 那一份 needs an earlier matched ETF unit.
                # A document 一份, even beside a mention of ETF, is not a share.
                if not re.search(r"那\s*$", target[:match.start()]) or not any(
                    previous.kind == "share" for previous in matched
                ):
                    continue
            if expected.kind in {"audience_count", "subscriber_count"}:
                following = target[match.end():].lstrip()
                if re.match(
                    r"(?:股|股份|單位|单位|份|文件|年|月|天|週|周|秒|小時|小时|公里|米|坪|棟|栋|套|韓元|韩元)",
                    following,
                ):
                    continue
                if expected.kind == "subscriber_count" and not (
                    re.search(r"(?:訂閱人數|订阅人数|訂閱者|订阅者)\s*[：:]?\s*$", target[:match.start()])
                    or re.match(r"(?:訂閱人數|订阅人数|訂閱者|订阅者)", following)
                ):
                    continue
            if expected.kind == "look_occurrence" and match.group(0).endswith("眼") \
                    and not re.search(
                        r"(?:看|瞥|望)(?:了|過|过)?(?:\{name\})?\s*$",
                        target[max(0, match.start() - 16):match.start()],
                    ):
                # 一眼 is a glance after a seeing verb, not one physical eye.
                continue
            value = _chinese_cardinal_value(match.group("number") or "")
            if expected.kind == "price_gap_pair" and match.group("pair"):
                value = Decimal(2)
            if expected.kind == "gym_approx_months" and value is not None:
                value += Decimal("0.5")
            if expected.kind == "work_cup_range":
                lexical_range = match.group("number") in {"一兩", "一两"} and not match.group("upper")
                numeric_range = value == 1 and _chinese_cardinal_value(match.group("upper") or "") == 2
                value = Decimal(1) if lexical_range or numeric_range else None
            if expected.kind == "exam_countdown" and match.group("countdown"):
                value = _chinese_cardinal_value(match.group("countdown"))
            if expected.kind == "tuition_month" and not match.group("number"):
                value = Decimal(1)
            if expected.kind == "never_course_days":
                value = _chinese_cardinal_value(match.group("course_days"))
            if expected.kind in {"microwave_duration", "screen_time_duration"}:
                minor = _chinese_cardinal_value(match.group("seconds" if expected.kind == "microwave_duration" else "minutes"))
                value = value * 60 + minor if value is not None and minor is not None and 0 <= minor < 60 else None
            if expected.kind == "monthly_headache_frequency":
                value = Decimal(1) if match.group("number") in {"一兩", "一两"} or (
                    _chinese_cardinal_value(match.group("range_start") or "") == 1
                    and _chinese_cardinal_value(match.group("range_end") or "") == 2
                ) else None
            if expected.kind == "age_over" and match.groupdict().get("over_age"):
                value = _chinese_cardinal_value(match.group("over_age"))
            if expected.kind == "duration_month_over" and match.groupdict().get("over_month"):
                value = _chinese_cardinal_value(match.group("over_month"))
            if expected.kind == "degree" and match.group("number") == "半":
                value = Decimal("0.5")
            if expected.kind == "one_plus_one_offer":
                value = Decimal(1)
            if expected.kind == "never_toss_turn" and match.groupdict().get("never_toss"):
                value = Decimal(1)
            if expected.kind == "never_toss_turn" and match.groupdict().get("toss_number"):
                value = _chinese_cardinal_value(match.group("toss_number"))
            if expected.kind in {'read_again', 'never_skip_week', 'never_utterance', 'never_sea_entry', 'per_person_bill', 'restaurant_per_person', 'gangnam_attempt', 'soup_sip', 'tea_sip'} and match.groupdict().get('once'):
                value = Decimal(1)
            if expected.kind == 'never_skip_week' and match.groupdict().get('after'):
                value = _chinese_cardinal_value(match.group('after'))
            if expected.kind == "feeling_pair" and match.groupdict().get("either_side"):
                value = Decimal(2)
            if expected.kind == "once_condition" and match.groupdict().get("once_condition"):
                value = Decimal(1)
            if expected.kind == "year" and match.groupdict().get("half_year"):
                value = Decimal("0.5")
            if expected.kind in {"referenced_sheet", "phone_call"} and match.group("number") in {"那", "這", "这"}:
                value = Decimal(1)
            if match.groupdict().get("first_sheet") \
                    or match.groupdict().get("one_breath"):
                value = Decimal(1)
            if expected.kind == "young_adult_group":
                value = Decimal(2030)
            if expected.kind in {"single_household", "single_market_day"} and match.group("number") in {"單", "单", "独", "獨"}:
                value = Decimal(1)
            if expected.kind == "next_month" and match.groupdict().get("next_month"):
                value = Decimal(1)
            if expected.kind in {"meal_invitation", "meal"} and match.groupdict().get("one_meal"):
                value = Decimal(1)
            if expected.kind == "coffee_cup" and match.groupdict().get("one_cup"):
                value = Decimal(1)
            if expected.kind == "per_character" and match.groupdict().get("per_character"):
                value = Decimal(1)
            if expected.kind == "per_line" and match.groupdict().get("per_line"):
                value = Decimal(1)
            if expected.kind == "meeting_invitation" and match.groupdict().get("one_meeting"):
                value = Decimal(1)
            if expected.kind == "photo_pair" and match.group("number") in {"雙", "双"}:
                value = Decimal(2)
            if expected.kind == "monthly_frequency" and match.groupdict().get("monthly"):
                value = Decimal(1)
            if expected.kind == "agreement_parties" and match.groupdict().get("pair"):
                value = Decimal(2)
            if expected.kind == "daily_frequency" and match.groupdict().get("daily"):
                value = Decimal(1)
            if expected.kind == "parent_pair" and match.groupdict().get("named_parents"):
                value = Decimal(2)
            if expected.kind in {"print_copy", "audience_count", "subscriber_count"} and match.groupdict().get("large_unit"):
                value = value * 10_000 if value is not None else None
            if expected.kind == "never_occurrence" and match.groupdict().get("never"):
                value = Decimal(1)
            if expected.kind == "referenced_sentence" and match.group("number") in {"那", "這", "这"}:
                value = Decimal(1)
            if expected.kind == "ordinal_line" and match.groupdict().get("first_line"):
                value = Decimal(1)
            if expected.kind == "meal" and match.group("number") in {"那", "這", "这"}:
                value = Decimal(1)
            if value is not None and (match.groupdict().get("half") or match.groupdict().get("half_before")):
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
        # Chinese places 两个 before its age modifier 过了三十. The source's
        # adjacent age/person pair must retain both counts despite that order.
        if expected.kind not in {'attachment_count', 'strike_line_count', 'receding_step', 'age_over', 'laughter_once'}:
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
    for kind in {q.kind for q in source_quantities} & LIFE_SCENE_COUNTER_KINDS:
        for match in _target_pattern_for_kind(kind).finditer(target):
            if kind == "job_posting_count" and any(
                q.kind == "entity" and q.start == match.start()
                and q.value == _chinese_cardinal_value(match.group("number")) for q in matched
            ):
                continue  # The separate source application count owns 兩個職缺.
            if not any(q.start <= match.start() and match.end() <= q.end for q in matched):
                errors.append(f"unmatched life-scene quantity: {kind}")
    if any(q.kind == "monthly_headache_frequency" for q in source_quantities):
        # The new monthly range must not borrow a later correct expression
        # after a changed count, period, unit, or negated occurrence. Scan the
        # whole witnessed frequency, not just the accepted one-to-two form.
        for match in re.finditer(
            rf"每(?:{CHINESE_CARDINAL})?[個个]?(?:小時|小时|分鐘|分钟|秒|月|年|週|周|天|日)[^，。；;\n]*?"
            rf"{CHINESE_CARDINAL}(?:\s*[~～至到-]\s*{CHINESE_CARDINAL})?"
            r"\s*(?:次|年|月|週|周|日|天|小時|小时|分鐘|分钟|分|秒|米|元|人)",
            target,
        ):
            if not any(q.start <= match.start() and match.end() <= q.end for q in matched):
                errors.append("unmatched monthly headache frequency")
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
    if any(q.kind == "young_adult_group" for q in source_quantities):
        for match in re.finditer(rf"{CHINESE_CARDINAL}\s*(?:多)?[歲岁]", target):
            if not any(q.start <= match.start() and match.end() <= q.end for q in matched):
                errors.append("unmatched catalogue target age invented")
    if any(q.kind == "workweek_days" for q in source_quantities):
        for match in re.finditer(rf"{CHINESE_CARDINAL}\s*(?:天|週|周|月|年)", target):
            if not any(q.start <= match.start() and match.end() <= q.end for q in matched):
                errors.append("unmatched catalogue target workweek quantity invented")
    if any(q.kind in {
        "young_adult_group", "workweek_days", "run_occurrence", "single_household",
        "secondary_battery", "second_startup", "photo_pair", "single_market_day",
    } for q in source_quantities):
        rest = _mask_spans(target, matched)
        for match in re.finditer(r"[零〇○一二两兩三四五六七八九十百千]+", rest):
            value = _chinese_cardinal_value(match.group())
            # Chinese may naturally introduce one classifier (那一晚 / 一起).
            # New catalogue normalizations may not hide extra plural numbers.
            if value is not None and value > 1:
                errors.append("unmatched catalogue native quantity invented")
    return errors


def _overlaps(amounts: list[MoneyAmount], start: int, end: int) -> bool:
    return any(start < amount.end and end > amount.start for amount in amounts)


def _mixed_manwon_value(match: re.Match[str]) -> Decimal:
    eok = match.group('eok') or '0'
    thousand = match.group('thousand')
    sign = -1 if eok.startswith('-') or thousand.startswith('-') else 1
    return Decimal(sign * (abs(int(eok)) * 100_000_000
        + abs(int(thousand)) * 10_000_000 + int(match.group('hundred')) * 1_000_000))


def _source_money_amounts(source: str) -> list[MoneyAmount]:
    amounts: list[MoneyAmount] = []
    # The purchase choice uses the mathematical minus U+2212, not an unsigned
    # amount preceded by an unsupported sign. Retain its sign and whole span.
    for match in re.finditer(r"(?<=산다 — 한 번쯤은 \()−(?P<number>\d[\d,]*)원(?=\)$)", source):
        amounts.append(MoneyAmount(match.start(), match.end(), -Decimal(match.group("number").replace(",", ""))))
    # The observed bill spells one sum across two units, not two transfers.
    # Keep the full amount span so neither component leaks into bare numbers.
    for match in re.finditer(r"(?<=1인당 )4만 5천원(?=이 나왔다)", source):
        amounts.append(MoneyAmount(match.start(), match.end(), Decimal(45000)))
    for match in SOURCE_MIXED_MANWON.finditer(source):
        amounts.append(MoneyAmount(match.start(), match.end(), _mixed_manwon_value(match)))
    if source.strip() == "첫 억":
        start = source.index("억")
        amounts.append(MoneyAmount(start, start + 1, Decimal(100_000_000)))
    for match in SOURCE_EOK_MONEY.finditer(source):
        if _overlaps(amounts, match.start(), match.end()):
            continue
        following = source[match.end():]
        if not match.group().endswith('원') and not following.startswith("원") and NON_MONEY_COUNTER.match(following):
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
            "조": Decimal(1_000_000_000_000),
            "천": Decimal(1_000),
            "만": Decimal(10_000),
            "천만": Decimal(10_000_000),
            "백만": Decimal(1_000_000),
        }[match.group("unit")]
        amounts.append(MoneyAmount(
            match.start(), match.end(), number * multiplier
        ))

    for match in SOURCE_WORD_MONEY.finditer(source):
        if _overlaps(amounts, match.start(), match.end()):
            continue
        if match.group() == "이 원" and source[:match.start()].endswith("{name}") \
                and source[match.start():].startswith("이 원하는 것을 본인보다 먼저 알고 있었다."):
            continue  # Subject particle + 원하는 (wants), not two won.
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
        if any(
            book.start("number") <= match.start() < match.end() <= book.end()
            for book in SOURCE_PRINT_RUN.finditer(source)
        ):
            # Only the explicit first-printing + copies construction; no won
            # label is removed and the full copy value is checked separately.
            continue
        if any(q.start <= match.start() < match.end() <= q.end
               for q in _source_audience_quantities(source)):
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
    signed = []
    for amount in amounts:
        prefix = re.search(r"(?<![가-힣])마이너스\s+$", source[:amount.start])
        signed.append(MoneyAmount(prefix.start(), amount.end, -amount.won)
                      if prefix and amount.won >= 0 else amount)
    return sorted(signed, key=lambda amount: amount.start)


def _target_money_amounts(target: str) -> list[MoneyAmount]:
    multipliers = {
        None: Decimal(1),
        "兆": Decimal(1_000_000_000_000),
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
    # Fully delimited observed native thousand-won amounts. Do not take the tail of
    # a larger/native decimal amount, and retain the sign in value comparison.
    for match in re.finditer(r"(?P<sign>[+\-−﹣－負负])?\s*(?P<thousands>一|五)千(?:韩元|韓元)", target):
        if _has_numeric_sign_prefix(target, match.start()):
            continue
        if re.match(r"(?:[%％‰‱倍千萬万億亿兆秒歲岁米年月日天元度人位]|公里|小時|小时|分鐘|分钟)", target[match.end():].lstrip()):
            continue
        sign = -1 if match.group("sign") in {"-", "−", "﹣", "－", "負", "负"} else 1
        amounts.append(MoneyAmount(match.start(), match.end(), Decimal(sign * {"一": 1000, "五": 5000}[match.group("thousands")])))
    for match in re.finditer(r"(?<![零〇一二两兩三四五六七八九十百千萬万億亿兆點点.])(?P<sign>[+\-−﹣－負负])?\s*一(?:個|个)?[亿億](?:韩元|韓元)", target):
        if re.search(rf"[{NUMERIC_PREFIX_CHARACTERS}]\s*$", target[:match.start()]):
            continue
        sign = -1 if match.group("sign") in {"-", "−", "﹣", "－", "負", "负"} else 1
        amounts.append(MoneyAmount(match.start(), match.end(), Decimal(sign * 100_000_000)))
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
    signed = []
    for amount in amounts:
        prefix = re.search(r"[負负−﹣－]\s*$", target[:amount.start])
        signed.append(MoneyAmount(prefix.start(), amount.end, -amount.won)
                      if prefix and amount.won >= 0 else amount)
    return sorted(signed, key=lambda amount: amount.start)


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


def _has_numeric_sign_prefix(text: str, start: int) -> bool:
    # A sentence-final period before a new paragraph is not a decimal prefix.
    # A numeric dot (十. 500) and separated signs/magnitudes still are.
    return bool(re.search(
        rf"[{NUMERIC_PREFIX_CHARACTERS.replace('.', '')}]\s*$|"
        r"[0-9零〇○一二两兩三四五六七八九十百千]\.\s*$", text[:start],
    ))


def _numeric_errors(source: str, target: str) -> list[str]:
    errors: list[str] = []
    if re.search(r"\d{1,2}[:：]\d{2}", source):
        for timecode in re.finditer(r"(?<!\d)\d{1,2}[:：]\d{2}(?!\d)", target):
            if _has_numeric_sign_prefix(target, timecode.start()):
                errors.append("timecode numeric/sign prefix is unsupported")
    if '메가바이트' in source:
        source_sizes = list(re.finditer(rf"(?P<number>{DECIMAL_LITERAL})\s*메가바이트", source))
        target_sizes = list(re.finditer(
            rf"(?P<number>{DECIMAL_LITERAL})\s*(?:MB(?![A-Za-z])|兆位元組|兆字節|兆字节)", target))
        if [m.group('number') for m in source_sizes] != [m.group('number') for m in target_sizes] \
                or any(_has_numeric_sign_prefix(target, m.start()) for m in target_sizes):
            errors.append("megabyte value/sign/unit mismatch")
    approximate_labels = 0
    approximate_source = source
    approximate_target = target
    for source_pattern, target_pattern in CATALOG_APPROXIMATE_WON:
        source_matches = list(source_pattern.finditer(source))
        target_matches = list(target_pattern.finditer(target))
        if any(re.search(r"[+\-−﹣－負负]\s*$", source[:m.start()]) for m in source_matches) \
                or any(re.search(r"[+\-−﹣－負负]\s*$", target[:m.start()]) for m in target_matches):
            errors.append("signed approximate Korean-won amount is unsupported")
        if any(re.search(rf"[{NUMERIC_PREFIX_CHARACTERS}]\s*$", target[:m.start()]) for m in target_matches):
            errors.append("approximate Korean-won numeric prefix is unsupported")
        if len(source_matches) != len(target_matches):
            errors.append("approximate Korean-won magnitude missing/invented")
        approximate_labels += min(len(source_matches), len(target_matches))
        approximate_source = source_pattern.sub(lambda m: " " * len(m.group()), approximate_source)
        approximate_target = target_pattern.sub(lambda m: " " * len(m.group()), approximate_target)
    source_amounts = _source_money_amounts(source)
    target_amounts = _target_money_amounts(target)
    for money_text, amounts in ((source, source_amounts), (target, target_amounts)):
        for amount in amounts:
            if not _has_numeric_sign_prefix(money_text, amount.start):
                continue
            if money_text == target and "그녀는 6,500원짜리 라떼를" in source \
                    and re.search(r"她[點点]$", target[:amount.start]) \
                    and re.match(r"的(?:拿鐵|拿铁)", target[amount.end:]):
                continue  # The observed ordering verb, not a decimal point.
            errors.append("Korean-won numeric/sign prefix is unsupported")
    source_values = [amount.won for amount in source_amounts]
    target_values = [amount.won for amount in target_amounts]
    if source_values != target_values:
        errors.append(
            f"Korean-won values changed: {source_values} != {target_values}"
        )
    target_label_count = len(re.findall(r"韩元|韓元", target))
    rhetorical_source = len(SOURCE_RHETORICAL_WON.findall(source))
    rhetorical_target = len(TARGET_RHETORICAL_WON.findall(target))
    if rhetorical_source != rhetorical_target:
        errors.append("rhetorical Korean-won phrase missing/invented")
    # A literal amount still needs its own label. Only the observed, source-
    # bound 어떤 원화도 construction can own an additional nonnumeric label.
    expected_labels = len(target_amounts) + min(rhetorical_source, rhetorical_target) + approximate_labels
    if (source_amounts or target_amounts or rhetorical_source or approximate_labels) and target_label_count != expected_labels:
        errors.append(
            f"Korean-won label count/topology mismatch "
            f"{target_label_count} != {expected_labels}"
        )

    source_quantities = _source_counter_quantities(
        _mask_spans(source, source_amounts)
    )
    counter_target = _mask_spans(approximate_target, target_amounts)
    # 周六兩點 is Saturday at two, never sixty-two o'clock. Verify the
    # weekday separately, then mask it before matching adjacent clock digits.
    ko_weekdays = {day + "요일": i + 1 for i, day in enumerate("월화수목금토일")}
    source_weekdays = [ko_weekdays[m.group()] for m in re.finditer(r"[월화수목금토일]요일", source)]
    target_weekdays = list(re.finditer(r"(?:星期|禮拜|礼拜|週|周)([一二三四五六日天1-7])", target))
    if source_weekdays:
        digits = dict(zip("一二三四五六日天1234567", [1, 2, 3, 4, 5, 6, 7, 7, 1, 2, 3, 4, 5, 6, 7]))
        if source_weekdays != [digits[m.group(1)] for m in target_weekdays]:
            errors.append("weekday sequence changed")
        for day in reversed(target_weekdays):
            if day.group(1) in "日天7" and any(q.kind == "sunday_count" for q in source_quantities):
                continue  # This counted Sunday retains its noun for typed matching.
            counter_target = counter_target[:day.start()] + " " * (day.end() - day.start()) + counter_target[day.end():]
    target_quantities, counter_errors = _match_target_counter_quantities(counter_target, source_quantities)
    errors.extend(counter_errors)
    offers = [q for q in source_quantities if q.kind == "one_plus_one_offer"]
    if offers and len(list(_target_pattern_for_kind("one_plus_one_offer").finditer(counter_target))) != len(offers):
        errors.append("one-plus-one offer count missing/invented")
    if offers:
        for offer in re.finditer(rf"[買买](?P<buy>{CHINESE_CARDINAL})[送贈赠](?P<free>{CHINESE_CARDINAL})", counter_target):
            if any(_chinese_cardinal_value(offer.group(part)) != 1 for part in ("buy", "free")):
                errors.append("one-plus-one offer quantities changed")
            if re.match(r"(?:元|圓|圆|人|位|歲|岁|天|年|米|度)", counter_target[offer.end():].lstrip()):
                errors.append("one-plus-one offer unit changed")
    errors.extend(_unexpected_target_entity_errors(
        counter_target, source_quantities,
        target_quantities,
    ))

    source_rest = _mask_spans(
        _mask_spans(approximate_source, source_amounts), source_quantities
    )
    target_rest = _mask_spans(
        counter_target, target_quantities
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
        if any(q.start <= match.start() < match.end() <= q.end
               for q in _source_audience_quantities(source)):
            continue
        if any(
            book.start("number") <= match.start() < match.end() <= book.end()
            for book in SOURCE_PRINT_RUN.finditer(source)
        ):
            continue
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
    has_won = bool(KOREAN_WON.search(source) or _source_money_amounts(source)
                   or any(pattern.search(source) for pattern, _ in CATALOG_APPROXIMATE_WON))
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


def _untranslated_english_errors(source: str, target: str, *, catalog: bool = False) -> list[str]:
    scrubbed = PLACEHOLDER.sub(" ", target)
    # Observed secondhand-listing prose, not the vegetable or a global brand
    # exception. Official identities: github.com/daangn/websites; daangn.com.
    if re.search(r"(?<![가-힣])당근에 물건을 올렸더니 댓글이 달렸다\.", source):
        for prepared in ("Daangn", "Karrot"):
            for match in reversed(_bounded_latin_matches(scrubbed, prepared)):
                scrubbed = scrubbed[:match.start()] + " " + scrubbed[match.end():]
    # Keep this composite index identifier whole. The generic token scanner
    # includes the Korean source's trailing ASCII period in P500. otherwise.
    if _bounded_latin_matches(re.sub(r"(?<![가-힣])미국(?=S&P500)", "", source), "S&P500"):
        for match in reversed(_bounded_latin_matches(scrubbed, "S&P500")):
            scrubbed = scrubbed[:match.start()] + " " + scrubbed[match.end():]
    for source_pattern, romanized in WORK_SOURCE_BRANDS:
        if source_pattern.search(source):
            matches = list(_bounded_latin_matches(scrubbed, romanized))
            if not matches:
                return [f"source-bound work brand missing/changed: {romanized}"]
            for match in reversed(matches):
                scrubbed = scrubbed[:match.start()] + " " + scrubbed[match.end():]
    for pattern, romanized in RELATIONSHIP_SOURCE_NAMES:
        if pattern.search(source):
            for match in reversed(_bounded_latin_matches(scrubbed, romanized)):
                scrubbed = scrubbed[:match.start()] + " " + scrubbed[match.end():]
    if '메가바이트' in source:
        scrubbed = re.sub(r'(?<![A-Za-z])MB(?![A-Za-z])', ' ', scrubbed)
    for phrase in sorted(CATALOG_LATIN_ALIASES.get(source.strip(), ()) if catalog else (), key=len, reverse=True):
        scrubbed = re.sub(rf"(?<![A-Za-z0-9]){re.escape(phrase)}(?![A-Za-z0-9])", " ", scrubbed)
    if re.search(r"(?<![가-힣])임\.\s*상\.\s*철\.", source):
        # The father revelation deliberately spells the established name in
        # three beats. Preserve that acting without allowing Sang/Chul alone.
        scrubbed = re.sub(r"(?<![A-Za-z0-9])Im[.。]\s*Sang[.。]\s*Chul[.。](?![A-Za-z0-9])", " ", scrubbed)
    if SOURCE_IM_SURNAME.search(source):
        # A source-bound surname, not a globally allowed English word/prefix.
        scrubbed = re.sub(r"(?<![A-Za-z0-9])Im(?![A-Za-z0-9])", " ", scrubbed)
    if SOURCE_KIM_SURNAME.search(source):
        scrubbed = re.sub(r"(?<![A-Za-z0-9])Kim(?![A-Za-z0-9])", " ", scrubbed)
    if SOURCE_HAN_CHAIRMAN.search(source):
        for match in reversed(_han_surname_matches(scrubbed)):
            scrubbed = scrubbed[:match.start()] + " " + scrubbed[match.end():]
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
    for korean, phrase in {**SOURCE_SCOPED_LATIN_TERMS, **SOURCE_OPTIONAL_LATIN_TERMS}.items():
        source_has_term = bool(SOURCE_APP_TERM.search(source)) if korean == "앱" else _source_scoped_term_present(source, korean)
        if source_has_term:
            # Case and spacing are part of the locked prepared form.
            for prepared in (phrase.values() if isinstance(phrase, dict) else (phrase,)):
                if korean in {"앱", "링크드인", "인스타", "인스타그램", "슬랙"}:
                    for match in reversed(_bounded_latin_matches(scrubbed, prepared)):
                        scrubbed = scrubbed[:match.start()] + " " + scrubbed[match.end():]
                else:
                    scrubbed = re.sub(
                        rf"(?<![A-Za-z0-9]){re.escape(prepared)}(?![A-Za-z0-9])",
                        " ", scrubbed,
                    )
    if SOURCE_XRAY_TERM.search(source):
        # Only the complete medical noun, not arbitrary X-prefixed Chinese.
        for match in reversed(_bounded_latin_matches(scrubbed, "X光")):
            if re.match(r"\s*(?:$|[，。！？、：；,.!?;:」』）)]|檢查|检查|片)", scrubbed[match.end():]):
                scrubbed = scrubbed[:match.start()] + " " + scrubbed[match.end():]
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
    catalog_context = key.startswith("catalog:")
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
            and not _allows_latin_only(source, target, catalog=catalog_context):
        errors.append("no Chinese Han glyphs in translated Korean source")
    errors.extend(_script_errors(lang, target))
    errors.extend(_terminology_errors(lang, source, target))
    errors.extend(_money_errors(lang, source, target))
    errors.extend(_untranslated_english_errors(source, target, catalog=catalog_context))
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
    parameter_contract = manifest.get("ui_parameterized_template_plan", {})
    final_inventory = parameter_contract.get(
        "source_inventory_phases", {}
    ).get("final", {}) if isinstance(parameter_contract, dict) else {}
    expected = {
        "source_language": "ko",
        "automatic_script_conversion": False,
        "body_translation": "held_until_explicit_demo_GO",
        "shipping": False,
        "static_ui_source_count": final_inventory.get(
            "legacy_korean_source_keys"
        ),
        "static_ui_source_keys_sha256": final_inventory.get(
            "legacy_korean_source_keys_sha256"
        ),
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


def _story_demo_exclusive_ui_pairs(
    runtime: dict[str, Any], inventory: UiInventory,
) -> tuple[dict[str, Any], list[str]]:
    """Collect only story-demo UI strings that have no older UI owner."""
    import story_demo_localization_audit as story_demo

    pairs, errors, _counts = story_demo.ui_pairs()
    existing_owners = (
        set(inventory.legacy_blueprint)
        | set(inventory.planned_context_blueprint)
        | set(runtime["merged_pairs"])
    )
    exclusive = {
        source: pair
        for source, pair in pairs.items()
        if source not in existing_owners
    }
    if len(exclusive) != EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS:
        errors.append(
            f"story-demo exclusive UI source count {len(exclusive)} != "
            f"{EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS}"
        )
    return exclusive, errors


def static_ui_coverage(
    lang: str, runtime: dict[str, Any], strict: bool,
    actual_override: Optional[dict[str, Any]] = None,
    raw_text_override: Optional[str] = None,
) -> tuple[int, int, int, int, int, int, list[str]]:
    inventory = _static_ui_inventory()
    legacy_entries = {entry.source: entry for entry in inventory.legacy_entries}
    context_entries = {
        entry.context_id: entry for entry in inventory.planned_context_entries
    }
    expected_legacy = set(inventory.legacy_blueprint)
    expected_context = set(inventory.planned_context_blueprint)
    # The isolated M01-M06 controller is not part of the legacy retail UI
    # denominator. Derive its exact owner set from the strict source collector
    # on every audit instead of copying those Korean strings into a whitelist.
    import story_demo_localization_audit as story_demo

    story_demo_pairs, story_source_errors = _story_demo_exclusive_ui_pairs(
        runtime, inventory
    )
    story_demo_exclusive_keys = set(story_demo_pairs)
    source_errors = [
        f"{lang}:story-demo-ui source: {error}"
        for error in story_source_errors
    ]
    dynamic_keys = set(runtime["merged_pairs"])
    ui_path = ROOT / "locale" / f"ui_{lang}.json"
    duplicate_keys: list[str] = []
    if raw_text_override is not None:
        duplicate_keys = duplicate_json_object_keys_from_text(raw_text_override)
    elif actual_override is None and ui_path.is_file():
        duplicate_keys = duplicate_json_object_keys(ui_path)
    if duplicate_keys:
        return (
            0, len(expected_legacy), 0, len(expected_context),
            0, len(story_demo_exclusive_keys),
            source_errors + [
                f"{lang}:ui: duplicate raw JSON keys {duplicate_keys[:12]}"
            ],
        )
    actual = actual_override
    if actual is None:
        actual = read_json(ui_path) if ui_path.is_file() else {}
    errors: list[str] = list(source_errors)
    if not isinstance(actual, dict):
        return (
            0, len(expected_legacy), 0, len(expected_context),
            0, len(story_demo_exclusive_keys),
            errors + [f"{ui_path.relative_to(ROOT)}: expected object"],
        )

    allowed = (
        expected_legacy | expected_context | dynamic_keys
        | story_demo_exclusive_keys
    )
    unknown = sorted(set(actual) - allowed)
    if unknown:
        errors.append(
            f"{lang}:ui: unknown source keys count={len(unknown)} "
            f"preview={unknown[:8]}"
        )
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
    story_demo_covered = 0
    for source in sorted(story_demo_exclusive_keys):
        if source not in actual:
            continue
        target = actual[source]
        if not isinstance(target, str) or not target.strip():
            errors.append(
                f"{lang}:story-demo-ui:{source!r}: empty/non-string translation"
            )
            continue
        story_demo_covered += 1
        pair = story_demo_pairs[source]
        entry_key = (
            "story-demo-ui::"
            + hashlib.sha1(source.encode("utf-8")).hexdigest()[:12]
        )
        for error in story_demo.target_text_errors(
            lang,
            entry_key,
            source,
            target,
            format_template=pair.format_template,
            english=pair.english,
        ):
            errors.append(f"{lang}:{entry_key}: {error}")
    if story_demo_covered != len(story_demo_exclusive_keys):
        errors.append(
            f"{lang}: required story-demo UI coverage "
            f"{story_demo_covered}/{len(story_demo_exclusive_keys)}"
        )
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
        story_demo_covered,
        len(story_demo_exclusive_keys),
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


def _life_scene_parser_self_test() -> tuple[int, list[str]]:
    """Observed life-scene repairs: quantity guards, not event-ID exemptions."""
    cases = 0
    failures: list[str] = []

    def numeric(label: str, source: str, target: str, valid: bool) -> None:
        nonlocal cases
        cases += 1
        errors = _numeric_errors(source, target)
        if bool(errors) == valid:
            failures.append(f"life-scene {label}: valid={valid}, got {errors}")

    # Keep each relevant sentence intact; full current leaves are separately
    # checked by the source-bound localization importer. Each mutation below
    # must start with a passing normal control, never an unrelated token error.
    fixtures = (
        ("months", "끝까지 넉 달이 남아 있었다.", "離終點還有四個月。", "四個月", "四", "remaining_four_month"),
        ("jobs", "눈에 띄는 공고 두 개. 덮어두지 않고 지원서를 썼다.", "有兩則職缺讓人留意。沒有就此擱著，而是寫了求職申請。", "兩則職缺", "兩", "job_posting_count"),
        ("jobs-cn", "눈에 띄는 공고 두 개. 덮어두지 않고 지원서를 썼다.", "有两则招聘信息引起了注意。没有搁在一边，而是写了申请。", "两则招聘信息", "两", "job_posting_count"),
        ("eggs", "새벽 한 시. 배가 고프다.\n냉장고를 열면 — 냉동 만두 반 봉지, 고추장, 오래된 달걀 두 개.", "凌晨一點。肚子餓了。\n打開冰箱——半包冷凍水餃、韓式辣椒醬、兩顆放了很久的蛋。", "兩顆放了很久的蛋", "兩", "egg_count"),
        ("task", "오래 미뤄왔던 전화 한 통, 해결 못 한 서류 한 장, 못 끝내던 과제 한 개.", "拖了很久的一通電話、一直沒處理好的一張文件、一項總是做不完的作業。", "一項總是做不完的作業", "一", "task_count"),
        ("task-cn", "오래 미뤄왔던 전화 한 통, 해결 못 한 서류 한 장, 못 끝내던 과제 한 개.", "一通拖了很久没打的电话，一张没处理好的文件，一项总没完成的任务。", "一项总没完成的任务", "一", "task_count"),
        ("rental", "세 번째 집을 계약한다. 조건이 가장 낫다.", "簽下第三間房的租約。條件最好。", "第三間房", "三", "rental_home_ordinal"),
        ("mirror", "기사 아저씨가 룸미러로 한번 보더니 말을 걸었다.", "司機大叔從後照鏡看了一眼，開口搭話。", "一眼", "一", "mirror_glance"),
        ("attempt", '"강남 한번 가보겠다고 했는데."', "「也說過想去江南闖一闖。」", "闖一闖", "一", "gangnam_attempt"),
        ("attempt-cn", '"강남 한번 가보겠다고 했는데."', "“也说过要去江南闯一次。”", "一次", "一", "gangnam_attempt"),
        ("school", "대학교 2학년 때 쓴 것 같다.", "大概是大學二年級時寫的。", "大學二年級", "二", "university_year"),
        ("bill", "강남 어느 식당. 1인 5만 원", "江南某家餐廳。每人5萬韓元", "每人", None, "restaurant_per_person"),
        ("exit", "지하 2번 출구", "地下2號出口", "2號出口", "2", "underground_exit"),
    )
    bad_numbers = ("零", "十一", "負一", "-1", "−\t1", "0.1", "數一")
    units = ("年", "月", "天", "秒", "小時", "分鐘", "公里", "米", "韓元", "人", "位")
    for label, source, target, counted, number, kind in fixtures:
        numeric(label + " normal", source, target, True)
        cases += 1
        if not any(q.kind == kind for q in _source_counter_quantities(_mask_spans(source, _source_money_amounts(source)))):
            failures.append(f"life-scene {label}: normal source did not own {kind}")
        for wrong in bad_numbers:
            replacement = counted.replace(number, wrong, 1) if number else wrong + "人各"
            numeric(label + " value " + repr(wrong), source, target.replace(counted, replacement, 1), False)
        # Suffix checks use real spaces, tabs and full-width spaces. The
        # numeral remains correct, so rejection must be about the unit.
        for separator in ("", " ", "\t", "　"):
            for unit in units:
                numeric(label + " suffix " + repr(separator + unit), source,
                        target.replace(counted, counted + separator + unit, 1), False)
            for prefix in ("-", "−", "負", "0.", "數", "十"):
                numeric(label + " prefix " + repr(prefix + separator), source,
                        target.replace(counted, prefix + separator + counted, 1), False)
        # A later correct number may not pay for an earlier incorrect count.
        if number:
            wrong_count = counted.replace(number, "十一", 1)
            numeric(label + " borrow later", source,
                    target.replace(counted, wrong_count + "，" + counted, 1), False)
        numeric(label + " duplicate", source, target.replace(counted, counted + "，" + counted, 1), False)

    for source, target in (
        ("과제 한 개.", "一項作業。"),
        ("세 번째 집을 계약한다.", "簽下第三間的租約。"),
        ("세 번째 집을 계약한다.", "签下第三套房的合同。"),
        ("오래된 달걀 두 개.", "两个放了很久的鸡蛋。"),
    ):
        numeric("classifier alternative", source, target, True)
    for source, target in (
        ("눈에 띄는 공고 두 개.", "兩則通知。"),
        ("오래된 달걀 두 개.", "兩顆藥丸。"),
        ("못 끝내던 과제 한 개.", "一項投資。"),
        ("세 번째 집을 계약한다.", "第三間公司。"),
        ("기사 아저씨가 룸미러로 한번 보더니 말을 걸었다.", "司機大叔有一眼。"),
        ('"강남 한번 가보겠다고 했는데."', "「去江南住一晚。」"),
        ("대학교 2학년 때 쓴 것 같다.", "大概是大學二年時寫的。"),
        ("강남 어느 식당. 1인 5만 원", "江南某家餐廳。每年5萬韓元"),
        ("지하 2번 출구", "地下2號房間"),
        ("강남 어느 식당. 1인 5만 원", "江南某家餐廳。每人6萬韓元"),
        ("강남 어느 식당. 1인 5만 원", "江南某家餐廳。每人5千韓元"),
        ("강남 어느 식당. 2인 5만 원", "江南某家餐廳。每人5萬韓元"),
        ("세 번째 집을 계약한다.", "签下第三套西装。"),
        ("세 번째 집을 계약한다.", "签下第三套软件。"),
        ("세 번째 집을 계약한다.", "签下第三间房地产公司。"),
        ("오래된 달걀 두 개.", "兩顆蛋白質。"),
        ("오래된 달걀 두 개.", "兩顆蛋黃。"),
        ("오래된 달걀 두 개.", "兩顆蛋糕。"),
    ):
        numeric("noun/unit/value drift", source, target, False)
    for separator in ("", " ", "\t", "　"):
        numeric("egg compound noun boundary", "오래된 달걀 두 개.", "兩顆蛋" + separator + "白質。", False)
        numeric("rental compound noun boundary", "세 번째 집을 계약한다.", "第三間房" + separator + "地產公司。", False)
        for prefix in ("不到", "不滿", "少於", "超過", "至少", "至多", "大約", "將近", "差不多", "沒有"):
            numeric("remaining month bound", "끝까지 넉 달이 남아 있었다.", "離終點還有" + prefix + separator + "四個月。", False)
        for suffix in ("以上", "以下", "以內", "以外", "左右", "上下", "多", "餘", "半"):
            numeric("remaining month approximation", "끝까지 넉 달이 남아 있었다.", "離終點還有四個月" + separator + suffix + "。", False)
    # These neighboring Korean constructions must not select the new kind.
    for source, kind in (
        ("끝까지 넉 달을 주었다.", "remaining_four_month"),
        ("대학교 2학년생이었다.", "university_year"),
        ("식당. 1인조였다.", "restaurant_per_person"),
        ("공고 두 개월이었다.", "job_posting_count"),
        ("달걀 두 개월치였다.", "egg_count"),
        ("과제 한 개월치였다.", "task_count"),
        ("세 번째 집을 그렸다.", "rental_home_ordinal"),
        ("룸미러로 한번 서류를 보더니 말을 걸었다.", "mirror_glance"),
        ("강남 한번 택배를 받아보겠다고 했다.", "gangnam_attempt"),
        ("지하 2번 출구조였다.", "underground_exit"),
    ):
        cases += 1
        if any(q.kind == kind for q in _source_counter_quantities(source)):
            failures.append(f"life-scene source scope escaped: {source}:{kind}")

    combined_source = '기사 아저씨가 룸미러로 한번 보더니 말을 걸었다.\n"강남 한번 가보겠다고 했는데."'
    combined_target = '司機大叔從後照鏡看了一眼，開口搭話。\n「也說過想去江南闖一闖。」'
    numeric("two independent actions", combined_source, combined_target, True)
    numeric("mirror cannot borrow attempt", combined_source, combined_target.replace("一眼", "兩眼"), False)
    numeric("attempt cannot borrow mirror", combined_source, combined_target.replace("闖一闖", "闖兩次"), False)
    numeric("action order", combined_source, '「也說過想去江南闖一闖。」\n司機大叔從後照鏡看了一眼，開口搭話。', False)

    for label in ("韩元", "韓元"):
        target = "放一千" + label + "進去。"
        numeric("native thousand", "천 원을 넣는다.", target, True)
        numeric("shared Arabic thousand", "4천 원", "4千" + label, True)
        for wrong in ("零千", "二千", "一百", "一萬", "一億", "一千萬", "十一千", "一千一百"):
            numeric("native won value", "천 원을 넣는다.", target.replace("一千", wrong), False)
        for separator in ("", " ", "\t", "　"):
            for prefix in ("-", "−", "負", "0.", "2.", "十", "數", "萬"):
                numeric("native won prefix", "천 원을 넣는다.", target.replace("一千", prefix + separator + "一千"), False)
            for suffix in ("萬", "億", "年", "天", "米", "人", "分鐘", "%", "％", "‰", "‱", "倍"):
                numeric("native won suffix", "천 원을 넣는다.", target.replace(label, label + separator + suffix), False)
        numeric("native won no source", "돈을 넣는다.", target, False)
        numeric("native won wrong currency", "천 원을 넣는다.", target.replace(label, "美元"), False)
        numeric("native won extra amount", "천 원을 넣는다.", target.replace("一千", "一千" + label + "和一千"), False)
        for source, translated in (
            ("5천 원과 천 원", "5千" + label + "和一千" + label),
            ("천 원과 5천 원", "一千" + label + "和5千" + label),
        ):
            numeric("mixed won source order", source, translated, True)
            numeric("mixed won order changed", source, "和".join(reversed(translated.split("和"))), False)

    for korean, latin in (("인스타", "Instagram"), ("링크드인", "LinkedIn")):
        source = f"{korean}에 접속했다."
        target = f"打開了{latin}。"
        for particle in ("에", "에서", "는", "을"):
            cases += 1
            if _untranslated_english_errors(f"{korean}{particle} 접속했다.", target):
                failures.append(f"life-scene brand particle rejected: {korean}{particle}")
        for bad_source in ("사이트에 접속했다.", f"{korean}에너지", f"{korean}에서류", "새" + source):
            cases += 1
            if not _untranslated_english_errors(bad_source, target):
                failures.append(f"life-scene brand source scope escaped: {bad_source}")
        for char in ("é", "_", "0", "\u0301", "\u0903", "\u0488"):
            for mutated in (char + latin, latin + char):
                cases += 1
                mutated_target = target.replace(latin, mutated)
                if _bounded_latin_matches(mutated_target, latin) or not (
                    _untranslated_english_errors(source, mutated_target)
                    or _numeric_errors(source, mutated_target)
                ):
                    failures.append(f"life-scene brand Unicode boundary escaped: {mutated!r}")
    return cases, failures


def _daily_life_parser_self_test() -> tuple[int, list[str]]:
    """Compound display units and language forms observed in daily life."""
    cases = 0
    failures: list[str] = []

    def numeric(label: str, source: str, target: str, valid: bool) -> None:
        nonlocal cases
        cases += 1
        errors = _numeric_errors(source, target)
        if bool(errors) == valid:
            failures.append(f"daily-life {label}: valid={valid}, got {errors}")

    fixtures = (
        ("microwave", "4,900원 도시락. 전자레인지 1분 30초. 이게 오늘의 저녁이다. 유통기한을 다시 확인한다.",
         "4,900韓元的便當。微波1分30秒。這就是今天的晚餐。又看了一眼保存期限。", "1分30秒",
         ("0分30秒", "2分30秒", "1分3秒", "1分31秒", "30分1秒", "0分90秒", "1時30秒", "1分30元", "1分30分鐘", "1分30秒殺優惠")),
        ("screen", "폰을 오래 봤더니 눈이 따가웠다.\n\n스크린 타임 알림이 떴다. 하루 7시간 48분.\n\n어쩌다 이렇게 됐나. 딱히 뭘 한 것도 없는데.",
         "看手機太久，眼睛刺痛。\n\n螢幕使用時間提醒彈了出來。一天7小時48分。\n\n怎麼會變成這樣。明明也沒做什麼。", "7小時48分",
         ("0小時48分", "8小時48分", "7小時49分", "7小時4分", "48小時7分", "6小時108分", "7小時48秒", "7公里48分", "7小時48元", "7小時48分貝", "7小時48分錢")),
        ("open-hours", "직진하면 24시 치킨 반반 17,000원.",
         "直走有一家24小時營業的炸雞店，雙拼炸雞17,000韓元。", "24小時營業的炸雞店",
         ("0小時營業的炸雞店", "23小時營業的炸雞店", "25小時營業的炸雞店", "24分鐘營業的炸雞店", "24點營業的炸雞店", "24小時關門的炸雞店", "24小時營業的超市", "24小時營業的炸雞店員", "24小時營業的炸雞店長")),
        ("monthly-range", "머리 한쪽이 지끈거렸다.\n\n스트레스성 편두통. 한 달에 한두 번은 온다.\n\n{name}은 진통제 위치를 알았다. 가방 안쪽 주머니.",
         "頭的一側一陣陣抽痛。\n\n壓力引起的偏頭痛。每個月總會發作一兩次。\n\n{name}知道止痛藥在哪。包包內側的口袋。", "每個月總會發作一兩次",
         ("每個月總會發作零次", "每個月總會發作一次", "每個月總會發作兩次", "每個月總會發作三次", "每個月總會發作12次", "每個月總會發作1~3次", "每個月總會發作2~1次", "每個月總會發作一兩年", "每年總會發作一兩次", "每個月不會發作一兩次", "每小時一兩次", "每兩月一兩次", "每二月一兩次")),
    )
    for label, source, target, counted, bad in fixtures:
        numeric(label + " normal", source, target, True)
        for replacement in bad:
            numeric(label + " value/unit", source, target.replace(counted, replacement), False)
            numeric(label + " cannot borrow later", source, target.replace(counted, replacement + "，" + counted), False)
        numeric(label + " duplicate", source, target.replace(counted, counted + "，" + counted), False)
        for separator in ("", " ", "\t", "　"):
            for prefix in ("-", "−", "負", "0.", "數", "十"):
                numeric(label + " prefix", source, target.replace(counted, prefix + separator + counted), False)
            for suffix in ("年", "小時", "分鐘", "秒", "米", "韓元", "人", "%", "％", "倍", "萬", "以上", "以下"):
                numeric(label + " suffix", source, target.replace(counted, counted + separator + suffix), False)
    for source, target in (
        ("전자레인지 1분 30초.", "微波1分鐘30秒。"),
        ("전자레인지 1분 30초.", "微波一分三十秒。"),
        ("전자레인지 1분 30초.", "微波1分鐘30秒鐘。"),
        ("스크린 타임 알림이 떴다. 하루 7시간 48분.", "螢幕使用時間提醒。一天7小時48分鐘。"),
        ("스트레스성 편두통. 한 달에 한두 번은 온다.", "偏頭痛。每月1~2次。"),
        ("스트레스성 편두통. 한 달에 한두 번은 온다.", "偏头痛。每月一两次。"),
    ):
        numeric("alternative", source, target, True)
    for source, forbidden_kind in (
        ("대화는 1분 30초.", "microwave_duration"),
        ("스크린 타임 알림이 떴다. 하루 7시간 48분간의 회의.", "screen_time_duration"),
        ("직진하면 24시 치킨 회의가 시작된다.", "chicken_open_hours"),
        ("스트레스성 편두통. 한 달에 한두 번씩 약을 버렸다.", "monthly_headache_frequency"),
    ):
        cases += 1
        if any(q.kind == forbidden_kind for q in _source_counter_quantities(source)):
            failures.append(f"daily-life source scope escaped: {source}")
    for source in ("전자레인지 2분 30초.", "전자레인지 1분 31초."):
        numeric("microwave changed source", source, "微波1分30秒。", False)
    for source in ("스크린 타임 알림이 떴다. 하루 8시간 48분.", "스크린 타임 알림이 떴다. 하루 7시간 49분."):
        numeric("screen changed source", source, "螢幕使用時間提醒。一天7小時48分。", False)
    for separator in ("", " ", "\t", "　"):
        for bound in ("至少", "至多", "大約", "並非", "不再"):
            numeric("monthly range bound", "스트레스성 편두통. 한 달에 한두 번은 온다.", bound + separator + "每月一兩次。", False)
    # Exact compound display times share the existing scalar-bound guard.
    # Preserve all other prose and also prevent borrowing a later exact time.
    for label, source, target, counted, _ in fixtures[:2]:
        for separator in ("", " ", "\t", "　"):
            for bound in ("不到", "超過"):
                changed = bound + separator + counted
                numeric(label + " exact bound", source, target.replace(counted, changed), False)
                numeric(label + " exact bound cannot borrow", source, target.replace(counted, changed + "，" + counted), False)

    for won in ("韩元", "韓元"):
        source = "근처 국밥집에 들어간다 — 오천 원짜리라도 제대로 먹자"
        target = "走進附近的湯飯店——就算只是五千" + won + "，也要好好吃一頓"
        numeric("five-thousand normal", source, target, True)
        for wrong in ("一千", "五百", "五萬", "五億", "五千萬", "十五千", "五千五百"):
            numeric("five-thousand value", source, target.replace("五千", wrong), False)
        for separator in ("", " ", "\t", "　"):
            for prefix in ("-", "−", "負", "0.", "2.", "十", "數", "萬"):
                numeric("five-thousand prefix", source, target.replace("五千", prefix + separator + "五千"), False)
            for suffix in ("%", "％", "倍", "萬", "億", "年", "天", "米", "人"):
                numeric("five-thousand suffix", source, target.replace(won, won + separator + suffix), False)
        numeric("five-thousand no source", "국밥을 먹는다.", target, False)
        numeric("five-thousand wrong currency", source, target.replace(won, "美元"), False)
        numeric("negative money preserved", "마이너스 오천 원", "負五千" + won, True)
        for original, translated in (("천 원과 오천 원", "一千" + won + "和五千" + won), ("5천 원과 천 원", "五千" + won + "和1千" + won)):
            numeric("native five money order", original, translated, True)
            numeric("native five order changed", original, "和".join(reversed(translated.split("和"))), False)

    for source, target in (("배달앱 열기", "打開外送App"), ("배달앱을 켰다.", "打開了外送App。"), ("엑스레이.", "X光。"), ("흉부 엑스레이.", "胸部X光。")):
        cases += 1
        if _untranslated_english_errors(source, target):
            failures.append(f"daily-life source-bound Latin rejected: {source}:{target}")
        for char in ("é", "_", "0", "\u0301", "\u0903", "\u0488"):
            latin = "App" if "App" in target else "X光"
            for altered in (char + latin, latin + char):
                cases += 1
                value = target.replace(latin, altered)
                if not (_untranslated_english_errors(source, value) or _numeric_errors(source, value)):
                    failures.append(f"daily-life Latin Unicode boundary escaped: {value!r}")
    for source, target in (("앱솔루트를 켰다.", "打開App。"), ("배달앱솔루트", "App"), ("음식배달앱을 켰다.", "打開App。"), ("배달을 시작했다.", "App"), ("레이저.", "X光。"), ("엑스레이저.", "X光。"), ("신엑스레이.", "X光。"), ("엑스레이.", "X遊戲。"), ("엑스레이.", "X光源。"), ("엑스레이.", "X光\t榮。")):
        cases += 1
        if not _untranslated_english_errors(source, target):
            failures.append(f"daily-life Latin source/noun scope escaped: {source}:{target}")
    # This is a reviewed script classification correction, not conversion.
    for target in ("尖峰時段", "高峰", "峰"):
        cases += 1
        if _script_errors("zh-TW", target):
            failures.append(f"MOE standard 峰 rejected: {target}")
    for target in ("尖峰时间", "尖峰车站", "峰值已经过去", "峰\uFE00"):
        cases += 1
        if not _script_errors("zh-TW", target):
            failures.append(f"MOE 峰 exemption leaked to other script/encoding: {target}")
    return cases, failures


def _work_scene_parser_self_test() -> tuple[int, list[str]]:
    """Observed work/study clauses, with independent value and scope controls."""
    cases, failures = 0, []

    def check(source: str, target: str, valid: bool) -> None:
        nonlocal cases
        cases += 1
        errors = _numeric_errors(source, target)
        if bool(errors) == valid:
            failures.append(f"work-scene expected valid={valid}: {source!r} -> {target!r}: {errors}")

    fixtures = (
        ("한두 잔만 하고 일찍 빠진다", "只喝一兩杯，早點離開", "一兩杯",
         ("一杯", "兩杯", "十二杯", "一兩瓶")),
        ("세 발짝 뒤에서 두 동료가 멈칫했다.", "三步外，兩位同事停頓了一下。", "兩位同事",
         ("一位同事", "三位同事", "兩年同事", "兩位同事業者")),
        ("불필요한 구독 서비스 2개를 해지했다. 작은 절약이 습관이 된다.", "取消了兩項不必要的訂閱服務。小小的節省，會變成習慣。", "兩項不必要的訂閱服務",
         ("一項不必要的訂閱服務", "三項不必要的訂閱服務", "兩年不必要的訂閱服務", "兩項不必要的訂閱服務費")),
        ("오늘부터 하루 3시간 공부한다", "從今天起，每天讀3個小時", "每天讀3個小時",
         ("每月讀3個小時", "每兩天讀3個小時", "每天讀2個小時", "每天讀3分鐘")),
        ("자격증 시험 D-14", "證照考試倒數14天", "倒數14天",
         ("倒數13天", "倒數15天", "倒數14年", "倒數14天後")),
        ("수강료는 한 달 25만원.", "每月學費25萬韓元。", "每月",
         ("每年", "每兩月", "每週", "每天")),
        ("스마트폰에 언어 학습 앱이 있다. 한 달 전에 깔았다가 3일 하고 그만뒀다.\n\n오늘 알림이 왔다. '돌아오세요. 30일 연속 달성하면 배지를 드려요.'\n\n배지 같은 건 필요 없지만 — 30일을 한 번도 해본 적이 없다는 게 마음에 걸린다.",
         "手機裡有個語言學習App。一個月前裝的，做了3天就停了。\n\n今天收到通知：「回來吧。連續完成30天，就送你徽章。」\n\n不需要什麼徽章——可是在意的是，自己從沒連續做滿30天。", "從沒連續做滿30天",
         ("曾經連續做滿30天", "從沒連續做滿29天", "從沒連續做滿31天", "從沒連續做滿30年")),
        ("한 곳에 집중해서 자소서를 다듬는다", "專心鎖定一家公司，修好自傳", "一家公司",
         ("兩家公司", "三家公司", "一家餐館", "一家公司債")),
        ("읽은 표시가 120개를 넘어가고 있었다.", "已讀數已經超過120。", "已讀數已經超過120",
         ("已讀數已經達到120", "已讀數已經不足120", "未讀數已經超過120", "已讀數已經超過121")),
        ("공고 27개를 열었다가 닫았다. 지원한 건 2개.", "點開27則徵才公告，又關掉。應徵了兩個職缺。", "27則徵才公告",
         ("26則徵才公告", "28則徵才公告", "27年徵才公告", "27則徵才公告費")),
    )
    for source, target, counted, wrong in fixtures:
        check(source, target, True)
        for changed in wrong:
            check(source, target.replace(counted, changed), False)
        # Keep the verb/source nouns when repeating a number, so an unrelated
        # missing-action failure cannot pretend to reject quantity borrowing.
        check(source, target + "，" + target, False)
        for changed in wrong[:2]:
            check(source, target.replace(counted, changed) + "，" + target, False)
        for prefix in ("-", "−\t", "不到 "):
            check(source, target.replace(counted, prefix + counted), False)
        for suffix in (" 年", "\t%以上"):
            check(source, target.replace(counted, counted + suffix), False)
    for source, target in (
        ("자격증 시험 D-14", "資格考試D-14"),
        ("자격증 시험 D-14", "资格考试倒计时14天"),
        ("한두 잔만 하고 일찍 빠진다", "只喝1~2杯，早点离开"),
        ("오늘부터 하루 3시간 공부한다", "从今天起，每天学3个小时"),
        ("수강료는 한 달 25만원.", "学费每月25万韩元。"),
        ("30일을 한 번도 해본 적이 없다는 게 마음에 걸린다.", "一次也没坚持满30天。"),
    ):
        check(source, target, True)
    # 一兩 is already the full 1–2 range, not a lower bound for a new range.
    for counted in ("一兩杯", "一两杯", "1~2杯", "一至兩杯", "1-2杯"):
        check("한두 잔만 하고 일찍 빠진다", "只喝" + counted + "，早點離開", True)
    for counted in ("一兩至三杯", "一兩到十二杯", "一兩-三杯"):
        check("한두 잔만 하고 일찍 빠진다", "只喝" + counted + "，早點離開", False)
    # Witness the wrong payment/study period even when a valid later clause
    # supplies the expected day/month; the earlier amount cannot borrow it.
    for period in ("每小時", "每分鐘", "每秒"):
        check("오늘부터 하루 3시간 공부한다", "從今天起，" + period + "讀三小時，每天讀3個小時", False)
        check("수강료는 한 달 25만원.", period + "學費25萬韓元，每月學費。", False)
    for source, kind in (
        ("한두 잔의 약을 버린다", "work_cup_range"),
        ("두 동료를 해고했다.", "coworker_count"),
        ("불필요한 구독 서비스 2개월을 해지했다.", "subscription_count"),
        ("오늘부터 하루 3시간 일한다", "study_daily_hours"),
        ("자격증 시험 D+14", "exam_countdown"),
        ("유효기간은 한 달 25만원.", "tuition_month"),
        ("30일을 한 번도 해본 적이 있다는 게 마음에 걸린다.", "never_course_days"),
        ("한 곳에 집중해서 서류를 버린다", "job_company_focus"),
        ("읽은 표시가 120개에 도달했다.", "read_mark_over_count"),
        ("공고 27개월을 열었다가 닫았다.", "job_posting_count"),
    ):
        cases += 1
        if any(q.kind == kind for q in _source_counter_quantities(source)):
            failures.append(f"work-scene source scope escaped: {source}")
    # The monthly price still owns both its money amount and payment period.
    check("수강료는 한 달 25만원.", "每月學費26萬韓元。", False)
    check("수강료는 한 달 25만원.", "每月學費25美元。", False)
    for source, target, terms in (
        ("인크루트 앱을 다시 설치했다", "重新安裝Incruit App", ("Incruit",)),
        ("잡코리아와 사람인을 번갈아 새로고침하고 있다.", "交替刷新JobKorea和Saramin。", ("JobKorea", "Saramin")),
        ("파이썬 입문, 원래 49,900원이 1,900원.", "Python入門，原價49,900韓元，現價1,900韓元。", ("Python",)),
    ):
        cases += 1
        if _untranslated_english_errors(source, target):
            failures.append(f"work brand normal rejected: {target}")
        for term in terms:
            for changed in ("", term + "x", term + "_", "é" + term, term + "\u0301"):
                cases += 1
                if not _untranslated_english_errors(source, target.replace(term, changed)):
                    failures.append(f"work brand boundary/deletion escaped: {changed!r}")
    for source, target in (("평범한 사람인 줄 알았다.", "Saramin"), ("인크루트앱솔루트를 썼다.", "Incruit"), ("잡코리아인 줄 알았다.", "JobKorea"), ("파이썬독 입문이었다.", "Python")):
        cases += 1
        if not _untranslated_english_errors(source, target):
            failures.append(f"work brand source false friend escaped: {source}")
    return cases, failures


def _spending_scene_parser_self_test() -> tuple[int, list[str]]:
    """Source-bound household-spending observations, not a generic waiver."""
    cases, failures = 0, []

    def check(source: str, target: str, valid: bool) -> None:
        nonlocal cases
        cases += 1
        errors = _numeric_errors(source, target)
        if bool(errors) == valid:
            failures.append(f"spending expected valid={valid}: {source!r} -> {target!r}: {errors}")

    fixtures = (
        ("'30대 자산관리'", "「三十多歲的資產管理」", "三十多歲",
         ("四十多歲", "三十歲", "三十多年", "三十多歲月")),
        ("한 달에 한 번씩 이런다.", "每個月都會這樣一次。", "每個月都會這樣一次",
         ("每兩個月都會這樣一次", "每小時都會這樣一次", "每個月都會這樣兩次", "每個月不會這樣一次")),
        ("편의점에서 캔맥주 두 개를 샀다", "在便利商店買了兩罐啤酒", "兩罐啤酒",
         ("一罐啤酒", "三罐啤酒", "兩瓶啤酒", "兩罐啤酒瓶")),
        ("...3개 일치. 5등. 5,000원.", "……對中3個。五獎。5,000韓元。", "對中3個",
         ("對中2個", "對中4個", "沒中3個", "對中3年")),
        ("...3개 일치. 5등. 5,000원.", "……對中3個。五獎。5,000韓元。", "五獎",
         ("四獎", "六獎", "五年", "五獎券")),
        ("3개월권 15만원. 등록할 때 결심이 단단했다. 첫 주는 갔다. 둘째 주는 세 번. 셋째 주는...",
         "三個月15萬韓元。報名的時候，下定了決心。第一週去了。第二週三次。第三週……", "三個月",
         ("兩個月", "四個月", "三年", "三個月以上")),
        ("한 달 반쯤 갔다. 기간이 지났을 때 조금 아쉬웠다. 다음엔 더 갈 것 같다.",
         "去了大約一個半月。期限到了，有點可惜。下次應該會多去一點。", "大約一個半月",
         ("大約兩個半月", "大約一個月", "一個半月", "大約一個年")),
        ("5만원. 서울에서의 첫 번째 행운이었다.", "5萬韓元。在首爾的第一份幸運。", "第一份幸運",
         ("第二份幸運", "第三份幸運", "第一份幸運券", "第一年份幸運")),
        ("3만원. 5만원. 둘 사이에 2만원이 있었다.", "3萬韓元。5萬韓元。這兩個數之間，差了2萬韓元。", "這兩個數之間",
         ("這三個數之間", "這一個數之間", "這兩個數之間以上", "這兩個數之間 年")),
    )
    for source, target, counted, wrong in fixtures:
        check(source, target, True)
        for changed in wrong:
            check(source, target.replace(counted, changed), False)
        # Retain the surrounding sentence and its other quantities while an
        # incorrect first clause attempts to borrow a later correct count.
        if "韓元" not in target:
            check(source, target.replace(counted, wrong[0]) + "，" + target, False)
            check(source, target + "，" + target, False)
        for changed in ("−\t" + counted, "不到 " + counted, counted + "\t%"):
            check(source, target.replace(counted, changed), False)
    for source, target in (
        ("3만원. 5만원. 둘 사이에 2만원이 있었다.", "3萬韓元。5萬韓元。中間差了2萬韓元。"),
        ("3만원. 5만원. 둘 사이에 2만원이 있었다.", "3万韩元。5万韩元。这两个数之间，差着2万韩元。"),
        ("산다 — 한 번쯤은 (−1,000원)", "買吧——就一次也好（−1,000韓元）"),
        ("산다 — 한 번쯤은 (−1,000원)", "买——就试一次吧（-1,000韩元）"),
        ("{name}이 원하는 것을 본인보다 먼저 알고 있었다.", "比{name}自己更早知道，自己想要什麼。"),
        ("이 원을 원했다.", "想要2韓元。"),
    ):
        check(source, target, True)
    for changed in ("1,000韓元", "+1,000韓元", "−2,000韓元", "−1,000美元"):
        check("산다 — 한 번쯤은 (−1,000원)", "買吧——就一次也好（" + changed + "）", False)
    check("{name}이 원하는 것을 본인보다 먼저 알고 있었다.", "想要2韓元。", False)
    check("이 원을 원했다.", "想要3韓元。", False)
    # Each amount occurs only once: these failures must come from the extra
    # wrong count, never from duplicating the currency or deleting a token.
    for source, target in (
        ("...3개 일치. 5등. 5,000원.", "……對中2個。對中3個。五獎。5,000韓元。"),
        ("...3개 일치. 5등. 5,000원.", "……對中3個。四獎。五獎。5,000韓元。"),
        ("3개월권 15만원. 등록할 때 결심이 단단했다. 첫 주는 갔다. 둘째 주는 세 번. 셋째 주는...", "兩個月。三個月15萬韓元。報名的時候，下定了決心。第一週去了。第二週三次。第三週……"),
        ("5만원. 서울에서의 첫 번째 행운이었다.", "5萬韓元。在首爾的第二份幸運。在首爾的第一份幸運。"),
        ("3만원. 5만원. 둘 사이에 2만원이 있었다.", "3萬韓元。5萬韓元。這三個數之間，差了。中間差了2萬韓元。"),
    ):
        check(source, target, False)
    # Independent review: unsupported first witnesses may not borrow a later
    # valid age, frequency, container, rank, or approximate month duration.
    # Preserve every other amount and sentence, so the rejection is not an
    # unrelated money/token failure.
    for source, normal, borrowed in (
        ("30대 자산관리", "「三十多歲的資產管理」",
         "「三十多年的資產管理」，「三十多歲的資產管理」"),
        ("한 달에 한 번씩 이런다.", "每個月都會這樣一次。",
         "每個月不會這樣一次。每個月都會這樣一次。"),
        ("편의점에서 캔맥주 두 개를 샀다", "在便利商店買了兩罐啤酒。",
         "在便利商店買了兩箱啤酒。買了兩罐啤酒。"),
        ("...3개 일치. 5등. 5,000원.", "……對中3個。五獎。5,000韓元。",
         "……對中3個。五次。五獎。5,000韓元。"),
        ("한 달 반쯤 갔다. 기간이 지났을 때 조금 아쉬웠다. 다음엔 더 갈 것 같다.",
         "去了大約一個半月。期限到了，有點可惜。下次應該會多去一點。",
         "去了大約一個半天。去了大約一個半月。期限到了，有點可惜。下次應該會多去一點。"),
    ):
        check(source, normal, True)
        check(source, borrowed, False)
    # No inference of a type from an event ID or an unrelated similar noun.
    for source, kind in (
        ("30대 자동차관리", "asset_age_decade"),
        ("한 달에 한 번씩 일한다.", "monthly_balance_once"),
        ("편의점에서 와인 두 개를 샀다", "beer_can_count"),
        ("...3개 불일치. 5등.", "lottery_match_count"),
        ("3개 불일치. 5등.", "lottery_prize_rank"),
        ("3개월권. 연장했다.", "gym_card_months"),
        ("한 달 반쯤 갔다. 계속 다닐 생각이다.", "gym_approx_months"),
        ("서울에서의 첫 번째 행동이었다.", "first_luck"),
        ("친구. 이웃. 둘 사이에 돈이 있었다.", "price_gap_pair"),
    ):
        cases += 1
        if any(q.kind == kind for q in _source_counter_quantities(source)):
            failures.append(f"spending source scope escaped: {source}")
    return cases, failures


def run_self_test(
    manifest: dict[str, Any], runtime: dict[str, Any],
) -> list[str]:
    failures: list[str] = []
    cases, life_failures = _life_scene_parser_self_test()
    failures.extend(life_failures)
    daily_cases, daily_failures = _daily_life_parser_self_test()
    cases += daily_cases
    failures.extend(daily_failures)
    work_cases, work_failures = _work_scene_parser_self_test()
    cases += work_cases
    failures.extend(work_failures)
    spending_cases, spending_failures = _spending_scene_parser_self_test()
    cases += spending_cases
    failures.extend(spending_failures)

    # Exact Korean-source catalogue names are not permission for unrelated
    # English prose or for deleting the noun around an allowed brand token.
    for source, forms in CATALOG_LATIN_ALIASES.items():
        for phrase in forms:
            cases += 1
            if _untranslated_english_errors(source, phrase, catalog=True):
                failures.append(f"catalogue brand not accepted in exact source: {source}:{phrase}")
            cases += 1
            if not _untranslated_english_errors(source, phrase + "Untranslated", catalog=True):
                failures.append(f"catalogue brand suffix escaped: {source}:{phrase}")
            # KoGPT/DX already occur literally in these Korean leaves and the
            # other components (Daon/POSCO) were globally prepared before this
            # batch; this is not a new source-scope exemption.
            if source not in {"다온 KoGPT", "포스코DX"} and _untranslated_english_errors("흰 종이.", phrase, catalog=True):
                cases += 1
                if not _untranslated_english_errors(source + " 파일", phrase, catalog=True):
                    failures.append(f"catalogue brand escaped exact-source boundary: {source}:{phrase}")
    for source, target in (
        ("구글 코리아", "Google"), ("깃허브 이력서", "GitHub"),
        ("네이버 데이터센터", "NAVER"), ("피벗 커뮤니티", "Pivot"),
        ("삼성 가우스2", "Gauss 2"), ("토스 이승건", "Toss"),
    ):
        cases += 1
        if catalog_latin_only(source, target):
            failures.append(f"partial catalogue name accepted as complete: {source}:{target}")
    for lang, source, target, valid in (
        ("zh-CN", "첫 억", "首个一亿韩元", True),
        ("zh-TW", "첫 억", "第一億韓元", True),
        ("zh-CN", "첫 억", "首个十亿韩元", False),
        ("zh-TW", "첫 억", "第一億", False),
        ("zh-CN", "첫 억", "首个一亿元", False),
        ("zh-CN", "기업가치 1조원 달성", "企业价值达到1万亿韩元", True),
        ("zh-TW", "기업가치 1조원 달성", "企業價值達到1兆韓元", True),
        ("zh-CN", "기업가치 1조원 달성", "企业价值达到1亿韩元", False),
        ("zh-TW", "기업가치 1조원 달성", "企業價值達到2兆韓元", False),
        ("zh-CN", "스물에 억대 계약.", "二十岁就签下上亿韩元的合同。", True),
        ("zh-TW", "스물에 억대 계약.", "20歲簽下上億韓元的契約。", True),
        ("zh-TW", "스물에 억대 계약.", "21歲簽下上億韓元的契約。", False),
        ("zh-CN", "스물에 억대 계약.", "二十岁就签下上千万韩元的合同。", False),
        ("zh-TW", "스물에 억대 계약.", "20歲簽下3億韓元的契約。", False),
        ("zh-CN", "창업자 수백억 EXIT 실현", "创始人实现数百亿韩元退出", True),
        ("zh-TW", "수조원 빅딜 성사 임박", "數兆韓元大交易即將成交", True),
        ("zh-CN", "창업자 수백억 EXIT 실현", "创始人实现数十亿韩元退出", False),
        ("zh-TW", "수조원 빅딜 성사 임박", "數億韓元大交易即將成交", False),
        ("zh-CN", "수백억 조회수", "数百亿韩元观看次数", False),
        ("zh-CN", "이름 석 자가 브랜드다.", "名字三个字就是品牌。", True),
        ("zh-TW", "이름 석 자가 브랜드다.", "名字四個字就是品牌。", False),
        ("zh-CN", "총 5번 런을 완료했다.", "共完成5轮人生。", True),
        ("zh-TW", "총 5번 런을 완료했다.", "總共完成6輪人生。", False),
        ("zh-CN", "5번 전화했다.", "打了5轮电话。", False),
        ("zh-CN", "다시 만난 밤, 둘이서 찍었다.", "重逢那晚，一起拍的双人照。", True),
        ("zh-TW", "다시 만난 밤, 둘이서 찍었다.", "重逢那晚，兩個人一起拍的。", True),
        ("zh-CN", "다시 만난 밤, 둘이서 찍었다.", "重逢那晚，一起拍的三人照。", False),
        ("zh-CN", "2030 직장인", "二三十岁的上班族", True),
        ("zh-TW", "2030 투자자", "20、30多歲投資人", True),
        ("zh-CN", "2030 직장인", "三四十岁的上班族", False),
        ("zh-TW", "2030 투자자", "20多歲投資人", False),
        ("zh-CN", "2030명 직장인", "二三十岁的上班族", False),
        ("zh-TW", "2030 투자자", "20、30多輛車", False),
        ("zh-CN", "30대 직장인", "30多岁的上班族", True),
        ("zh-TW", "차량 30대", "30多歲", False),
        ("zh-CN", "1인 가구", "独居人群", True),
        ("zh-TW", "1인 가구", "單人家戶", True),
        ("zh-CN", "1인 가구", "三人家庭", False),
        ("zh-TW", "1인 가구", "兩人家戶", False),
        ("zh-CN", "2차전지주", "二次电池股", True),
        ("zh-TW", "2차전지주", "三次電池股", False),
        ("zh-CN", "2차 협상", "二次电池", False),
        ("zh-TW", "2차 창업자 네트워크", "第二次創業者人脈網", True),
        ("zh-CN", "2차 창업자 네트워크", "三次创业者网络", False),
        ("zh-CN", "주4일제 의무화", "强制实行每周四天工作制", True),
        ("zh-TW", "주4일제 의무화", "強制每週工作4天", True),
        ("zh-CN", "주4일제 의무화", "强制实行每周五天工作制", False),
        ("zh-TW", "주4회 의무화", "每週工作4天", False),
        ("zh-TW", "사흘 밤.", "三個夜晚。", True),
        ("zh-CN", "사흘 밤.", "三个白天。", False),
        ("zh-CN", "구독자 100만 = 연봉 10억", "100万订阅者＝10亿韩元年薪", True),
        ("zh-TW", "구독자 100만 = 연봉 10억", "100萬訂閱者＝年薪10億韓元", True),
        ("zh-CN", "구독자 100만 = 연봉 10억", "101万订阅者＝10亿韩元年薪", False),
        ("zh-TW", "구독자 100만 = 연봉 10억", "100萬股＝年薪10億韓元", False),
        ("zh-CN", "구독자 100만 = 연봉 10억", "100万韩元＝10亿韩元年薪", False),
        ("zh-TW", "구독자 100만 = 연봉 10억", "100萬訂閱者＝年薪10億", False),
        ("zh-CN", "계좌 100만 = 연봉 10억", "100万订阅者＝10亿韩元年薪", False),
        ("zh-TW", "1억원", "-一億韓元", False),
        ("zh-TW", "1억원", "負 一億韓元", False),
        ("zh-CN", "1억원", "−一亿韩元", False),
        ("zh-CN", "-1억원", "负一亿韩元", True),
        ("zh-TW", "1억원", "零點一億韓元", False),
        ("zh-CN", "1억원", "零点一亿韩元", False),
        ("zh-TW", "1억원", "一點一億韓元", False),
        ("zh-TW", "1억원", "一兆一億韓元", False),
        ("zh-TW", "1억원", "兩兆 一億韓元", False),
        ("zh-CN", "1억원", "一万 一亿韩元", False),
        ("zh-TW", "창업자 수백억 EXIT 실현", "創辦人實現-數百億韓元出場", False),
        ("zh-CN", "창업자 수백억 EXIT 실현", "创始人实现负数百亿韩元退出", False),
        ("zh-TW", "창업자 수백억 EXIT 실현", "創辦人實現一兆數百億韓元出場", False),
        ("zh-TW", "수조원 빅딜 성사 임박", "一兆 數兆韓元大交易即將成交", False),
        ("zh-TW", "2030 직장인", "一百二三十歲上班族", False),
        ("zh-CN", "2030 직장인", "一百 二三十岁上班族", False),
        ("zh-TW", "2030 직장인", "二三十歲的上班族與四十歲", False),
        ("zh-CN", "2030 직장인", "20、30多岁与40岁上班族", False),
        ("zh-TW", "주4일제 의무화", "每週工作四天與五天", False),
        ("zh-CN", "주4일제 의무화", "每周工作四天与五年", False),
        ("zh-TW", "2030 직장인", "二三十歲的上班族與四十 歲", False),
        ("zh-TW", "2030 직장인", "二三十歲的上班族與四十年", False),
        ("zh-TW", "주4일제 의무화", "每週工作四天與五 天", False),
        ("zh-TW", "총 5번 런을 완료했다.", "完成五輪和六輪人生。", False),
        ("zh-TW", "1억원", "數一億韓元", False),
        ("zh-TW", "1억원", "數 一億韓元", False),
        ("zh-CN", "1억원", "数一亿韩元", False),
        ("zh-TW", "첫 억", "一億韓元", False),
        ("zh-TW", "첫 억", "第二筆一億韓元", False),
    ):
        cases += 1
        observed = validate_text(lang, "catalog:self-test", source, target)
        if bool(observed) == valid:
            failures.append(f"catalogue quantity valid={valid} {source}:{target}: {observed}")

    creator_source = (
        "댓글 알림이 멈추지 않았다. 100만이었다. 구독자 100만. "
        "처음 영상을 올리던 날, 조회수 43이었다. "
        "그게 부끄럽지 않았다. 그냥 찍고 싶었으니까. "
        "그게 1만이 됐고, 10만이 됐고, 지금 여기까지 왔다."
    )
    creator_cn = "留言通知不停。100万了。订阅人数100万。第一次上传视频时观看次数43。不觉得丢脸，只是想拍。后来变成1万、10万，走到了今天。"
    creator_tw = "留言通知不停。100萬了。訂閱人數100萬。第一次上傳影片時觀看次數43。不覺得丟臉，只是想拍。後來變成1萬、10萬，走到了今天。"
    for lang, source, target, expected_error in (
        ("zh-CN", creator_source, creator_cn, ""),
        ("zh-TW", creator_source, creator_tw, ""),
        ("zh-CN", creator_source + " 契약금 100만원.", creator_cn + " 签约金100万韩元。", ""),
        ("zh-TW", creator_source, creator_tw.replace("100萬", "101萬", 1), "counter quantity missing/changed"),
        ("zh-CN", creator_source, creator_cn.replace("100万", "100", 1), "counter quantity missing/changed"),
        ("zh-TW", creator_source, creator_tw.replace("100萬了。", ""), "counter quantity missing/changed"),
        ("zh-CN", creator_source, creator_cn.replace("1万、10万", "10万、1万"), "counter quantity missing/changed"),
        ("zh-TW", creator_source, creator_tw.replace("43", "44"), "non-money number sequence changed"),
        ("zh-CN", creator_source, creator_cn.replace("100万", "100万韩元"), "Korean-won values changed"),
        ("zh-TW", creator_source + " 契약금 100만원.", creator_tw + " 簽約金100萬。", "Korean-won values changed"),
        ("zh-CN", creator_source.replace("100만이었다", "100만원이었다"), creator_cn, "Korean-won values changed"),
        ("zh-CN", creator_source, creator_cn.replace("订阅人数100万", "100万股股份"), "counter quantity missing/changed"),
        ("zh-TW", creator_source, creator_tw.replace("訂閱人數100萬", "訂閱人數100萬股"), "counter quantity missing/changed"),
        ("zh-CN", creator_source, creator_cn.replace("订阅人数100万", "股份数量100万"), "counter quantity missing/changed"),
        ("zh-TW", creator_source, creator_tw.replace("1萬、10萬", "1萬份文件、10萬"), "counter quantity missing/changed"),
        ("zh-CN", creator_source, creator_cn.replace("100万了", "100万年了"), "counter quantity missing/changed"),
    ):
        cases += 1
        observed = validate_text(lang, "self-test::creator-audience", source, target)
        if (not expected_error and observed) or (
            expected_error and not any(expected_error in error for error in observed)
        ):
            failures.append(f"creator audience scope {lang}: expected {expected_error!r}, got {observed}")

    for lang, target in (
        ("zh-CN", "在江南，目标是30亿韩元。"),
        ("zh-TW", "在江南，目標是30億韓元。"),
    ):
        cases += 1
        errors = validate_text(lang, "self-test::valid-money", "강남에서 목표는 30억원.", target)
        if errors:
            failures.append(f"valid {lang} sample failed: {errors}")

    mutations = (
        ("shares-etf-document-head", "zh-CN", "첫 매수는 ETF 한 주였다.", "第一次买入一份 ETF 文件。", "counter quantity missing/changed"),
        ("shares-etf-report-head", "zh-TW", "첫 매수는 ETF 한 주였다.", "第一次買進一份 ETF 的報告。", "counter quantity missing/changed"),
        ("shares-etf-contract-head", "zh-CN", "첫 매수는 ETF 한 주였다.", "第一次买入一份 ETF 合约。", "counter quantity missing/changed"),
        ("app-fused-token", "zh-TW", "앱을 닫았다.", "關掉 AppETF。", "untranslated English token"),
        ("app-fused-prefix", "zh-CN", "앱을 닫았다.", "关掉 ETFApp。", "untranslated English token"),
        ("app-source-substring", "zh-CN", "앱솔루트의 종이를 닫았다.", "关掉 App。", "untranslated English token"),
        ("taeho-fused-token", "zh-TW", "태호를 차단했다.", "封鎖了 TaehoETF。", "untranslated English token"),
        ("sangjin-fused-token", "zh-CN", "박상진의 이름.", "Park SangjinETF的名字。", "untranslated English"),
        ("shares-document-after-etf", "zh-CN", "첫 매수는 ETF 한 주였다.", "第一次买入 ETF 文件一份，放在桌上。", "counter quantity missing/changed"),
        ("shares-reference-without-unit", "zh-TW", "첫 매수는 ETF 한 주였다.", "第一次買進 ETF 文件，那一份，放在桌上。", "counter quantity missing/changed"),
        ("shares-reference-wrong-count", "zh-CN", "첫 매수는 ETF 한 주였다.\n그 한 주가 씨앗이었다.", "第一次买入一份 ETF。\n那两份，是种子。", "counter quantity missing/changed"),
        ("shares-etf-waiting-week", "zh-TW", "ETF 한 주를 기다렸다.", "等候一股 ETF。", "counter quantity missing/changed"),
        ("never-not-future-cn", "zh-CN", "한 번도 찍히지 않은 숫자.", "从未来收到的数字。", "counter quantity missing/changed"),
        ("never-not-future-tw", "zh-TW", "한 번도 찍히지 않은 숫자.", "從未來收到的數字。", "counter quantity missing/changed"),
        ("sangjin-single-alias", "zh-TW", "박상진의 이름.", "Park Sangjin（朴）的名字。", "unapproved Han-character alias"),
        ("sangjin-single-alias-before", "zh-CN", "박상진의 이름.", "（朴）Park Sangjin的名字。", "unapproved Han-character alias"),
        ("taeho-single-alias", "zh-CN", "태호를 차단했다.", "拉黑了 Taeho（泰）。", "unapproved Han-character alias"),
        ("taeho-single-alias-before", "zh-TW", "태호를 차단했다.", "封鎖了（泰）Taeho。", "unapproved Han-character alias"),
        ("taeho-single-alias-latin-bracket", "zh-CN", "태호를 차단했다.", "拉黑了泰（Taeho）。", "unapproved Han-character alias"),
        ("chairs-count", "zh-TW", "비어 있는 의자 세 개.", "兩張空椅子。", "counter quantity missing/changed"),
        ("chairs-unit", "zh-CN", "의자 세 개.", "三人餐桌。", "counter quantity missing/changed"),
        ("table-seats-count", "zh-CN", "네 자리 식탁.", "三人餐桌。", "counter quantity missing/changed"),
        ("table-seats-unit", "zh-TW", "네 자리 식탁.", "四張椅子。", "counter quantity missing/changed"),
        ("table-seats-not-slot", "zh-CN", "네 자리만 남았다.", "四人餐桌。", "counter quantity missing/changed"),
        ("portion-count", "zh-CN", "1인분을 주문했다.", "点了两人份。", "counter quantity missing/changed"),
        ("portion-unit", "zh-TW", "1인분을 주문했다.", "點了一杯。", "counter quantity missing/changed"),
        ("two-names-count", "zh-CN", "두 이름.", "三个名字。", "counter quantity missing/changed"),
        ("two-names-unit", "zh-TW", "두 이름.", "兩張文件。", "counter quantity missing/changed"),
        ("shares-not-week", "zh-CN", "첫 매수는 ETF 한 주였다.", "第一次买入 ETF 是一周。", "counter quantity missing/changed"),
        ("shares-value", "zh-TW", "첫 매수는 ETF 한 주였다.", "第一次買進三股 ETF。", "counter quantity missing/changed"),
        ("shares-document", "zh-CN", "첫 매수는 ETF 한 주였다.", "第一次买入 ETF 是一份文件。", "counter quantity missing/changed"),
        ("shares-not-any-week", "zh-TW", "한 주를 기다렸다.", "等待一股。", "counter quantity missing/changed"),
        ("referenced-sentence-count", "zh-CN", "그 한 문장이 남았다.", "那两句话留下了。", "counter quantity missing/changed"),
        ("referenced-sentence-not-two", "zh-TW", "그 두 문장이 남았다.", "這句話留下了。", "counter quantity missing/changed"),
        ("enabled-time-real-hour", "zh-CN", "선택을 버티게 한 시간이었다. 한 시간 남았다.", "是撑过选择的时间。还剩两小时。", "counter quantity missing/changed"),
        ("real-hour-not-enabled", "zh-TW", "한 시간 남았다.", "還有時間。", "counter quantity missing/changed"),
        ("never-occurrence-twice", "zh-CN", "한 번도 찍히지 않은 숫자.", "两次也没有出现的数字。", "counter quantity missing/changed"),
        ("never-occurrence-affirmed", "zh-TW", "한 번도 찍히지 않은 숫자.", "出現過一次的數字。", "counter quantity missing/changed"),
        ("never-not-once", "zh-CN", "한 번 찍혔다.", "从未出现。", "counter quantity missing/changed"),
        ("retirement-age-changed", "zh-TW", "서른여덟의 아침이었다.", "39歲的一個早晨。", "counter quantity missing/changed"),
        ("retirement-age-unit", "zh-CN", "쉰 전에 일을 놓는다.", "50天以前放下工作。", "counter quantity missing/changed"),
        ("retirement-age-no-number", "zh-TW", "쉰 전에 일을 놓는다.", "以後放下工作。", "counter quantity missing/changed"),
        ("taeho-no-source", "zh-CN", "그를 차단했다.", "拉黑了 Taeho。", "untranslated English token"),
        ("taeho-han-only", "zh-TW", "태호를 차단했다.", "封鎖了泰浩。", "canonical prepared form"),
        ("sangjin-no-source", "zh-CN", "그 이름.", "Park Sangjin 这个名字。", "untranslated English phrase"),
        ("sangjin-han-alias", "zh-TW", "박상진의 이름.", "Park Sangjin（朴相鎮）的名字。", "unapproved Han-character alias"),
        ("app-no-source", "zh-CN", "종이를 닫았다.", "关掉 App。", "untranslated English token"),
        ("app-token-prefix", "zh-TW", "앱을 닫았다.", "關掉 Application。", "untranslated English token"),
        ("bare-large-still-money", "zh-CN", "계약금 100만.", "签约金100万。", "Korean-won values changed"),
        ("rooms-wrong-count", "zh-CN", "방 세 개짜리 집.", "有两间卧室的家。", "counter quantity missing/changed"),
        ("rooms-wrong-unit", "zh-TW", "방 세 개짜리 집.", "有三個人的家。", "counter quantity missing/changed"),
        ("rooms-no-count", "zh-CN", "방 세 개짜리 집.", "有卧室的家。", "counter quantity missing/changed"),
        ("rooms-not-boxes", "zh-TW", "상자 세 개였다.", "有三間臥室。", "counter quantity missing/changed"),
        ("parents-four", "zh-CN", "두 부모를 모실 방.", "接四位长辈来住的房间。", "counter quantity missing/changed"),
        ("parents-missing", "zh-TW", "두 부모를 모실 방.", "安頓父母的房間。", "counter quantity missing/changed"),
        ("parents-wrong-unit", "zh-CN", "두 부모 방.", "两个房间。", "counter quantity missing/changed"),
        ("parents-not-people", "zh-TW", "두 사람의 방.", "安頓父親和 Daeun 的母親的房間。", "counter quantity missing/changed"),
        ("concept-three", "zh-CN", "그 둘의 경계는 흐릿했다.", "三者的界线模糊了。", "counter quantity missing/changed"),
        ("concept-missing", "zh-TW", "그 둘의 경계는 흐릿했다.", "界線模糊了。", "counter quantity missing/changed"),
        ("concept-not-people", "zh-CN", "둘은 남았다.", "两者留下了。", "counter quantity missing/changed"),
        ("document-two", "zh-TW", "등기 한 장.", "兩份產權登記文件。", "counter quantity missing/changed"),
        ("document-missing", "zh-CN", "서류 한 장.", "文件。", "counter quantity missing/changed"),
        ("document-not-photo", "zh-TW", "사진 한 장.", "一紙文件。", "counter quantity missing/changed"),
        ("document-not-meal", "zh-CN", "서류 한 장.", "一份饭。", "counter quantity missing/changed"),
        ("won-rhetorical-missing", "zh-TW", "30억. 어떤 원화도.", "30億韓元。", "rhetorical Korean-won phrase"),
        ("won-rhetorical-invented", "zh-CN", "30억.", "30亿韩元。每一韩元。", "rhetorical Korean-won phrase"),
        ("won-rhetorical-amount-unlabeled", "zh-TW", "30억. 어떤 원화도.", "30億。每一韓元。", "Korean-won values changed"),
        ("won-rhetorical-value-changed", "zh-CN", "30억. 어떤 원화도.", "3亿韩元。每一韩元。", "Korean-won values changed"),
        ("won-rhetorical-duplicate", "zh-TW", "30억. 어떤 원화도.", "30億韓元。每一韓元。每一韓元。", "rhetorical Korean-won phrase"),
        ("won-rhetorical-literal-one", "zh-CN", "30억. 어떤 원화도.", "30亿韩元。1韩元。", "Korean-won values changed"),
        ("monthly-wrong-frequency", "zh-CN", "한 달에 한 번", "每月两次", "counter quantity missing/changed"),
        ("monthly-wrong-period", "zh-TW", "한 달에 한 번", "每年一次", "counter quantity missing/changed"),
        ("monthly-longer-period", "zh-CN", "한 달에 한 번", "每三个月一次", "counter quantity missing/changed"),
        ("monthly-not-two-months", "zh-TW", "두 달에 한 번", "每月一次", "counter quantity missing/changed"),
        ("monthly-not-deadline", "zh-CN", "한 달을 기다렸다.", "每月等待。", "counter quantity missing/changed"),
        ("repeated-three-month-two", "zh-CN", "석 달마다 병원에 갔다.", "每隔两个月去医院。", "counter quantity missing/changed"),
        ("repeated-three-month-four", "zh-TW", "석 달마다 병원에 갔다.", "每隔四個月去醫院。", "counter quantity missing/changed"),
        ("repeated-three-month-calendar", "zh-CN", "석 달마다 병원에 갔다.", "每年三月去医院。", "counter quantity missing/changed"),
        ("repeated-three-month-once", "zh-TW", "석 달마다 병원에 갔다.", "三個月去醫院。", "counter quantity missing/changed"),
        ("ordinal-call-third", "zh-CN", "두 번째 전화", "第三通电话", "counter quantity missing/changed"),
        ("ordinal-call-message", "zh-TW", "두 번째 전화", "第二通訊息", "counter quantity missing/changed"),
        ("ordinal-call-not-check", "zh-CN", "두 번째 확인", "第二通电话", "counter quantity missing/changed"),
        ("ordinal-call-not-rings", "zh-TW", "두 번째 전화", "響了兩聲", "counter quantity missing/changed"),
        ("financial-tier-reordered", "zh-CN", "1금융과 2금융", "第二金融圈和第一金融圈", "counter quantity missing/changed"),
        ("financial-tier-third", "zh-TW", "1금융과 2금융", "第一金融圈和第三金融圈", "counter quantity missing/changed"),
        ("financial-tier-deleted", "zh-CN", "1금융과 2금융", "第一金融圈", "counter quantity missing/changed"),
        ("financial-tier-other-number", "zh-TW", "1번과 2번", "第一金融圈和第二金融圈", "counter quantity missing/changed"),
        ("im-without-source", "zh-CN", "그 사람 빚", "那个 Im 先生的债", "untranslated English token"),
        ("im-source-word-boundary", "zh-TW", "담임씨는 왔다.", "Im 先生來了。", "untranslated English token"),
        ("im-wrong-case", "zh-CN", "그 임씨 빚", "那个 im 先生的债", "Romanized form 'Im'"),
        ("im-token-prefix", "zh-TW", "그 임씨 빚", "Imitation 的債", "Romanized form 'Im'"),
        ("im-new-han-name", "zh-CN", "그 임씨 빚", "林先生的债", "Romanized form 'Im'"),
        ("im-han-alias", "zh-TW", "그 임씨 빚", "Im（林某）的債", "unapproved Han-character alias"),
        ("im-single-han-alias", "zh-TW", "그 임씨 빚", "與 Im（林）有關的債", "unapproved Han-character alias"),
        ("im-single-han-alias-before", "zh-CN", "그 임씨 빚", "与（林）Im有关的债", "unapproved Han-character alias"),
        ("im-single-han-alias-latin-bracket", "zh-TW", "그 임씨 빚", "林（Im）的債", "unapproved Han-character alias"),
        ("im-single-han-alias-latin-bracket-before", "zh-CN", "그 임씨 빚", "（Im）林的债", "unapproved Han-character alias"),
        ("im-single-han-alias-square", "zh-TW", "그 임씨 빚", "Im[任]的債", "unapproved Han-character alias"),
        ("im-single-han-alias-square-before", "zh-CN", "그 임씨 빚", "[任]Im的债", "unapproved Han-character alias"),
        ("im-single-han-alias-without-source", "zh-TW", "그 사람 빚", "與 Im（林）有關的債", "untranslated English token"),
        ("print-copy-six", "zh-CN", "초판 5만 부.", "首印6万册。", "counter quantity missing/changed"),
        ("print-copy-missing-scale", "zh-TW", "초판 5만 부.", "首刷5本。", "counter quantity missing/changed"),
        ("print-copy-money-instead", "zh-CN", "초판 5만 부.", "首印5万韩元。", "Korean-won values changed"),
        ("print-copy-won-still-money", "zh-TW", "초판 5만원.", "首刷5萬本。", "Korean-won values changed"),
        ("print-copy-other-unit", "zh-CN", "초판 5만 부.", "首印5万年。", "counter quantity missing/changed"),
        ("print-copy-fee-unit-deleted", "zh-TW", "초판 5만 부. 계약금 5만원.", "首刷5萬本。簽約金5萬。", "Korean-won values changed"),
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
            "ring-count-drift", "zh-CN", "수신음이 두 번 울렸다.",
            "回铃音响了三声。", "counter quantity missing/changed",
        ),
        (
            "ring-count-missing", "zh-TW", "수신음이 두 번 울렸다.",
            "回鈴音響了。", "counter quantity missing/changed",
        ),
        (
            "non-ring-sound-classifier", "zh-CN", "두 번은 확인했다.",
            "确认了两声。", "counter quantity missing/changed",
        ),
        (
            "demonstrative-not-two-meals", "zh-TW", "그때 만든 두 끼.",
            "當時的那頓飯。", "counter quantity missing/changed",
        ),
        (
            "actual-two-won-not-a-wish", "zh-CN", "이 원을 냈다.",
            "付了3韩元。", "Korean-won values changed",
        ),
        (
            "actual-won-label-retained", "zh-TW", "200원을 냈다.",
            "付了200。", "Korean won amount must use",
        ),
        (
            "formatted-won-comparison-unit", "zh-CN", "%s원보다 적었다.",
            "比%s还少。", "Korean won amount must use",
        ),
        (
            "formatted-won-only-unit", "zh-TW", "%d원밖에 없다.",
            "只剩%d。", "Korean won amount must use",
        ),
        (
            "box-only-classifier-value", "zh-CN", "박스 두 개였다.",
            "是三只箱子。", "counter quantity missing/changed",
        ),
        (
            "box-classifier-value", "zh-TW", "상자 두 개였다.",
            "總共三箱。", "counter quantity missing/changed",
        ),
        (
            "box-count-missing", "zh-CN", "박스 두 개였다.",
            "只有箱子。", "counter quantity missing/changed",
        ),
        (
            "box-not-unrelated-only-classifier", "zh-CN", "박스 두 개였다.",
            "有两只鸟。", "counter quantity missing/changed",
        ),
        (
            "box-not-generic-entity", "zh-TW", "사과 두 개였다.",
            "有兩箱。", "counter quantity missing/changed",
        ),
        (
            "box-not-person-counter", "zh-CN", "사람 두 명이었다.",
            "有两只箱子。", "counter quantity missing/changed",
        ),
        (
            "character-count-value", "zh-CN", "두 글자가 남았다.",
            "留下三个字。", "counter quantity missing/changed",
        ),
        (
            "character-count-missing", "zh-TW", "두 글자가 남았다.",
            "留下文字。", "counter quantity missing/changed",
        ),
        (
            "character-not-heading", "zh-TW", "두 글자가 남았다.",
            "留下兩個標題。", "counter quantity missing/changed",
        ),
        (
            "heading-count-value", "zh-TW", "두 제목을 적었다.",
            "寫了三個標題。", "counter quantity missing/changed",
        ),
        (
            "heading-count-missing", "zh-CN", "두 제목을 적었다.",
            "写下标题。", "counter quantity missing/changed",
        ),
        (
            "heading-not-character", "zh-CN", "두 제목을 적었다.",
            "写了两个字。", "counter quantity missing/changed",
        ),
        (
            "look-count-value", "zh-CN", "박스를 두 번 보고 돌아섰다.",
            "看了一眼箱子，转过身。", "counter quantity missing/changed",
        ),
        (
            "look-count-missing", "zh-TW", "박스를 한 번 보고 돌아섰다.",
            "看看箱子後轉身。", "counter quantity missing/changed",
        ),
        (
            "eye-classifier-not-confirmation", "zh-CN", "한 번 확인했다.",
            "确认了一眼。", "counter quantity missing/changed",
        ),
        (
            "eye-classifier-not-collision", "zh-TW", "열쇠가 한 번 부딪혔다.",
            "鑰匙碰了一眼。", "counter quantity missing/changed",
        ),
        (
            "glance-not-physical-eye", "zh-CN", "박스를 한 번 보고 돌아섰다.",
            "只剩一眼，转过身。", "counter quantity missing/changed",
        ),
        (
            "answered-call-ring-value", "zh-TW",
            "아버지의 연락처를 눌렀다. 아버지는 두 번 만에 받았다.",
            "按下父親的聯絡人。響了三聲，父親接起電話。",
            "counter quantity missing/changed",
        ),
        (
            "answered-call-ring-missing", "zh-CN",
            "아버지의 연락처를 눌렀다. 아버지는 두 번 만에 받았다.",
            "按下父亲的联系人。父亲接了电话。",
            "counter quantity missing/changed",
        ),
        (
            "receiving-parcel-not-ringing", "zh-TW", "택배를 두 번 만에 받았다.",
            "響了兩聲就收到包裹。", "counter quantity missing/changed",
        ),
        (
            "prior-call-not-document-ringing", "zh-CN",
            "전화를 걸었다. 서류를 두 번 만에 받았다.",
            "打过电话。文件两声才收到。", "counter quantity missing/changed",
        ),
        (
            "prior-call-not-topic-document-ringing", "zh-CN",
            "전화를 걸었다. 서류는 두 번 만에 받았다.",
            "打过电话。响了两声，文件就收到了。", "counter quantity missing/changed",
        ),
        (
            "father-contact-not-topic-document-ringing", "zh-TW",
            "아버지의 연락처를 눌렀다. 서류는 두 번 만에 받았다.",
            "按下父親的聯絡人。響了兩聲，文件就收到了。",
            "counter quantity missing/changed",
        ),
        (
            "father-contact-not-object-document-ringing", "zh-CN",
            "아버지의 연락처를 눌렀다. 아버지는 서류를 두 번 만에 받았다.",
            "按下父亲的联系人。响了两声，父亲就收到文件。",
            "counter quantity missing/changed",
        ),
        (
            "desk-space-count-value", "zh-CN",
            "책상 위에는 수첩이 한 칸씩 자리를 차지했다.",
            "书桌上的笔记本各占两处。", "counter quantity missing/changed",
        ),
        (
            "desk-space-count-missing", "zh-TW",
            "책상 위에는 수첩이 한 칸씩 자리를 차지했다.",
            "書桌上的筆記本占了地方。", "counter quantity missing/changed",
        ),
        (
            "table-cell-not-place", "zh-CN", "표의 한 칸을 채웠다.",
            "填了一处。", "counter quantity missing/changed",
        ),
        (
            "desk-table-cell-not-physical-space", "zh-TW",
            "책상 위에는 표의 한 칸이 비어 있었다.",
            "書桌上的表格空著一塊地方。", "counter quantity missing/changed",
        ),
        (
            "first-line-not-second", "zh-TW", "첫 줄에 적었다.",
            "寫在第二行。", "counter quantity missing/changed",
        ),
        (
            "second-line-not-first-lexeme", "zh-TW", "두 번째 줄에 적었다.",
            "寫在首行。", "counter quantity missing/changed",
        ),
        (
            "first-line-missing", "zh-CN", "첫 줄에 적었다.",
            "写了下来。", "counter quantity missing/changed",
        ),
        (
            "first-week-not-line", "zh-TW", "첫 주에 적었다.",
            "寫在首行。", "counter quantity missing/changed",
        ),
        (
            "causative-still-requires-first-week", "zh-TW",
            "기다리게 한 사람이 있었다. 첫 주는 비었다. 사람 한 명을 적었다.",
            "有被留下等待的人。第二週空白。寫下一個人。",
            "counter quantity missing/changed",
        ),
        (
            "actual-one-person-not-causative", "zh-CN",
            "한 사람이 기다렸다. 첫 주는 비었다.",
            "有人等待。第一周空着。", "counter quantity missing/changed",
        ),
        (
            "hanpd-source-scope", "zh-CN", "건설사에서 왔다.",
            "来自HanPD 建设。", "untranslated English token",
        ),
        (
            "hanpd-similar-source-not-owner", "zh-TW", "한 건설사에서 왔다.",
            "來自HanPD 建設。", "untranslated English token",
        ),
        (
            "hanpd-no-extra-english", "zh-CN", "한PD건설에서 왔다.",
            "来自HanPD 建设，Money。", "untranslated English token",
        ),
        (
            "hanpd-region-still-locked", "zh-TW", "한PD건설에서 왔다.",
            "來自HanPD 建设。", "regional script mismatch",
        ),
        (
            "shared-qun-does-not-allow-mixed-script", "zh-TW", "한 무리였다.",
            "那一群人很鲜艳。", "regional script mismatch",
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
            "colloquial-per-item-money", "zh-CN", "건당 백.",
            "每个10万韩元。", "Korean-won values changed",
        ),
        (
            "hanbit-invented-hanja", "zh-CN", "한빛유통에서 일한다",
            "在韩光流通工作", "canonical prepared form",
        ),
        (
            "hanbit-exact-extra-prose", "zh-CN", "한빛유통",
            "在Hanbit 流通工作", "exact prepared form mismatch",
        ),
        (
            "hanbit-unrelated-source", "zh-CN", "다른 회사에서 일한다",
            "在Hanbit 流通工作", "untranslated English token",
        ),
        (
            "tw-shared-bed-keeps-script-gate", "zh-TW", "침대에서 문을 연다",
            "在床上开门", "regional script mismatch",
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
            "native-three-month-two", "zh-CN", "석 달",
            "两个月", "counter quantity missing/changed",
        ),
        (
            "native-three-month-four", "zh-TW", "석 달",
            "四個月", "counter quantity missing/changed",
        ),
        (
            "message-counter-cn-value", "zh-CN", "문자 한 통",
            "两则短信", "counter quantity missing/changed",
        ),
        (
            "message-counter-tw-value", "zh-TW", "문자 한 통",
            "兩則訊息", "counter quantity missing/changed",
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

    for lang, source, target, label in (
        (
            "zh-CN", "통장 세 개 더 구하면 건당 백.",
            "再弄三个存折，每个100万韩元。", "per-item money",
        ),
        (
            "zh-TW", "통장 세 개 더 구하면 건당 백.",
            "再弄三個帳戶，每個100萬韓元。", "per-item money",
        ),
        ("zh-CN", "한빛유통", "Hanbit 流通", "exact Hanbit business"),
        (
            "zh-CN", "한빛유통에서 일한다", "在Hanbit 流通工作",
            "scoped Hanbit business",
        ),
        (
            "zh-TW", "한빛유통에서 일한다", "在Hanbit 流通工作",
            "scoped Hanbit business",
        ),
        ("zh-TW", "침대에 눕는다", "躺到床上", "Taiwan shared 床"),
    ):
        cases += 1
        scoped_errors = validate_text(
            lang, f"self-test::scoped-{label}", source, target,
        )
        if scoped_errors:
            failures.append(
                f"valid scoped {label} row failed {lang}: {scoped_errors}"
            )

    valid_semantic_rows = (
        ("zh-TW", "비어 있는 의자 세 개.", "三張空椅子。"),
        ("zh-CN", "의자 세 개가 비었다.", "三把椅子空着。"),
        ("zh-CN", "네 자리 식탁.", "四人餐桌。"),
        ("zh-TW", "네 자리 식탁.", "四人餐桌。"),
        ("zh-CN", "1인분을 주문했다.", "点了一人份。"),
        ("zh-TW", "1인분을 주문했다.", "點了一人份。"),
        ("zh-CN", "두 이름.", "两个名字。"),
        ("zh-TW", "두 이름.", "兩個名字。"),
        ("zh-CN", "첫 매수는 ETF 한 주였다.\n그 한 주가 씨앗이었다.", "第一次买入，是一份 ETF。\n那一份，是种子。"),
        ("zh-TW", "첫 매수는 ETF 한 주였다.\n그 한 주가 씨앗이었다.", "第一次買進一股 ETF。\n那一股是種子。"),
        ("zh-CN", "그 한 문장이 남았다.", "那句话留下了。"),
        ("zh-TW", "그 한 문장이 남았다.", "這句話留下了。"),
        ("zh-CN", "선택을 버티게 한 시간이었다.", "是撑过选择的时间。"),
        ("zh-TW", "선택을 버티게 한 시간이었다. 한 시간 남았다.", "是撐過選擇的時間。還剩一小時。"),
        ("zh-CN", "한 번도 찍히지 않은 숫자.", "从未出现的数字。"),
        ("zh-TW", "한 번도 찍히지 않은 숫자.", "從未出現的數字。"),
        ("zh-CN", "한 번도 찍히지 않은 숫자.", "一次也没有出现的数字。"),
        ("zh-TW", "서른여덟의 아침이었다. 쉰 전에 일을 놓는다.", "38歲的一個早晨。50歲以前放下工作。"),
        ("zh-CN", "서른여덟의 아침이었다. 쉰 전에 일을 놓는다.", "三十八岁的早晨。五十岁以前放下工作。"),
        ("zh-TW", "박상진의 이름.", "Park Sangjin 的名字。"),
        ("zh-CN", "태호를 차단했다.", "拉黑了 Taeho。"),
        ("zh-TW", "앱을 닫았다.", "關掉 App。"),
        ("zh-TW", "앱을 닫았다.", "關掉應用程式。"),
        ("zh-CN", "앱을 닫았다.", "关掉软件。"),
        ("zh-CN", "방 세 개짜리 집.", "有三间卧室的家。"),
        ("zh-TW", "방 세 개짜리 집.", "有三間臥室的家。"),
        ("zh-CN", "두 부모를 모실 방.", "接两位长辈来住的房间。"),
        ("zh-TW", "두 부모 방.", "安頓兩位長輩的房間。"),
        ("zh-TW", "다은. 두 부모 방.", "Daeun。安頓父親和 Daeun 的母親的房間。"),
        ("zh-CN", "그 둘의 경계는 흐릿했다.", "两者的界线模糊了。"),
        ("zh-TW", "그 둘의 경계는 흐릿했다.", "兩者的界線模糊了。"),
        ("zh-TW", "등기 한 장.", "一份產權登記文件。"),
        ("zh-CN", "등기 한 장.", "一份产权登记文件。"),
        ("zh-TW", "서류 한 장.", "一紙文件。"),
        ("zh-CN", "서류 한 장.", "一张文件。"),
        ("zh-CN", "30억. 어떤 원화도.", "30亿韩元。每一韩元。"),
        ("zh-TW", "30억. 어떤 원화도.", "30億韓元。每一韓元。"),
        ("zh-TW", "30억. 어떤 원화도.", "30億韓元。任何韓元。"),
        ("zh-TW", "그 임씨 빚", "與 Im 有關的債"),
        ("zh-CN", "그 임씨 빚", "Im先生的债"),
        ("zh-CN", "한 달에 한 번", "每月一次"),
        ("zh-TW", "한 달에 한 번", "每月一次"),
        ("zh-CN", "한 달에 한 번", "一个月一次"),
        ("zh-TW", "한 달에 한 번", "一個月一次"),
        ("zh-CN", "석 달마다 병원에 갔다.", "每隔三个月去医院。"),
        ("zh-TW", "석 달마다 병원에 갔다.", "每三個月去醫院。"),
        ("zh-CN", "두 번째 전화", "第二通电话"),
        ("zh-TW", "두 번째 전화", "第二通電話"),
        ("zh-TW", "두 번째 전화", "第二次打來的電話"),
        ("zh-CN", "1금융과 2금융", "第一金融圈和第二金融圈"),
        ("zh-TW", "1금융과 2금융", "第1金融圈和第2金融圈"),
        ("zh-CN", "그 임씨 빚", "那个 Im 先生的债"),
        ("zh-TW", "그 임씨 빚", "那個姓 Im 的人的債"),
        ("zh-CN", "초판 5만 부.", "首印5万册。"),
        ("zh-TW", "초판 5만 부.", "首刷5萬本。"),
        ("zh-CN", "초판 5만 부.", "首印五万册。"),
        ("zh-TW", "초판 5만 부.", "首刷50000本。"),
        ("zh-CN", "초판 5만 부. 계약금 5만원.", "首印5万册。签约金5万韩元。"),
        ("zh-TW", "초판 5만원.", "首刷5萬韓元。"),
        ("zh-CN", "박스 두 개였다.", "是两只箱子。"),
        ("zh-TW", "박스 두 개였다.", "是兩只箱子。"),
        ("zh-CN", "상자 두 개였다.", "总共两箱。"),
        ("zh-TW", "상자 두 개였다.", "總共兩箱。"),
        ("zh-CN", "박스 두 개였다.", "是两个箱子。"),
        ("zh-TW", "상자 두 개였다.", "是兩個箱子。"),
        ("zh-CN", "두 글자가 남았다.", "留下两个字。"),
        ("zh-TW", "두 글자가 남았다.", "留下兩個字。"),
        ("zh-TW", "두 글자가 남았다.", "留下兩字。"),
        ("zh-CN", "두 제목을 적었다.", "写了两个标题。"),
        ("zh-TW", "두 제목을 적었다.", "寫了兩個標題。"),
        ("zh-CN", "박스를 한 번 보고 돌아섰다.", "看了一眼箱子，转过身。"),
        ("zh-TW", "박스를 한 번 보고 돌아섰다.", "看了一眼箱子後轉身。"),
        (
            "zh-TW", "박스를 한 번 보고, 열쇠가 한 번 부딪혔다.",
            "看了一眼箱子，鑰匙碰了一下。",
        ),
        (
            "zh-CN", "아버지의 연락처를 눌렀다. 아버지는 두 번 만에 받았다.",
            "按下父亲的联系人。响了两声，父亲接了电话。",
        ),
        (
            "zh-TW", "아버지의 연락처를 눌렀다. 아버지는 두 번 만에 받았다.",
            "按下父親的聯絡人。響了兩聲，父親接起電話。",
        ),
        (
            "zh-CN", "책상 위에는 수첩이 한 칸씩 자리를 차지했다.",
            "书桌上的笔记本各占一处。",
        ),
        (
            "zh-TW", "책상 위에는 수첩이 한 칸씩 자리를 차지했다.",
            "書桌上的筆記本各占一塊地方。",
        ),
        ("zh-CN", "첫 줄에 적었다.", "写在首行。"),
        ("zh-TW", "첫 줄에 적었다.", "寫在首行。"),
        (
            "zh-CN", "기다리게 한 사람이 있었다. 첫 주는 비었다. 사람 한 명을 적었다.",
            "有被留下等待的人。第一周空着。写下一个人。",
        ),
        (
            "zh-TW", "기다리게 한 사람이 있었다. 첫 주는 비었다. 사람 한 명을 적었다.",
            "有被留下等待的人。第一週空白。寫下一個人。",
        ),
        ("zh-CN", "한PD건설", "HanPD 建设"),
        ("zh-TW", "한PD건설", "HanPD 建設"),
        ("zh-CN", "한PD건설에서 왔다.", "来自HanPD 建设。"),
        ("zh-TW", "한PD건설에서 왔다.", "來自HanPD 建設。"),
        ("zh-CN", "한 무리였다.", "那是一群人。"),
        ("zh-TW", "한 무리였다.", "那是一群人。"),
        ("zh-CN", "둘이 원한 만큼만 했다.", "只办到了两个人想要的规模。"),
        ("zh-TW", "둘이 원한 만큼만 했다.", "只辦成兩個人想要的樣子。"),
        ("zh-CN", "수신음이 두 번 울렸다.", "回铃音响了两声。"),
        ("zh-TW", "수신음이 두 번 울렸다.", "回鈴音響了兩聲。"),
        ("zh-CN", "그때 만든 한 끼.", "当时的那顿饭。"),
        ("zh-TW", "그때 만든 한 끼.", "當時的那頓飯。"),
        ("zh-CN", "이 원을 냈다.", "付了2韩元。"),
        ("zh-TW", "이 원을 냈다.", "付了2韓元。"),
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
        ("zh-CN", "석 달", "三个月"),
        ("zh-TW", "석 달", "三個月"),
        ("zh-CN", "문자 한 통", "一则短信"),
        ("zh-TW", "문자 한 통", "一則訊息"),
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
    ].pop("강남 아파트", None)
    if not chinese_contract_errors(changed):
        failures.append("101-key collision partition mutation was not rejected")

    cases += 1
    expected_inventory = _static_ui_inventory()
    expected_legacy_total = len(expected_inventory.legacy_blueprint)
    expected_context_total = len(expected_inventory.planned_context_blueprint)
    for lang in LANGUAGES:
        (
            legacy_covered,
            legacy_total,
            context_covered,
            context_total,
            story_demo_covered,
            story_demo_total,
            skeleton_errors,
        ) = static_ui_coverage(lang, runtime, False, {})
        non_owner_errors = [
            error for error in skeleton_errors
            if "required story-demo UI coverage" not in error
        ]
        if legacy_covered != 0 or legacy_total != expected_legacy_total \
                or context_covered != 0 \
                or context_total != expected_context_total \
                or story_demo_covered != 0 \
                or story_demo_total != EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS \
                or non_owner_errors:
            failures.append(
                f"empty {lang} two-layer skeleton was rejected: "
                f"legacy={legacy_covered}/{legacy_total} "
                f"context={context_covered}/{context_total} "
                f"story_demo={story_demo_covered}/{story_demo_total} "
                f"errors={skeleton_errors}"
            )
        if not any(
            f"required story-demo UI coverage "
            f"0/{EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS}" in error
            for error in skeleton_errors
        ):
            failures.append(
                f"empty {lang} story-demo UI owner mutation escaped"
            )
        *_coverage, strict_errors = static_ui_coverage(lang, runtime, True, {})
        if not any("strict legacy static_ui coverage" in error for error in strict_errors):
            failures.append(f"empty {lang} strict legacy UI mutation escaped")
        if not any(
            f"strict context static_ui coverage 0/{expected_context_total}" in error
                   for error in strict_errors):
            failures.append(f"empty {lang} strict context UI mutation escaped")

    cases += 1
    for lang in LANGUAGES:
        live_ui = read_json(ROOT / "locale" / f"ui_{lang}.json")
        (
            _legacy_covered,
            _legacy_total,
            _context_covered,
            _context_total,
            story_demo_covered,
            story_demo_total,
            live_ui_errors,
        ) = static_ui_coverage(lang, runtime, False, live_ui)
        if story_demo_covered != EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS \
                or story_demo_total != EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS \
                or live_ui_errors:
            failures.append(
                f"live {lang} story-demo UI owner failed: "
                f"{story_demo_covered}/{story_demo_total} {live_ui_errors}"
            )

        story_pairs, story_source_errors = _story_demo_exclusive_ui_pairs(
            runtime, expected_inventory
        )
        owner_keys = set(story_pairs)
        if story_source_errors:
            failures.append(
                f"{lang} story-demo UI source collector failed: "
                f"{story_source_errors}"
            )
        if not owner_keys:
            continue
        removed = dict(live_ui)
        removed.pop(sorted(owner_keys)[0])
        *_coverage, removed_errors = static_ui_coverage(
            lang, runtime, False, removed
        )
        if not any(
            f"required story-demo UI coverage "
            f"{EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS - 1}/"
            f"{EXPECTED_STORY_DEMO_EXCLUSIVE_UI_KEYS}" in error
            for error in removed_errors
        ):
            failures.append(
                f"missing {lang} story-demo UI owner key mutation escaped"
            )

        invalid = dict(live_ui)
        invalid_source = sorted(owner_keys)[0]
        invalid[invalid_source] = invalid_source
        *_coverage, invalid_errors = static_ui_coverage(
            lang, runtime, False, invalid
        )
        if not any("Hangul remains" in error for error in invalid_errors):
            failures.append(
                f"invalid {lang} story-demo UI owner target mutation escaped"
            )

    cases += 1
    *_coverage, unknown_errors = static_ui_coverage(
        "zh-CN", runtime, False, {"ui.unknown_context": "未知"}
    )
    if not any("unknown source keys" in error for error in unknown_errors):
        failures.append("unknown Chinese context dictionary key was accepted")

    cases += 1
    duplicate_source = sorted(expected_inventory.legacy_blueprint)[0]
    duplicate_key = json.dumps(duplicate_source, ensure_ascii=False)
    duplicate_fixture = (
        "{" + duplicate_key + ":\"first\"," + duplicate_key + ":\"last\"}"
    )
    *_coverage, duplicate_errors = static_ui_coverage(
        "zh-CN",
        runtime,
        False,
        {duplicate_source: "last"},
        raw_text_override=duplicate_fixture,
    )
    if not any("duplicate raw JSON keys" in error for error in duplicate_errors):
        failures.append("duplicate Chinese raw UI key mutation escaped")

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
            ui_story_demo_covered,
            ui_story_demo_total,
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
            f"ui_story_demo={ui_story_demo_covered}/{ui_story_demo_total} "
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
