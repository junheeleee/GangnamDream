# Multilingual Infrastructure

Updated: 2026-08-25

## Status

Retail and the legacy V2 demo still expose only Korean and English through
`LocaleManager.SHIPPING_LANGUAGES`. ORDER-126 adds one deliberately narrow
exception: the staged M01-M06 story-demo namespace
`GangnamDream_StoryDemo_v1` exposes Korean, English, Japanese, Simplified
Chinese, and Traditional Chinese in its own first-run selector and StoryMode
language menu. It does not change the retail allowlist or Steam metadata.

| Code | Retail/V2 surface | ORDER-126 story-demo surface | Story-demo font |
|---|---|---|---|
| `ko` | Shipping source | Source | Pretendard |
| `en` | Shipping strict fallback | Source fallback | Pretendard |
| `ja` | Prepared beta, hidden | 11/11 events · 82/82 leaves · 117/117 UI · 1/1 catalog | Noto Sans JP |
| `zh-CN` | Prepared, hidden | 11/11 events · 82/82 leaves · 117/117 UI · 1/1 catalog | Noto Sans SC |
| `zh-TW` | Prepared, hidden | 11/11 events · 82/82 leaves · 117/117 UI · 1/1 catalog | Noto Sans TC |

The three target overlays are direct Korean-to-target translations. The two
Chinese bodies are independently authored rather than OpenCC-converted copies.
Their native-language release gates remain OPEN: the exact candidate may be
played in all five languages after package L1/L2, but Japanese and Chinese
Steam language claims remain blocked until their respective native reviewers
approve voice, meaning, and rendered context.

`LocaleManager.SHIPPING_LANGUAGES` remains the retail player-facing allowlist.
Adding a language to `SUPPORTED_LANGUAGES`, or exposing it only inside the exact
story-demo custom namespace, is not permission to add it to retail first-run or
Steam metadata.

## UI Contract

Unparameterized call sites continue to use `LocaleManager.ui(korean, english)`
or `_tr(korean, english)`. For a prepared language, the Korean source string is
used as the legacy lookup key in `locale/ui_<code>.json`:

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

Only the current 27 Korean keys whose call sites have genuinely different meanings use
the additional `LocaleManager.ui_context(context_id, korean, english)` API. The
29 reached context IDs remain flat top-level string keys in the same
`ui_<code>.json`; they are not gameplay IDs and do not introduce a second file
format. Korean and English return their supplied arguments byte-for-byte. A
prepared language resolves in this exact order:

1. community-pack context ID;
2. community-pack legacy Korean key;
3. built-in context ID;
4. built-in legacy Korean key;
5. the supplied English string.

Built-in and community dictionaries therefore remain separate caches. Merging
them before lookup would let a built-in context row incorrectly defeat an old
community pack's Korean-key override. When both context and legacy rows are
missing, the runtime records one deduplicated miss as `context:<id>` and returns
English. Refreshing community packs clears both provenance caches and all UI
misses. Existing community packs need no migration; a new pack may add context
IDs beside its existing Korean keys.

The ORDER-96 baseline source audit found 107 Korean keys whose then-current call
sites carried more than one English value. Thirty-four were formatting-only, 45
could share one target translation after an explicit semantic allowlist, and 28
required 30 stable context IDs across 37 call sites. At that revision the
historical inventory was `3,217 legacy + 37 context` calls and 2,730 legacy
Korean keys. The dated ORDER-96 audit evidence owns that exact historical
partition. The active manifest owns only the currently reached context rows,
including each surviving ID, Korean source, allowed English variants, owner
function, and call count; it does not rewrite the historical snapshot.

ORDER-97 adds a separate parameterized-template contract without reopening the
historical context meanings. Its migration revision measured `3,310 calls = 3,273 legacy +
37 context` and 2,780 unique legacy Korean keys. Later W1 and controller surfaces
and the later removal of three superseded context call sites changed the reached
inventory without changing the surviving meanings. The current measured inventory
is exactly `3,311 calls = 3,277 legacy + 34 context`, with 2,816 unique legacy
Korean keys and 29 reached context IDs. Japanese owns all
`2,816 legacy + 29 context = 2,845` rows; both Chinese skeletons remain
`legacy 0/2,816 + context 0/29`.

`LocaleManager.ui_format(ko_template, en_template, ko_args, en_args)` performs a
stable legacy-template lookup before inserting values. Korean and English each
validate and format their own template and argument list independently; their
arity may legitimately differ. A prepared-language hit must have the same
placeholder conversion kinds and order and the same newline count as the Korean
template, then formats with the target/Korean argument list. A miss formats the
English template with the explicit English argument list. Width and zero-padding
such as `%d` versus `%02d` may differ without changing the conversion kind.
Explicit positive-sign and precision modifiers are semantic and must match the
Korean template. An invalid percent sequence, wrong argument count or type,
reordered conversion, semantic-modifier drift, or newline drift fails closed
instead of returning a partially formatted or wrong-language string.

Nested values follow the same provenance boundary. Target arguments may contain
localized copy or locale-formatted money, while fallback arguments must be
produced explicitly in English; reusing a current-locale completed value on both
sides can produce an English parent with Japanese or Chinese content. The
collector locks exactly 15 raw-migration argument-provenance rows in addition to
the templates.

The current registry is `55 raw candidates = 47 migrated
lookup-before-format calls / 42 templates + 4 dynamic pair readers + 2
branch-selected literals + 2 locale money formatters`. Two pre-existing calls
were outside that raw-55 set because their template lookup order was already
correct: the Aruba status parent and GameState's year-choice quote. ORDER-97
separately split their target and English argument provenance. Runtime therefore
contains exactly 49 `ui_format` calls: the 47 raw migrations plus those two
supplemental existing calls. Registry validation rejects missing, extra,
duplicate, stale, or selector-partial path/function/template/signature/count rows
rather than adjusting the expected inventory.

The two exact whole-won owners remain
`CommitmentTask::_format_money` and `SeoulCycleBoard::_format_money`. They share
`LocaleManager.format_whole_won()` and are not template keys: the formatter keeps
whole-won digits, sign, and comma placement exact. `CommitmentTask` preserves its
signed English `KRW` prefix policy, while `SeoulCycleBoard` preserves its `won`
suffix; Japanese, Simplified Chinese, and Traditional Chinese emit `ウォン`,
`韩元`, and `韓元`. English fallback arguments that need the general
large-number formatter use an explicit English producer, never the active-locale
formatter.

Every locale UI file is also a raw JSON source contract. Object keys must be
unique in the file itself; accepting the last value returned by `json.load` does
not make a duplicate key valid. Generation and audit tooling must reject raw
duplicates before using effective dictionary counts. Japanese and Chinese body
work must build on this locked inventory rather than reopening either key
migration.

ORDER-126 does not claim the full retail UI denominator. Its separate
`story_demo_localization_audit.py` collector locks 35 unique controller keys,
81 unique StoryMode keys, their merged set, and the localized default name as
exactly 117 required UI keys. A story-demo translation can pass this narrow
surface while the same locale remains incomplete and hidden in retail.

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

## Public M01-M06 Story Demo Scope (ORDER-126)

The public story-demo translation unit follows only text reachable from
`StoryChoiceM1M6Playtest` and `StoryMode`; it does not inherit the retired
monthly action board's denominator.

- 11 Korean event IDs, 27 choices, and 82 translatable leaves cover both M01
  branches, both M04 entries and merge, M03-M05 character scenes, and the five
  reachable M06 choices.
- The shell owns 35 unique UI keys and StoryMode owns 81. After overlaps and the
  default player name, each target locale must provide exactly 117 UI values.
- Only `jobs.job_01.name` is a required catalog row. This slice has no ending
  overlay.
- Korean and English remain the source/fallback pair. Japanese, `zh-CN`, and
  `zh-TW` each own an 11-row `story_demo_events.json`, the 117 required UI rows,
  and that one catalog name.
- The localized surface contains StoryMode choices plus scene-local actions;
  `주력/함께/여력`, AP cards, and weekly/monthly planning copy are not part of
  this product or its translation denominator.
- The staged custom user-data name is the only authority to expose all five
  language choices. Retail, V2, and ORDER-124 continue to follow their existing
  language surfaces and saves.

`story_demo_localization_audit.py` checks structure, token/newline parity,
Hangul and English-fallback leakage, region script, won meaning, canonical
names, and required UI/catalog rows. `StoryDemoFourLanguageCheck.tscn` then
drives every locale through both M01 and M04 route shapes, M06, save/resume, and
zero AP surface. Those checks make a playable candidate; they do not judge
native prose quality.

## Legacy 24-Week V2 Demo Scope

This older, larger denominator remains the retail/V2 migration and eventual
full 24-week translation baseline. It is not the ORDER-126 public story-demo
scope. `tools/demo_localization_scope.py` follows every
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
locked 730 dynamic occurrences / 701 unique dynamic keys below.

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

- 72 visible events: 11 prologue, one Chapter 1 card, and 60 Week 1-24 events.
- 467 translatable event text leaves and zero endings. The Week-24 CTA is not a
  `finish_run` ending.
- 701 unique Korean lookup keys across 730 dynamic KO/EN pair occurrences,
  including the monthly planner, mandatory three-slide first-planner tutorial,
  opening cinematic, runtime event/name surfaces, portrait labels, the
  inventory-task contract, and every legal randomized
  convenience, delivery, resume, and interview surface. The randomized activity
  portion is 147 occurrences / 146 unique keys; the inventory task adds 32
  contract-pair occurrences. ORDER-93 adds exactly eight occurrences/keys:
  four player-facing Month-One decision verbs and four possible primary traces;
  ORDER-94 adds the 28 occurrences / 24 unique Seoul Cycle board labels above.
- Four asset names visible in the Week-21 market route.
- The 467 event leaves, 701 unique dynamic keys, and four asset names form 1,172
  unique demo translation sources in total. Repeated dynamic occurrences do not
  increase that source total.

`callback_escaped_dirty_trace` is a claimed receipt/source event whose visible
Week-24 foreground is `v2_dirty_trace_initial_call`; counting both would invent
a scene the player never reads. The scope manifest locks the source hashes and
the complete event-ID hash so a content change cannot silently leave the
translation plan stale.

The table below is the locked pre-ORDER-126 coverage snapshot for the legacy
24-week V2 denominator. It remains deliberately incomplete and does not count
the 117-key/11-event story-demo overlays above. Static UI is a separate claim
surface for any future 24-week or retail language claim: that broader product
cannot ship with its 2,816 required UI keys falling back to English even after
its event body is complete.

| Locale | Static UI | Events | Event text leaves | Dynamic keys | Demo catalog |
|---|---:|---:|---:|---:|---:|
| `ja` | legacy 2,816/2,816; context 29/29 | 1/72 | 8/467 | 9/701 | 0/4 |
| `zh-CN` | legacy 0/2,816; context 0/29 | 0/72 | 0/467 | 0/701 | 0/4 |
| `zh-TW` | legacy 0/2,816; context 0/29 | 0/72 | 0/467 | 0/701 | 0/4 |

Skeleton mode verifies this scope, existing rows, fallback paths, and the hidden
shipping state without pretending missing prose is complete. Per-language
`--strict` additionally requires 72/72 events, 467/467 leaves, 701/701 dynamic
keys, 4/4 catalog names, and zero direct English bypasses. It is expected to fail
until an approved body-translation wave is finished. Japanese has the required
terminology and source-shape validator now. `zh_translation_audit.py --strict`
adds 2,816/2,816 legacy UI keys and 29/29 context IDs, separate
Simplified/Traditional script and
terminology, Korean-won semantics, romanized-name locks, and a project-owned
regional font route. It cannot certify one region from the other region's text.
The narrow manifest-locked dynamic lookup routes currently report zero direct
English bypasses. A broader production-runtime scan separately reports 13
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

The project bundles `NotoSansJP-Variable.ttf`. When `ja` is active, `FontKit`
uses it as the primary font for the entire Japanese run—hiragana, katakana,
kanji, and Japanese punctuation—at exact `wght` values `400`, `600`, and `700`.
Weight-matched Pretendard follows for non-Japanese glyphs, and the bundled emoji
font is last. For `ko` and `en`, Pretendard remains primary and weight-matched
Noto Sans JP remains the next fallback. Locale changes mutate the shared role
resources in place so controls created before the change switch with the rest of
the UI.

This ordering is a correctness boundary, not an aesthetic preference.
Pretendard contains kana but does not contain the full Japanese kanji set, while
the bundled variable Noto source defaults to `wght=100`. Leaving Pretendard as
the Japanese primary therefore mixed Pretendard kana with Noto kanji and could
render the latter at Thin. `FontRoutingCheck.tscn` rejects that split by proving
the variable axis, the three exact weights, one Noto RID for representative
Japanese text, weight-matched KO/EN fallback, emoji-last ordering, runtime locale
switching, and zero direct product font loads. The font and its retained
`OFL-NotoSansJP.txt` came from the official Google Fonts Noto Sans JP
distribution.

SHA-256 locks:

- `NotoSansJP-Variable.ttf`: `c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f`
- `OFL-NotoSansJP.txt`: `babcfe66c8a098b2fa279bc724a3a342f8124f77ce18941fbcc1bbb39823cded`

ORDER-126 adopts the official Google Fonts variable TTFs
`NotoSansSC-Variable.ttf` and `NotoSansTC-Variable.ttf`. Simplified Chinese uses
SC as its primary; Traditional Chinese uses TC. Each active Chinese role uses
the exact variable weights `400`, `600`, and `700`, followed by weight-matched
Pretendard, Noto Sans JP, and the bundled emoji font. The regional primary
therefore wins before the JP shared-Han fallback, and an OS font is never the
primary evidence.

SHA-256 locks:

- `NotoSansSC-Variable.ttf`: `a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da`
- `NotoSansTC-Variable.ttf`: `864727d210d54f2537bbe23b3a839436c3992af72de9322af5270897246bd44f`
- `OFL-NotoSansSC.txt`: `1c05c68c34f9708415aada51f17e1b0092d2cea709bf4a94cd38114f9e73d7d9`
- `OFL-NotoSansTC.txt`: `1c05c68c34f9708415aada51f17e1b0092d2cea709bf4a94cd38114f9e73d7d9`

The adopted Noto Sans CJK JP/SC/TC family is distributed under SIL Open Font
License 1.1. The font files, retained license copies, full hashes, generated
notice data, and package copies are one release contract:

- <https://github.com/notofonts/noto-cjk>
- <https://github.com/googlefonts/noto-cjk/blob/main/Sans/LICENSE>
- <https://github.com/notofonts/noto-cjk/releases>

`FontRoutingCheck.tscn` requires the JA/SC/TC primaries, all three weights,
Pretendard and JP fallback ordering, emoji-last, and runtime locale switching.
This closes the deterministic font asset/routing gate for the macOS story-demo
candidate. It does not close translated-surface visual review on other target
platforms or any native-language release gate.

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
python3 tools/story_demo_localization_audit.py --self-test
python3 tools/story_demo_localization_audit.py
godot --headless res://tools/I18nInfrastructureCheck.tscn
STORY_DEMO_ALLOW_ISOLATED_QA=1 \
STORY_DEMO_QA_BOOTSTRAP_NAME=GangnamDream_StoryDemo_RuntimeQA_docs \
  godot --headless res://tools/StoryDemoFourLanguageCheck.tscn
godot --headless res://tools/ModLayerCheck.tscn
godot --rendering-driver opengl3 --resolution 1280x800 \
  res://tools/ScreenshotQA.tscn -- --qa=i18n-layout --lang=ja
```

The story-demo runtime pass must end with
`STORY_DEMO_FOUR_LANGUAGE_CHECK_OK locales=5 routes=4 months=30 weeks=120 settlements=30 ap_surface=0 save=5 story=5 build=2026.08.25.1`.
The 30 months and 120 weeks are the five locale runs combined; one player run
is still M01-M06, 24 weeks, and six settlements.

The default full-game coverage command keeps English strict and prepared locales
in skeleton mode. Its current strict collector scans all 1,758 packaged event
descriptions and 35 endings: 1,603 shipping events plus 155 author-only events.
That pass contains the 1,603-event shipping release claim but is not the same
denominator. `ja_translation_audit.py --scope ui` requires all 2,816 legacy
UI keys and all 29 reached context IDs. It also
requires exact placeholder/newline parity, zero Hangul or yen conversion,
canonical names and casino terms, and no lock/unlock polarity reversal. The
dated ORDER-96 ledger preserves the historical `34 + 45 + 28` partition; the two
current source collectors lock only the reached `29 + 44 + 27` partition and
29-ID/34-call registry. The
runtime check proves alias normalization, five-layer context lookup,
provenance-preserving community refresh, UI miss logging, English
event/ending/catalog fallback, locale money labels, and bundled glyph coverage.
The parameterized registry additionally locks the raw `55 = 47 + 4 + 2 + 2`
disposition, the two supplemental existing calls, 49 runtime `ui_format` calls,
the two exact-money owners, 15 argument-provenance rows, and raw duplicate-key
rejection.

`ja_translation_pipeline.py` defaults to UI-only generation. Its read-only
`--scope demo --inventory` proves that the future wave contains exactly 467 event
leaves, 701 dynamic keys, four catalog names, and no ending: 1,172 unique demo
translation sources in total. Demo generation exits
with `BODY_TRANSLATION_HELD` unless `--allow-body` is passed after the approved
24-week source text is declared final; it merges those rows without deleting
existing static UI or out-of-demo translations. Every full-body scope requires
the separate `--allow-full-body` gate and does not accept that demo-text freeze.
The event-bearing `events` and `all` scopes collect the complete 1,758-event
packaged corpus (1,603 shipping + 155 author-only); `endings` and `catalog`
collect only their own full targets.
The source-hash cache lives under `.git` so generated drafts do not become release
assets.

`zh_translation_audit.py` reads both regions from the Korean source independently.
Its normal mode reports the still-incomplete legacy denominator without
claiming completion; the SC/TC font routes are now present, while the separate
story-demo audit owns the narrow translated slice. Its region-specific strict
mode requires 2,816/2,816 legacy
UI keys and 29/29 context IDs, the exact 72/467/701/4 demo body (1,172 unique demo translation sources),
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
The remaining legacy/full strict failures are therefore release evidence, not
CI debt to hide; they do not contradict the separate narrow story-demo audit.
See
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

## Legacy 24-Week Translation Wave Gate

The 72-event/1,172-source Japanese wave for the older 24-week V2 denominator
remains held. ORDER-126's much smaller M01-M06 body is already authored as a
separate 11-event/82-leaf/117-UI candidate and must not be used to claim that
the legacy wave or full game is complete. The Japanese retail UI dictionary
remains a hidden beta and is not a shipping-language promise.
ORDER-97's L3 screen review is also still open: the user must select three actual
Batch A surfaces and three actual Batch B surfaces from the same candidate, and
one failure rejects the corresponding whole 23- or 24-call batch. Inventory,
template, or screenshot automation does not supply that evidence.
Once the approved 24-week source text is declared final, the remaining wave requires:

1. A terminology and character-address sheet before bulk translation.
2. Strict parity for all 72 demo events, choices, variants, dynamic strings, and
   the four visible catalog names; no demo ending is fabricated.
3. Zero Korean in target values.
4. Bundled deterministic fonts and 1280x800 layout captures.
5. A Japanese native reviewer directly comparing the Korean source and the same
   `demo_rc` at normal speed, plus replay of all legally reachable events and
   choices. Character voice, relationship distance, subtext, KRW weight,
   translationese, and causal meaning are human gates rather than key counts.

The ORDER-126 story-demo candidate, the legacy 24-week Japanese claim, and the
eventual full-game Japanese release claim are separate. Passing the narrow
candidate does not satisfy the legacy denominator or 1,603-event/35-ending
full-game coverage. Passing its structure/font gates must never add `ja` to
retail `SHIPPING_LANGUAGES` or Steam metadata. Native review remains OPEN and
blocks the Japanese shipping claim, while the exact five-language candidate may
still be played for evaluation after package L1/L2.

## Chinese Regional Wave Gate

ORDER-126 opens only the M01-M06 Chinese story-demo wave. `zh-CN` and `zh-TW`
now own separate 11-event/82-leaf/117-UI/1-catalog translations made directly
from Korean; OpenCC or another script conversion did not create the second
region. The larger legacy 24-week body remains held. Official character Hanja
must not be invented, so established romanized names remain locked until a
user/native decision updates the glossary and validator together.

For the narrow story demo, each region must pass the exact localization audit,
its dedicated SC/TC font route, all legal M01 and M04 branch shapes, M06,
save/resume, and rendered package checks. That makes the locale selectable in
the isolated candidate, not in retail.

Before either legacy 24-week Chinese claim, that region requires:

1. 2,816/2,816 legacy UI keys, 29/29 context IDs, and strict parity for all 72 demo events, 467 event
   leaves, 701 dynamic keys, and four catalog names: 1,172 unique demo translation
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
layout. Each OPEN gate blocks its regional Steam/shipping claim, but it does not
block local play of the exact ORDER-126 candidate after package L1/L2. A narrow
demo approval never authorizes the legacy 24-week denominator, the
1,603-event/35-ending full-game Chinese release, or a retail addition to
`SHIPPING_LANGUAGES` or Steam metadata.
