#!/usr/bin/env python3
"""Exact MetaProgression 242 insertion inverse for historical source audits.

The approved live file must match before its historical observation is exposed.
This helper neither changes source nor accepts an old file as a live rollback.
The semantic UI collector keeps its separate ID/field/pair ownership contract.
"""

from __future__ import annotations

import hashlib
import json


META_TITLE_PATH = "autoloads/MetaProgression.gd"
PREVIOUS_SHA256 = "a36617f4979e08a37e89cecc0566a4e64d54bb5373469e2fa1e162d10dde34dc"
CURRENT_SHA256 = "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58"
# The reviewed single insertion, including its comments and exact LF boundary.
# Registry seam for the pre-code finite fault cases; not a caller-supplied rule.
META_TITLE_TRANSITION = (
    META_TITLE_PATH, PREVIOUS_SHA256, CURRENT_SHA256, (
        "\t# Only these existing title fields opt into prepared-language UI lookup.\n"
        "\t# Preserve KO/EN compatibility, raw constants, and every unselected title.\n"
        "\tmatch title_id:\n"
        "\t\t\"gosiwon_survivor\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"고시원 생존자\", \"Gosiwon Survivor\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"고시원에서 12개월을 버텼다. 이 경험은 잊지 못할 것이다.\", \"Survived 12 months in a gosiwon. You will not forget that room.\")\n"
        "\t\t\"first_move\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"첫 이사\", \"First Move\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"처음으로 고시원을 벗어나 새 공간으로 이사했다.\", \"Left the gosiwon for the first time and moved into a new space.\")\n"
        "\t\t\"apartment_life\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"아파트 입성\", \"Apartment Life\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"드디어 아파트에 살게 됐다. 경비 아저씨가 반겨준다.\", \"Finally living in an apartment. Even the security guard greets you.\")\n"
        "\t\t\"gangnam_resident\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"강남 입성\", \"Gangnam Resident\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"강남 아파트. 주소만으로도 사람들의 눈빛이 달라진다.\", \"A Gangnam apartment. The address alone changes how people look at you.\")\n"
        "\t\t\"long_gosiwon\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"고시원 장기거주자\", \"Long-Term Gosiwon Tenant\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"고시원 24개월. 이제 이 냄새도 집냄새처럼 느껴진다.\", \"24 months in a gosiwon. Even the smell has started to feel like home.\")\n"
        "\t\t\"first_paycheck\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"첫 월급의 무게\", \"Weight of the First Paycheck\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"통장에 처음으로 월급이 찍혔다. 기쁘면서도 이상하게 허탈했다.\", \"Your first salary hit the account. It felt joyful and strangely hollow.\")\n"
        "\t\t\"one_year_worker\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"1년 직장인\", \"One-Year Worker\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"같은 회사를 1년 다녔다. 어느새 선배가 돼 있었다.\", \"Stayed at the same company for a year. Somehow, you became senior to someone.\")\n"
        "\t\t\"three_year_worker\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"베테랑 직장인\", \"Office Veteran\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"3년. 회사 서류함에 내 이름이 녹아들었다.\", \"Three years. Your name has seeped into the company's filing cabinets.\")\n"
        "\t\t\"long_unemployed\":\n"
        "\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"백수의 자유\", \"Freedom of Unemployment\")\n"
        "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"12개월을 무직으로 버텼다. 누군가는 백수라 하고 누군가는 자유인이라 한다.\", \"Stayed unemployed for 12 months. Some call it joblessness. Some call it freedom.\")\n"
    ).encode("utf-8"),
)
_REGISTRY_SHA256 = "66b5c77c342815652cf763635d11d89afec0773850e8a756ac890ec164f905e3"


def _history_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    errors: list[str] = []
    if META_TITLE_PATH != "autoloads/MetaProgression.gd" or relative != META_TITLE_PATH:
        errors.append("ORDER-244: meta-title history path is not the owned path")
    try:
        path, previous_sha, current_sha, insertion = META_TITLE_TRANSITION
        registry_sha = hashlib.sha256(json.dumps(
            [path, previous_sha, current_sha, insertion.decode("utf-8")],
            ensure_ascii=False, separators=(",", ":")).encode("utf-8")).hexdigest()
        if registry_sha != _REGISTRY_SHA256 or (
                path, previous_sha, current_sha) != (
                    META_TITLE_PATH, PREVIOUS_SHA256, CURRENT_SHA256):
            errors.append("ORDER-244: exact meta-title history registry drifted")
    except (TypeError, ValueError, AttributeError, UnicodeError):
        errors.append("ORDER-244: malformed meta-title history registry")
    if hashlib.sha256(current).hexdigest() != CURRENT_SHA256:
        errors.append("ORDER-244: unapproved current MetaProgression source bytes")
    if errors:
        return current, errors
    if current.count(insertion) != 1:
        return current, ["ORDER-244: meta-title insertion is not unique"]
    projected = current.replace(insertion, b"", 1)
    if hashlib.sha256(projected).hexdigest() != PREVIOUS_SHA256:
        return current, ["ORDER-244: exact meta-title inverse does not restore predecessor"]
    return projected, []


def meta_title_history_source_errors(
        relative: str, current: bytes, registered_previous: str) -> list[str]:
    """Validate live raw and its caller's unchanged historical registration."""
    errors = _history_projection(current, relative)[1]
    if registered_previous != PREVIOUS_SHA256:
        errors.append("ORDER-244: meta-title predecessor registration drifted")
    return errors


def meta_title_history_project_bytes(current: bytes, relative: str) -> bytes:
    """Expose the exact predecessor only from approved live raw; else identity."""
    return _history_projection(current, relative)[0]


def meta_title_history_project_byte_hash(
        current_hash: str, relative: str, current: bytes) -> str:
    """A hash claim is only an observation and must match validated actual raw."""
    projected, errors = _history_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != current_hash:
        return current_hash
    return hashlib.sha256(projected).hexdigest()
