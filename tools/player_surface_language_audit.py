#!/usr/bin/env python3
"""Reject RPG/stat-system language from localized player-facing GDScript.

The audit deliberately parses localized calls instead of grepping source lines:
comments and quoted examples are ignored, multiline calls are supported, and
each finding is attributed to its owning function.  Exceptions are narrow
``(path, function, rule)`` contracts for explicit meta galleries, casino odds,
and the honest pre-choice NOW/COST/LATER preview.  There is no non-zero
baseline: every non-exempt match fails.
"""

from __future__ import annotations

import argparse
import ast
import bisect
import re
import sys
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLAYER_SURFACE_DIRS = ("scenes", "autoloads", "systems", "ui_components")

FUNCTION_RE = re.compile(
    r"(?m)^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\("
)
CALL_RE = re.compile(
    r"(?<![A-Za-z0-9_])"
    r"(LocaleManager\.ui_context|LocaleManager\.ui_format|"
    r"LocaleManager\.ui|_localized_slide|_tr)\s*\("
)

# Argument indexes which carry Korean/English player copy.  Tutorial slides
# contain a localized title pair and a localized body pair.
LOCALIZED_ARGUMENTS: dict[str, tuple[tuple[int, str], ...]] = {
    "_tr": ((0, "ko"), (1, "en")),
    "LocaleManager.ui": ((0, "ko"), (1, "en")),
    "LocaleManager.ui_context": ((1, "ko"), (2, "en")),
    "LocaleManager.ui_format": ((0, "ko"), (1, "en")),
    "_localized_slide": ((1, "ko"), (2, "en"), (3, "ko"), (4, "en")),
}

FORMAT_VALUE = r"(?:[+-]\s*(?:\d+(?:\.\d+)?|%[-+0-9.*]*[diouxXf])|%\+[-0-9.*]*[diouxXf])"


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: re.Pattern[str]
    description: str


RULES: tuple[Rule, ...] = (
    Rule(
        "stat_delta_ko",
        re.compile(
            r"(?<![0-9A-Za-z가-힣_])"
            r"(?:정신(?:력)?|건강|지력|사회성|사교력|외모|투자\s*감각|"
            r"운|평판|업무\s*성과|호감)\s*" + FORMAT_VALUE
        ),
        "Korean stat name followed by a signed value",
    ),
    Rule(
        "stat_delta_en",
        re.compile(
            r"(?i)(?<![A-Za-z])"
            r"(?:mental|health|intelligence|social(?:\s+skill)?|appearance|"
            r"invest(?:ing|ment)(?:\s+skill)?|luck|reputation|"
            r"work\s+performance|performance|affinity)\s*" + FORMAT_VALUE
        ),
        "English stat name followed by a signed value",
    ),
    # 피해금 is a normal legal noun, not the UI term 해금.  The immediate
    # lexical guard prevents the known false positive without weakening 해금.
    Rule("unlock_ko", re.compile(r"(?<!피)해금"), "Korean unlock language"),
    Rule(
        "unlock_en", re.compile(r"(?i)\bunlocked\b"),
        "English unlock language",
    ),
    Rule(
        "multiplier_ko",
        re.compile(
            r"(?:\d+(?:\.\d+)?|%[-+0-9.*]*[df])\s*배(?:로)?\s*(?:상승|강화)"
        ),
        "Korean system multiplier increase",
    ),
    Rule(
        "multiplier_en", re.compile(r"(?i)\bx\d+(?:\.\d+)?\b"),
        "xN system multiplier",
    ),
    Rule("wave_ko", re.compile(r"웨이브"), "Korean wave system label"),
    # Uppercase is intentional.  Narrative English may naturally use the
    # lowercase noun "wave"; the retired UI label was authored as WAVE.
    Rule("wave_en", re.compile(r"\bWAVE\b"), "English WAVE system label"),
    Rule(
        "grade_ko", re.compile(r"평가\s*[A-D]\b", re.IGNORECASE),
        "Korean letter grade",
    ),
    Rule(
        "grade_en", re.compile(r"\bGRADE\s*[A-D]\b", re.IGNORECASE),
        "English letter grade",
    ),
)


@dataclass(frozen=True)
class AllowRule:
    path: str
    function: str
    rule: str
    reason: str


# Exceptions are pattern-specific.  A title function may say "unlocked", but
# the same function still fails if it starts exposing a stat delta or grade.
ALLOWLIST: tuple[AllowRule, ...] = (
    # Explicit title/achievement/archive meta-progression surfaces.
    AllowRule(
        "scenes/MainGame.gd", "_check_title_unlocks", "unlock_ko",
        "title meta-progression notification",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_check_title_unlocks", "unlock_en",
        "title meta-progression notification",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_ending_add_unlocks", "unlock_ko",
        "ending title/achievement meta summary",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_ending_add_unlocks", "unlock_en",
        "ending title/achievement meta summary",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_open_title_collection", "unlock_ko",
        "title collection gallery",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_open_title_collection", "unlock_en",
        "title collection gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_cg_card", "unlock_ko",
        "achievement/scene archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_cg_card", "unlock_en",
        "achievement/scene archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_scene_card", "unlock_ko",
        "achievement/scene archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_scene_card", "unlock_en",
        "achievement/scene archive gallery",
    ),
    # Casino odds/payout semantics.  Do not allow other rule families here.
    AllowRule(
        "scenes/BlackjackTable.gd", "_render_game", "multiplier_en",
        "blackjack double-down wager multiplier",
    ),
    # Exact costs are intentionally honest before a choice.  Only stat-delta
    # rules are exempt: unlock/WAVE/grade copy remains forbidden here.
    AllowRule(
        "scenes/MainGame.gd", "_weekly_commitment_base_preview",
        "stat_delta_ko", "pre-choice NOW/COST/LATER disclosure",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_weekly_commitment_base_preview",
        "stat_delta_en", "pre-choice NOW/COST/LATER disclosure",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_ap_action_preview", "stat_delta_ko",
        "pre-choice action-card disclosure",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_ap_action_preview", "stat_delta_en",
        "pre-choice action-card disclosure",
    ),
    # Generic dynamic-composition checks use their own rule names.  Exact
    # pre-choice disclosures remain legal, but the same formatter copied to a
    # result function fails.
    AllowRule(
        "scenes/MainGame.gd", "_choice_effects_preview",
        "dynamic_stat_composition", "pre-choice exact effect disclosure",
    ),
    AllowRule(
        "scenes/StoryMode.gd", "_choice_effect_preview",
        "dynamic_stat_composition", "pre-choice exact effect disclosure",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_weekly_commitment_return_cost_text",
        "dynamic_stat_composition", "pre-choice delayed-cost disclosure",
    ),
    AllowRule(
        "scenes/CoreLoopPlanner.gd", "_routine_effect_copy",
        "dynamic_stat_composition", "pre-choice routine effect disclosure",
    ),
    # Title/achievement/archive are explicit meta-progression.  These entries
    # exempt only dynamic stat/grade composition, never unrelated rule families.
    AllowRule(
        "scenes/MainGame.gd", "_check_title_unlocks",
        "dynamic_stat_composition", "title meta-progression notification",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_check_title_unlocks",
        "dynamic_grade_composition", "title meta-progression notification",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_ending_add_unlocks",
        "dynamic_stat_composition", "ending title/achievement meta summary",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_ending_add_unlocks",
        "dynamic_grade_composition", "ending title/achievement meta summary",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_open_title_collection",
        "dynamic_stat_composition", "title collection gallery",
    ),
    AllowRule(
        "scenes/MainGame.gd", "_open_title_collection",
        "dynamic_grade_composition", "title collection gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_cg_card",
        "dynamic_stat_composition", "achievement/scene archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_cg_card",
        "dynamic_grade_composition", "achievement/scene archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_scene_card",
        "dynamic_stat_composition", "achievement/scene archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_scene_card",
        "dynamic_grade_composition", "achievement/scene archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_hidden_card",
        "dynamic_stat_composition", "achievement archive gallery",
    ),
    AllowRule(
        "scenes/StartMenu.gd", "_archive_hidden_card",
        "dynamic_grade_composition", "achievement archive gallery",
    ),
)

ALLOW_INDEX = {
    (entry.path, entry.function, entry.rule): entry.reason
    for entry in ALLOWLIST
}


@dataclass(frozen=True)
class SurfaceLiteral:
    path: str
    line: int
    function: str
    call: str
    language: str
    text: str


@dataclass(frozen=True)
class Violation:
    path: str
    line: int
    function: str
    rule: str
    language: str
    text: str

    def render(self) -> str:
        sample = self.text.replace("\n", "\\n")
        if len(sample) > 180:
            sample = sample[:177] + "..."
        return (
            f"{self.path}:{self.line}:{self.function}:{self.language}:"
            f"{self.rule}: {sample}"
        )


def _function_positions(source: str) -> list[tuple[int, str]]:
    return [(match.start(), match.group(1)) for match in FUNCTION_RE.finditer(source)]


def _function_owner(functions: list[tuple[int, str]], offset: int) -> str:
    positions = [position for position, _name in functions]
    index = bisect.bisect_right(positions, offset) - 1
    return functions[index][1] if index >= 0 else "<module>"


def _iter_localized_calls(source: str):
    """Yield real localized call tokens, ignoring comments and strings."""
    index = 0
    quote = ""
    escaped = False
    in_comment = False
    while index < len(source):
        character = source[index]
        if in_comment:
            if character == "\n":
                in_comment = False
            index += 1
            continue
        if quote:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = ""
            index += 1
            continue
        if character == "#":
            in_comment = True
            index += 1
            continue
        if character in ("\"", "'"):
            quote = character
            index += 1
            continue
        match = CALL_RE.match(source, index)
        if match:
            yield match.group(1), match.start(), match.end() - 1
            index = match.end()
            continue
        index += 1


def _call_body(source: str, opening: int) -> tuple[str, int]:
    depth = 0
    quote = ""
    escaped = False
    in_comment = False
    for index in range(opening, len(source)):
        character = source[index]
        if in_comment:
            if character == "\n":
                in_comment = False
            continue
        if quote:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = ""
            continue
        if character == "#":
            in_comment = True
        elif character in ("\"", "'"):
            quote = character
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                return source[opening + 1:index], index + 1
    raise ValueError("unterminated localized call")


def _split_arguments(body: str) -> list[str]:
    arguments: list[str] = []
    start = 0
    depths = {"(": 0, "[": 0, "{": 0}
    closers = {")": "(", "]": "[", "}": "{"}
    quote = ""
    escaped = False
    in_comment = False
    for index, character in enumerate(body):
        if in_comment:
            if character == "\n":
                in_comment = False
            continue
        if quote:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = ""
            continue
        if character == "#":
            in_comment = True
        elif character in ("\"", "'"):
            quote = character
        elif character in depths:
            depths[character] += 1
        elif character in closers:
            depths[closers[character]] -= 1
        elif character == "," and not any(depths.values()):
            arguments.append(body[start:index].strip())
            start = index + 1
    arguments.append(body[start:].strip())
    return arguments


def _string_literals(expression: str) -> list[str]:
    """Decode string tokens from one localized argument expression."""
    values: list[str] = []
    index = 0
    in_comment = False
    while index < len(expression):
        if in_comment:
            if expression[index] == "\n":
                in_comment = False
            index += 1
            continue
        if expression[index] == "#":
            in_comment = True
            index += 1
            continue
        if expression[index] not in ("\"", "'"):
            index += 1
            continue
        quote = expression[index]
        start = index
        index += 1
        escaped = False
        while index < len(expression):
            character = expression[index]
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                index += 1
                break
            index += 1
        token = expression[start:index]
        try:
            value = ast.literal_eval(token)
        except (SyntaxError, ValueError):
            continue
        if isinstance(value, str):
            values.append(value)
    return values


def extract_surface_literals(
    path: str, source: str,
) -> tuple[list[SurfaceLiteral], list[Violation], int]:
    functions = _function_positions(source)
    surfaces: list[SurfaceLiteral] = []
    errors: list[Violation] = []
    call_count = 0
    for call, offset, opening in _iter_localized_calls(source):
        call_count += 1
        line = source.count("\n", 0, offset) + 1
        owner = _function_owner(functions, offset)
        try:
            body, _end = _call_body(source, opening)
        except ValueError as exc:
            errors.append(Violation(
                path, line, owner, "parse_error", "source", str(exc)))
            continue
        arguments = _split_arguments(body)
        for argument_index, language in LOCALIZED_ARGUMENTS[call]:
            if argument_index >= len(arguments):
                errors.append(Violation(
                    path, line, owner, "parse_error", language,
                    f"{call} has {len(arguments)} args; expected index {argument_index}",
                ))
                continue
            for text in _string_literals(arguments[argument_index]):
                surfaces.append(SurfaceLiteral(
                    path, line, owner, call, language, text))
    return surfaces, errors, call_count


def _literal_violations(surfaces: list[SurfaceLiteral]) -> list[Violation]:
    violations: list[Violation] = []
    for surface in surfaces:
        for rule in RULES:
            if rule.pattern.search(surface.text):
                violations.append(Violation(
                    surface.path, surface.line, surface.function, rule.name,
                    surface.language, surface.text,
                ))
    return violations


def _function_bodies(source: str) -> dict[str, tuple[int, str]]:
    result: dict[str, tuple[int, str]] = {}
    for match in FUNCTION_RE.finditer(source):
        first_newline = source.find("\n", match.end())
        cursor = len(source) if first_newline < 0 else first_newline + 1
        end = len(source)
        while cursor < len(source):
            next_newline = source.find("\n", cursor)
            line_end = len(source) if next_newline < 0 else next_newline + 1
            line = source[cursor:line_end]
            if line.strip() and not line[0].isspace():
                end = cursor
                break
            cursor = line_end
        result[match.group(1)] = (match.start(), source[match.start():end])
    return result


DYNAMIC_STAT_RESOLVER_RE = re.compile(
    r"(?:_stat_name|_stat_display_name)\s*\(|_STAT_(?:KR|EN)\s*(?:\.get|\[)"
)
DYNAMIC_STAT_LABEL_LITERAL_RE = re.compile(
    r"(?i)^\s*(?:정신(?:력)?|건강|지력|사회성|사교력|외모|투자\s*감각|"
    r"운|평판|업무\s*성과|호감(?:도)?|돈|월수입|mental|health|"
    r"intelligence|social(?:\s+skill)?|appearance|invest(?:ing|ment)"
    r"(?:\s+skill)?|luck|reputation|work\s+performance|performance|"
    r"affinity|money|monthly\s+income)\s*$"
)
DYNAMIC_STAT_PLACEHOLDER_LITERAL_RE = re.compile(
    r"(?i)(?<![0-9A-Za-z가-힣_])"
    r"(?:정신(?:력)?|건강|지력|사회성|사교력|외모|투자\s*감각|"
    r"운|평판|업무\s*성과|호감(?:도)?|돈|월수입|mental|health|"
    r"intelligence|social(?:\s+skill)?|appearance|invest(?:ing|ment)"
    r"(?:\s+skill)?|luck|reputation|work\s+performance|performance|"
    r"affinity|money|monthly\s+income)"
    r"\s*(?::|·)?\s*(?:\{[A-Za-z_][A-Za-z0-9_]*\}|%[sd])"
)
DYNAMIC_SIGNED_FORMAT_RE = re.compile(
    r"%\+[-0-9.*]*[diouxXf]|%d\s*(?:→|->)\s*%d|"
    r"[\"'][^\"'\n]*%s[^\"'\n]*%d[^\"'\n]*[\"']\s*%\s*\["
)
DYNAMIC_DELTA_VALUE_RE = re.compile(
    r"\b[A-Za-z_][A-Za-z0-9_]*(?:delta|diff|change)"
    r"[A-Za-z0-9_]*\b|\b(?:delta|diff|change)\b",
    re.IGNORECASE,
)
DYNAMIC_RUNTIME_VALUE_RE = re.compile(
    r"\b(?!(?:true|false|null)\b)[A-Za-z_][A-Za-z0-9_]*\b|"
    r"(?<![A-Za-z0-9_])[+-]?\d+(?:\.\d+)?"
)
DYNAMIC_GRADE_SOURCE_RE = re.compile(
    r"\[\s*[\"']D[\"']\s*,\s*[\"']C[\"']\s*,\s*"
    r"[\"']B[\"']\s*,\s*[\"']A[\"']\s*\]",
    re.IGNORECASE,
)
DYNAMIC_GRADE_SURFACE_RE = re.compile(r"평가|\bGrade\b", re.IGNORECASE)
DYNAMIC_GRADE_LABEL_LITERAL_RE = re.compile(
    r"^\s*(?:등급|GRADE)(?:\s*%s)?\s*$", re.IGNORECASE)
DYNAMIC_GRADE_LABEL_CALL_RE = re.compile(
    r"(?<![A-Za-z0-9_])(?:_tr|LocaleManager\.ui|_label)\s*\(\s*"
    r"[\"'](?:등급|평가)[\"']\s*,\s*[\"'](?:GRADE|Grade)[\"']"
)
DYNAMIC_GRADE_GET_RE = re.compile(
    r"(?P<get>\.get)\s*\(\s*[\"']grade[\"']", re.IGNORECASE)
DYNAMIC_GRADE_INDEX_RE = re.compile(
    r"(?P<index>\[)\s*[\"']grade[\"']\s*\]", re.IGNORECASE)
DYNAMIC_GRADE_VALUE_RE = re.compile(r"\bgrade\b", re.IGNORECASE)
DYNAMIC_TRIPLE_FORMAT_RE = re.compile(
    r"[\"'][^\"'\n]*%[sd][^\"'\n]*%[sd][^\"'\n]*"
    r"%[sd][^\"'\n]*[\"']"
    r"\s*(?P<operator>%\s*\[)"
)


def _mask_comments_and_optionally_strings(
    source: str, *, keep_strings: bool,
) -> str:
    """Return an offset-stable lexical view of executable GDScript.

    Generic composition checks need format strings, but resolver names written
    inside comments or quoted documentation are not executable.  Keeping both
    views prevents examples such as ``"_stat_name(key) %+d"`` from becoming a
    false player-surface finding while retaining the real ``"%+d"`` formatter.
    """
    masked = list(source)
    quote = ""
    escaped = False
    in_comment = False
    for index, character in enumerate(source):
        if in_comment:
            if character == "\n":
                in_comment = False
            else:
                masked[index] = " "
            continue
        if quote:
            if not keep_strings and character != "\n":
                masked[index] = " "
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = ""
            continue
        if character == "#":
            in_comment = True
            masked[index] = " "
        elif character in ("\"", "'"):
            quote = character
            if not keep_strings:
                masked[index] = " "
    return "".join(masked)


def _localized_call_texts(call: str, call_body: str) -> list[str]:
    """Return only the player-copy literals belonging to one localized call."""
    arguments = _split_arguments(call_body)
    texts: list[str] = []
    for argument_index, _language in LOCALIZED_ARGUMENTS[call]:
        if argument_index < len(arguments):
            texts.extend(_string_literals(arguments[argument_index]))
    return texts


def _dynamic_sign_context(body: str) -> tuple[set[str], set[str], bool]:
    """Return sign variables, rendered-value variables, and real sign branches."""
    executable_body = _mask_comments_and_optionally_strings(
        body, keep_strings=False)
    string_body = _mask_comments_and_optionally_strings(
        body, keep_strings=True)
    sign_variables: set[str] = set()
    has_conditional_sign = False
    conditional_pattern = re.compile(
        r"(?<!\\)[\"'][+-][\"']\s+(?P<if>if)\b[^\n]*\belse\b"
    )
    for conditional in conditional_pattern.finditer(string_body):
        if not executable_body[conditional.start("if")].isspace():
            has_conditional_sign = True

    sign_assignment_pattern = re.compile(
        r"(?m)^\s*(?:var\s+)?(?P<name>[A-Za-z_][A-Za-z0-9_]*)\b"
        r"[^\n=]*?(?::=|=)\s*\(*\s*(?<!\\)[\"'][+-][\"']\s+"
        r"(?P<if>if)\b[^\n]*\belse\b"
    )
    for assignment in sign_assignment_pattern.finditer(string_body):
        if not executable_body[assignment.start("if")].isspace():
            sign_variables.add(assignment.group("name"))

    shown_variables: set[str] = set()
    shown_assignment_pattern = re.compile(
        r"(?m)^\s*(?:var\s+)?(?P<name>[A-Za-z_][A-Za-z0-9_]*)\b"
        r"[^\n=]*?(?::=|=)[^\n]*(?:\bstr\s*\(|\bformat_money\s*\()"
    )
    for assignment in shown_assignment_pattern.finditer(executable_body):
        shown_variables.add(assignment.group("name"))
    return sign_variables, shown_variables, has_conditional_sign


def _localized_stat_dictionary_names(body: str) -> set[str]:
    """Find dictionaries whose entries contain exact localized stat labels."""
    executable_body = _mask_comments_and_optionally_strings(
        body, keep_strings=False)
    dictionary_assignments = list(re.finditer(
        r"(?m)^\s*(?:var\s+)?(?P<name>[A-Za-z_][A-Za-z0-9_]*)\b"
        r"[^\n=]*?(?::=|=)\s*\{",
        executable_body,
    ))
    names: set[str] = set()
    for call, offset, opening in _iter_localized_calls(body):
        try:
            call_body, _call_end = _call_body(body, opening)
        except ValueError:
            continue
        texts = _localized_call_texts(call, call_body)
        if not any(DYNAMIC_STAT_LABEL_LITERAL_RE.fullmatch(text) for text in texts):
            continue
        line_start = body.rfind("\n", 0, offset) + 1
        if re.search(r"[\"'][^\"'\n]+[\"']\s*:\s*$", body[line_start:offset]) \
                is None:
            continue
        for assignment in reversed(dictionary_assignments):
            if assignment.end() > offset:
                continue
            opening_brace = assignment.end() - 1
            scope = executable_body[opening_brace:offset]
            if scope.count("{") > scope.count("}"):
                names.add(assignment.group("name"))
                break
    return names


def _dictionary_dynamic_stat_signal(body: str) -> tuple[int, str] | None:
    """Catch dictionary label -> sign -> rendered-value player copy."""
    dictionary_names = _localized_stat_dictionary_names(body)
    if not dictionary_names:
        return None
    executable_body = _mask_comments_and_optionally_strings(
        body, keep_strings=False)
    string_body = _mask_comments_and_optionally_strings(
        body, keep_strings=True)
    sign_variables, shown_variables, has_conditional_sign = \
        _dynamic_sign_context(body)
    if not has_conditional_sign:
        return None

    for formatter in DYNAMIC_TRIPLE_FORMAT_RE.finditer(string_body):
        if executable_body[formatter.start("operator")].isspace():
            continue
        if shown_variables or re.search(
            r"\b(?:str|format_money)\s*\(", executable_body
        ):
            return formatter.start(), formatter.group(0)

    label_names = set(dictionary_names)
    for dictionary_name in dictionary_names:
        alias_pattern = re.compile(
            rf"(?m)^\s*(?:var\s+)?"
            rf"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\b[^\n=]*?"
            rf"(?::=|=)\s*(?:str\s*\(\s*)?"
            rf"{re.escape(dictionary_name)}\s*\["
        )
        label_names.update(
            match.group("name") for match in alias_pattern.finditer(executable_body)
        )

    cursor = 0
    for line in executable_body.splitlines(keepends=True):
        identifiers = set(re.findall(
            r"\b[A-Za-z_][A-Za-z0-9_]*\b", line))
        if line.count("+") < 2 or not identifiers.intersection(label_names):
            cursor += len(line)
            continue
        original_line = body[cursor:cursor + len(line)]
        line_has_sign = bool(identifiers.intersection(sign_variables)) \
            or _dynamic_sign_context(original_line)[2]
        line_has_value = bool(identifiers.intersection(shown_variables)) \
            or re.search(r"\b(?:str|format_money)\s*\(", line) is not None
        if line_has_sign and line_has_value:
            return cursor, original_line.strip()
        cursor += len(line)
    return None


def _dynamic_grade_value_signal(
    body: str, surfaces: list[SurfaceLiteral],
) -> tuple[int, str] | None:
    """Catch an exact GRADE caption paired with any dynamic grade value."""
    executable_body = _mask_comments_and_optionally_strings(
        body, keep_strings=False)
    string_body = _mask_comments_and_optionally_strings(
        body, keep_strings=True)
    has_surface_label = any(
        DYNAMIC_GRADE_LABEL_LITERAL_RE.fullmatch(surface.text)
        for surface in surfaces
    )
    if not has_surface_label:
        label_call = next((candidate for candidate in
            DYNAMIC_GRADE_LABEL_CALL_RE.finditer(string_body)
            if not executable_body[candidate.start()].isspace()), None)
        if label_call is None:
            return None
    grade_get = next((candidate for candidate in
        DYNAMIC_GRADE_GET_RE.finditer(string_body)
        if not executable_body[candidate.start("get")].isspace()), None)
    if grade_get is not None:
        return grade_get.start(), grade_get.group(0)
    grade_index = next((candidate for candidate in
        DYNAMIC_GRADE_INDEX_RE.finditer(string_body)
        if not executable_body[candidate.start("index")].isspace()), None)
    if grade_index is not None:
        return grade_index.start(), grade_index.group(0)
    grade_value = DYNAMIC_GRADE_VALUE_RE.search(executable_body)
    if grade_value is not None:
        return grade_value.start(), grade_value.group(0)
    return None


def _localized_dynamic_stat_signal(body: str) -> tuple[int, str] | None:
    """Find a dynamic stat value attached to its exact localized expression.

    Function-wide co-presence is deliberately insufficient: a large rendering
    function can contain both an unrelated ``.format`` call and a legal stat
    label.  Each branch below requires the value assembler to be chained to the
    same localized stat literal that supplies the player-facing prefix.
    """
    executable_body = _mask_comments_and_optionally_strings(
        body, keep_strings=False)
    string_body = _mask_comments_and_optionally_strings(
        body, keep_strings=True)
    for call, _offset, opening in _iter_localized_calls(body):
        try:
            call_body, call_end = _call_body(body, opening)
        except ValueError:
            continue
        texts = _localized_call_texts(call, call_body)

        if any(DYNAMIC_STAT_PLACEHOLDER_LITERAL_RE.search(text) for text in texts):
            localized_string_body = _mask_comments_and_optionally_strings(
                call_body, keep_strings=True)
            if call == "LocaleManager.ui_format":
                arguments = _split_arguments(call_body)
                runtime_source = ", ".join(arguments[2:])
                executable_runtime = _mask_comments_and_optionally_strings(
                    runtime_source, keep_strings=False)
                runtime_dynamic = (
                    DYNAMIC_SIGNED_FORMAT_RE.search(localized_string_body)
                    is not None
                    or DYNAMIC_RUNTIME_VALUE_RE.search(executable_runtime)
                    is not None
                )
                if runtime_dynamic:
                    return opening, call

            chain = re.match(r"\s*\.format\s*\(", body[call_end:])
            if chain is not None:
                format_open = call_end + chain.end() - 1
                try:
                    format_body, _format_end = _call_body(body, format_open)
                except ValueError:
                    format_body = ""
                executable_format_body = _mask_comments_and_optionally_strings(
                    format_body, keep_strings=False)
                string_format_body = _mask_comments_and_optionally_strings(
                    format_body, keep_strings=True)
                dynamic_value = DYNAMIC_DELTA_VALUE_RE.search(
                    executable_format_body)
                signed_value = DYNAMIC_SIGNED_FORMAT_RE.search(
                    string_format_body)
                if dynamic_value is not None or signed_value is not None:
                    signal_offset = call_end + chain.start()
                    return signal_offset, body[
                        signal_offset:format_open + 1].strip()

            line_end = body.find("\n", call_end)
            if line_end < 0:
                line_end = len(body)
            tail = body[call_end:line_end]
            percent_formatter = re.match(r"\s*%", tail)
            signed_value = DYNAMIC_SIGNED_FORMAT_RE.search(
                _mask_comments_and_optionally_strings(
                    tail, keep_strings=True)
                if percent_formatter is not None else ""
            )
            if percent_formatter is not None and signed_value is not None:
                signal_offset = call_end + percent_formatter.start()
                return signal_offset, tail[
                    percent_formatter.start():signed_value.end()
                ].strip()

        if not any(DYNAMIC_STAT_LABEL_LITERAL_RE.fullmatch(text) for text in texts):
            continue
        line_end = body.find("\n", call_end)
        if line_end < 0:
            line_end = len(body)
        tail = body[call_end:line_end]
        executable_tail = _mask_comments_and_optionally_strings(
            tail, keep_strings=False)
        variable_concat = re.search(
            r"\+\s*(?P<sign>[A-Za-z_][A-Za-z0-9_]*)\s*"
            r"\+\s*str\s*\(\s*[A-Za-z_][A-Za-z0-9_]*",
            executable_tail,
        )
        if variable_concat is not None:
            sign = variable_concat.group("sign")
            sign_assignment = next((candidate for candidate in re.finditer(
                rf"\b(?:var\s+)?{re.escape(sign)}\b[^\n=]*?"
                rf"(?::=|=)\s*(?<!\\)[\"']\+[\"']\s+if\b"
                rf"[^\n]*\belse\b",
                string_body,
            ) if not executable_body[candidate.start()].isspace()), None)
            if sign_assignment is not None:
                return (
                    call_end + variable_concat.start(),
                    tail[variable_concat.start():variable_concat.end()],
                )

        direct_concat = re.search(
            r"\+\s*\(\s+if\b[^\n]*?\belse\b[^\n)]*\)\s*"
            r"\+\s*str\s*\(\s*"
            r"[A-Za-z_][A-Za-z0-9_]*",
            executable_tail,
        )
        if direct_concat is not None:
            direct_source = tail[
                direct_concat.start():direct_concat.end()]
            if re.search(r"(?<!\\)[\"']\+[\"']\s+if\b", direct_source):
                return (
                    call_end + direct_concat.start(),
                    direct_source,
                )
    return None


def _generic_dynamic_violations(path: str, source: str) -> list[Violation]:
    """Catch stat/grade composition regardless of the owning function name."""
    violations: list[Violation] = []
    bodies = _function_bodies(source)
    lexical_views: dict[str, tuple[str, str]] = {}
    localized_surfaces: dict[str, list[SurfaceLiteral]] = {}
    grade_helpers: set[str] = set()
    for function, (_body_offset, body) in bodies.items():
        executable_body = _mask_comments_and_optionally_strings(
            body, keep_strings=False)
        string_body = _mask_comments_and_optionally_strings(
            body, keep_strings=True)
        surfaces, _errors, _calls = extract_surface_literals(path, body)
        lexical_views[function] = (executable_body, string_body)
        localized_surfaces[function] = surfaces
        for grade_match in DYNAMIC_GRADE_SOURCE_RE.finditer(string_body):
            # The opening bracket must be executable syntax.  A quoted example
            # containing '["D", "C", "B", "A"]' remains documentation.
            if executable_body[grade_match.start()] == "[":
                grade_helpers.add(function)
                break

    for function, (body_offset, body) in bodies.items():
        executable_body, string_body = lexical_views[function]
        surfaces = localized_surfaces[function]

        label_match = DYNAMIC_STAT_RESOLVER_RE.search(executable_body)
        if label_match is None:
            label_surface = next(
                (surface for surface in surfaces
                 if DYNAMIC_STAT_LABEL_LITERAL_RE.fullmatch(surface.text)),
                None,
            )
            if label_surface is not None:
                label_match = re.search(
                    re.escape(label_surface.text), body, re.IGNORECASE)
        signed_match = DYNAMIC_SIGNED_FORMAT_RE.search(string_body)
        if label_match is not None and signed_match is not None:
            offset = body_offset + signed_match.start()
            violations.append(Violation(
                path, source.count("\n", 0, offset) + 1, function,
                "dynamic_stat_composition", "source", signed_match.group(0),
            ))
        localized_signal = _localized_dynamic_stat_signal(body)
        if localized_signal is not None:
            signal_offset, signal_text = localized_signal
            offset = body_offset + signal_offset
            violations.append(Violation(
                path, source.count("\n", 0, offset) + 1, function,
                "dynamic_stat_composition", "source", signal_text,
            ))
        else:
            dictionary_signal = _dictionary_dynamic_stat_signal(body)
            if dictionary_signal is not None:
                signal_offset, signal_text = dictionary_signal
                offset = body_offset + signal_offset
                violations.append(Violation(
                    path, source.count("\n", 0, offset) + 1, function,
                    "dynamic_stat_composition", "source", signal_text,
                ))

        grade_source = None
        for candidate in DYNAMIC_GRADE_SOURCE_RE.finditer(string_body):
            if executable_body[candidate.start()] == "[":
                grade_source = candidate
                break
        if grade_source is None:
            for helper in sorted(grade_helpers):
                if helper == function:
                    continue
                helper_call = re.search(
                    rf"\b{re.escape(helper)}\s*\(", executable_body)
                if helper_call is not None:
                    grade_source = helper_call
                    break
        grade_surface = next(
            (surface for surface in surfaces
             if DYNAMIC_GRADE_SURFACE_RE.search(surface.text)),
            None,
        )
        if grade_source is not None and grade_surface is not None:
            offset = body_offset + grade_source.start()
            violations.append(Violation(
                path, source.count("\n", 0, offset) + 1, function,
                "dynamic_grade_composition", "source", grade_surface.text,
            ))
        elif grade_source is None:
            grade_value_signal = _dynamic_grade_value_signal(body, surfaces)
            if grade_value_signal is not None:
                signal_offset, signal_text = grade_value_signal
                offset = body_offset + signal_offset
                violations.append(Violation(
                    path, source.count("\n", 0, offset) + 1, function,
                    "dynamic_grade_composition", "source", signal_text,
                ))
    return violations


def _structural_violations(path: str, source: str) -> list[Violation]:
    """Guard dynamic A1-A4/root composition which literal regexes cannot see."""
    bodies = _function_bodies(source)
    checks_by_path: dict[
        str, dict[str, tuple[tuple[str, re.Pattern[str]], ...]]
    ] = {
        "scenes/MainGame.gd": {
            "_weekly_commitment_outcome_text": (
                ("weekly_stat_join", re.compile(r"\bordered_stats\b")),
                ("weekly_signed_stat_fallback", re.compile(
                    r"_weekly_commitment_signed_number")),
                ("weekly_affinity_fallback", re.compile(r"\baffinity_delta\b")),
                ("weekly_letter_grade", re.compile(
                    r"\[\s*\"D\"\s*,\s*\"C\"\s*,\s*\"B\"\s*,\s*\"A\"\s*\]")),
            ),
            "_weekly_commitment_echo_record": (
                ("retired_a1_receipt", re.compile(
                    r"택한 것\s*·|CHOSEN\s*·|실제 결과\s*·|ACTUAL RESULT\s*·|"
                    r"그 주에 놓친 길\s*·|NOT CHOSEN THAT WEEK\s*·")),
            ),
            "_weekly_commitment_echo_sentence": (
                ("retired_a2_receipt", re.compile(
                    r"지난 선택\s*·|LAST CHOICE\s*·|실제 결과\s*·|ACTUAL RESULT\s*·|"
                    r"그 주에 놓친 길\s*·|NOT CHOSEN THAT WEEK\s*·")),
            ),
            "_append_scene_commitment_ledger": (
                ("retired_a3_receipt", re.compile(
                    r"실제 결과|ACTUAL RESULT|그 주에 놓친 길|NOT CHOSEN THAT WEEK|"
                    r"남은 웨이브|REMAINING WAVE")),
            ),
            "_show_ap_action_commit": (
                ("retired_a4_receipt", re.compile(
                    r"실제 결과\s*·|ACTUAL RESULT\s*·|닫힌 길\s*·|"
                    r"CLOSED PATHS\s*·|후속\s*·|LATER\s*·")),
            ),
            "_ap_contact_person": (
                ("dynamic_contact_stat_result", re.compile(
                    r"정신\s*%d\s*→\s*%d|Mental\s*%d\s*→\s*%d|"
                    r"호감도\s*%d|Affinity\s*%d")),
            ),
            "_ap_deep_study": (
                ("dynamic_study_stat_result", re.compile(
                    r"지력\s*%d\s*→\s*%d|Intelligence\s*%d\s*→\s*%d")),
            ),
            "_core_loop_v2_send_fresh_w1_application": (
                ("dynamic_application_grade", re.compile(
                    r"\[\s*\"D\"\s*,\s*\"C\"\s*,\s*\"B\"\s*,\s*\"A\"\s*\]"
                    r"|평가\s*%s|Grade\s*%s", re.IGNORECASE)),
            ),
            "_core_loop_v2_completion_view_model": (
                ("result_exact_stat_table", re.compile(
                    r"_tr\s*\(\s*[\"'](?:건강|정신력)[\"']\s*,\s*"
                    r"[\"'](?:Health|HEALTH|Mental|MENTAL)[\"']|"
                    r"[\"'][^\"'\n]*%[-+0-9.*]*d\s*/\s*100[^\"'\n]*[\"']")),
            ),
            "_core_loop_v2_condition_metric": (
                ("condition_exact_stat_output", re.compile(
                    r"_tr\s*\(\s*[\"'](?:건강|정신력)[\"']\s*,\s*"
                    r"[\"'](?:Health|HEALTH|Mental|MENTAL)[\"']|"
                    r"\bstr\s*\(\s*(?:raw_value|value)\s*\)|"
                    r"[\"'][^\"'\n]*%[-+0-9.*]*d[^\"'\n]*[\"']\s*%\s*"
                    r"(?:raw_value|value)\b|"
                    r"[\"']value[\"']\s*:\s*(?:raw_value|value)\b")),
            ),
            "_core_loop_v2_show_completion": (
                ("result_exact_stat_table", re.compile(
                    r"_tr\s*\(\s*[\"'](?:건강|정신력)[\"']\s*,\s*"
                    r"[\"'](?:Health|HEALTH|Mental|MENTAL)[\"']|"
                    r"[\"'][^\"'\n]*%[-+0-9.*]*d\s*/\s*100[^\"'\n]*[\"']")),
            ),
            "_core_loop_v2_show_month_summary": (
                ("result_exact_stat_table", re.compile(
                    r"_tr\s*\(\s*[\"'](?:건강|정신력)[\"']\s*,\s*"
                    r"[\"'](?:Health|HEALTH|Mental|MENTAL)[\"']|"
                    r"[\"'][^\"'\n]*%[-+0-9.*]*d\s*/\s*100[^\"'\n]*[\"']")),
            ),
            "_ending_stat_grid": (
                ("ending_system_report", re.compile(
                    r"EndingSystem\.get_score\s*\(|GameState\.reputation\b|"
                    r"_tr\s*\(\s*[\"'](?:점수|명성|건강|정신력)[\"']\s*,\s*"
                    r"[\"'](?:Score|Reputation|Health|Mental)[\"']|"
                    r"[\"'][^\"'\n]*%[-+0-9.*]*d\s*/\s*100[^\"'\n]*[\"']")),
            ),
            "_ending_milestones": (
                ("ending_system_milestone", re.compile(
                    r"최고\s*티어|Top-tier|투자\s*(?:고수|중수)|"
                    r"(?:expert|intermediate)\s+investor", re.IGNORECASE)),
            ),
            "_ending_playstyle": (
                ("ending_hidden_playstyle", re.compile(
                    r"get_playstyle_label\s*\(|플레이\s*스타일\s*진단|"
                    r"Playstyle\s+Diagnosis", re.IGNORECASE)),
            ),
            "_add_ending_mood_card": (
                ("ending_hidden_stat_bar", re.compile(
                    r"float\s*\(\s*GameState\.(?:health|mental)\s*\)\s*/\s*100")),
            ),
            "_show_effects_float": (
                ("dynamic_effect_stat_label", re.compile(
                    r"_STAT_(?:KR|EN)|\blabel_kr\b")),
                ("dynamic_effect_signed_value", re.compile(
                    r"\bvar\s+sign\b|\"%s%d\"|\"%s%s\"")),
            ),
            "_ap_result_effect_badge": (
                ("dynamic_result_stat_badge", re.compile(
                    r"_stat_name\s*\(|_ap_result_effect_value\s*\(")),
            ),
            "_ap_result_effect_value": (
                ("dynamic_result_signed_value", re.compile(
                    r"\bvar\s+sign\b|\"%s%d\"|format_money\s*\(")),
            ),
            "_story_result_cast_badge": (
                ("dynamic_affinity_result", re.compile(
                    r"호감도|\bAffinity\b|\"%s%d\"", re.IGNORECASE)),
            ),
            "_montage_record_card": (
                ("dynamic_montage_stat_result", re.compile(
                    r"\"%s%d\"\s*%\s*\[\s*\"\+\"\s+if\s+"
                    r"(?:health_d|mental_d)")),
            ),
            "_render_sidebars": (
                ("dynamic_inventory_stat_effect", re.compile(
                    r"effect_parts\.append\([^\n]*_stat_name\s*\(")),
            ),
        },
        "scenes/StoryMode.gd": {
            "_show_story_result_record": (
                ("story_dynamic_stat_badge", re.compile(
                    r"_stat_display_name\s*\(|_story_result_value_text\s*\(")),
                ("story_dynamic_affinity_badge", re.compile(
                    r"호감도|\bAffinity\b|\bvar\s+sign\b|\"%s%d\"",
                    re.IGNORECASE)),
            ),
            "_show_change_toasts": (
                ("story_dynamic_change_stat_label", re.compile(
                    r"_stat_display_name\s*\(|\bdisp_name\b")),
                ("story_dynamic_change_signed_value", re.compile(
                    r"\btxt\s*=\s*\"[^\"\n]*%[sd]|_story_money\s*\(\s*abs\s*\(diff\)")),
            ),
        },
    }
    checks = checks_by_path.get(path, {})
    if not checks:
        return []
    violations: list[Violation] = []
    for function, function_checks in checks.items():
        if function not in bodies:
            continue
        body_offset, body = bodies[function]
        for rule_name, pattern in function_checks:
            match = pattern.search(body)
            if not match:
                continue
            offset = body_offset + match.start()
            violations.append(Violation(
                path, source.count("\n", 0, offset) + 1, function,
                rule_name, "source", match.group(0),
            ))
    return violations


def scan_source(
    path: str, source: str,
) -> tuple[list[Violation], list[Violation], int, int]:
    surfaces, errors, calls = extract_surface_literals(path, source)
    observed = (
        errors
        + _literal_violations(surfaces)
        + _structural_violations(path, source)
        + _generic_dynamic_violations(path, source)
    )
    allowed: list[Violation] = []
    blocked: list[Violation] = []
    for violation in observed:
        key = (violation.path, violation.function, violation.rule)
        if key in ALLOW_INDEX:
            allowed.append(violation)
        else:
            blocked.append(violation)
    return blocked, allowed, calls, len(surfaces)


def repository_targets() -> list[Path]:
    targets: list[Path] = []
    for directory in PLAYER_SURFACE_DIRS:
        root = ROOT / directory
        if root.is_dir():
            targets.extend(root.rglob("*.gd"))
    return sorted(targets)


def audit_repository() -> tuple[list[Violation], int, int, int, int]:
    blocked: list[Violation] = []
    allowed_count = 0
    calls = 0
    literals = 0
    targets = repository_targets()
    for target in targets:
        relative = str(target.relative_to(ROOT))
        source = target.read_text(encoding="utf-8", errors="strict")
        source_blocked, source_allowed, source_calls, source_literals = scan_source(
            relative, source)
        blocked.extend(source_blocked)
        allowed_count += len(source_allowed)
        calls += source_calls
        literals += source_literals
    blocked.sort(key=lambda row: (
        row.path, row.line, row.function, row.rule, row.language, row.text))
    return blocked, allowed_count, len(targets), calls, literals


def run_self_test() -> tuple[list[str], int]:
    failures: list[str] = []
    cases = 0

    def expect_rules(
        label: str, source: str, expected: set[str],
        path: str = "scenes/SelfTest.gd",
    ) -> None:
        nonlocal cases
        cases += 1
        blocked, _allowed, _calls, _literals = scan_source(path, source)
        actual = {row.rule for row in blocked}
        if actual != expected:
            failures.append(f"{label}: expected={sorted(expected)} actual={sorted(actual)}")

    expect_rules(
        "Korean stat", 'func show():\n return _tr("정신 -8", "quiet night")\n',
        {"stat_delta_ko"},
    )
    expect_rules(
        "English stat", 'func show():\n return _tr("조용한 밤", "Mental +2")\n',
        {"stat_delta_en"},
    )
    expect_rules(
        "formatted stat", 'func show():\n return _tr("정신력 %+d", "Mental %+d")\n',
        {"stat_delta_ko", "stat_delta_en"},
    )
    expect_rules(
        "Korean unlock", 'func show():\n return _tr("새 장소 해금", "A new place opened")\n',
        {"unlock_ko"},
    )
    expect_rules(
        "English unlock", 'func show():\n return _tr("새 장소", "Venue Unlocked")\n',
        {"unlock_en"},
    )
    expect_rules(
        "Korean multiplier", 'func show():\n return _tr("사회성 3배 상승", "People respond")\n',
        {"multiplier_ko"},
    )
    expect_rules(
        "English multiplier", 'func show():\n return _tr("두 배", "Social x3")\n',
        {"multiplier_en"},
    )
    expect_rules(
        "Korean wave", 'func show():\n return _tr("남은 웨이브", "It remains")\n',
        {"wave_ko"},
    )
    expect_rules(
        "English WAVE", 'func show():\n return _tr("남은 일", "REMAINING WAVE")\n',
        {"wave_en"},
    )
    expect_rules(
        "letter grade", 'func show():\n return _tr("평가 A", "Grade A")\n',
        {"grade_ko", "grade_en"},
    )
    expect_rules(
        "ui wrapper", 'func show():\n return LocaleManager.ui("평판 +2", "Reputation +2")\n',
        {"stat_delta_ko", "stat_delta_en"},
    )
    expect_rules(
        "context wrapper",
        'func show():\n return LocaleManager.ui_context("key", "해금", "unlocked")\n',
        {"unlock_ko", "unlock_en"},
    )
    expect_rules(
        "format wrapper",
        'func show():\n return LocaleManager.ui_format("평가 B", "GRADE B", 1, 1)\n',
        {"grade_ko", "grade_en"},
    )
    expect_rules(
        "slide body",
        'func show():\n return _localized_slide("i", "제목", "Title", "웨이브", "WAVE")\n',
        {"wave_ko", "wave_en"},
    )
    expect_rules(
        "multiline and concatenated literals",
        'func show():\n return _tr(\n  "앞" + "사회성 +3",\n  "front" + " Social +3")\n',
        {"stat_delta_ko", "stat_delta_en"},
    )
    expect_rules(
        "comment ignored",
        '# _tr("정신 -8", "Mental -8")\nfunc show():\n return "safe"\n',
        set(),
    )
    expect_rules(
        "quoted example ignored",
        'func show():\n return "_tr(\\\"정신 -8\\\", \\\"Mental -8\\\")"\n',
        set(),
    )
    expect_rules(
        "legal 피해금 noun", 'func show():\n return _tr("피해금 반환", "Return")\n',
        set(),
    )
    expect_rules(
        "natural lowercase wave", 'func show():\n return _tr("파도가 왔다", "A wave reached shore")\n',
        set(),
    )
    expect_rules(
        "ordinary double cost", 'func show():\n return _tr("교통비 2배", "Twice the fare")\n',
        set(),
    )
    expect_rules(
        "title allowlist",
        'func _open_title_collection():\n return _tr("해금", "Unlocked")\n',
        set(), "scenes/MainGame.gd",
    )
    expect_rules(
        "copied title wording outside meta",
        'func _open_inventory():\n return _tr("해금", "Unlocked")\n',
        {"unlock_ko", "unlock_en"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "casino multiplier allowlist",
        'func _render_game():\n return _tr("더블 x2", "Double x2")\n',
        set(), "scenes/BlackjackTable.gd",
    )
    expect_rules(
        "casino allowlist is pattern-specific",
        'func _render_game():\n return _tr("정신 -2", "Mental -2")\n',
        {"stat_delta_ko", "stat_delta_en"}, "scenes/BlackjackTable.gd",
    )
    expect_rules(
        "pre-choice stat disclosure allowlist",
        'func _ap_action_preview():\n return _tr("건강 -3", "Health -3")\n',
        set(), "scenes/MainGame.gd",
    )
    expect_rules(
        "pre-choice allowlist is pattern-specific",
        'func _ap_action_preview():\n return _tr("웨이브", "WAVE")\n',
        {"wave_ko", "wave_en"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "dynamic weekly stat join",
        'func _weekly_commitment_outcome_text(record):\n var ordered_stats = []\n',
        {"weekly_stat_join"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "dynamic stat-name and signed-value assembler",
        'func _show_effects_float(effects):\n'
        ' var label_kr = _STAT_KR[key]\n'
        ' var sign = "+" if val > 0 else ""\n'
        ' var text = "%s%d %s" % [sign, val, label_kr]\n',
        {"dynamic_effect_stat_label", "dynamic_effect_signed_value",
         "dynamic_stat_composition"},
        "scenes/MainGame.gd",
    )
    expect_rules(
        "dynamic affinity assembler",
        'func _story_result_cast_badge(pid, affinity_delta):\n'
        ' var sign = "+" if affinity_delta > 0 else ""\n'
        ' return _tr("호감도 ", "Affinity ") + "%s%d" % [sign, affinity_delta]\n',
        {"dynamic_affinity_result", "dynamic_stat_composition"},
        "scenes/MainGame.gd",
    )
    expect_rules(
        "dynamic grade assembler",
        'func _core_loop_v2_send_fresh_w1_application(button):\n'
        ' var grade = ["D", "C", "B", "A"][quality]\n'
        ' return LocaleManager.ui_format("평가 %s", "Grade %s", grade, grade)\n',
        {"dynamic_application_grade", "dynamic_grade_composition"},
        "scenes/MainGame.gd",
    )
    expect_rules(
        "StoryMode dynamic result badge",
        'func _show_story_result_record(choice):\n'
        ' var label = _stat_display_name(key, key)\n'
        ' var value = _story_result_value_text(key, val)\n',
        {"story_dynamic_stat_badge"}, "scenes/StoryMode.gd",
    )
    expect_rules(
        "StoryMode dynamic change toast",
        'func _show_change_toasts(before):\n'
        ' var disp_name = _stat_display_name(key, key)\n'
        ' var txt = "%s %s%d" % [disp_name, "+", diff]\n',
        {"dynamic_stat_composition", "story_dynamic_change_signed_value",
         "story_dynamic_change_stat_label"},
        "scenes/StoryMode.gd",
    )
    expect_rules(
        "completion exact health table",
        'func _core_loop_v2_completion_view_model(snapshot):\n'
        ' return {"label": _tr("건강", "HEALTH"), '
        '"value": "%d / 100" % snapshot.health}\n',
        {"result_exact_stat_table"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "ending score report",
        'func _ending_stat_grid(parent):\n'
        ' var score = EndingSystem.get_score()\n'
        ' return _tr("점수", "Score") + str(score)\n',
        {"ending_system_report"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "ending hidden stat bar",
        'func _add_ending_mood_card(parent):\n'
        ' return float(GameState.health) / 100.0\n',
        {"ending_hidden_stat_bar"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "ending hidden playstyle verdict",
        'func _ending_playstyle(parent):\n'
        ' return _tr("플레이 스타일 진단", "Playstyle Diagnosis") + '
        'GameState.get_playstyle_label()\n',
        {"ending_hidden_playstyle"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "ending system milestone",
        'func _ending_milestones(parent):\n'
        ' return _tr("투자 고수 레벨 달성", "Reached expert investor level")\n',
        {"ending_system_milestone"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "observational result copy remains legal",
        'func _core_loop_v2_completion_view_model(snapshot):\n'
        ' return _tr("숨이 고르게 돌아왔다", "Breathing settled")\n',
        set(), "scenes/MainGame.gd",
    )
    expect_rules(
        "condition helper cannot stringify hidden value",
        'func _core_loop_v2_condition_metric(kind, raw_value, note):\n'
        ' return {"label": _tr("몸", "BODY"), '
        '"value": str(raw_value), "note": note}\n',
        {"condition_exact_stat_output"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "arbitrary owner localized stat plus signed number",
        'func completely_new_result(value):\n'
        ' return _tr("정신 ", "Mental ") + "%+d" % value\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner dynamic stat name plus signed number",
        'func renamed_surface(key, value):\n'
        ' return "%s %+d" % [_stat_name(key), value]\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner dynamic grade",
        'func unknown_grade_surface(quality):\n'
        ' var letter = ["D", "C", "B", "A"][quality]\n'
        ' return _tr("평가 %s", "Grade %s") % letter\n',
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner placeholder format dictionary",
        'func unrelated_result(delta):\n'
        ' return _tr("정신 {delta}", "Mental {delta}").format('
        '{"delta": "%+d" % delta})\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner placeholder percent formatter",
        'func unrelated_percent_result(delta):\n'
        ' return _tr("정신 %s", "Mental %s") % ("%+d" % delta)\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner ui-format signed placeholder",
        'func unrelated_ui_format(delta):\n'
        ' return LocaleManager.ui_format('
        '"정신 %s", "Mental %s", "%+d" % delta, "%+d" % delta)\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner brace placeholder with dynamic format value",
        'func bypass_brace_format(delta):\n'
        ' return _tr("건강 {delta}", "Health {delta}").format('
        '{"delta": delta})\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "non-stat brace placeholder remains legal",
        'func harmless_brace_format(name):\n'
        ' return _tr("봉투 {name}", "Envelope {name}").format('
        '{"name": name})\n',
        set(), "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner conditional plus with string cast",
        'func bypass_conditional_plus(delta):\n'
        ' var sign = "+" if delta > 0 else ""\n'
        ' return _tr("정신 ", "Mental ") + sign + str(delta)\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "non-stat conditional plus remains legal",
        'func harmless_conditional_plus(delta):\n'
        ' var sign = "+" if delta > 0 else ""\n'
        ' return _tr("좌석 ", "Seat ") + sign + str(delta)\n',
        set(), "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary owner cross-helper dynamic grade",
        'func helper_grade_letter(quality):\n'
        ' return ["D", "C", "B", "A"][quality]\n'
        'func bypass_cross_helper_grade(quality):\n'
        ' return _tr("평가 %s", "Grade %s") % helper_grade_letter(quality)\n',
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "cross-helper letters without grade surface remain legal",
        'func helper_drawer_letter(index):\n'
        ' return ["D", "C", "B", "A"][index]\n'
        'func harmless_cross_helper_letter(index):\n'
        ' return _tr("서랍 %s", "Drawer %s") % helper_drawer_letter(index)\n',
        set(), "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary ui-format runtime affinity delta",
        'func arbitrary_affinity_receipt(delta):\n'
        ' var signed_delta = ("+" if delta > 0 else "") + str(delta)\n'
        ' return LocaleManager.ui_format('
        '"호감도 %s", "Affinity %s", signed_delta, signed_delta)\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary ui-format runtime numeric delta",
        'func arbitrary_health_receipt(change):\n'
        ' return LocaleManager.ui_format('
        '"건강 %d", "Health %d", change, change)\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "arbitrary dictionary label sign shown assembler",
        'func arbitrary_dictionary_receipt(delta):\n'
        ' var labels := {"mental": LocaleManager.ui("정신력", "Mental")}\n'
        ' var label = str(labels["mental"])\n'
        ' var sign = "+" if delta >= 0 else "-"\n'
        ' var shown = str(abs(delta))\n'
        ' return label + " " + sign + shown\n',
        {"dynamic_stat_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "routine effect pre-choice exact allowlist",
        'func _routine_effect_copy(value):\n'
        ' var labels := {"health": LocaleManager.ui("건강", "Health")}\n'
        ' var shown = str(abs(value))\n'
        ' return "%s %s%s" % [labels["health"], '
        '"+" if value >= 0 else "-", shown]\n',
        set(), "scenes/CoreLoopPlanner.gd",
    )
    expect_rules(
        "arbitrary visible grade from dynamic ending data",
        'func arbitrary_ending_grade(ending):\n'
        ' var caption = _tr("등급", "GRADE")\n'
        ' return caption + " " + str(ending.get("grade", "?"))\n',
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "grade placeholder formatted from dictionary get",
        "func arbitrary_grade_get(ending):\n"
        " return _tr('등급 %s', 'Grade %s') % "
        "str(ending.get('grade', '?'))\n",
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "grade caption plus dictionary index",
        "func arbitrary_grade_index(ending):\n"
        " var caption = _tr('등급', 'GRADE')\n"
        " return caption + str(ending['grade'])\n",
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "grade caption plus parameter string cast",
        "func arbitrary_grade_parameter(grade):\n"
        " var caption = _tr('등급', 'GRADE')\n"
        " return caption + str(grade)\n",
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "grade placeholder formatted from parameter",
        "func arbitrary_grade_formatter(grade):\n"
        " return _tr('등급 %s', 'Grade %s') % grade\n",
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "grade caption plus uncast dictionary get",
        "func arbitrary_grade_get_without_cast(ending):\n"
        " var caption = _tr('등급', 'GRADE')\n"
        " return caption + ending.get('grade', '?')\n",
        {"dynamic_grade_composition"}, "scenes/SelfTest.gd",
    )
    expect_rules(
        "title dynamic grade exact allowlist",
        'func _check_title_unlocks(data):\n'
        ' return _tr("등급", "GRADE") + str(data.get("grade", "?"))\n',
        set(), "scenes/MainGame.gd",
    )
    expect_rules(
        "non-letter mastery label remains legal",
        'func arbitrary_mastery(data):\n'
        ' return _tr("숙련", "MASTERY") + str(data.get("mastery", 0))\n',
        set(), "scenes/SelfTest.gd",
    )
    expect_rules(
        "generic dynamic comment ignored",
        'func arbitrary_owner():\n'
        ' # _stat_name(key) and value %+d are an example\n'
        ' return _tr("조용한 밤", "Quiet night")\n',
        set(), "scenes/SelfTest.gd",
    )
    expect_rules(
        "generic dynamic quoted example ignored",
        'func arbitrary_owner():\n'
        ' return "_stat_name(key) %+d"\n',
        set(), "scenes/SelfTest.gd",
    )
    expect_rules(
        "retired A4 receipt",
        'func _show_ap_action_commit():\n return _tr("닫힌 길 · x", "CLOSED PATHS · x")\n',
        {"retired_a4_receipt"}, "scenes/MainGame.gd",
    )
    expect_rules(
        "malformed localized call",
        'func show():\n return _tr("해금", "Unlocked"\n',
        {"parse_error"},
    )

    if not failures:
        print(f"PLAYER_SURFACE_LANGUAGE_SELF_TEST_OK cases={cases}")
    return failures, cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    failures: list[str] = []
    if args.self_test:
        self_test_failures, cases = run_self_test()
        if self_test_failures:
            print(
                "PLAYER_SURFACE_LANGUAGE_SELF_TEST_FAIL "
                f"cases={cases} failures={len(self_test_failures)}"
            )
            for failure in self_test_failures:
                print(f"  {failure}")
            failures.extend(self_test_failures)

    try:
        violations, allowed, files, calls, literals = audit_repository()
    except (OSError, UnicodeError) as exc:
        print(f"PLAYER_SURFACE_LANGUAGE_AUDIT_FAIL read_error={exc}")
        return 1

    print(
        "PLAYER_SURFACE_LANGUAGE "
        f"files={files} localized_calls={calls} literals={literals} "
        f"allowed={allowed} violations={len(violations)}"
    )
    if violations:
        print(f"PLAYER_SURFACE_LANGUAGE_AUDIT_FAIL violations={len(violations)}")
        for violation in violations[:200]:
            print(f"  {violation.render()}")
        if len(violations) > 200:
            print(f"  ... {len(violations) - 200} more")
        return 1
    if failures:
        return 1
    print("PLAYER_SURFACE_LANGUAGE_AUDIT_OK violations=0")
    return 0


if __name__ == "__main__":
    sys.exit(main())
