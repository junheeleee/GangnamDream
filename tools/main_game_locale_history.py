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

# BEGIN_INVENTORY_DISPLAY_HISTORY_261
# Physical Main/DR authority precedes the preserved 256/243 observation chain.
_INVENTORY_DISPLAY_PINS = {
    "autoloads/DataRegistry.gd": [
        "9ee97b7003efb1d9b80673d1fce162b71ab0cb6f929a363e04ead29a98d9a1df",
        "8887fd8a1c8becaef27e2638efea78218281786699546fda26695753d9978f7e"
    ],
    "scenes/MainGame.gd": [
        "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "da046f2bdec4e652b98498c49db67b262ce13f5be5475cc719aa5f938e117445"
    ]
}
INVENTORY_DISPLAY_TRANSITIONS = json.loads(r'''{
  "autoloads/DataRegistry.gd": {
    "previous_sha256": "9ee97b7003efb1d9b80673d1fce162b71ab0cb6f929a363e04ead29a98d9a1df",
    "current_sha256": "8887fd8a1c8becaef27e2638efea78218281786699546fda26695753d9978f7e",
    "inverses": [
      {
        "id": "loaded_name_metadata",
        "before": "var content_revision: int = 0\n",
        "after": "var content_revision: int = 0\n# Display provenance is separate from saved inventory and live registry overrides.\nvar _inventory_display_loaded_language: String = \"\"\nvar _inventory_display_aliases: Dictionary = {}\nvar _inventory_display_loaded_names: Dictionary = {}\nvar _inventory_display_pending_language: String = \"\"\nvar _inventory_display_pending_revision: int = -1\nvar _inventory_display_pending_names: Dictionary = {}\n",
        "kind": "replace_once"
      },
      {
        "id": "capture_after_actual_item_pipeline",
        "before": "\titems_by_id = _index_by_id(items)\n",
        "after": "\titems_by_id = _index_by_id(items)\n\t_capture_inventory_display_snapshot(lang)\n",
        "kind": "replace_once"
      },
      {
        "id": "display_helpers_eof",
        "before": "\t\tpush_warning(\"Invalid JSON file: %s\" % path)\n\treturn parsed\n",
        "after": "\t\tpush_warning(\"Invalid JSON file: %s\" % path)\n\treturn parsed\n\n# Capture builtin aliases without presets; a preset/custom saved name is not an alias.\nfunc _capture_inventory_display_snapshot(lang: String) -> void:\n\tvar source_rows: Array = _load_array(ITEMS_PATH)\n\t_inventory_display_aliases.clear()\n\tfor raw_row in source_rows:\n\t\tif not raw_row is Dictionary:\n\t\t\tcontinue\n\t\tvar source_id: Variant = (raw_row as Dictionary).get(\"id\")\n\t\tif source_id is String and not source_id.is_empty():\n\t\t\t_inventory_display_aliases[source_id] = {}\n\tfor alias_language in [\"ko\", \"en\", \"ja\", \"zh-CN\", \"zh-TW\"]:\n\t\tvar defaults: Array = source_rows.duplicate(true)\n\t\tif alias_language != \"ko\":\n\t\t\t_apply_catalog_en_overlay(defaults, ITEM_TEXT_EN)\n\t\t\t_apply_catalog_locale_overlay(defaults, _load_locale_catalog(alias_language), \"items\")\n\t\tfor raw_row in defaults:\n\t\t\tif not raw_row is Dictionary:\n\t\t\t\tcontinue\n\t\t\tvar row: Dictionary = raw_row\n\t\t\tvar row_id: Variant = row.get(\"id\")\n\t\t\tvar name_value: Variant = row.get(\"name\")\n\t\t\tif not row_id is String or not _inventory_display_aliases.has(row_id):\n\t\t\t\tcontinue\n\t\t\tif name_value is String and not name_value.strip_edges().is_empty():\n\t\t\t\t_inventory_display_aliases[row_id][name_value] = true\n\t_inventory_display_loaded_names = _inventory_display_name_snapshot(items)\n\t_inventory_display_loaded_language = lang\n\t_inventory_display_pending_language = \"\"\n\t_inventory_display_pending_revision = -1\n\t_inventory_display_pending_names.clear()\n\nfunc _inventory_display_name_snapshot(rows: Array) -> Dictionary:\n\tvar result: Dictionary = {}\n\tfor raw_row in rows:\n\t\tif not raw_row is Dictionary:\n\t\t\tcontinue\n\t\tvar row: Dictionary = raw_row\n\t\tvar row_id: Variant = row.get(\"id\")\n\t\tif not row_id is String or row_id.is_empty():\n\t\t\tcontinue\n\t\t# Preserve field presence and raw type, including explicit empty/nonstring names.\n\t\tresult[row_id] = {\"name\": row[\"name\"]}.duplicate(true) if row.has(\"name\") else {}\n\treturn result\n\nfunc get_inventory_display_name(item: Dictionary, legacy_fallback: String) -> String:\n\tvar raw_id: Variant = item.get(\"id\")\n\tif _inventory_display_loaded_language.is_empty() or not raw_id is String:\n\t\treturn legacy_fallback\n\tvar item_id: String = raw_id\n\tif not _inventory_display_aliases.has(item_id):\n\t\treturn legacy_fallback\n\tif item.has(\"name\"):\n\t\tvar stored_name: Variant = item[\"name\"]\n\t\tif not stored_name is String or not _inventory_display_aliases[item_id].has(stored_name):\n\t\t\treturn legacy_fallback\n\n\tvar lang: String = LocaleManager.language\n\tif lang != _inventory_display_loaded_language:\n\t\t# set_language emits before reload. Preview that reload, not its old memory\n\t\t# overrides; settings-only changes never enter this branch.\n\t\tif _inventory_display_pending_language != lang or _inventory_display_pending_revision != content_revision:\n\t\t\tvar pending_rows: Array = _load_array(ITEMS_PATH)\n\t\t\tif lang != \"ko\":\n\t\t\t\t_apply_catalog_en_overlay(pending_rows, ITEM_TEXT_EN)\n\t\t\t\t_apply_catalog_locale_overlay(pending_rows, _load_locale_catalog(lang), \"items\")\n\t\t\t_apply_catalog_presets(pending_rows, \"items\")\n\t\t\t_inventory_display_pending_names = _inventory_display_name_snapshot(pending_rows)\n\t\t\t_inventory_display_pending_language = lang\n\t\t\t_inventory_display_pending_revision = content_revision\n\t\tvar pending_name: Dictionary = _inventory_display_pending_names.get(item_id, {})\n\t\treturn str(pending_name[\"name\"]) if pending_name.has(\"name\") else legacy_fallback\n\n\t# Same loaded language: honor live in-memory changes without rereading presets.\n\tvar live_row: Variant = get_item(item_id)\n\tif not live_row is Dictionary or not live_row.has(\"name\"):\n\t\treturn legacy_fallback\n\tvar baseline: Dictionary = _inventory_display_loaded_names.get(item_id, {})\n\tif not baseline.has(\"name\"):\n\t\treturn str(live_row[\"name\"])\n\tif typeof(live_row[\"name\"]) != typeof(baseline[\"name\"]) or live_row[\"name\"] != baseline[\"name\"]:\n\t\treturn str(live_row[\"name\"])\n\treturn str(baseline[\"name\"])\n",
        "kind": "replace_eof"
      }
    ]
  },
  "scenes/MainGame.gd": {
    "previous_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
    "current_sha256": "da046f2bdec4e652b98498c49db67b262ce13f5be5475cc719aa5f938e117445",
    "inverses": [
      {
        "id": "nongift_display_call",
        "before": "\t\tvar inv_name: String = _gift_display_name(item_id) if str(item.get(\"category\", \"\")) == \"gift\" else str(item.get(\"name\", _tr(\"아이템\", \"Item\")))\n",
        "after": "\t\tvar inv_name: String = _gift_display_name(item_id) if str(item.get(\"category\", \"\")) == \"gift\" else DataRegistry.get_inventory_display_name(item, str(item.get(\"name\", _tr(\"아이템\", \"Item\"))))\n",
        "kind": "replace_once"
      }
    ]
  }
}''')
_INVENTORY_DISPLAY_REGISTRY_SHA256 = "82d9e52117666e7bb9b53e03dae47ebb1cadd2fad3a8b4a76873ff2d27fb244c"
_INVENTORY_OLD_SOURCE_ERRORS = main_game_history_source_errors
_INVENTORY_OLD_PROJECT_BYTES = main_game_history_project_bytes
_INVENTORY_OLD_PROJECT_HASH = main_game_history_project_byte_hash


def _inventory_display_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    errors: list[str] = []
    pins = _INVENTORY_DISPLAY_PINS.get(relative)
    if pins is None:
        return current, ["ORDER-261: inventory display path is not owned"]
    if hashlib.sha256(current).hexdigest() != pins[1]:
        errors.append("ORDER-261: unapproved current inventory display source bytes")
    try:
        registry = INVENTORY_DISPLAY_TRANSITIONS
        if not isinstance(registry, dict) or set(registry) != set(_INVENTORY_DISPLAY_PINS):
            raise ValueError("transition paths")
        encoded = json.dumps(registry, ensure_ascii=False, sort_keys=True,
                             separators=(",", ":")).encode("utf-8")
        if hashlib.sha256(encoded).hexdigest() != _INVENTORY_DISPLAY_REGISTRY_SHA256:
            errors.append("ORDER-261: inventory display registry seal differs")
        shapes = {
            "scenes/MainGame.gd": (("nongift_display_call", "replace_once"),),
            "autoloads/DataRegistry.gd": (
                ("loaded_name_metadata", "replace_once"),
                ("capture_after_actual_item_pipeline", "replace_once"),
                ("display_helpers_eof", "replace_eof")),
        }
        for path, fixed in _INVENTORY_DISPLAY_PINS.items():
            row = registry[path]
            if not isinstance(row, dict) or set(row) != {
                    "previous_sha256", "current_sha256", "inverses"}:
                raise ValueError("transition fields")
            if (row["previous_sha256"], row["current_sha256"]) != tuple(fixed):
                errors.append("ORDER-261: fixed inventory display transition differs")
            inverses = row["inverses"]
            if not isinstance(inverses, list) or len(inverses) != len(shapes[path]):
                raise ValueError("inverse cardinality")
            for inverse, wanted in zip(inverses, shapes[path]):
                if (not isinstance(inverse, dict) or set(inverse) != {
                        "id", "kind", "before", "after"}
                        or (inverse["id"], inverse["kind"]) != wanted
                        or not isinstance(inverse["before"], str)
                        or not isinstance(inverse["after"], str)
                        or not inverse["before"] or not inverse["after"]):
                    raise ValueError("inverse shape/order")
        inverses = registry[relative]["inverses"]
    except (TypeError, ValueError, KeyError, AttributeError, UnicodeError):
        errors.append("ORDER-261: malformed inventory display inverse registry")
    if errors:
        return current, errors
    old = current
    for inverse in reversed(inverses):
        before = inverse["before"].encode("utf-8")
        after = inverse["after"].encode("utf-8")
        if old.count(after) != 1:
            return current, ["ORDER-261: inventory display inverse is not unique"]
        if inverse["kind"] == "replace_eof" and not old.endswith(after):
            return current, ["ORDER-261: inventory display EOF differs"]
        old = old.replace(after, before, 1)
    if hashlib.sha256(old).hexdigest() != pins[0]:
        return current, ["ORDER-261: inventory display inverse does not recover fixed source"]
    return old, []


def inventory_display_source_errors(
        relative: str, current: bytes, registered_previous: str | None = None) -> list[str]:
    errors = _inventory_display_projection(current, relative)[1]
    pins = _INVENTORY_DISPLAY_PINS.get(relative)
    if registered_previous is not None and (pins is None or registered_previous != pins[0]):
        errors.append("ORDER-261: inventory display predecessor registration differs")
    return errors


def inventory_display_project_bytes(current: bytes, relative: str) -> bytes:
    return _inventory_display_projection(current, relative)[0]


def inventory_display_project_byte_hash(claim: str, relative: str, current: bytes) -> str:
    old, errors = _inventory_display_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return hashlib.sha256(old).hexdigest()


def main_game_history_source_errors(relative: str, current: bytes) -> list[str]:
    if relative != "scenes/MainGame.gd":
        return _INVENTORY_OLD_SOURCE_ERRORS(relative, current)
    old, errors = _inventory_display_projection(current, relative)
    if errors:
        return errors + _INVENTORY_OLD_SOURCE_ERRORS(relative, current)
    return _INVENTORY_OLD_SOURCE_ERRORS(relative, old)


def main_game_history_project_bytes(current: bytes, relative: str) -> bytes:
    if relative != "scenes/MainGame.gd":
        return _INVENTORY_OLD_PROJECT_BYTES(current, relative)
    old, errors = _inventory_display_projection(current, relative)
    return current if errors else _INVENTORY_OLD_PROJECT_BYTES(old, relative)


def main_game_history_project_byte_hash(current_hash: str, relative: str, current: bytes) -> str:
    if relative != "scenes/MainGame.gd":
        return _INVENTORY_OLD_PROJECT_HASH(current_hash, relative, current)
    old, errors = _inventory_display_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != current_hash:
        return current_hash
    return _INVENTORY_OLD_PROJECT_HASH(hashlib.sha256(old).hexdigest(), relative, old)
# END_INVENTORY_DISPLAY_HISTORY_261
