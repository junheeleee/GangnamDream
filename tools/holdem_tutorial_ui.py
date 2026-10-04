"""Four source-owned Holdem tutorial UI leaves, separate from the demo scope.

Only literal title/body pairs in the reached two-slide branch are sources.
Lookup uses the raw body; the checked reader cleans it only after localization.
This provider neither builds a demo inventory nor reads any target dictionary.
"""
from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from pathlib import Path

from demo_localization_scope import _gd_call_args, _gd_call_body, _gd_concat_string

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = "scenes/TutorialOverlay.gd"
CATEGORY = "ui_holdem_tutorial"
LOCALE_PATH = "autoloads/LocaleManager.gd"
HOLDEM_PATH = "scenes/HoldemClub.gd"
SOURCE_PATHS = (SOURCE_PATH, LOCALE_PATH, HOLDEM_PATH)
# These existing literal consumers identify a full tutorial source inventory.
# Missing *targets* never influence ownership of the four new sources.
STATIC_ANCHORS = frozenset(("힌트: ", "다음 ›"))
READER_FUNCTIONS = {
    SOURCE_PATH: {
        "maybe_show": "e9615643d39dc1f2ecd65bb4c7c40ad80ba660c083f2af42e6396726532194e5",
        "force_show": "8ef22cdaafd05be8607633bc043b99f98b7f936d9f8701ffa955853bb5913f7c",
        "_show": "e1d0f1b3dd60476039b1e3160c65870bfcc61f89d796dffbe942f6da2c8df798",
        "_localized_slide": "641fb1af660cb01ea5f1589034329f3dbbd49bc43d4a79f6459bb0c038f2fb72",
        "_clean_body_for_surface": "37e850ef1dfe28ac9a22bc988ef7e7a7a108c04743f3af279d92a8653b3903ab",
        "_ready": "62fd941da2a891dccf02d3a176b612ecca1954ec73fc299f57ad48f533f4e627",
        "_build_ui": "7a930e3a90f38da3ff90799d9d1bd21b1ef42361714caacd318bdbd59d400255",
        "_show_slide": "3109501431d351eedbd205c9815c837df9e861dc77027742912969dff70cd662",
        "_on_next": "2f89695449028bf18625b42e9afab2ad08d53bd4a439e67eb08f73a2230e31cd",
    },
    LOCALE_PATH: {
        "ui": "f635420ba5c8e4be2b0eb3c0a012a38fe52e775f56124b838a5bda5ca5ebf83f",
        "_lookup_legacy_ui": "509e2cc7c662d1a634eb7dd54a4ee22df1959fc4856532005cbbb976ea19a8d6",
    },
    HOLDEM_PATH: {
        "_open_session": "eb6a52689ff615728ffb72ddfe655152b873e56be786393f2551fcf7865b6286",
        "_pad_show_rules": "9ed12fb694a72fd4d0500b3de95787c8e9b204b89aa3f59a4d0b2655b5573cdf",
    },
}


class HoldemTutorialSourceError(ValueError):
    pass


@dataclass(frozen=True)
class HoldemTutorialUiEntry:
    source: str
    english: str
    slide: int
    field: str

    @property
    def key(self) -> str:
        escaped = self.source.replace("~", "~0").replace("/", "~1")
        return f"ui:{self.source}:/{escaped}"

    @property
    def source_path(self) -> str:
        return SOURCE_PATH

    @property
    def owner(self) -> str:
        return f"{SOURCE_PATH}::_get_slides(holdem)[{self.slide}].{self.field}"


def _function(source: str, name: str) -> str:
    lines = source.splitlines(keepends=True)
    declaration = re.compile(r"^(?:static )?func " + re.escape(name) + r"\(")
    starts = [i for i, line in enumerate(lines) if declaration.match(line)]
    if len(starts) != 1:
        raise HoldemTutorialSourceError(f"tutorial consumer missing/duplicate: {name}")
    start = starts[0]
    end = start + 1
    while end < len(lines) and (not lines[end].strip() or lines[end][0].isspace()
                               or lines[end].startswith("#")):
        end += 1
    # Column-zero comments do not end a GDScript function. Retain them when
    # indented code follows, but exclude trailing section comments as before.
    while end > start + 1 and (not lines[end - 1].strip()
                              or lines[end - 1].startswith("#")):
        end -= 1
    return "".join(lines[start:end]).rstrip() + "\n"


def _check_readers(source: str, path: str) -> None:
    for name, expected in READER_FUNCTIONS[path].items():
        body = _function(source, name)
        if hashlib.sha256(body.encode("utf-8")).hexdigest() != expected:
            raise HoldemTutorialSourceError(f"tutorial consumer changed: {path}::{name}")


def _literal(expression: str) -> str:
    # The shared parser decodes strings. This narrow grammar also rejects
    # adjacent literals, unbalanced grouping and stray operators it ignores.
    expression = expression.strip()
    if expression.startswith("("):
        body, end = _gd_call_body(expression, 0)
        if end != len(expression):
            raise HoldemTutorialSourceError("tutorial argument has trailing expression")
        expression = body.strip()
    literal = r'"(?:\\.|[^"\\])*"'
    if not re.fullmatch(literal + r"(?:\s*\+\s*" + literal + r")*", expression):
        raise HoldemTutorialSourceError("tutorial argument is not a literal concatenation")
    value = _gd_concat_string(expression)
    if not value.strip():
        raise HoldemTutorialSourceError("tutorial argument is empty")
    return value


def parse_holdem_tutorial_ui_entries(tutorial_source: str) -> list[HoldemTutorialUiEntry]:
    """Pure parser seam: validate the Tutorial reader and extract only Holdem."""
    _check_readers(tutorial_source, SOURCE_PATH)
    function = _function(tutorial_source, "_get_slides")
    if not function.startswith("static func _get_slides(game_id: String) -> Array:\n\tmatch game_id:\n"):
        raise HoldemTutorialSourceError("tutorial game-id dispatch changed")
    branches = list(re.finditer(r'^\t\t"holdem":\s*\n', function, re.MULTILINE))
    if len(branches) != 1:
        raise HoldemTutorialSourceError("tutorial Holdem branch missing/duplicate")
    before = function[:branches[0].start()].splitlines()[2:]
    # A new wildcard/combined case or early return ahead of Holdem could make
    # these literals unreachable while leaving the extracted branch intact.
    headers = [line for line in before if re.match(r'^\t\t\S', line)]
    if headers != ['\t\t"baccarat":', '\t\t"blackjack":'] or any(
            line.startswith("\t") and not line.startswith("\t\t") for line in before):
        raise HoldemTutorialSourceError("tutorial dispatch before Holdem changed")
    remainder = function[branches[0].end():]
    following = re.search(r'^\t\t[^\s].*:\s*$', remainder, re.MULTILINE)
    if following is None:
        raise HoldemTutorialSourceError("tutorial Holdem branch boundary missing")
    block = remainder[:following.start()]
    container = re.fullmatch(
        r'(?:[ \t]*\n)*\t\t\treturn[ \t]*\[(.*)\n\t\t\t\][ \t]*(?:\n[ \t]*)*',
        block, re.DOTALL)
    if container is None:
        raise HoldemTutorialSourceError("tutorial Holdem branch is not one returned slide array")
    calls = container.group(1)
    rows: list[HoldemTutorialUiEntry] = []
    cursor = 0
    expected = (("♠", "텍사스 홀덤 — 기본 규칙"), ("🏆", "홀덤 — 패 순위 (강한 순)"))
    try:
        for slide, (icon, title) in enumerate(expected):
            match = re.match(r'\s*_localized_slide\(', calls[cursor:])
            if match is None:
                raise HoldemTutorialSourceError("tutorial needs exactly two localized slides")
            body, cursor = _gd_call_body(calls, cursor + match.end() - 1)
            args = _gd_call_args(body)
            if len(args) != 5:
                raise HoldemTutorialSourceError("tutorial slide needs exactly five arguments")
            values = [_literal(arg) for arg in args]
            if values[0] != icon or values[1] != title:
                raise HoldemTutorialSourceError("tutorial Holdem slide roles/order changed")
            rows.extend(HoldemTutorialUiEntry(values[ko], values[en], slide, field)
                        for field, ko, en in (("title", 1, 2), ("body", 3, 4)))
            if slide == 0:
                comma = re.match(r'\s*,', calls[cursor:])
                if comma is None:
                    raise HoldemTutorialSourceError("tutorial slide separator missing")
                cursor += comma.end()
        if not re.fullmatch(r'\s*,?\s*', calls[cursor:]):
            raise HoldemTutorialSourceError("tutorial has extra slides/expressions")
    except ValueError as exc:
        raise HoldemTutorialSourceError(str(exc)) from exc
    if len({row.source for row in rows}) != 4:
        raise HoldemTutorialSourceError("tutorial needs four unique Korean sources")
    return rows


def collect_holdem_tutorial_ui_entries(root: Path = ROOT) -> list[HoldemTutorialUiEntry]:
    """Re-read actual consumers on every call; no target or cached admission."""
    try:
        sources = {path: (root / path).read_bytes().decode("utf-8") for path in SOURCE_PATHS}
    except (OSError, UnicodeError) as exc:
        raise HoldemTutorialSourceError(f"tutorial source unavailable/invalid: {exc}") from exc
    for path in (LOCALE_PATH, HOLDEM_PATH):
        _check_readers(sources[path], path)
    return parse_holdem_tutorial_ui_entries(sources[SOURCE_PATH])


def holdem_tutorial_ui_additions(
    rows: list[HoldemTutorialUiEntry], static_keys: set[str],
    dynamic_keys: set[str], story_keys: set[str], *, allow_partial_static: bool = False,
) -> dict[str, HoldemTutorialUiEntry]:
    """Own four disjoint leaves, never a general unknown-UI exemption."""
    if [(row.slide, row.field) for row in rows] != [
            (0, "title"), (0, "body"), (1, "title"), (1, "body")]:
        raise HoldemTutorialSourceError("tutorial source roles/count changed")
    keys = {row.source for row in rows}
    if len(keys) != 4:
        raise HoldemTutorialSourceError("tutorial needs four unique Korean sources")
    for name, owned in (("static", static_keys), ("demo", dynamic_keys), ("story", story_keys)):
        if keys & owned:
            raise HoldemTutorialSourceError(f"tutorial/{name} UI source collision")
    if not STATIC_ANCHORS <= static_keys:
        if allow_partial_static:
            return {}
        raise HoldemTutorialSourceError("tutorial static consumer anchors missing")
    return {row.source: row for row in rows}
