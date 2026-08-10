# Multilingual Infrastructure

## Status

Korean and English are the only languages currently exposed by the development
build. The public demo target is Korean, English, Japanese, and Chinese, with
both Simplified and Traditional Chinese supported. Japanese and both Chinese
regions remain prepared targets, not selectable player options. Japanese UI is a machine-assisted beta with structural and semantic
gates; new story, ending, dynamic, and catalog prose remains held until the
approved 24-week source text is declared final. One existing Japanese prologue event is a
seed, not evidence that the demo body is translated. Simplified and Traditional
Chinese have separate source, script, money, font, and native-review contracts,
but their dictionaries and body overlays remain empty.

| Code | Status | UI dictionary | Event overlay | Ending overlay |
|---|---|---|---|---|
| `ko` | Shipping, source | Inline source | `content/events/` | `content/endings.json` |
| `en` | Shipping, strict | Inline fallback | `content/events_en/` | `content/endings_en.json` |
| `ja` | Prepared beta, hidden | 2,730/2,730 keys | 1/1,603 full; 1/73 demo | 0/35 full; 0 required by demo |
| `zh-CN` | Prepared, hidden; font blocked | 0/2,730 keys | 0/1,603 full; 0/73 demo | 0/35 full; 0 required by demo |
| `zh-TW` | Prepared, hidden; font blocked | 0/2,730 keys | 0/1,603 full; 0/73 demo | 0/35 full; 0 required by demo |

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

A source audit found 107 Korean keys whose current call sites carry more than
one English value. Thirty-four are formatting-only, 45 can share one target
translation after an explicit semantic allowlist, and 28 require 30 stable
context IDs across 37 call sites. That `LOC-0` migration is a translation
blocker, not part of the current 2,730-key legacy dictionary: it must preserve
all existing Korean keys, add the context-aware lookup and audit contract, and
finish before Japanese or Chinese body translation begins. No context API or
context-key translation is implemented yet.

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

ORDER-93 adds a fresh-start Month-One presentation without deleting the old
translation surface. Its four promise cards, primary/secondary labels, `0/2`
counter, one Start-Month action, three ownership tutorial pages, read-only record,
and four possible inline Week-Four primary traces are demo dynamic sources in
Korean and English and future source rows for Japanese, Simplified Chinese, and
Traditional Chinese. The old Month-One week/routine/review strings remain in
scope because committed/in-progress saves must still render them. Hiding a
control on the fresh path is not permission to delete its localization key.

ORDER-94 adds the fresh Seoul Cycle's month-specific board labels without
deleting those legacy surfaces. Its Month-One compatibility nodes plus Months
Two through Six contribute 28 dynamic pair occurrences and 24 unique Korean
keys. Every locale must distinguish the visible job, livelihood, people, and
recovery actions while preserving their deadlines and without translating
gameplay IDs or clock values into an overlay.

The final Seoul Cycle save-retry gate adds ten static UI pair-call occurrences
but only nine unique source keys because its retry button reuses an existing key.
Nine Japanese rows were added to keep the hidden UI beta complete. The final
manual-save failure gate then adds two more static calls sharing one new source
key and one Japanese row. These are static UI sources and do not change the
locked 686 dynamic occurrences / 657 unique dynamic keys below.

Every locale must preserve the ownership boundary in meaning, not merely token
shape:

- the four visible cards are promises Minjun can choose, and their order means
  primary/secondary rather than good/bad or success/failure;
- the tutorial may say that the world can interrupt, but it may not name Hyunsu,
  the unknown caller, or the Week-Four crisis before they arrive;
- `hyunsu_first_meet` is never translated as Minjun's appointment, self-note, or
  missed offer;
- each Week-Four bridge describes only the concrete trace of the actually
  completed primary promise and adds no moral judgment, forecast, stat, amount,
  or extra interaction;
- a missing-primary or legacy path uses the old scene text without inventing a
  generic trace.

The implementation-derived counts below include the new keys and all four trace
branches. The source manifest must lock these exact values; a count drop caused
by deleting legacy Month-One strings is a scope error rather than a documentation
adjustment.

- 73 visible events: 12 prologue, one Chapter 1 card, and 60 Week 1-24 events.
- 465 translatable event text leaves and zero endings. The Week-24 CTA is not a
  `finish_run` ending.
- 657 unique Korean lookup keys across 686 dynamic KO/EN pair occurrences,
  including the monthly planner, mandatory three-slide first-planner tutorial,
  opening cinematic, runtime event/name surfaces, portrait labels, the
  inventory-task contract, and every legal randomized
  convenience, delivery, resume, and interview surface. The randomized activity
  portion is 147 occurrences / 146 unique keys; the inventory task adds 32
  contract-pair occurrences. ORDER-93 adds exactly eight occurrences/keys:
  four player-facing Month-One decision verbs and four possible primary traces;
  ORDER-94 adds the 28 occurrences / 24 unique Seoul Cycle board labels above.
- Four asset names visible in the Week-21 market route.
- The 465 event leaves, 657 unique dynamic keys, and four asset names form 1,126
  unique demo translation sources in total. Repeated dynamic occurrences do not
  increase that source total.

`callback_escaped_dirty_trace` is a claimed receipt/source event whose visible
Week-24 foreground is `v2_dirty_trace_initial_call`; counting both would invent
a scene the player never reads. The scope manifest locks the source hashes and
the complete event-ID hash so a content change cannot silently leave the
translation plan stale.

Current prepared coverage is deliberately incomplete. Static UI is a separate
claim surface: a Chinese demo cannot ship with its 2,730 current UI keys falling
back to English even after the event body is complete.

| Locale | Static UI | Events | Event text leaves | Dynamic keys | Demo catalog |
|---|---:|---:|---:|---:|---:|
| `ja` | 2,730/2,730 | 1/73 | 8/465 | 9/657 | 0/4 |
| `zh-CN` | 0/2,730 | 0/73 | 0/465 | 0/657 | 0/4 |
| `zh-TW` | 0/2,730 | 0/73 | 0/465 | 0/657 | 0/4 |

Skeleton mode verifies this scope, existing rows, fallback paths, and the hidden
shipping state without pretending missing prose is complete. Per-language
`--strict` additionally requires 73/73 events, 465/465 leaves, 657/657 dynamic
keys, 4/4 catalog names, and zero direct English bypasses. It is expected to fail
until an approved body-translation wave is finished. Japanese has the required
terminology and source-shape validator now. `zh_translation_audit.py --strict`
adds 2,730/2,730 static UI keys, separate Simplified/Traditional script and
terminology, Korean-won semantics, romanized-name locks, and a project-owned
regional font route. It cannot certify one region from the other region's text.
The narrow manifest-locked dynamic lookup routes currently report zero direct
English bypasses. A broader production-runtime scan separately reports 14
legacy `is_english()` branches and an AUTO reading-rate route that omits both
Chinese locales; Chinese strict mode intentionally fails on those blockers.

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

Both Chinese font routes are blocked. `FontKit.ZH_CN_FONT_PATH` and
`FontKit.ZH_TW_FONT_PATH` are deliberately empty until a complete licensed bundle
is adopted. The current Japanese fallback may display many Traditional Chinese
and shared Han codepoints, but it is attached before emoji and can select Japanese
glyph forms. That incidental coverage is evidence for neither `zh-CN` nor
`zh-TW`. macOS can additionally hide missing glyphs by selecting an OS font,
which is not a deterministic Windows or Steam Deck result.

Approved candidate family: Noto Sans CJK JP/SC/TC, regular and semibold subsets
or language-specific TTFs. The official project distributes the family under
SIL Open Font License 1.1 and recommends TTF rather than CFF2 variable fonts on
Windows where corruption is still documented:

- <https://github.com/notofonts/noto-cjk>
- <https://github.com/googlefonts/noto-cjk/blob/main/Sans/LICENSE>
- <https://github.com/notofonts/noto-cjk/releases>

Before enabling a prepared language, bundle its region-specific font, attach it
ahead of JP for that active locale in `FontKit`, retain the OFL license and full
SHA-256 in distribution notices, and pass real translated-surface glyph/layout
checks on Windows, macOS, and Linux/Steam Deck. The blocked baseline is reported
as `primary=missing shared_han_jp_first=1`; readiness requires a real path,
`shared_han_jp_first=0`, and all required glyphs covered.

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
python3 tools/zh_translation_audit.py --lang all
python3 tools/zh_translation_audit.py --self-test
godot --headless res://tools/I18nInfrastructureCheck.tscn
godot --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=i18n-layout --lang=ja
```

The default full-game coverage command keeps English strict and prepared locales
in skeleton mode. `ja_translation_audit.py --scope ui` requires all 2,730 current
UI keys, exact placeholder/newline parity, zero Hangul or yen conversion,
canonical names and casino terms, and no lock/unlock polarity reversal. The
runtime check proves alias normalization, UI miss logging, English
event/ending/catalog fallback, locale money labels, and bundled glyph coverage.

`ja_translation_pipeline.py` defaults to UI-only generation. Its read-only
`--scope demo --inventory` proves that the future wave contains exactly 465 event
leaves, 657 dynamic keys, four catalog names, and no ending: 1,126 unique demo
translation sources in total. Demo generation exits
with `BODY_TRANSLATION_HELD` unless `--allow-body` is passed after the approved
24-week source text is declared final; it merges those rows without deleting
existing static UI or out-of-demo translations. Full `events`, `endings`,
`catalog`, and `all` scopes do not accept that demo-text freeze and require the
separate `--allow-full-body` gate.
The source-hash cache lives under `.git` so generated drafts do not become release
assets.

`zh_translation_audit.py` reads both regions from the Korean source independently.
Its normal mode reports the empty skeleton and both blocked font routes without
claiming completion. Its region-specific strict mode requires 2,730/2,730 static
UI keys, the exact 73/465/657/4 demo body (1,126 unique demo translation sources),
zero direct English bypasses, every
context-unambiguous wrong-region character in the pinned OpenCC 1.3.1 classifier
set (4,093 for `zh-CN`, 3,804 for `zh-TW`), project-locked regional terms,
Korean-won meaning, approved romanized names, and a deterministic project-owned
SC or TC font. The dictionary data is classification-only: the audit never
converts or rewrites either translation. Identity/overlap entries such as
context-dependent `后`, `干`, `台`, `里`, and `系` are deliberately excluded from
the character ban; phrase rules cover locked usages and the same-revision native
review must judge every remaining context. Both regions reject CJK compatibility
ideographs and Han variation-selector sequences instead of silently normalizing
them, so a visually similar noncanonical encoding cannot bypass the classifier.
The current strict failures are
therefore release evidence, not CI debt to hide. See
[`I18N_GLOSSARY_ZH.md`](I18N_GLOSSARY_ZH.md).
Numeric validation normalizes Korean-won values, signs, dates, times, durations,
counts, ordinals, ticket identifiers, native-Korean counters, and corresponding
Chinese numerals. Calendar months, month durations, ordinal units, and the demo's
sheet/building/vehicle/cup/line/pair classifiers remain distinct; colloquial
`월 220`, `즉시 200`, and `보증금 천에 월 오십오` are normalized as implicit
ten-thousand-won amounts. The check is source-driven so normal Latin/Chinese
spacing, natural singular classifiers, and idioms such as `一点` are not mistaken
for invented names or gameplay quantities. Same-revision native review remains
the semantic and context-dependent script backstop. The pinned classifier carries
its source revision, input hashes, derivation rule, and Apache-2.0 copy under
[`tools/data`](../tools/data/opencc_script_variants_1_3_1.json).

## Translation Wave Gate

Japanese infrastructure began after content freeze, but prose generation is
held because the playable demo is still being revised. The Japanese
UI dictionary remains a hidden beta and is not a shipping-language promise.
Once the approved 24-week source text is declared final, the remaining wave requires:

1. A terminology and character-address sheet before bulk translation.
2. Strict parity for all 73 demo events, choices, variants, dynamic strings, and
   the four visible catalog names; no demo ending is fabricated.
3. Zero Korean in target values.
4. Bundled deterministic fonts and 1280x800 layout captures.
5. A Japanese native reviewer directly comparing the Korean source and the same
   `demo_rc` at normal speed, plus replay of all legally reachable events and
   choices. Character voice, relationship distance, subtext, KRW weight,
   translationese, and causal meaning are human gates rather than key counts.

The Japanese demo claim and the eventual full-game Japanese release claim are
separate. Passing the demo gate does not satisfy 1,603-event/35-ending full-game
coverage. Passing the current UI/font gates alone must never add `ja` to
`SHIPPING_LANGUAGES` or Steam metadata. The Japanese demo gate also blocks the
combined four-language public demo, while Korean/English development candidates
may still be tested before translation is complete.

## Chinese Regional Wave Gate

Chinese prose and UI generation remain held. When the user explicitly opens a
Chinese demo translation wave, `zh-CN` and `zh-TW` must be translated from Korean
as two independent bodies; OpenCC or another script conversion cannot create the
second region. Official character Hanja must not be invented, so established
romanized names remain locked until a user/native decision updates the glossary
and validator together.

Before either Chinese demo claim, that region requires:

1. 2,730/2,730 static UI keys and strict parity for all 73 demo events, 465 event
   leaves, 657 dynamic keys, and four catalog names: 1,126 unique demo translation
   sources in total; no ending is fabricated.
2. Zero Hangul, kana, untranslated English prose, direct English bypass, wrong-
   region script, currency conversion, or placeholder/paragraph drift.
3. Korean won preserved as `韩元` with `万/亿` for `zh-CN`, and `韓元` with
   `萬/億` for `zh-TW`.
4. A project-owned SC or TC font that wins before JP shared-Han fallback and has
   complete license, hash, package notice, and target-platform evidence.
5. A Mainland Chinese native reviewer for `zh-CN` and a Taiwan native reviewer
   for `zh-TW`, each directly comparing Korean against the same `demo_rc` at
   normal speed and replaying every legal event and choice.

Those reviewers judge voice, relationship distance, subtext, aftertaste, Korean
cultural explanation, KRW weight, causal meaning, regional glyph forms, and real
layout. Each gate blocks its regional claim and the combined four-language demo
release. Korean/English development candidates may still be tested before
translation is complete, but the public demo cannot ship until Japanese,
Simplified Chinese, and Traditional Chinese claims all pass. A demo approval
never authorizes the 1,603-event/35-ending full-game Chinese release or adds a
language to `SHIPPING_LANGUAGES` or Steam metadata before the prepared release
wiring is complete.
