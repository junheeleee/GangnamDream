# Multilingual Infrastructure

## Status

Korean and English are the only shipping languages. Japanese, Simplified
Chinese, and Traditional Chinese are prepared targets, not selectable player
options. Their dictionaries intentionally contain no translations until the
content-freeze declaration.

| Code | Status | UI dictionary | Event overlay | Ending overlay |
|---|---|---|---|---|
| `ko` | Shipping, source | Inline source | `content/events/` | `content/endings.json` |
| `en` | Shipping, strict | Inline fallback | `content/events_en/` | `content/endings_en.json` |
| `ja` | Prepared | `locale/ui_ja.json` | `content/events_ja/` | `content/endings_ja.json` |
| `zh-CN` | Prepared | `locale/ui_zh-CN.json` | `content/events_zh-CN/` | `content/endings_zh-CN.json` |
| `zh-TW` | Prepared | `locale/ui_zh-TW.json` | `content/events_zh-TW/` | `content/endings_zh-TW.json` |

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

Runtime inspection of the bundled Pretendard Regular found Japanese hiragana
coverage but no reliable Simplified or Traditional Chinese core glyph coverage.
macOS can hide this by selecting an operating-system fallback, which is not a
deterministic Windows or Steam Deck result. Chinese remains non-shipping until
project-owned fallback fonts are bundled and tested on all target platforms.

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
python3 tools/i18n_coverage_check.py --lang ja --strict
python3 tools/multilingual_surface_audit.py
godot --headless res://tools/I18nInfrastructureCheck.tscn
godot --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=i18n-layout --lang=zh-CN
```

The default coverage command keeps English strict and prepared locales in
skeleton mode. `--strict` is the translation-wave completion gate. The runtime
check proves alias normalization, UI miss logging, English event/ending/catalog
fallback, locale money labels, and font coverage reporting.

## Translation Wave Gate

Translation starts only after Claude declares content freeze. The order is
Japanese, Simplified Chinese, then Traditional Chinese. Each wave requires:

1. A terminology and character-address sheet before bulk translation.
2. Strict event, choice, moral variant, and ending-DIK parity.
3. Zero Korean in target values.
4. Bundled deterministic fonts and 1280x800 layout captures.
5. Native-speaker spot checks of the opening, romance registers, money terms,
   the moral perception variants, and at least five endings.
