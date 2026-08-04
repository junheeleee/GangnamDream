# Multilingual Infrastructure

## Status

Korean and English are the only shipping languages. Japanese, Simplified
Chinese, and Traditional Chinese are prepared targets, not selectable player
options. Japanese UI is a machine-assisted beta with structural and semantic
gates; new story, ending, dynamic, and catalog prose remains held until the user
gives an explicit demo GO decision. One existing Japanese prologue event is a
seed, not evidence that the demo body is translated. Chinese dictionaries remain
empty.

| Code | Status | UI dictionary | Event overlay | Ending overlay |
|---|---|---|---|---|
| `ko` | Shipping, source | Inline source | `content/events/` | `content/endings.json` |
| `en` | Shipping, strict | Inline fallback | `content/events_en/` | `content/endings_en.json` |
| `ja` | Prepared beta, hidden | 2,546/2,546 keys | 1/1,599 full; 1/70 demo | 0/35 full; 0 required by demo |
| `zh-CN` | Prepared, hidden | Empty | 0/1,599 full; 0/70 demo | 0/35 full; 0 required by demo |
| `zh-TW` | Prepared, hidden | Empty | 0/1,599 full; 0/70 demo | 0/35 full; 0 required by demo |

`LocaleManager.SHIPPING_LANGUAGES` is the player-facing allowlist. Adding a
language to `SUPPORTED_LANGUAGES` is not permission to expose it in the first-run
gate or Steam metadata.

## UI Contract

The existing `LocaleManager.ui(korean, english)` and `_tr(korean, english)`
call sites remain unchanged. For a prepared language, the Korean source string
is used as the lookup key in `locale/ui_<code>.json`:

```json
{
  "다음 주로": "translated value"
}
```

An absent key returns the English argument and records one unique miss in
`LocaleManager.get_ui_misses(code)`. It must never return Korean for a
non-Korean language. The source text is a content identifier for this layer, so
changing Korean UI copy after translation freeze requires moving the matching
dictionary key in the same commit.

## Content Contract

Localized content is an ID overlay, never a second gameplay database.

1. Load Korean gameplay data.
2. For every non-Korean locale, merge the complete English overlay.
3. For `ja`, `zh-CN`, or `zh-TW`, merge that locale's text overlay last.
4. A missing target row therefore shows English, never Korean.

Event overlays may contain only `id`, text variants, `description_if_known`,
`description_if_moral`, and choice text/result text. Choice order and count must
match Korean. Ending overlays must preserve every `description_if_known` key.
Gameplay conditions, effects, flags, backgrounds, portraits, CG ownership, and
routing remain in Korean source data.

Catalog text uses `locale/catalog_<code>.json` with these sections:
`assets`, `jobs`, `items`, `achievements`, `clues`, `thoughts`, and `news`.
Each section is an object keyed by the source row ID. Empty sections inherit the
English catalog.

## Actual 24-Week Demo Scope

The demo translation unit is derived from the runtime sources rather than one
representative playthrough. `tools/demo_localization_scope.py` follows every
legal Week 1-24 bundle, foreground root, immediate follow-up, the complete
prologue closure, and the required Chapter 1 card. The current locked scope is:

- 70 visible events: 12 prologue, one Chapter 1 card, and 57 Week 1-24 events.
- 431 translatable event text leaves and zero endings. The Week-24 CTA is not a
  `finish_run` ending.
- 479 unique Korean lookup keys across 486 dynamic KO/EN pair occurrences,
  including the monthly planner, opening cinematic, runtime event/name surfaces,
  portrait labels, and every legal randomized convenience, delivery, resume, and
  interview surface. The activity portion is 147 occurrences / 146 unique keys.
- Four asset names visible in the Week-21 market route.

`callback_escaped_dirty_trace` is a claimed receipt/source event whose visible
Week-24 foreground is `v2_dirty_trace_initial_call`; counting both would invent
a scene the player never reads. The scope manifest locks the source hashes and
the complete event-ID hash so a content change cannot silently leave the
translation plan stale.

Current prepared coverage is deliberately incomplete:

| Locale | Events | Event text leaves | Dynamic keys | Demo catalog |
|---|---:|---:|---:|---:|
| `ja` | 1/70 | 8/431 | 8/479 | 0/4 |
| `zh-CN` | 0/70 | 0/431 | 0/479 | 0/4 |
| `zh-TW` | 0/70 | 0/431 | 0/479 | 0/4 |

Skeleton mode verifies this scope, existing rows, fallback paths, and the hidden
shipping state without pretending missing prose is complete. Per-language
`--strict` additionally requires 70/70 events, 431/431 leaves, 479/479 dynamic
keys, 4/4 catalog names, and zero direct English bypasses. It is expected to fail
until an approved body-translation wave is finished. Japanese has the required
terminology and source-shape validator now. Chinese strict mode intentionally
refuses to certify either region until ORDER-82 adds separate Simplified and
Traditional Chinese script, terminology, money, abbreviation, and font gates.

## Money And Units

The fiction and balance use Korean won in every language. Relabeling the same
numeric value with `¥` would turn 100 million won into 100 million yen or yuan
without conversion and materially misrepresent the story. The locale layer
therefore preserves the currency while localizing large-number reading:

| Locale | Example for 123,450,000 won |
|---|---|
| `ko` | `1.2억원` |
| `en` | `123.5 million won` |
| `ja` | `1.2億ウォン` |
| `zh-CN` | `1.2亿韩元` |
| `zh-TW` | `1.2億韓元` |

`GameState.format_money_compact()` exists for space-constrained surfaces. A
future total conversion may add an explicit exchange/value profile, but a
language switch alone never changes economic value.

Housing labels, loan products, job catalogs, default names, and legacy KO/EN
branches use the same rule: Korean for `ko`; target dictionary where present;
otherwise English.

## Font Gate

The project bundles `NotoSansJP-Variable.ttf` and attaches it through `FontKit`
before the emoji fallback. Runtime inspection now proves hiragana, katakana,
kanji, and Japanese punctuation from project-owned files rather than an
operating-system fallback. The font and its retained `OFL-NotoSansJP.txt` came
from the official Google Fonts Noto Sans JP distribution.

SHA-256 locks:

- `NotoSansJP-Variable.ttf`: `c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f`
- `OFL-NotoSansJP.txt`: `babcfe66c8a098b2fa279bc724a3a342f8124f77ce18941fbcc1bbb39823cded`

Simplified Chinese core glyph coverage is still incomplete. macOS can hide
that by selecting an OS font, which is not a deterministic Windows or Steam
Deck result. Chinese therefore remains non-shipping until project-owned SC/TC
fallbacks are bundled and tested on every target platform.

Approved candidate family: Noto Sans CJK JP/SC/TC, regular and semibold subsets
or language-specific TTFs. The official project distributes the family under
SIL Open Font License 1.1 and recommends TTF rather than CFF2 variable fonts on
Windows where corruption is still documented:

- <https://github.com/notofonts/noto-cjk>
- <https://github.com/googlefonts/noto-cjk/blob/main/Sans/LICENSE>
- <https://github.com/notofonts/noto-cjk/releases>

Before enabling a prepared language, bundle its font, attach it in `FontKit`,
retain the OFL license in distribution notices, and pass the CJK screenshot on
Windows, macOS, and Linux/Steam Deck.

## Validation

```bash
python3 tools/i18n_coverage_check.py
python3 tools/multilingual_surface_audit.py
python3 tools/ja_translation_audit.py --scope ui
python3 tools/ja_translation_pipeline.py --scope demo --inventory
python3 tools/ja_translation_pipeline.py --self-test
python3 tools/ja_translation_audit.py --scope demo
python3 tools/demo_localization_scope.py --self-test
python3 tools/demo_localization_scope.py --lang all
godot --headless res://tools/I18nInfrastructureCheck.tscn
godot --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=i18n-layout --lang=ja
```

The default full-game coverage command keeps English strict and prepared locales
in skeleton mode. `ja_translation_audit.py --scope ui` requires all 2,546 current
UI keys, exact placeholder/newline parity, zero Hangul or yen conversion,
canonical names and casino terms, and no lock/unlock polarity reversal. The
runtime check proves alias normalization, UI miss logging, English
event/ending/catalog fallback, locale money labels, and bundled glyph coverage.

`ja_translation_pipeline.py` defaults to UI-only generation. Its read-only
`--scope demo --inventory` proves that the future wave contains exactly 431 event
leaves, 479 dynamic keys, four catalog names, and no ending. Demo generation exits
with `BODY_TRANSLATION_HELD` unless `--allow-body` is passed after the explicit
demo GO decision; it merges those rows without deleting existing static UI or
out-of-demo translations. Full `events`, `endings`, `catalog`, and `all` scopes do
not accept that demo approval and require the separate `--allow-full-body` gate.
The source-hash cache lives under `.git` so generated drafts do not become release
assets.

## Translation Wave Gate

Japanese infrastructure began after content freeze, but prose generation is
held because the playable demo is still being revised. The Japanese
UI dictionary remains a hidden beta and is not a shipping-language promise.
Once the user gives demo GO, the remaining wave requires:

1. A terminology and character-address sheet before bulk translation.
2. Strict parity for all 70 demo events, choices, variants, dynamic strings, and
   the four visible catalog names; no demo ending is fabricated.
3. Zero Korean in target values.
4. Bundled deterministic fonts and 1280x800 layout captures.
5. A Japanese native reviewer directly comparing the Korean source and the same
   `demo_rc` at normal speed, plus replay of all legally reachable events and
   choices. Character voice, relationship distance, subtext, KRW weight,
   translationese, and causal meaning are human gates rather than key counts.

The Japanese demo claim and the eventual full-game Japanese release claim are
separate. Passing the demo gate does not satisfy 1,599-event/35-ending full-game
coverage. Passing the current UI/font gates alone must never add `ja` to
`SHIPPING_LANGUAGES` or Steam metadata.
