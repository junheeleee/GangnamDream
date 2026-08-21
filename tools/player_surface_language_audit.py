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
    matches = list(FUNCTION_RE.finditer(source))
    result: dict[str, tuple[int, str]] = {}
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        result[match.group(1)] = (match.start(), source[match.start():end])
    return result


def _structural_violations(path: str, source: str) -> list[Violation]:
    """Guard dynamic A1-A4/root composition which literal regexes cannot see."""
    if path != "scenes/MainGame.gd":
        return []
    bodies = _function_bodies(source)
    checks: dict[str, tuple[tuple[str, re.Pattern[str]], ...]] = {
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
    }
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
    observed = errors + _literal_violations(surfaces) + _structural_violations(path, source)
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
