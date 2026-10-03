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

# BEGIN_GIFT_CAPTION_HISTORY_262
# One caption inverse and one bounded collector span; old registries are intact.
_GIFT_CAPTION_PINS = {
    "scenes/MainGame.gd": ("da046f2bdec4e652b98498c49db67b262ce13f5be5475cc719aa5f938e117445",
                           "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532"),
    "tools/ja_translation_pipeline.py": ("3a2d791038a46dcf3442776f4703cd1398998590843b91904c2668425a7427f4",
                                          "8bb536853809fa273587734215bfcb3d6a78b9bd4d4b941b595e2136e8ebec6c"),
}
GIFT_CAPTION_TRANSITIONS = {
    "scenes/MainGame.gd": {
        "previous_sha256": "da046f2bdec4e652b98498c49db67b262ce13f5be5475cc719aa5f938e117445",
        "current_sha256": "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532",
        "inverses": [{"id": "caption", "kind": "replace_once",
            "before": "\t\t\titem_content.add_child(_wrap_label(_tr(\"선물 — 사람 메뉴에서 전달\", \"Gift — deliver from the People menu\"), 13, \"#c8a0d8\"))\n",
            "after": "\t\t\titem_content.add_child(_wrap_label(_tr(\"선물\", \"Gift\"), 13, \"#c8a0d8\"))\n"}],
    },
    "tools/ja_translation_pipeline.py": {
        "previous_sha256": "3a2d791038a46dcf3442776f4703cd1398998590843b91904c2668425a7427f4",
        "current_sha256": "8bb536853809fa273587734215bfcb3d6a78b9bd4d4b941b595e2136e8ebec6c",
        "inverses": [{"id": "collector", "kind": "remove_span",
            "start": "# BEGIN_GIFT_CAPTION_COLLECTOR_262\n",
            "end": "# END_GIFT_CAPTION_COLLECTOR_262\n\n",
            "sha256": "3ee604d4e7670d72714bdcef7f10dfe84e880c5bd70b7a3d194e653db2b4536d"}],
    },
}
_GIFT_CAPTION_REGISTRY_SHA256 = "e4b14eb146d4f90a8816c2db0724d41e07f05a8234038b0133ff47f4de87ded8"
_GIFT_OLD_SOURCE_ERRORS = main_game_history_source_errors
_GIFT_OLD_PROJECT_BYTES = main_game_history_project_bytes
_GIFT_OLD_PROJECT_HASH = main_game_history_project_byte_hash


def _gift_caption_projection(current, relative):
    if relative not in _GIFT_CAPTION_PINS:
        return current, ["ORDER-262: gift caption path is not owned"]
    try:
        digest = hashlib.sha256(json.dumps(GIFT_CAPTION_TRANSITIONS, ensure_ascii=False,
                    sort_keys=True, separators=(",", ":")).encode()).hexdigest()
        if set(GIFT_CAPTION_TRANSITIONS) != set(_GIFT_CAPTION_PINS) or digest != _GIFT_CAPTION_REGISTRY_SHA256:
            raise ValueError("registry seal")
        rule = GIFT_CAPTION_TRANSITIONS[relative]
        prior, actual = _GIFT_CAPTION_PINS[relative]
        if (rule["previous_sha256"], rule["current_sha256"]) != (prior, actual):
            raise ValueError("independent source pins")
        if hashlib.sha256(current).hexdigest() != actual:
            raise ValueError("unapproved current source")
        rows = rule["inverses"]
        expected = ("caption", "replace_once") if relative == MAIN_GAME_PATH else ("collector", "remove_span")
        if len(rows) != 1 or (rows[0]["id"], rows[0]["kind"]) != expected:
            raise ValueError("inverse identity/cardinality")
        row = rows[0]
        if relative == MAIN_GAME_PATH:
            before, after = row["before"].encode(), row["after"].encode()
            if not after or after == before or current.count(after) != 1:
                raise ValueError("caption inverse is not unique")
            old = current.replace(after, before, 1)
        else:
            start, end = row["start"].encode(), row["end"].encode()
            if not start or not end or current.count(start) != 1 or current.count(end) != 1:
                raise ValueError("collector boundaries")
            a = current.index(start)
            z = current.index(end, a) + len(end)
            if hashlib.sha256(current[a:z]).hexdigest() != row["sha256"]:
                raise ValueError("collector span")
            old = current[:a] + current[z:]
        if hashlib.sha256(old).hexdigest() != prior:
            raise ValueError("whole predecessor inverse")
        return old, []
    except (KeyError, TypeError, ValueError, AttributeError, IndexError, UnicodeError) as error:
        return current, ["ORDER-262: gift caption raw/registry rejected: " + str(error)]


def gift_caption_source_errors(relative, current):
    return _gift_caption_projection(current, relative)[1]


def gift_caption_project_bytes(current, relative):
    return _gift_caption_projection(current, relative)[0]


def gift_caption_project_byte_hash(claim, relative, current):
    old, errors = _gift_caption_projection(current, relative)
    return claim if errors or hashlib.sha256(current).hexdigest() != claim else hashlib.sha256(old).hexdigest()


def _gift_caption_main_source_errors(relative, current):
    if relative != MAIN_GAME_PATH:
        return _GIFT_OLD_SOURCE_ERRORS(relative, current)
    old, errors = _gift_caption_projection(current, relative)
    return errors + _GIFT_OLD_SOURCE_ERRORS(relative, current) if errors else _GIFT_OLD_SOURCE_ERRORS(relative, old)


def _gift_caption_main_project_bytes(current, relative):
    if relative != MAIN_GAME_PATH:
        return _GIFT_OLD_PROJECT_BYTES(current, relative)
    old, errors = _gift_caption_projection(current, relative)
    return current if errors else _GIFT_OLD_PROJECT_BYTES(old, relative)


def _gift_caption_main_project_hash(claim, relative, current):
    if relative != MAIN_GAME_PATH:
        return _GIFT_OLD_PROJECT_HASH(claim, relative, current)
    old, errors = _gift_caption_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return _GIFT_OLD_PROJECT_HASH(hashlib.sha256(old).hexdigest(), relative, old)


main_game_history_source_errors = _gift_caption_main_source_errors
main_game_history_project_bytes = _gift_caption_main_project_bytes
main_game_history_project_byte_hash = _gift_caption_main_project_hash
# END_GIFT_CAPTION_HISTORY_262

# BEGIN_NEW_RUN_LOG_HISTORY_267
# A finite GS/collector observation layer; previous registries/functions remain raw.
NEW_RUN_LOG_GS = "autoloads/GameState.gd"
NEW_RUN_LOG_JA = "tools/ja_translation_pipeline.py"
_NEW_RUN_LOG_PINS = {
  "autoloads/GameState.gd": [
    "8a40740286ff910b2a16049e2c2794cc0dc22fed5dfc78d2fc6ce458c833018d",
    "5076adf75b13920ae97ff9174945acf9c43fc80dec73cb356da44f314b7741d8"
  ],
  "tools/ja_translation_pipeline.py": [
    "8bb536853809fa273587734215bfcb3d6a78b9bd4d4b941b595e2136e8ebec6c",
    "90ad8caf9efc07d217cb8960715434ae09ae227de4ce0dee36e5ad74278ea270"
  ]
}
NEW_RUN_LOG_TRANSITIONS = json.loads(r'''{
  "autoloads/GameState.gd": {
    "previous_sha256": "8a40740286ff910b2a16049e2c2794cc0dc22fed5dfc78d2fc6ce458c833018d",
    "current_sha256": "5076adf75b13920ae97ff9174945acf9c43fc80dec73cb356da44f314b7741d8",
    "inverses": [
      {
        "id": "profile_parent",
        "before": "\tadd_log(LocaleManager.ui(\n\t\t\"다시 시작한 아침. 출발점은 %s였다.\",\n\t\t\"Another beginning. He started out %s.\") %\n\t\t_localized_profile_label(starting_profile), \"system\")\n",
        "after": "\tadd_log(LocaleManager.ui_format(\n\t\t\"다시 시작한 아침. 출발점은 %s였다.\",\n\t\t\"Another beginning. He started out %s.\",\n\t\t[_localized_profile_label(starting_profile)],\n\t\t[_localized_profile_label(starting_profile, true)]), \"system\")\n",
        "kind": "replace_once"
      },
      {
        "id": "profile_label",
        "before": "func _localized_profile_label(profile: String) -> String:\n\tif not LocaleManager.is_english():\n\t\treturn profile\n\tvar labels := {\n\t\t\"백수\": \"unemployed\",\n\t\t\"알바\": \"working part-time\",\n\t}\n\treturn str(labels.get(profile, profile))\n",
        "after": "func _localized_profile_label(profile: String, english_only: bool = false) -> String:\n\tvar labels := {\n\t\t\"백수\": \"unemployed\",\n\t\t\"알바\": \"working part-time\",\n\t}\n\tif english_only:\n\t\treturn str(labels.get(profile, profile))\n\tmatch profile:\n\t\t\"백수\":\n\t\t\treturn LocaleManager.ui(\"백수\", \"unemployed\")\n\t\t\"알바\":\n\t\t\treturn LocaleManager.ui(\"알바\", \"working part-time\")\n\treturn profile\n",
        "kind": "replace_once"
      },
      {
        "id": "theme_log",
        "before": "func _roll_run_theme():\n\tvar pool = [\"investment\", \"jobs\", \"social\", \"health\", \"relationship\", \"gambling\", \"finance\"]\n\tpool.shuffle()\n\trun_theme_categories = [pool[0], pool[1]]\n\tvar label_map = {\n\t\t\"investment\": \"투자\", \"jobs\": \"직장\", \"social\": \"인간관계\",\n\t\t\"health\": \"건강\", \"relationship\": \"연애\", \"gambling\": \"도박\", \"finance\": \"재정\"\n\t}\n\tif LocaleManager.is_english():\n\t\tlabel_map = {\n\t\t\t\"investment\": \"Investing\", \"jobs\": \"Jobs\", \"social\": \"Social\",\n\t\t\t\"health\": \"Health\", \"relationship\": \"Relationships\", \"gambling\": \"Gambling\", \"finance\": \"Finance\"\n\t\t}\n\tvar a = label_map.get(pool[0], pool[0])\n\tvar b = label_map.get(pool[1], pool[1])\n\tadd_log(LocaleManager.ui(\n\t\t\"이번에는 %s와 %s에 얽힌 소식이 유난히 먼저 눈에 들어왔다.\",\n\t\t\"This time, news tied to %s and %s caught his eye first.\"\n\t) % [a, b], \"system\")\n",
        "after": "func _roll_run_theme():\n\tvar pool = [\"investment\", \"jobs\", \"social\", \"health\", \"relationship\", \"gambling\", \"finance\"]\n\tpool.shuffle()\n\trun_theme_categories = [pool[0], pool[1]]\n\tvar label_map = {\n\t\t\"investment\": LocaleManager.ui(\"투자\", \"Investing\"),\n\t\t\"jobs\": LocaleManager.ui(\"직장\", \"Jobs\"),\n\t\t\"social\": LocaleManager.ui(\"인간관계\", \"Social\"),\n\t\t\"health\": LocaleManager.ui(\"건강\", \"Health\"),\n\t\t\"relationship\": LocaleManager.ui(\"연애\", \"Relationships\"),\n\t\t\"gambling\": LocaleManager.ui(\"도박\", \"Gambling\"),\n\t\t\"finance\": LocaleManager.ui(\"재정\", \"Finance\"),\n\t}\n\tvar english_labels = {\n\t\t\"investment\": \"Investing\", \"jobs\": \"Jobs\", \"social\": \"Social\",\n\t\t\"health\": \"Health\", \"relationship\": \"Relationships\", \"gambling\": \"Gambling\", \"finance\": \"Finance\"\n\t}\n\tvar a = label_map.get(pool[0], pool[0])\n\tvar b = label_map.get(pool[1], pool[1])\n\tadd_log(LocaleManager.ui_format(\n\t\t\"이번에는 %s와 %s에 얽힌 소식이 유난히 먼저 눈에 들어왔다.\",\n\t\t\"This time, news tied to %s and %s caught his eye first.\",\n\t\t[a, b], [english_labels.get(pool[0], pool[0]), english_labels.get(pool[1], pool[1])]\n\t), \"system\")\n",
        "kind": "replace_once"
      }
    ]
  },
  "tools/ja_translation_pipeline.py": {
    "previous_sha256": "8bb536853809fa273587734215bfcb3d6a78b9bd4d4b941b595e2136e8ebec6c",
    "current_sha256": "90ad8caf9efc07d217cb8960715434ae09ae227de4ce0dee36e5ad74278ea270",
    "inverses": [
      {
        "id": "collector",
        "kind": "remove_span",
        "start": "# BEGIN_NEW_RUN_LOG_COLLECTOR_267\n",
        "end": "# END_NEW_RUN_LOG_COLLECTOR_267\n\n",
        "sha256": "991227b74314628c16bfe403046787b9620f10b942d5ab6c2fd94df8156fce2a"
      }
    ]
  }
}''')
_NEW_RUN_LOG_REGISTRY_SHA256 = "35dfa70440208eeacb3d3f68f86a447ea6676aad449d45c344cc416511940d48"
_NEW_RUN_OLD_SOURCE_ERRORS = main_game_history_source_errors
_NEW_RUN_OLD_PROJECT_BYTES = main_game_history_project_bytes
_NEW_RUN_OLD_PROJECT_HASH = main_game_history_project_byte_hash


def _new_run_log_projection(current, relative):
    if relative not in _NEW_RUN_LOG_PINS:
        return current, []
    try:
        encoded = json.dumps(NEW_RUN_LOG_TRANSITIONS, ensure_ascii=False,
                             sort_keys=True, separators=(",", ":")).encode()
        if set(NEW_RUN_LOG_TRANSITIONS) != set(_NEW_RUN_LOG_PINS) or hashlib.sha256(encoded).hexdigest() != _NEW_RUN_LOG_REGISTRY_SHA256:
            raise ValueError("registry seal")
        for path, fixed in _NEW_RUN_LOG_PINS.items():
            row = NEW_RUN_LOG_TRANSITIONS[path]
            if set(row) != {"previous_sha256", "current_sha256", "inverses"} or (row["previous_sha256"], row["current_sha256"]) != tuple(fixed):
                raise ValueError("independent transition pins")
            wanted = (("profile_parent", "replace_once"), ("profile_label", "replace_once"),
                      ("theme_log", "replace_once")) if path == NEW_RUN_LOG_GS else (("collector", "remove_span"),)
            if len(row["inverses"]) != len(wanted) or tuple((i["id"], i["kind"]) for i in row["inverses"]) != wanted:
                raise ValueError("inverse cardinality/order")
        prior, actual = _NEW_RUN_LOG_PINS[relative]
        if hashlib.sha256(current).hexdigest() != actual:
            raise ValueError("unapproved physical source")
        old = current
        for row in reversed(NEW_RUN_LOG_TRANSITIONS[relative]["inverses"]):
            if row["kind"] == "replace_once":
                before, after = row["before"].encode(), row["after"].encode()
                if not before or not after or before == after or old.count(after) != 1:
                    raise ValueError("inverse is not exact1")
                old = old.replace(after, before, 1)
            else:
                start, end = row["start"].encode(), row["end"].encode()
                if not start or not end or old.count(start) != 1 or old.count(end) != 1:
                    raise ValueError("collector boundaries")
                a = old.index(start)
                z = old.index(end, a) + len(end)
                if hashlib.sha256(old[a:z]).hexdigest() != row["sha256"]:
                    raise ValueError("collector span hash")
                old = old[:a] + old[z:]
        if hashlib.sha256(old).hexdigest() != prior:
            raise ValueError("whole predecessor inverse")
        return old, []
    except (KeyError, TypeError, ValueError, AttributeError, IndexError, UnicodeError) as exc:
        return current, ["ORDER-267: new-run source/registry rejected: " + str(exc)]


def new_run_log_source_errors(relative, current, registered_previous=None):
    errors = _new_run_log_projection(current, relative)[1]
    if registered_previous is not None:
        pins = _NEW_RUN_LOG_PINS.get(relative)
        if pins is None or registered_previous != pins[0]:
            errors.append("ORDER-267: new-run predecessor registration differs")
    return errors


def new_run_log_project_bytes(current, relative):
    return _new_run_log_projection(current, relative)[0]


def new_run_log_project_byte_hash(claim, relative, current):
    old, errors = _new_run_log_projection(current, relative)
    return claim if errors or hashlib.sha256(current).hexdigest() != claim else hashlib.sha256(old).hexdigest()


def _new_run_public_source_errors(relative, current):
    if relative == NEW_RUN_LOG_GS:
        return new_run_log_source_errors(relative, current)
    return _NEW_RUN_OLD_SOURCE_ERRORS(relative, current)


def _new_run_public_project_bytes(current, relative):
    if relative == NEW_RUN_LOG_GS:
        return new_run_log_project_bytes(current, relative)
    return _NEW_RUN_OLD_PROJECT_BYTES(current, relative)


def _new_run_public_project_hash(claim, relative, current):
    if relative == NEW_RUN_LOG_GS:
        return new_run_log_project_byte_hash(claim, relative, current)
    return _NEW_RUN_OLD_PROJECT_HASH(claim, relative, current)


main_game_history_source_errors = _new_run_public_source_errors
main_game_history_project_bytes = _new_run_public_project_bytes
main_game_history_project_byte_hash = _new_run_public_project_hash
# END_NEW_RUN_LOG_HISTORY_267

# BEGIN_MODAL_FONT_HISTORY_381
# Current admission only. Every older definition and pin above stays intact.
MODAL_BEFORE_COMMIT = "280a030e65c0a64b77517b70e244ab2c7f170ed2"
MODAL_AFTER_COMMIT = "b9b5c3d1cb3c6fd177cd8e03aed7fac2086b9032"
MODAL_TREES = ("00171f2c015f7a049d3f51c9c183234ee0a0ae19", "ee670cf4827aad07e9386b0773f714d402db5ebe")
MODAL_BLOBS = ("99d5f16fc40ae94b1e6ff219c102e01bcd70cd35", "48e038af02412ef82decdb451b9e9b1d7135235e")
MODAL_HASHES = ("3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532",
                "6c26e3db61c810cd52022128a459a7160abf49c6a0c3d085f196755f9e232f8d")
MODAL_REPLACEMENTS = (
    ('\tmodal_pad_hint_label = _label("", 12, "#7f8794")\n',
     '\tmodal_pad_hint_label = _label("", 12, "#7f8794")\n\tmodal_pad_hint_label.clip_text = false\n'),
    ('\tmodal_close_button = _small_button("✕", "#242433")\n',
     '\tmodal_close_button = _small_button("×", "#242433")\n'),
    ('\tif _font_bold:\n\t\t_job_pad_hint_label.add_theme_font_override("bold_font", _font_bold)\n',
     '\tif _font_regular:\n\t\t_job_pad_hint_label.add_theme_font_override("normal_font", _font_regular)\n'
     '\tif _font_bold:\n\t\t_job_pad_hint_label.add_theme_font_override("bold_font", _font_bold)\n'),
)


def _modal_git(root, *args, input=None):
    import subprocess
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    if result.returncode:
        raise ValueError("ORDER-381: immutable Git proof unavailable")
    return result.stdout


def modal_font_predecessor(current, root=None):
    """Prove the exact three repairs afresh; return comparison-only old bytes."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != MODAL_HASHES[1]:
        raise ValueError("ORDER-381: unapproved current MainGame raw")
    requests = [(c, c, "commit") for c in (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT)]
    requests += [(t, t, "tree") for t in MODAL_TREES]
    requests += [(c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in
                 zip((MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT), MODAL_BLOBS)]
    raw = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = raw.index(b"\n", cursor)
        oid, actual_kind, size = raw[cursor:end].decode().split()
        size = int(size)
        value = raw[end + 1:end + 1 + size]
        if (oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or raw[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-381: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(raw):
        raise ValueError("ORDER-381: trailing immutable proof bytes")
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + MODAL_TREES[index].encode()]:
            raise ValueError("ORDER-381: immutable tree differs")
        if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + MODAL_BEFORE_COMMIT.encode()]:
            raise ValueError("ORDER-381: direct parent differs")
    if _modal_git(root, "diff", "--name-status", "-z", MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
        raise ValueError("ORDER-381: exact product path population differs")
    _modal_git(root, "merge-base", "--is-ancestor", MODAL_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != MODAL_BLOBS[1]:
        raise ValueError("ORDER-381: current Git MainGame differs")
    before, after = values[4:]
    if after != current or tuple(hashlib.sha256(v).hexdigest() for v in (before, after)) != MODAL_HASHES:
        raise ValueError("ORDER-381: whole raw/blob binding differs")
    recovered = after
    if len(MODAL_REPLACEMENTS) != 3:
        raise ValueError("ORDER-381: inverse population differs")
    for a, b in reversed(MODAL_REPLACEMENTS):
        a, b = a.encode(), b.encode()
        if not a or a == b or recovered.count(b) != 1:
            raise ValueError("ORDER-381: inverse is not exact1")
        recovered = recovered.replace(b, a, 1)
    if recovered != before:
        raise ValueError("ORDER-381: changes outside the exact three repairs")
    return before


_MODAL_OLD_PUBLIC = (main_game_history_source_errors, main_game_history_project_bytes,
                     main_game_history_project_byte_hash)
_MODAL_OLD_GIFT = (gift_caption_source_errors, gift_caption_project_bytes, gift_caption_project_byte_hash)


def _modal_dispatch(functions, mode, relative, current, claim=None):
    import subprocess
    if relative != MAIN_GAME_PATH:
        return (functions[0](relative, current) if mode == 0 else functions[1](current, relative)
                if mode == 1 else functions[2](claim, relative, current))
    if mode == 2 and (not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != claim):
        return claim
    try:
        previous = modal_font_predecessor(current)
    except (OSError, ValueError, TypeError, IndexError, UnicodeError, subprocess.TimeoutExpired) as exc:
        return ["ORDER-381: current modal admission: " + str(exc)] if mode == 0 else current if mode == 1 else claim
    return (functions[0](relative, previous) if mode == 0 else functions[1](previous, relative)
            if mode == 1 else functions[2](hashlib.sha256(previous).hexdigest(), relative, previous))


def main_game_history_source_errors(relative, current):
    return _modal_dispatch(_MODAL_OLD_PUBLIC, 0, relative, current)


def main_game_history_project_bytes(current, relative):
    return _modal_dispatch(_MODAL_OLD_PUBLIC, 1, relative, current)


def main_game_history_project_byte_hash(claim, relative, current):
    return _modal_dispatch(_MODAL_OLD_PUBLIC, 2, relative, current, claim)


def gift_caption_source_errors(relative, current):
    return _modal_dispatch(_MODAL_OLD_GIFT, 0, relative, current)


def gift_caption_project_bytes(current, relative):
    return _modal_dispatch(_MODAL_OLD_GIFT, 1, relative, current)


def gift_caption_project_byte_hash(claim, relative, current):
    return _modal_dispatch(_MODAL_OLD_GIFT, 2, relative, current, claim)
# END_MODAL_FONT_HISTORY_381


# BEGIN_JOB_STATUS_WRAP_HISTORY_382
# Keep the complete ORDER-381 implementation above as its historical contract.
# The successor proves both actual Git transitions without spoofing old HEAD.
JOB_STATUS_BEFORE_COMMIT = "ec26d1a69d08c7f7bd09293c396bc78ee89c9268"
JOB_STATUS_AFTER_COMMIT = "37a3479ad7ce5b640d580d9c50a1c52039adf49d"
JOB_STATUS_TREES = ("5cbd6ec1234bc9b8d01caf0d74be20699df648b3", "89846b1b925864511d7972041199436ac7db9de3")
JOB_STATUS_BLOBS = ("48e038af02412ef82decdb451b9e9b1d7135235e", "4acea38b4d1a0641e7696d1af9ae2d9631dc4c13")
JOB_STATUS_HASHES = ("6c26e3db61c810cd52022128a459a7160abf49c6a0c3d085f196755f9e232f8d",
                     "eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea")
JOB_STATUS_REPLACEMENT = (
    b'\t\tstatus_box.add_child(_label(\n\t\t\t"%s \xc2\xb7 Tier %d \xc2\xb7 %s %d/%d" % [\n',
    b'\t\tstatus_box.add_child(_wrap_label(\n\t\t\t"%s \xc2\xb7 Tier %d \xc2\xb7 %s %d/%d" % [\n',
)
_JOB_STATUS_OLD_MODAL_PREDECESSOR = modal_font_predecessor


def _job_status_wrap_proof(current, root=None):
    """Fresh current admission; return (pre382, pre381) comparison bytes only."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != JOB_STATUS_HASHES[1]:
        raise ValueError("ORDER-382: unapproved current MainGame raw")
    stages = (
        (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT, MODAL_TREES, MODAL_BLOBS, MODAL_HASHES),
        (JOB_STATUS_BEFORE_COMMIT, JOB_STATUS_AFTER_COMMIT, JOB_STATUS_TREES, JOB_STATUS_BLOBS, JOB_STATUS_HASHES),
    )
    requests = []
    for before_commit, after_commit, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before_commit, after_commit))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in
                        zip((before_commit, after_commit), blobs))
    raw = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = raw.index(b"\n", cursor)
        oid, actual_kind, size = raw[cursor:end].decode().split()
        size = int(size)
        value = raw[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or raw[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-382: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(raw):
        raise ValueError("ORDER-382: trailing immutable proof bytes")
    for stage, (before_commit, after_commit, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-382: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before_commit.encode()]:
                raise ValueError("ORDER-382: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-382: whole raw/blob binding differs")
        if _modal_git(root, "diff", "--name-status", "-z", before_commit, after_commit) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
            raise ValueError("ORDER-382: exact product path population differs")
    _modal_git(root, "merge-base", "--is-ancestor", MODAL_AFTER_COMMIT, JOB_STATUS_BEFORE_COMMIT)
    _modal_git(root, "merge-base", "--is-ancestor", JOB_STATUS_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != JOB_STATUS_BLOBS[1]:
        raise ValueError("ORDER-382: current Git MainGame differs")
    pre381, post381, pre382, post382 = values[4], values[5], values[10], values[11]
    if current != post382 or pre382 != post381:
        raise ValueError("ORDER-382: current or consecutive raw binding differs")
    a, b = JOB_STATUS_REPLACEMENT
    if not a or a == b or post382.count(b) != 1 or post382.replace(b, a, 1) != pre382:
        raise ValueError("ORDER-382: change outside the exact employed-status token")
    recovered = pre382
    if len(MODAL_REPLACEMENTS) != 3:
        raise ValueError("ORDER-382: prior inverse population differs")
    for a, b in reversed(MODAL_REPLACEMENTS):
        a, b = a.encode(), b.encode()
        if not a or a == b or recovered.count(b) != 1:
            raise ValueError("ORDER-382: prior inverse is not exact1")
        recovered = recovered.replace(b, a, 1)
    if recovered != pre381:
        raise ValueError("ORDER-382: changes outside the prior exact three repairs")
    return pre382, pre381


def job_status_wrap_predecessor(current, root=None):
    return _job_status_wrap_proof(current, root)[0]


def modal_font_predecessor(current, root=None):
    """Preserve the public pre381 comparison contract for admitted current382."""
    return _job_status_wrap_proof(current, root)[1]
# END_JOB_STATUS_WRAP_HISTORY_382


# BEGIN_INVESTMENT_FOOTER_HISTORY_386
# Rendering-only successor: earlier functions and pins above remain historical.
INVESTMENT_BEFORE_COMMIT = "ebe72d23f520101a616035e333d05defd4ba3356"
INVESTMENT_AFTER_COMMIT = "6dacf74f7ece36bbf720a07b24a8d55fdcd06aa6"
INVESTMENT_TREES = ("38575dd0150b2cdba3f58b1b3f0ebed622f68f65", "91ce8f0924f6f2a30c6df94ad9233f1e9472a4aa")
INVESTMENT_BLOBS = ("4acea38b4d1a0641e7696d1af9ae2d9631dc4c13", "57a21ec92e0ca0a681aae4de5df1b7c5c24b1854")
INVESTMENT_HASHES = ("eb9efa2243ae97e032ca13e64bae3f42558fe9618babe97c5bc3d21a05e23cea",
                     "6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90")
INVESTMENT_REPLACEMENTS = (
    ('\t_invest_page_body.add_child(_build_investment_page_caption(\n'
     '\t\tpage_no,\n'
     '\t\t_tr("↑↓ 자산 · ←→ 매수/매도 · LB/RB 페이지", "↑↓ asset · ←→ buy/sell · LB/RB page"),\n'
     '\t\t"#5b9cf6"))\n',
     '\tvar caption := _build_investment_page_caption(\n'
     '\t\tpage_no,\n'
     '\t\t_tr("↑↓ 자산 · ←→ 매수/매도 · LB/RB 페이지", "↑↓ asset · ←→ buy/sell · LB/RB page"),\n'
     '\t\t"#5b9cf6")\n'
     '\t_invest_page_body.add_child(caption)\n'
     '\tvar caption_row := caption.get_child(0) as HBoxContainer\n'
     '\tfor direction in [-1, 1]:\n'
     '\t\tvar move_btn := _small_button("↑" if direction < 0 else "↓", "#243851")\n'
     '\t\tmove_btn.custom_minimum_size = Vector2(46, 46)\n'
     '\t\tmove_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER\n'
     '\t\tmove_btn.focus_mode = Control.FOCUS_NONE\n'
     '\t\tmove_btn.disabled = rows.size() < 2\n'
     '\t\tmove_btn.pressed.connect(func():\n'
     '\t\t\tif _modal_kind != "investments" or not is_instance_valid(modal_layer) or not modal_layer.visible:\n'
     '\t\t\t\treturn\n'
     '\t\t\tif _invest_current_page_id() != "assets" or not is_instance_valid(_invest_page_body):\n'
     '\t\t\t\treturn\n'
     '\t\t\tif not is_instance_valid(caption) or caption.is_queued_for_deletion() or caption.get_parent() != _invest_page_body:\n'
     '\t\t\t\treturn\n'
     '\t\t\t_invest_move_asset(direction, false))\n'
     '\t\tcaption_row.add_child(move_btn)\n'),
    ('\tvar visible_count := mini(2, rows.size())\n'
     '\tvar start_idx := clampi(_invest_pad_asset_idx - 1, 0, maxi(0, rows.size() - visible_count))\n',
     '\tvar visible_count := 1\n\tvar start_idx := _invest_pad_asset_idx\n'),
    ('func _invest_move_asset(delta: int) -> bool:\n'
     '\tif _invest_pad_asset_ids.is_empty():\n\t\treturn true\n'
     '\t_invest_pad_asset_idx = int(posmod(_invest_pad_asset_idx + delta, _invest_pad_asset_ids.size()))\n'
     '\t_invest_pad_action_idx = 0\n\tAudioManager.play_ui_click()\n',
     'func _invest_move_asset(delta: int, play_sound: bool = true) -> bool:\n'
     '\tif _invest_pad_asset_ids.is_empty():\n\t\treturn true\n'
     '\t_invest_pad_asset_idx = int(posmod(_invest_pad_asset_idx + delta, _invest_pad_asset_ids.size()))\n'
     '\t_invest_pad_action_idx = 0\n\tif play_sound:\n\t\tAudioManager.play_ui_click()\n'),
)


def _investment_footer_proof(current, root=None):
    """Fresh actual386 Git admission; return (pre386, pre381) comparison bytes."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != INVESTMENT_HASHES[1]:
        raise ValueError("ORDER-386: unapproved current MainGame raw")
    stages = (
        (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT, MODAL_TREES, MODAL_BLOBS, MODAL_HASHES),
        (JOB_STATUS_BEFORE_COMMIT, JOB_STATUS_AFTER_COMMIT, JOB_STATUS_TREES, JOB_STATUS_BLOBS, JOB_STATUS_HASHES),
        (INVESTMENT_BEFORE_COMMIT, INVESTMENT_AFTER_COMMIT, INVESTMENT_TREES, INVESTMENT_BLOBS, INVESTMENT_HASHES),
    )
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in zip((before, after), blobs))
    proof = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = proof.index(b"\n", cursor)
        oid, actual_kind, size = proof[cursor:end].decode().split()
        size = int(size)
        value = proof[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or proof[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-386: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-386: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-386: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-386: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-386: immutable whole raw differs")
        if _modal_git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
            raise ValueError("ORDER-386: product path population differs")
        if stage:
            _modal_git(root, "merge-base", "--is-ancestor", stages[stage - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-386: nonconsecutive raw history")
    _modal_git(root, "merge-base", "--is-ancestor", INVESTMENT_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != INVESTMENT_BLOBS[1]:
        raise ValueError("ORDER-386: current Git MainGame differs")
    if values[17] != current:
        raise ValueError("ORDER-386: current/blob binding differs")
    recovered = current
    inverse_stages = ((INVESTMENT_REPLACEMENTS, values[16]),
                      ((tuple(v.decode() for v in JOB_STATUS_REPLACEMENT),), values[10]),
                      (MODAL_REPLACEMENTS, values[4]))
    if tuple(len(parts) for parts, _ in inverse_stages) != (3, 1, 3):
        raise ValueError("ORDER-386: inverse population differs")
    for replacements, before in inverse_stages:
        for old, new in reversed(replacements):
            old, new = old.encode(), new.encode()
            if not old or old == new or recovered.count(new) != 1:
                raise ValueError("ORDER-386: inverse is not exact1")
            recovered = recovered.replace(new, old, 1)
        if recovered != before:
            raise ValueError("ORDER-386: changes outside exact rendering repairs")
    return values[16], recovered


def investment_footer_predecessor(current, root=None):
    return _investment_footer_proof(current, root)[0]


def modal_font_predecessor(current, root=None):
    """Keep the public pre381 comparison contract for admitted actual386."""
    return _investment_footer_proof(current, root)[1]
# END_INVESTMENT_FOOTER_HISTORY_386

# BEGIN_TUTORIAL_COPY_HISTORY_390
# A source-pair correction, not a rendering-only exemption. Older bodies/pins
# stay literal; only this exact current Git transition reaches their inverses.
TUTORIAL_BEFORE_COMMIT = "8da4a8b7d2709c9ecbd9ea78780b76ebc117ff37"
TUTORIAL_AFTER_COMMIT = "d24ac6fb2eaa7a193080915ebf119247a3c35291"
TUTORIAL_TREES = ("876f6a121ae34ffa19131ea95a22f89bc5552edb", "af209ca49fc5f0d5d984405f7761fb773cf4844a")
TUTORIAL_BLOBS = ("57a21ec92e0ca0a681aae4de5df1b7c5c24b1854", "f527d67772081a38ffd75e5a47426e5e5f7ff74e")
TUTORIAL_HASHES = ("6432a5ceb5844c1fdc54265547053dc82db8808ea87f442058412f03d24eed90",
                    "db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff")
TUTORIAL_OLD_KO = "건강/정신력이 0이 되거나 빚이 -1억을 넘으면 끝납니다."
TUTORIAL_NEW_KO = "건강/정신력이 0이 되거나 순자산이 -1억 원 미만이면 끝납니다."
TUTORIAL_OLD_EN = "It's over if Health/Mental hits 0, or if debt exceeds -KRW 100M."
TUTORIAL_NEW_EN = "It's over if Health/Mental hits 0, or if Net Worth falls below -KRW 100M."
TUTORIAL_REPLACEMENT = tuple(
    '\t\t_tr("' + ko + '", "' + en + '"),\n'
    for ko, en in ((TUTORIAL_OLD_KO, TUTORIAL_OLD_EN), (TUTORIAL_NEW_KO, TUTORIAL_NEW_EN))
)


def _tutorial_copy_proof(current, root=None):
    """Fresh exact copy admission; return (pre390, pre386, pre381) bytes."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != TUTORIAL_HASHES[1]:
        raise ValueError("ORDER-390: unapproved current MainGame raw")
    stages = (
        (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT, MODAL_TREES, MODAL_BLOBS, MODAL_HASHES),
        (JOB_STATUS_BEFORE_COMMIT, JOB_STATUS_AFTER_COMMIT, JOB_STATUS_TREES, JOB_STATUS_BLOBS, JOB_STATUS_HASHES),
        (INVESTMENT_BEFORE_COMMIT, INVESTMENT_AFTER_COMMIT, INVESTMENT_TREES, INVESTMENT_BLOBS, INVESTMENT_HASHES),
        (TUTORIAL_BEFORE_COMMIT, TUTORIAL_AFTER_COMMIT, TUTORIAL_TREES, TUTORIAL_BLOBS, TUTORIAL_HASHES),
    )
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in zip((before, after), blobs))
    proof = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = proof.index(b"\n", cursor)
        oid, actual_kind, size = proof[cursor:end].decode().split()
        size = int(size)
        value = proof[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or proof[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-390: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-390: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-390: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-390: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-390: immutable whole raw differs")
        if _modal_git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
            raise ValueError("ORDER-390: product path population differs")
        if stage:
            _modal_git(root, "merge-base", "--is-ancestor", stages[stage - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-390: nonconsecutive raw history")
    _modal_git(root, "merge-base", "--is-ancestor", TUTORIAL_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != TUTORIAL_BLOBS[1]:
        raise ValueError("ORDER-390: current Git MainGame differs")
    if values[23] != current:
        raise ValueError("ORDER-390: current/blob binding differs")
    recovered = current
    inverse_stages = (((TUTORIAL_REPLACEMENT,), values[22]),
                      (INVESTMENT_REPLACEMENTS, values[16]),
                      ((tuple(v.decode() for v in JOB_STATUS_REPLACEMENT),), values[10]),
                      (MODAL_REPLACEMENTS, values[4]))
    if tuple(len(parts) for parts, _ in inverse_stages) != (1, 3, 1, 3):
        raise ValueError("ORDER-390: inverse population differs")
    for replacements, before in inverse_stages:
        for old, new in reversed(replacements):
            old, new = old.encode(), new.encode()
            if not old or old == new or recovered.count(new) != 1:
                raise ValueError("ORDER-390: inverse is not exact1")
            recovered = recovered.replace(new, old, 1)
        if recovered != before:
            raise ValueError("ORDER-390: changes outside exact copy/rendering repairs")
    return values[22], values[16], recovered


def tutorial_copy_predecessor(current, root=None):
    return _tutorial_copy_proof(current, root)[0]


def investment_footer_predecessor(current, root=None):
    return _tutorial_copy_proof(current, root)[1]


def modal_font_predecessor(current, root=None):
    """Keep the public pre381 comparison contract for admitted actual390."""
    return _tutorial_copy_proof(current, root)[2]
# END_TUTORIAL_COPY_HISTORY_390

# BEGIN_PAD_HINT_FONT_HISTORY_393
# Exact rendering successor. Earlier bodies and pins remain historical; no
# historical HEAD is substituted when proving the actual current source.
PAD_HINT_BEFORE_COMMIT = "b48bc211092c14b80b51b3d8c8f06a4d79b84919"
PAD_HINT_AFTER_COMMIT = "d0a7c9cf38b8d64f65bf0c9020bbb9ce0a1de91b"
PAD_HINT_TREES = ("cba97af32d67a79891fd57489fe742783a340e4c", "c3bc87da49fc23388648ca9466092e522eac5cb4")
PAD_HINT_BLOBS = ("f527d67772081a38ffd75e5a47426e5e5f7ff74e", "c0bfef9cff660c40351c8ae046f75f5fc776c536")
PAD_HINT_HASHES = ("db5d0dc1f8890ea5ae3e0b9d1f212c2a316be50ef3265804dbde9dba0279a8ff",
                   "ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d")
PAD_HINT_REPLACEMENTS = tuple(
    ('\tif _font_bold:\n\t\t_' + label + '_pad_hint_label.add_theme_font_override("bold_font", _font_bold)\n',
     '\tif _font_regular:\n\t\t_' + label + '_pad_hint_label.add_theme_font_override("normal_font", _font_regular)\n'
     '\tif _font_bold:\n\t\t_' + label + '_pad_hint_label.add_theme_font_override("bold_font", _font_bold)\n')
    for label in ("people", "invest")
)


def _pad_hint_font_inverse(current, before):
    """Pure comparison-only exact four-line inverse, also tested without hashes."""
    if not isinstance(current, bytes) or not isinstance(before, bytes) or len(PAD_HINT_REPLACEMENTS) != 2:
        raise ValueError("ORDER-393: inverse population/type differs")
    recovered = current
    for old, new in reversed(PAD_HINT_REPLACEMENTS):
        old, new = old.encode(), new.encode()
        if (not old or old == new or before.count(old) != 1 or before.count(new) != 0
                or recovered.count(new) != 1):
            raise ValueError("ORDER-393: font inverse is not exact1 at each consumer")
        recovered = recovered.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-393: changes outside exact four font lines")
    return recovered


def _pad_hint_font_proof(current, root=None):
    """Fresh actual393 proof; return pre393/pre390/pre386/pre381 comparisons."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != PAD_HINT_HASHES[1]:
        raise ValueError("ORDER-393: unapproved current MainGame raw")
    stages = (
        (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT, MODAL_TREES, MODAL_BLOBS, MODAL_HASHES),
        (JOB_STATUS_BEFORE_COMMIT, JOB_STATUS_AFTER_COMMIT, JOB_STATUS_TREES, JOB_STATUS_BLOBS, JOB_STATUS_HASHES),
        (INVESTMENT_BEFORE_COMMIT, INVESTMENT_AFTER_COMMIT, INVESTMENT_TREES, INVESTMENT_BLOBS, INVESTMENT_HASHES),
        (TUTORIAL_BEFORE_COMMIT, TUTORIAL_AFTER_COMMIT, TUTORIAL_TREES, TUTORIAL_BLOBS, TUTORIAL_HASHES),
        (PAD_HINT_BEFORE_COMMIT, PAD_HINT_AFTER_COMMIT, PAD_HINT_TREES, PAD_HINT_BLOBS, PAD_HINT_HASHES),
    )
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in zip((before, after), blobs))
    proof = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = proof.index(b"\n", cursor)
        oid, actual_kind, size = proof[cursor:end].decode().split()
        size = int(size)
        value = proof[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or proof[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-393: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-393: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-393: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-393: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-393: immutable whole raw differs")
        if _modal_git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
            raise ValueError("ORDER-393: product path population differs")
        if stage:
            _modal_git(root, "merge-base", "--is-ancestor", stages[stage - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-393: nonconsecutive raw history")
    _modal_git(root, "merge-base", "--is-ancestor", PAD_HINT_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != PAD_HINT_BLOBS[1]:
        raise ValueError("ORDER-393: current Git MainGame differs")
    if values[29] != current:
        raise ValueError("ORDER-393: current/blob binding differs")
    recovered = _pad_hint_font_inverse(current, values[28])
    inverse_stages = (((TUTORIAL_REPLACEMENT,), values[22]),
                      (INVESTMENT_REPLACEMENTS, values[16]),
                      ((tuple(v.decode() for v in JOB_STATUS_REPLACEMENT),), values[10]),
                      (MODAL_REPLACEMENTS, values[4]))
    if tuple(len(parts) for parts, _ in inverse_stages) != (1, 3, 1, 3):
        raise ValueError("ORDER-393: prior inverse population differs")
    for replacements, before in inverse_stages:
        for old, new in reversed(replacements):
            old, new = old.encode(), new.encode()
            if not old or old == new or recovered.count(new) != 1:
                raise ValueError("ORDER-393: prior inverse is not exact1")
            recovered = recovered.replace(new, old, 1)
        if recovered != before:
            raise ValueError("ORDER-393: changes outside prior exact copy/rendering repairs")
    return values[28], values[22], values[16], recovered


def pad_hint_font_predecessor(current, root=None):
    return _pad_hint_font_proof(current, root)[0]


def tutorial_copy_predecessor(current, root=None):
    return _pad_hint_font_proof(current, root)[1]


def investment_footer_predecessor(current, root=None):
    return _pad_hint_font_proof(current, root)[2]


def modal_font_predecessor(current, root=None):
    """Keep the public pre381 comparison contract for admitted actual393."""
    return _pad_hint_font_proof(current, root)[3]
# END_PAD_HINT_FONT_HISTORY_393


# BEGIN_PEOPLE_CARD_HEIGHT_HISTORY_402
# Two actual MainGame-only transitions; the first failed rendering candidate
# remains an immutable checkpoint, not an accepted current source.
# Earlier source functions and immutable pins remain unchanged.
PEOPLE_CARD_BEFORE_COMMIT = "11cb081d64d48b26af6a09921ce34ff04e859399"
PEOPLE_CARD_AFTER_COMMIT = "ef41993805c7ce6e68ffbef8336b83cec6f7e744"
PEOPLE_CARD_TREES = ("c1b5356fdf06d3ada42aaf0c3cad5df11be9b051", "6a0fece7aa64f03cc048cffe28f039a1a0d1ec1c")
PEOPLE_CARD_BLOBS = ("c0bfef9cff660c40351c8ae046f75f5fc776c536", "f1343051117712d9e53c0b1bd57a43a8d31d7f65")
PEOPLE_CARD_HASHES = ("ed116a1d4dae6dc0fcac708204c97eaadf988070e501c0bb1df437be6e38170d",
                      "b8a03419633a837b5493ddc22569c6f256ac91e602551eb5327cf0e71dabb881")
PEOPLE_CARD_INITIAL_REPLACEMENT = ("\tbtn.custom_minimum_size = Vector2(0, 60)\n\tbtn.focus_mode = Control.FOCUS_NONE\n\tbtn.set_meta(\"people_action_idx\", index)\n",
                           "\tbtn.custom_minimum_size = Vector2(0, 60)\n\tif thumb is AtlasTexture:\n\t\tfor child in btn.get_children():\n\t\t\tif child is MarginContainer:\n\t\t\t\tbtn.custom_minimum_size.y = maxf(btn.custom_minimum_size.y, child.get_combined_minimum_size().y)\n\tbtn.focus_mode = Control.FOCUS_NONE\n\tbtn.set_meta(\"people_action_idx\", index)\n")
PEOPLE_CARD_REPAIR_BEFORE_COMMIT = "7cf2ed99560da06b44966f0ff6c0b6fd6031c63d"
PEOPLE_CARD_REPAIR_AFTER_COMMIT = "30a147848f7640e1b5f0c9c0e18b946cdf8a2ce4"
PEOPLE_CARD_REPAIR_TREES = ("91c0e44d8ab34ef7107bec8dd5938846a55d9471", "47dac749bb10ad2a54272ead3d0590a1cd495d59")
PEOPLE_CARD_REPAIR_BLOBS = ("f1343051117712d9e53c0b1bd57a43a8d31d7f65", "d79d63645ed9b4b5fa9062380fca28942add169a")
PEOPLE_CARD_REPAIR_HASHES = ("b8a03419633a837b5493ddc22569c6f256ac91e602551eb5327cf0e71dabb881",
                           "473aab2946d2b76a6263e57fc36facfc24de83629fddf88f3005200a81a15e7d")
PEOPLE_CARD_REPAIR_REPLACEMENT = (
    PEOPLE_CARD_INITIAL_REPLACEMENT[1],
    "\tbtn.custom_minimum_size = Vector2(0, 60)\n\tif thumb is AtlasTexture:\n\t\tfor child in btn.get_children():\n\t\t\tif child is MarginContainer:\n\t\t\t\tvar fit_height := func() -> void:\n\t\t\t\t\tif is_instance_valid(btn) and is_instance_valid(child) and btn.is_inside_tree():\n\t\t\t\t\t\tbtn.custom_minimum_size.y = maxf(60.0, child.get_combined_minimum_size().y)\n\t\t\t\tbtn.ready.connect(fit_height, CONNECT_ONE_SHOT)\n\t\t\t\tchild.minimum_size_changed.connect(fit_height)\n\tbtn.focus_mode = Control.FOCUS_NONE\n\tbtn.set_meta(\"people_action_idx\", index)\n")
PEOPLE_CARD_REPLACEMENT = (PEOPLE_CARD_INITIAL_REPLACEMENT[0], PEOPLE_CARD_REPAIR_REPLACEMENT[1])


def _people_card_height_step_inverse(current, before, replacement):
    """Pure exact local inverse; no digest gate can mask semantic controls."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(replacement, tuple) or len(replacement) != 2
            or any(not isinstance(part, str) for part in replacement)):
        raise ValueError("ORDER-402: inverse population/type differs")
    old, new = (part.encode() for part in replacement)
    if (not old or old == new or before.count(old) != 1 or before.count(new) != 0
            or current.count(new) != 1):
        raise ValueError("ORDER-402: local inverse is not exact1")
    recovered = current.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-402: changes outside exact people-card height")
    return recovered


def _people_card_height_inverse(current, before):
    """Exact combined final-to-pre402 inverse, independent of immutable hashes."""
    return _people_card_height_step_inverse(current, before, PEOPLE_CARD_REPLACEMENT)


def _people_card_height_proof(current, root=None):
    """Fresh actual402 proof; pre402/pre393/pre390/pre386/pre381 comparisons."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != PEOPLE_CARD_REPAIR_HASHES[1]:
        raise ValueError("ORDER-402: unapproved current MainGame raw")
    stages = (
        (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT, MODAL_TREES, MODAL_BLOBS, MODAL_HASHES),
        (JOB_STATUS_BEFORE_COMMIT, JOB_STATUS_AFTER_COMMIT, JOB_STATUS_TREES, JOB_STATUS_BLOBS, JOB_STATUS_HASHES),
        (INVESTMENT_BEFORE_COMMIT, INVESTMENT_AFTER_COMMIT, INVESTMENT_TREES, INVESTMENT_BLOBS, INVESTMENT_HASHES),
        (TUTORIAL_BEFORE_COMMIT, TUTORIAL_AFTER_COMMIT, TUTORIAL_TREES, TUTORIAL_BLOBS, TUTORIAL_HASHES),
        (PAD_HINT_BEFORE_COMMIT, PAD_HINT_AFTER_COMMIT, PAD_HINT_TREES, PAD_HINT_BLOBS, PAD_HINT_HASHES),
        (PEOPLE_CARD_BEFORE_COMMIT, PEOPLE_CARD_AFTER_COMMIT, PEOPLE_CARD_TREES, PEOPLE_CARD_BLOBS, PEOPLE_CARD_HASHES),
        (PEOPLE_CARD_REPAIR_BEFORE_COMMIT, PEOPLE_CARD_REPAIR_AFTER_COMMIT, PEOPLE_CARD_REPAIR_TREES,
         PEOPLE_CARD_REPAIR_BLOBS, PEOPLE_CARD_REPAIR_HASHES),
    )
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in zip((before, after), blobs))
    proof = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = proof.index(b"\n", cursor)
        oid, actual_kind, size = proof[cursor:end].decode().split()
        size = int(size)
        value = proof[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or proof[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-402: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-402: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-402: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-402: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-402: immutable whole raw differs")
        if _modal_git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
            raise ValueError("ORDER-402: product path population differs")
        if stage:
            _modal_git(root, "merge-base", "--is-ancestor", stages[stage - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-402: nonconsecutive raw history")
    _modal_git(root, "merge-base", "--is-ancestor", PEOPLE_CARD_REPAIR_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != PEOPLE_CARD_REPAIR_BLOBS[1]:
        raise ValueError("ORDER-402: current Git MainGame differs")
    if values[41] != current:
        raise ValueError("ORDER-402: current/blob binding differs")
    recovered = _people_card_height_inverse(current, values[34])
    intermediate = _people_card_height_step_inverse(current, values[40], PEOPLE_CARD_REPAIR_REPLACEMENT)
    if _people_card_height_step_inverse(intermediate, values[34], PEOPLE_CARD_INITIAL_REPLACEMENT) != recovered:
        raise ValueError("ORDER-402: stagewise and combined inverses differ")
    recovered = _pad_hint_font_inverse(recovered, values[28])
    inverse_stages = (((TUTORIAL_REPLACEMENT,), values[22]),
                      (INVESTMENT_REPLACEMENTS, values[16]),
                      ((tuple(v.decode() for v in JOB_STATUS_REPLACEMENT),), values[10]),
                      (MODAL_REPLACEMENTS, values[4]))
    if tuple(len(parts) for parts, _ in inverse_stages) != (1, 3, 1, 3):
        raise ValueError("ORDER-402: prior inverse population differs")
    for replacements, before in inverse_stages:
        for old, new in reversed(replacements):
            old, new = old.encode(), new.encode()
            if not old or old == new or recovered.count(new) != 1:
                raise ValueError("ORDER-402: prior inverse is not exact1")
            recovered = recovered.replace(new, old, 1)
        if recovered != before:
            raise ValueError("ORDER-402: changes outside prior exact copy/rendering repairs")
    return values[34], values[28], values[22], values[16], recovered


def people_card_height_predecessor(current, root=None):
    return _people_card_height_proof(current, root)[0]


def pad_hint_font_predecessor(current, root=None):
    return _people_card_height_proof(current, root)[1]


def tutorial_copy_predecessor(current, root=None):
    return _people_card_height_proof(current, root)[2]


def investment_footer_predecessor(current, root=None):
    return _people_card_height_proof(current, root)[3]


def modal_font_predecessor(current, root=None):
    """Keep the public pre381 comparison contract for admitted actual402."""
    return _people_card_height_proof(current, root)[4]
# END_PEOPLE_CARD_HEIGHT_HISTORY_402


# BEGIN_AXIS_BADGE_FIT_HISTORY_403
# Exact MainGame-only axis-label successor, bound to actual immutable objects.
# All older functions and pins remain byte-exact, including the failed402 checkpoint.
AXIS_BADGE_BEFORE_COMMIT = "3ab189eb38cd6fcfe534dbf11ce6ed1b470255e4"
AXIS_BADGE_AFTER_COMMIT = "652c53e541c025be67efb73d9613a52ff05615d4"
AXIS_BADGE_TREES = ("871a61f22387327a555e8b05a6deac643f639270", "2d76927bafc7dfdc00c929cdb3c52b017cb0fec3")
AXIS_BADGE_BLOBS = ("d79d63645ed9b4b5fa9062380fca28942add169a", "011511d838985d811bed8f87cbc94c64967f1fcf")
AXIS_BADGE_HASHES = ("473aab2946d2b76a6263e57fc36facfc24de83629fddf88f3005200a81a15e7d",
                     "4c86abe5880d49128a511da36ad361f76c4290c10103d976e1dd33d66294d6bf")
AXIS_BADGE_REPLACEMENT = (
    '\t\tvar axis_lbl := _label(_axis_label(axis_tag), 10, _axis_color(axis_tag) if not disabled else "#5a6070")\n\t\taxis_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER\n',
    '\t\tvar axis_lbl := _label(_axis_label(axis_tag), 10, _axis_color(axis_tag) if not disabled else "#5a6070")\n\t\taxis_lbl.clip_text = false\n\t\taxis_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER\n')


def _axis_badge_fit_inverse(current, before):
    """Pure exact axis-only inverse, independent of all digest checks."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(AXIS_BADGE_REPLACEMENT, tuple) or len(AXIS_BADGE_REPLACEMENT) != 2
            or any(not isinstance(part, str) for part in AXIS_BADGE_REPLACEMENT)):
        raise ValueError("ORDER-403: inverse population/type differs")
    old, new = (part.encode() for part in AXIS_BADGE_REPLACEMENT)
    if (not old or old == new or before.count(old) != 1 or before.count(new) != 0
            or current.count(new) != 1):
        raise ValueError("ORDER-403: local inverse is not exact1")
    recovered = current.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-403: changes outside exact axis badge fit")
    return recovered


def _axis_badge_fit_proof(current, root=None):
    """One fresh actual403 proof; pre403 and all five earlier comparisons."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != AXIS_BADGE_HASHES[1]:
        raise ValueError("ORDER-403: unapproved current MainGame raw")
    stages = (
        (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT, MODAL_TREES, MODAL_BLOBS, MODAL_HASHES),
        (JOB_STATUS_BEFORE_COMMIT, JOB_STATUS_AFTER_COMMIT, JOB_STATUS_TREES, JOB_STATUS_BLOBS, JOB_STATUS_HASHES),
        (INVESTMENT_BEFORE_COMMIT, INVESTMENT_AFTER_COMMIT, INVESTMENT_TREES, INVESTMENT_BLOBS, INVESTMENT_HASHES),
        (TUTORIAL_BEFORE_COMMIT, TUTORIAL_AFTER_COMMIT, TUTORIAL_TREES, TUTORIAL_BLOBS, TUTORIAL_HASHES),
        (PAD_HINT_BEFORE_COMMIT, PAD_HINT_AFTER_COMMIT, PAD_HINT_TREES, PAD_HINT_BLOBS, PAD_HINT_HASHES),
        (PEOPLE_CARD_BEFORE_COMMIT, PEOPLE_CARD_AFTER_COMMIT, PEOPLE_CARD_TREES, PEOPLE_CARD_BLOBS, PEOPLE_CARD_HASHES),
        (PEOPLE_CARD_REPAIR_BEFORE_COMMIT, PEOPLE_CARD_REPAIR_AFTER_COMMIT, PEOPLE_CARD_REPAIR_TREES,
         PEOPLE_CARD_REPAIR_BLOBS, PEOPLE_CARD_REPAIR_HASHES),
        (AXIS_BADGE_BEFORE_COMMIT, AXIS_BADGE_AFTER_COMMIT, AXIS_BADGE_TREES, AXIS_BADGE_BLOBS, AXIS_BADGE_HASHES),
    )
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in zip((before, after), blobs))
    proof = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = proof.index(b"\n", cursor)
        oid, actual_kind, size = proof[cursor:end].decode().split()
        size = int(size)
        value = proof[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or proof[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-403: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-403: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-403: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-403: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-403: immutable whole raw differs")
        if _modal_git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
            raise ValueError("ORDER-403: product path population differs")
        if stage:
            _modal_git(root, "merge-base", "--is-ancestor", stages[stage - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-403: nonconsecutive raw history")
    _modal_git(root, "merge-base", "--is-ancestor", AXIS_BADGE_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != AXIS_BADGE_BLOBS[1]:
        raise ValueError("ORDER-403: current Git MainGame differs")
    if values[47] != current:
        raise ValueError("ORDER-403: current/blob binding differs")
    pre403 = _axis_badge_fit_inverse(current, values[46])
    recovered = _people_card_height_inverse(pre403, values[34])
    intermediate = _people_card_height_step_inverse(pre403, values[40], PEOPLE_CARD_REPAIR_REPLACEMENT)
    if _people_card_height_step_inverse(intermediate, values[34], PEOPLE_CARD_INITIAL_REPLACEMENT) != recovered:
        raise ValueError("ORDER-403: stagewise and combined inverses differ")
    recovered = _pad_hint_font_inverse(recovered, values[28])
    inverse_stages = (((TUTORIAL_REPLACEMENT,), values[22]),
                      (INVESTMENT_REPLACEMENTS, values[16]),
                      ((tuple(v.decode() for v in JOB_STATUS_REPLACEMENT),), values[10]),
                      (MODAL_REPLACEMENTS, values[4]))
    if tuple(len(parts) for parts, _ in inverse_stages) != (1, 3, 1, 3):
        raise ValueError("ORDER-403: prior inverse population differs")
    for replacements, before in inverse_stages:
        for old, new in reversed(replacements):
            old, new = old.encode(), new.encode()
            if not old or old == new or recovered.count(new) != 1:
                raise ValueError("ORDER-403: prior inverse is not exact1")
            recovered = recovered.replace(new, old, 1)
        if recovered != before:
            raise ValueError("ORDER-403: changes outside prior exact copy/rendering repairs")
    return pre403, values[34], values[28], values[22], values[16], recovered

def axis_badge_fit_predecessor(current, root=None):
    return _axis_badge_fit_proof(current, root)[0]


def people_card_height_predecessor(current, root=None):
    return _axis_badge_fit_proof(current, root)[1]


def pad_hint_font_predecessor(current, root=None):
    return _axis_badge_fit_proof(current, root)[2]


def tutorial_copy_predecessor(current, root=None):
    return _axis_badge_fit_proof(current, root)[3]


def investment_footer_predecessor(current, root=None):
    return _axis_badge_fit_proof(current, root)[4]


def modal_font_predecessor(current, root=None):
    """Preserve the public pre381 comparison contract for actual403."""
    return _axis_badge_fit_proof(current, root)[5]
# END_AXIS_BADGE_FIT_HISTORY_403


# BEGIN_PROMOTION_REVIEW_HISTORY_406
# Exact one-pair copy successor; all earlier bodies/pins remain immutable.
PROMOTION_BEFORE_COMMIT = "b615316abf5b3f7cc198c5ee78eac904e6c4cde1"
PROMOTION_AFTER_COMMIT = "cd42885dacadd57af6c2dd5b88c8e3dafbf218cc"
PROMOTION_TREES = ("d853788caf9aeca73585218409df7065ade029e1", "eb7efb98dc1fa0e696305f9ddcf8d1dc85719ce2")
PROMOTION_BLOBS = ("011511d838985d811bed8f87cbc94c64967f1fcf", "660f0f98b9a3ac3f2809d9bdb8a1856b51e410ba")
PROMOTION_HASHES = ("4c86abe5880d49128a511da36ad361f76c4290c10103d976e1dd33d66294d6bf",
                    "bda4961c1a377edcaee454b83937c3a580bce029b3a802ef293118f3f2d3823d")
PROMOTION_OLD_KO = "이번 달 승진 판정 대상!  (35% 확률)"
PROMOTION_NEW_KO = "이번 달 승진 판정 대상!"
PROMOTION_OLD_EN = "Up for promotion this month!  (35% chance)"
PROMOTION_NEW_EN = "Eligible for a promotion review this month!"
PROMOTION_REPLACEMENT = (
    "\t\t\tif tenure >= threshold and perf >= 60:\n\t\t\t\tmodal_body.add_child(_wrap_label(_tr(\"이번 달 승진 판정 대상!  (35% 확률)\", \"Up for promotion this month!  (35% chance)\"), 13, _info_text_hex(\"#f0b429\", 0.02)))\n\t\t\telif tenure >= threshold:\n",
    "\t\t\tif tenure >= threshold and perf >= 60:\n\t\t\t\tmodal_body.add_child(_wrap_label(_tr(\"이번 달 승진 판정 대상!\", \"Eligible for a promotion review this month!\"), 13, _info_text_hex(\"#f0b429\", 0.02)))\n\t\t\telif tenure >= threshold:\n")


def _promotion_review_copy_inverse(current, before):
    """One exact anchored pair inverse; no hashes can hide semantic controls."""
    if (not isinstance(current, bytes) or not isinstance(before, bytes)
            or not isinstance(PROMOTION_REPLACEMENT, tuple) or len(PROMOTION_REPLACEMENT) != 2
            or any(not isinstance(part, str) for part in PROMOTION_REPLACEMENT)):
        raise ValueError("ORDER-406: inverse population/type differs")
    old, new = (part.encode() for part in PROMOTION_REPLACEMENT)
    if (not old or old == new or before.count(old) != 1 or before.count(new) != 0
            or current.count(new) != 1):
        raise ValueError("ORDER-406: local inverse is not exact1")
    recovered = current.replace(new, old, 1)
    if recovered != before:
        raise ValueError("ORDER-406: changes outside exact promotion review copy")
    return recovered


def _promotion_review_copy_proof(current, root=None):
    """Fresh actual406 proof; seven exact comparison-only predecessors."""
    from pathlib import Path
    root = Path(root) if root is not None else Path(__file__).resolve().parents[1]
    if not isinstance(current, bytes) or hashlib.sha256(current).hexdigest() != PROMOTION_HASHES[1]:
        raise ValueError("ORDER-406: unapproved current MainGame raw")
    stages = (
        (MODAL_BEFORE_COMMIT, MODAL_AFTER_COMMIT, MODAL_TREES, MODAL_BLOBS, MODAL_HASHES),
        (JOB_STATUS_BEFORE_COMMIT, JOB_STATUS_AFTER_COMMIT, JOB_STATUS_TREES, JOB_STATUS_BLOBS, JOB_STATUS_HASHES),
        (INVESTMENT_BEFORE_COMMIT, INVESTMENT_AFTER_COMMIT, INVESTMENT_TREES, INVESTMENT_BLOBS, INVESTMENT_HASHES),
        (TUTORIAL_BEFORE_COMMIT, TUTORIAL_AFTER_COMMIT, TUTORIAL_TREES, TUTORIAL_BLOBS, TUTORIAL_HASHES),
        (PAD_HINT_BEFORE_COMMIT, PAD_HINT_AFTER_COMMIT, PAD_HINT_TREES, PAD_HINT_BLOBS, PAD_HINT_HASHES),
        (PEOPLE_CARD_BEFORE_COMMIT, PEOPLE_CARD_AFTER_COMMIT, PEOPLE_CARD_TREES, PEOPLE_CARD_BLOBS, PEOPLE_CARD_HASHES),
        (PEOPLE_CARD_REPAIR_BEFORE_COMMIT, PEOPLE_CARD_REPAIR_AFTER_COMMIT, PEOPLE_CARD_REPAIR_TREES,
         PEOPLE_CARD_REPAIR_BLOBS, PEOPLE_CARD_REPAIR_HASHES),
        (AXIS_BADGE_BEFORE_COMMIT, AXIS_BADGE_AFTER_COMMIT, AXIS_BADGE_TREES, AXIS_BADGE_BLOBS, AXIS_BADGE_HASHES),
        (PROMOTION_BEFORE_COMMIT, PROMOTION_AFTER_COMMIT, PROMOTION_TREES, PROMOTION_BLOBS, PROMOTION_HASHES),
    )
    requests = []
    for before, after, trees, blobs, _hashes in stages:
        requests.extend((c, c, "commit") for c in (before, after))
        requests.extend((t, t, "tree") for t in trees)
        requests.extend((c + ":" + MAIN_GAME_PATH, oid, "blob") for c, oid in zip((before, after), blobs))
    proof = _modal_git(root, "cat-file", "--batch", input=("\n".join(r[0] for r in requests) + "\n").encode())
    values, cursor = [], 0
    for _expression, wanted, kind in requests:
        end = proof.index(b"\n", cursor)
        oid, actual_kind, size = proof[cursor:end].decode().split()
        size = int(size)
        value = proof[end + 1:end + 1 + size]
        if (size < 0 or oid != wanted or actual_kind != kind or len(value) != size
                or hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + value).hexdigest() != oid
                or proof[end + 1 + size:end + 2 + size] != b"\n"):
            raise ValueError("ORDER-406: forged immutable object")
        values.append(value)
        cursor = end + 2 + size
    if cursor != len(proof):
        raise ValueError("ORDER-406: trailing immutable proof bytes")
    for stage, (before, after, trees, _blobs, hashes) in enumerate(stages):
        offset = stage * 6
        for index in range(2):
            headers = values[offset + index].split(b"\n\n", 1)[0].splitlines()
            if [h for h in headers if h.startswith(b"tree ")] != [b"tree " + trees[index].encode()]:
                raise ValueError("ORDER-406: immutable tree differs")
            if index and [h for h in headers if h.startswith(b"parent ")] != [b"parent " + before.encode()]:
                raise ValueError("ORDER-406: direct parent differs")
        if tuple(hashlib.sha256(v).hexdigest() for v in values[offset + 4:offset + 6]) != hashes:
            raise ValueError("ORDER-406: immutable whole raw differs")
        if _modal_git(root, "diff", "--name-status", "-z", before, after) != b"M\0" + MAIN_GAME_PATH.encode() + b"\0":
            raise ValueError("ORDER-406: product path population differs")
        if stage:
            _modal_git(root, "merge-base", "--is-ancestor", stages[stage - 1][1], before)
            if values[offset + 4] != values[offset - 1]:
                raise ValueError("ORDER-406: nonconsecutive raw history")
    _modal_git(root, "merge-base", "--is-ancestor", PROMOTION_AFTER_COMMIT, "HEAD")
    if _modal_git(root, "rev-parse", "HEAD:" + MAIN_GAME_PATH).decode().strip() != PROMOTION_BLOBS[1]:
        raise ValueError("ORDER-406: current Git MainGame differs")
    if values[53] != current:
        raise ValueError("ORDER-406: current/blob binding differs")
    pre406 = _promotion_review_copy_inverse(current, values[52])
    pre403 = _axis_badge_fit_inverse(pre406, values[46])
    recovered = _people_card_height_inverse(pre403, values[34])
    intermediate = _people_card_height_step_inverse(pre403, values[40], PEOPLE_CARD_REPAIR_REPLACEMENT)
    if _people_card_height_step_inverse(intermediate, values[34], PEOPLE_CARD_INITIAL_REPLACEMENT) != recovered:
        raise ValueError("ORDER-406: stagewise and combined inverses differ")
    recovered = _pad_hint_font_inverse(recovered, values[28])
    inverse_stages = (((TUTORIAL_REPLACEMENT,), values[22]),
                      (INVESTMENT_REPLACEMENTS, values[16]),
                      ((tuple(v.decode() for v in JOB_STATUS_REPLACEMENT),), values[10]),
                      (MODAL_REPLACEMENTS, values[4]))
    if tuple(len(parts) for parts, _ in inverse_stages) != (1, 3, 1, 3):
        raise ValueError("ORDER-406: prior inverse population differs")
    for replacements, before in inverse_stages:
        for old, new in reversed(replacements):
            old, new = old.encode(), new.encode()
            if not old or old == new or recovered.count(new) != 1:
                raise ValueError("ORDER-406: prior inverse is not exact1")
            recovered = recovered.replace(new, old, 1)
        if recovered != before:
            raise ValueError("ORDER-406: changes outside prior exact copy/rendering repairs")
    return pre406, pre403, values[34], values[28], values[22], values[16], recovered



def promotion_review_predecessor(current, root=None):
    return _promotion_review_copy_proof(current, root)[0]


def axis_badge_fit_predecessor(current, root=None):
    return _promotion_review_copy_proof(current, root)[1]


def people_card_height_predecessor(current, root=None):
    return _promotion_review_copy_proof(current, root)[2]


def pad_hint_font_predecessor(current, root=None):
    return _promotion_review_copy_proof(current, root)[3]


def tutorial_copy_predecessor(current, root=None):
    return _promotion_review_copy_proof(current, root)[4]


def investment_footer_predecessor(current, root=None):
    return _promotion_review_copy_proof(current, root)[5]


def modal_font_predecessor(current, root=None):
    return _promotion_review_copy_proof(current, root)[6]
# END_PROMOTION_REVIEW_HISTORY_406
