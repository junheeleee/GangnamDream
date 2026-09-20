"""Source-owned UI chrome of StartMenu's notice reader, not legal text.

Korean/English copy lives only in the notice JSON. This provider admits its
bounded UI roles after checking their actual reader; it never walks legal entry
values, URLs, filenames or bundled license files as translation sources.
"""
from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NOTICE_PATH = "content/meta/third_party_notices.json"
READER_PATH = "scenes/StartMenu.gd"
LOCALE_PATH = "autoloads/LocaleManager.gd"
SOURCE_PATHS = (NOTICE_PATH, READER_PATH, LOCALE_PATH)
SURFACE_FIELDS = ("title", "intro", "package_note")
LABEL_FIELDS = (
    "provider", "copyright", "license", "source", "license_terms",
    "license_copy_required", "attribution_required", "voluntary_credit",
)
SECTION_IDS = ("engine", "fonts", "audio")
# Only reached reader bodies are bound, not either whole GDScript file. A reader
# change requires a fresh source/consumer review, not a historical projection.
READER_FUNCTIONS = {
    READER_PATH: {
        "_notice_localized": "52c9129eb3f589b2b770a2a1b86478fa1890b90328c0f9688abd98354008fc43",
        "_load_third_party_notice_data": "61995f627752e45e150670a45175833bafc3fe6f761713e18a93c31d5cc0f65f",
        "_open_third_party_notices": "c12512f1abd6ccf545384e8d650b512d3e5bc369ee79f14e4df01931e7f0b404",
        "_set_third_party_notice_section": "8c10aab0145e7143eeace16267d4e59d93d4dedef29d8c5ee76c9c9c3d71f70d",
        "_third_party_notice_entry": "1fe6c9fc23c452c817a462fac18ff18e0aa416264e22050145583ecba734da30",
    },
    LOCALE_PATH: {
        "ui": "f635420ba5c8e4be2b0eb3c0a012a38fe52e775f56124b838a5bda5ca5ebf83f",
        "_lookup_legacy_ui": "509e2cc7c662d1a634eb7dd54a4ee22df1959fc4856532005cbbb976ea19a8d6",
    },
}


class NoticeSourceError(ValueError):
    pass


@dataclass(frozen=True)
class NoticeUiEntry:
    source: str
    english: str
    pointer: str
    static_fallback: bool = False

    @property
    def key(self) -> str:
        escaped = self.source.replace("~", "~0").replace("/", "~1")
        return f"ui:{self.source}:/{escaped}"

    @property
    def owner(self) -> str:
        return f"{NOTICE_PATH}#{self.pointer} -> {READER_PATH}::_notice_localized"


def _object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise NoticeSourceError(f"duplicate raw notice JSON key: {key}")
        result[key] = value
    return result


def _function(source: str, name: str) -> str:
    lines = source.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if line.startswith(f"func {name}(")]
    if len(starts) != 1:
        raise NoticeSourceError(f"notice reader function missing/duplicate: {name}")
    start = starts[0]
    end = start + 1
    while end < len(lines) and (not lines[end].strip() or lines[end][0].isspace()):
        end += 1
    return "".join(lines[start:end]).rstrip() + "\n"


def collect_third_party_notice_ui_entries(root: Path = ROOT) -> list[NoticeUiEntry]:
    try:
        readers = {path: (root / path).read_bytes().decode("utf-8")
                   for path in READER_FUNCTIONS}
        for path, functions in READER_FUNCTIONS.items():
            for name, expected in functions.items():
                body = _function(readers[path], name)
                if hashlib.sha256(body.encode("utf-8")).hexdigest() != expected:
                    raise NoticeSourceError(f"notice reader changed: {path}::{name}")
        paths = re.findall(r'^const THIRD_PARTY_NOTICE_PATH\s*[:=][^\n]*$',
                           readers[READER_PATH], re.MULTILINE)
        if paths != [f'const THIRD_PARTY_NOTICE_PATH := "res://{NOTICE_PATH}"']:
            raise NoticeSourceError("notice reader JSON path changed")
        data = json.loads((root / NOTICE_PATH).read_bytes().decode("utf-8"),
                          object_pairs_hook=_object)
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise NoticeSourceError(f"notice source unavailable/invalid: {exc}") from exc
    if not isinstance(data, dict) or type(data.get("schema_version")) is not int \
            or data["schema_version"] != 1:
        raise NoticeSourceError("unsupported notice JSON schema")
    surface = data.get("surface")
    if not isinstance(surface, dict) or set(surface) != {*SURFACE_FIELDS, "labels"}:
        raise NoticeSourceError("notice surface roles missing/extra")
    labels = surface["labels"]
    if not isinstance(labels, dict) or set(labels) != set(LABEL_FIELDS):
        raise NoticeSourceError("notice label roles missing/extra")
    sections = data.get("sections")
    if not isinstance(sections, list) or any(not isinstance(s, dict) for s in sections) \
            or [s.get("id") for s in sections] != list(SECTION_IDS):
        raise NoticeSourceError("notice section IDs missing/extra/duplicate/reordered")
    rows = []

    def add(pair, pointer, static=False):
        if not isinstance(pair, dict) or set(pair) != {"ko", "en"} \
                or any(not isinstance(pair[k], str) or not pair[k].strip() for k in ("ko", "en")):
            raise NoticeSourceError(f"notice UI role needs exactly nonempty KO/EN: {pointer}")
        rows.append(NoticeUiEntry(pair["ko"], pair["en"], pointer, static))

    for field in SURFACE_FIELDS:
        add(surface[field], f"/surface/{field}", field == "title")
    for field in LABEL_FIELDS:
        add(labels[field], f"/surface/labels/{field}", field == "license_terms")
    statuses = set()
    for index, section in enumerate(sections):
        add(section.get("title"), f"/sections/{index}/title")
        entries = section.get("entries")
        if not isinstance(entries, list) or any(not isinstance(e, dict) for e in entries):
            raise NoticeSourceError(f"notice section entries malformed: {section['id']}")
        statuses.update(e.get("notice_status", "") for e in entries
                        if isinstance(e.get("notice_status", ""), str))
        if any(not isinstance(e.get("notice_status", ""), str) for e in entries):
            raise NoticeSourceError("notice status role is not a string")
    if statuses - {"", *LABEL_FIELDS[5:]} or not set(LABEL_FIELDS[5:]) <= statuses:
        raise NoticeSourceError("notice status roles unsupported/missing")
    if len({row.source for row in rows}) != len(rows):
        raise NoticeSourceError("duplicate notice UI Korean key across roles")
    # The two already-static identities must remain the actual literal fallback
    # pairs. Read those literals from the checked reader, never duplicate copy.
    for row, name, role in (
        (rows[0], "_open_third_party_notices", "title"),
        (rows[7], "_third_party_notice_entry", "license_terms"),
    ):
        body = _function(readers[READER_PATH], name)
        literal = r'"(?:[^"\\]|\\.)*"'
        matches = re.findall(r'get\("' + role + r'", \{\}\), _tr\((' + literal +
                             r'), (' + literal + r')\)\)', body)
        if len(matches) != 1 or tuple(map(json.loads, matches[0])) != (row.source, row.english):
            raise NoticeSourceError(f"notice static fallback pair drift: {role}")
    return rows


def notice_ui_additions(
    rows: list[NoticeUiEntry], static_keys: set[str], *, allow_partial_static: bool = False,
) -> dict[str, NoticeUiEntry]:
    """Keep old identities; a partial static source view owns no notice extras."""
    overlap = {row.source for row in rows} & static_keys
    fallbacks = {row.source for row in rows if row.static_fallback}
    if overlap - fallbacks:
        raise NoticeSourceError("notice/static UI unexpected source collision")
    if overlap != fallbacks:
        if allow_partial_static:
            # The caller explicitly supports a partial *source* inventory.
            # Never infer this from missing targets or exempt any notice extra.
            return {}
        raise NoticeSourceError("notice/static UI overlap is not the two reader fallbacks")
    return {row.source: row for row in rows if not row.static_fallback}
