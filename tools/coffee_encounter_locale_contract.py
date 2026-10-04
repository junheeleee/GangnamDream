"""Exact coffee-encounter meanings; numeric comparison only, never UI copy.

The owned event title counts a meeting, not a cup. The Japanese recollection
retains every character after its corrected opening. Other addresses/locales
remain outside this contract, including the already-correct static UI title.
"""
from __future__ import annotations

EVENT_ID = "arc_sangchul_02_coffee"
EVENT_KEY = "events:" + EVENT_ID + ":/title"
EVENT_SOURCE = "두 번째 커피"
EVENT_SOURCE_PATH = "content/events/arc_events.json"
EVENT_SOURCE_SHA256 = "a10464294daad385d8ffc075dd038fbb8b9d9ddae141e10ba54c50a18b3bb6b4"
EVENT_TARGETS = {"ja": "二度目のコーヒー", "zh-CN": "第二次咖啡闲谈", "zh-TW": "第二次喝咖啡"}
EVENT_BEFORE_TARGETS = {"ja": "二杯目のコーヒー", "zh-CN": "第二杯咖啡", "zh-TW": "第二杯咖啡"}
RECALL_SOURCE = "두 번째 커피 이후로 임상철은 진짜 이야기를 시작했다. 30년의 눈이 담긴 이야기들."
RECALL_KEY = "ui:" + RECALL_SOURCE + ":/" + RECALL_SOURCE
RECALL_SOURCE_PATH = "runtime:static_ui"
RECALL_SOURCE_SHA256 = "05ec1e8e01d2c43391cf4a676452f58b712adb3137dd4b326a8e0ee8eba4a52b"
RECALL_BEFORE_TARGET = "二杯目のコーヒーの後、イム・サンチョルは本題を語り始めた。三十年の眼が込められた物語だ。"
RECALL_TARGET = "二度目のコーヒーの後、イム・サンチョルは本題を語り始めた。三十年の眼が込められた物語だ。"


def coffee_encounter_numbers(locale, key, source, target, *, source_path=None, source_sha256=None):
    """Return a numeric pair/errors only for the four declared locale leaves.

An owned address with drifted source identity is an error, never an exemption.
The direct Chinese validator supplies an exact ID/source; the official Leaf
path additionally supplies its physical origin and canonical source digest.
Only a complete canonical corrected target gets numeric normalization. All
other validators must continue receiving the original source and target.
    """
    if key == EVENT_KEY and locale in EVENT_TARGETS:
        expected_source, expected_path, expected_hash = EVENT_SOURCE, EVENT_SOURCE_PATH, EVENT_SOURCE_SHA256
        expected_target = EVENT_TARGETS[locale]
    elif key == RECALL_KEY and locale == "ja":
        expected_source, expected_path, expected_hash = RECALL_SOURCE, RECALL_SOURCE_PATH, RECALL_SOURCE_SHA256
        expected_target = RECALL_TARGET
    else:
        return None
    if (source != expected_source or source_path not in (None, expected_path)
            or source_sha256 not in (None, expected_hash)):
        return source, target, ["source-bound coffee encounter address/source identity mismatch"]
    if target != expected_target:
        return source, target, ["source-bound coffee encounter ordinal/cup/wording mismatch"]
    if locale == "ja":
        numeric_source = source.replace("두 번째", "2번째", 1)
        numeric_target = target.replace("二度目", "2度目", 1)
        if key == RECALL_KEY:
            # Preserve the exact thirty-year clause, normalizing only its
            # written digits for the existing Arabic-number comparison.
            numeric_target = numeric_target.replace("三十年", "30年", 1)
        return numeric_source, numeric_target, []
    # Reuse the already-established occasion interpretation, not ordinal cups.
    return source.replace("커피", "대화", 1), target, []
