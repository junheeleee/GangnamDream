# Multilingual Infrastructure

## Status

Korean and English are the only shipping languages. Japanese, Simplified
Chinese, and Traditional Chinese are prepared targets, not selectable player
options. Japanese UI is a machine-assisted beta with structural and semantic
gates; its story and ending overlays remain intentionally empty until the user
gives an explicit demo GO decision. Chinese dictionaries remain empty.

| Code | Status | UI dictionary | Event overlay | Ending overlay |
|---|---|---|---|---|
| `ko` | Shipping, source | Inline source | `content/events/` | `content/endings.json` |
| `en` | Shipping, strict | Inline fallback | `content/events_en/` | `content/endings_en.json` |
| `ja` | Prepared beta, hidden | 1,957/1,957 keys | Held, empty | Held, empty |
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
godot --headless res://tools/I18nInfrastructureCheck.tscn
godot --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=i18n-layout --lang=ja
```

The default coverage command keeps English strict and prepared locales in
skeleton mode. `ja_translation_audit.py --scope ui` requires all 1,957 current
UI keys, exact placeholder/newline parity, zero Hangul or yen conversion,
canonical names and casino terms, and no lock/unlock polarity reversal. The
runtime check proves alias normalization, UI miss logging, English
event/ending/catalog fallback, locale money labels, and bundled glyph coverage.

`ja_translation_pipeline.py` defaults to UI-only generation. Event, ending, and
catalog scopes exit with `BODY_TRANSLATION_HELD` unless `--allow-body` is passed;
that flag may be used only after the explicit demo GO decision. The source-hash
cache lives under `.git` so generated drafts do not become release assets.

## Translation Wave Gate

Japanese infrastructure began after content freeze, but prose generation is
partially held because the playable demo is still being revised. The Japanese
UI dictionary remains a hidden beta and is not a shipping-language promise.
Once the user gives demo GO, the remaining wave requires:

1. A terminology and character-address sheet before bulk translation.
2. Strict event, choice, moral variant, and ending-DIK parity.
3. Zero Korean in target values.
4. Bundled deterministic fonts and 1280x800 layout captures.
5. Native-speaker spot checks of the opening, romance registers, money terms,
   the moral perception variants, and at least five endings.

The planned 15 Japanese scene captures and `--lang ja --strict` content gate
belong after that body wave. Passing the current UI/font gates alone must never
add `ja` to `SHIPPING_LANGUAGES` or Steam metadata.
