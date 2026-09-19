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
    "fdbcc5701bc78e6dac5023d6b2e295cfdf2f96f40e039f07f0f02f6985e0779b"
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
    "current_sha256": "fdbcc5701bc78e6dac5023d6b2e295cfdf2f96f40e039f07f0f02f6985e0779b",
    "inverses": [
      {
        "id": "collector",
        "kind": "remove_span",
        "start": "# BEGIN_NEW_RUN_LOG_COLLECTOR_267\n",
        "end": "# END_NEW_RUN_LOG_COLLECTOR_267\n\n",
        "sha256": "6cd6cf8e6e0c5060de710adf5f94f488f1cf90d9bd1100431eb6be81a8580bee"
      }
    ]
  }
}''')
_NEW_RUN_LOG_REGISTRY_SHA256 = "2fc12c857507019e4a33e6f2c2b89632ca234ebfc8520ecc2d4e0e11386a31f1"
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
