#!/usr/bin/env python3
"""Exact, read-only MainGame 240 -> 239 -> 220 history adapter.

Only the approved live raw is admitted. Projection is an observation for older
audits, not permission to run a rolled-back source or to rewrite historical pins.
No filesystem access, runtime mutation, normalization, or caller-hash authority.
"""

from __future__ import annotations

import hashlib
import json


MAIN_GAME_PATH = "scenes/MainGame.gd"
CURRENT_SHA256 = "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d"
ORDER239_SHA256 = "014bdae5a87cb3a873f61c5f83d8337f6d686068366641eb92c94e515bebad86"
ORDER220_SHA256 = "5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88"

# Frozen before implementation; each inverse is (predecessor, successor).
# This is the sole registry seam used by the finite tamper controls.
HISTORY_STAGES = (
    ("ORDER240", "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
     "014bdae5a87cb3a873f61c5f83d8337f6d686068366641eb92c94e515bebad86", (
         ("\t\trelationship_box.add_child(_info_empty_card(_tr(\"아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.\", \"No important relationships yet. People appear here through relationship actions or story progress.\"), \"#64748b\"))\n".encode("utf-8"),
          "\t\trelationship_box.add_child(_info_empty_card(_tr(\"아직 기록된 인연이 없습니다. 이야기를 진행하며 맺은 인연이 여기에 표시됩니다.\", \"No connections recorded yet. Connections formed through the story appear here.\"), \"#64748b\"))\n".encode("utf-8")),
         ("\t\t\"romantic\": _tr(\"연인\", \"Partner\"),\n".encode("utf-8"),
          "\t\t\"romantic\": _tr(\"연애 관련\", \"Romance\"),\n".encode("utf-8")),
     )),
    ("ORDER239", "014bdae5a87cb3a873f61c5f83d8337f6d686068366641eb92c94e515bebad86",
     "5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88", (
         ("\t\tvar name_lbl: Label = _label(str(rel.get(\"name\", \"?\")), 16, \"#e8eaf0\")\n".encode("utf-8"),
          "\t\tvar name_lbl: Label = _label(relationship_system.get_display_name(str(rel.get(\"name\", \"?\"))), 16, \"#e8eaf0\")\n".encode("utf-8")),
         ("\t\trel_names.append(str(rel.get(\"name\", \"?\")))\n".encode("utf-8"),
          "\t\trel_names.append(relationship_system.get_display_name(str(rel.get(\"name\", \"?\"))))\n".encode("utf-8")),
     )),
)
_REGISTRY_SHA256 = "f1df5b07d0dde85587ba127ba09364008ee7bb2e315cf56b714a24701425a200"


def _history_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    errors: list[str] = []
    if MAIN_GAME_PATH != "scenes/MainGame.gd" or relative != MAIN_GAME_PATH:
        errors.append("ORDER-243: locale history path is not the owned path")
    try:
        registry = [
            [name, before_sha, after_sha,
             [[before.decode("utf-8"), after.decode("utf-8")]
              for before, after in patches]]
            for name, before_sha, after_sha, patches in HISTORY_STAGES
        ]
        registry_sha = hashlib.sha256(json.dumps(
            registry, ensure_ascii=False, separators=(",", ":")).encode("utf-8")).hexdigest()
        if registry_sha != _REGISTRY_SHA256 or (
                CURRENT_SHA256, ORDER239_SHA256, ORDER220_SHA256) != (
                    HISTORY_STAGES[0][1], HISTORY_STAGES[0][2], HISTORY_STAGES[1][2]):
            errors.append("ORDER-243: exact locale history registry drifted")
    except (IndexError, TypeError, ValueError, AttributeError, UnicodeError):
        errors.append("ORDER-243: malformed locale history registry")
    if hashlib.sha256(current).hexdigest() != CURRENT_SHA256:
        errors.append("ORDER-243: unapproved current MainGame source bytes")
    if errors:
        return current, errors

    projected = current
    for name, from_sha, to_sha, patches in HISTORY_STAGES:
        if hashlib.sha256(projected).hexdigest() != from_sha:
            return current, [f"ORDER-243: {name} inverse input pin drifted"]
        for before, after in patches:
            if projected.count(after) != 1:
                return current, [f"ORDER-243: {name} inverse is not unique"]
            projected = projected.replace(after, before, 1)
        if hashlib.sha256(projected).hexdigest() != to_sha:
            return current, [f"ORDER-243: {name} inverse output pin drifted"]
    return projected, []


def main_game_history_source_errors(relative: str, current: bytes) -> list[str]:
    """Validate live raw first; 239/220 are history, never alternate live bases."""
    return _history_projection(current, relative)[1]


def main_game_history_project_bytes(current: bytes, relative: str) -> bytes:
    """Expose 220 only from the exact valid current raw; otherwise identity."""
    return _history_projection(current, relative)[0]


def main_game_history_project_byte_hash(
        current_hash: str, relative: str, current: bytes) -> str:
    """Observe a projection only when the caller's claim also matches valid raw."""
    projected, errors = _history_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != current_hash:
        return current_hash
    return hashlib.sha256(projected).hexdigest()

# BEGIN_TITLE_BUTTON_MAIN_SUCCESSOR_256
# One finite approved UI change. Old history functions/registries above are
# retained verbatim; this facade admits current raw before invoking that chain.
_TITLE_BUTTON_CURRENT_SHA256 = "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81"
_TITLE_BUTTON_PREVIOUS_SHA256 = "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d"
TITLE_BUTTON_TRANSITION = json.loads(r'''{
  "path": "scenes/MainGame.gd",
  "previous_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
  "current_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
  "inverses": [
    {
      "id": "creation",
      "kind": "replace_once",
      "before": "\t_title_collection_button = _small_button(_tr(\"칭호\", \"Title\"), \"#1a2a1a\")\n",
      "after": "\t_title_collection_button = _small_button(_title_collection_button_text(), \"#1a2a1a\")\n"
    },
    {
      "id": "refresh",
      "kind": "replace_once",
      "before": "\tif is_instance_valid(_title_collection_button):\n\t\t_title_collection_button.visible = not DEMO_CORE_LOOP_V2.requested()\n",
      "after": "\tif is_instance_valid(_title_collection_button):\n\t\t_title_collection_button.text = _title_collection_button_text()\n\t\t_title_collection_button.visible = not DEMO_CORE_LOOP_V2.requested()\n"
    },
    {
      "id": "label_helper",
      "kind": "append_eof",
      "before": "",
      "after": "\nfunc _title_collection_button_text() -> String:\n\treturn _tr(\"칭호\", \"Title\")\n"
    }
  ]
}''')
_TITLE_BUTTON_REGISTRY_SHA256 = "7fe2e86c872eb74467bfd562f5bfeb7f9affc5a6965db72a18e01a4b2ffd8aa1"

_TITLE_BUTTON_OLD_SOURCE_ERRORS = main_game_history_source_errors
_TITLE_BUTTON_OLD_PROJECT_BYTES = main_game_history_project_bytes
_TITLE_BUTTON_OLD_PROJECT_HASH = main_game_history_project_byte_hash


def _title_button_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    """Validate whole raw and a unique finite inverse; no newline normalization."""
    errors: list[str] = []
    if relative != "scenes/MainGame.gd":
        errors.append("ORDER-256: title button history path is not the owned path")
    if hashlib.sha256(current).hexdigest() != _TITLE_BUTTON_CURRENT_SHA256:
        errors.append("ORDER-256: unapproved current MainGame source bytes")
    try:
        row = TITLE_BUTTON_TRANSITION
        if not isinstance(row, dict) or set(row) != {
                "path", "previous_sha256", "current_sha256", "inverses"}:
            raise ValueError("transition fields")
        encoded = json.dumps(row, ensure_ascii=False, sort_keys=True,
                             separators=(",", ":")).encode("utf-8")
        if hashlib.sha256(encoded).hexdigest() != _TITLE_BUTTON_REGISTRY_SHA256:
            errors.append("ORDER-256: title button registry seal differs")
        # The separately fixed predecessor/raw pins are not supplied by the
        # mutable registry checksum; resealing it cannot skip an older stage.
        if (row["path"] != "scenes/MainGame.gd"
                or row["previous_sha256"] != _TITLE_BUTTON_PREVIOUS_SHA256
                or row["current_sha256"] != _TITLE_BUTTON_CURRENT_SHA256):
            errors.append("ORDER-256: title button fixed transition differs")
        inverses = row["inverses"]
        if not isinstance(inverses, list) or len(inverses) != 3:
            raise ValueError("inverse cardinality")
        wanted = (("creation", "replace_once"), ("refresh", "replace_once"),
                  ("label_helper", "append_eof"))
        for inverse, (name, kind) in zip(inverses, wanted):
            if (not isinstance(inverse, dict)
                    or set(inverse) != {"id", "kind", "before", "after"}
                    or (inverse["id"], inverse["kind"]) != (name, kind)
                    or not isinstance(inverse["before"], str)
                    or not isinstance(inverse["after"], str)
                    or not inverse["after"]
                    or (kind == "append_eof") != (inverse["before"] == "")):
                raise ValueError("inverse shape/order")
    except (TypeError, ValueError, KeyError, AttributeError, UnicodeError):
        errors.append("ORDER-256: malformed title button inverse registry")
    if errors:
        return current, errors

    old = current
    for inverse in reversed(inverses):
        before, after = inverse["before"].encode("utf-8"), inverse["after"].encode("utf-8")
        if old.count(after) != 1:
            return current, ["ORDER-256: title button inverse is not unique"]
        if inverse["kind"] == "append_eof":
            if not old.endswith(after):
                return current, ["ORDER-256: title button helper is not the exact EOF suffix"]
            old = old[:-len(after)]
        else:
            old = old.replace(after, before, 1)
    if hashlib.sha256(old).hexdigest() != _TITLE_BUTTON_PREVIOUS_SHA256:
        return current, ["ORDER-256: title button inverse does not recover fixed MainGame"]
    return old, []


def title_button_source_errors(relative: str, current: bytes) -> list[str]:
    return _title_button_projection(current, relative)[1]


def title_button_project_bytes(current: bytes, relative: str) -> bytes:
    return _title_button_projection(current, relative)[0]


def title_button_project_byte_hash(claim: str, relative: str, current: bytes) -> str:
    old, errors = _title_button_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return hashlib.sha256(old).hexdigest()


def main_game_history_source_errors(relative: str, current: bytes) -> list[str]:
    if relative != "scenes/MainGame.gd":
        return _TITLE_BUTTON_OLD_SOURCE_ERRORS(relative, current)
    old, errors = _title_button_projection(current, relative)
    if errors:
        return errors + _TITLE_BUTTON_OLD_SOURCE_ERRORS(relative, current)
    return _TITLE_BUTTON_OLD_SOURCE_ERRORS(relative, old)


def main_game_history_project_bytes(current: bytes, relative: str) -> bytes:
    if relative != "scenes/MainGame.gd":
        return _TITLE_BUTTON_OLD_PROJECT_BYTES(current, relative)
    old, errors = _title_button_projection(current, relative)
    if errors:
        return current
    return _TITLE_BUTTON_OLD_PROJECT_BYTES(old, relative)


def main_game_history_project_byte_hash(
        current_hash: str, relative: str, current: bytes) -> str:
    if relative != "scenes/MainGame.gd":
        return _TITLE_BUTTON_OLD_PROJECT_HASH(current_hash, relative, current)
    old, errors = _title_button_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != current_hash:
        return current_hash
    return _TITLE_BUTTON_OLD_PROJECT_HASH(hashlib.sha256(old).hexdigest(), relative, old)
# END_TITLE_BUTTON_MAIN_SUCCESSOR_256
