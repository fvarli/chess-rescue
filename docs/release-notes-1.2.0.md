# Release Notes — Chess Rescue 1.2.0 (+6)

The visual-identity release. Everything below was developed between 2026-06-07 and
2026-06-27 and sat unreleased until this build: `1.1.1+5` was the last version bump
(`1b4dd44`, 2026-06-06), and **19 feature commits landed on top of it without a release
artifact**. Closed-test testers on `1.1.1+5` have seen none of it.

See `release-build.md` for build/signing, `versioning-notes.md` for bumps,
`closed-test-checklist.md` for the go-to-test runbook.

## Build identity

| Field | Value |
|---|---|
| Version name | `1.2.0` |
| Version code | `6` (pubspec `1.2.0+6`) |
| Previous release | `1.1.1+5` (`1b4dd44`, 2026-06-06) |
| Commits since previous release | 19 (`4115c61` … `70a8234`) |

## What's new

### Visual identity — the Threshold foundation

- **Threshold design system** (`4115c61`, `820ee71`): unified token layer for color,
  typography, and premium piece materials.
- **Board materials + coordinate system** (`0bd354d`): tiled grain overlay (~3% effective
  opacity) and a real coordinate frame, replacing the flat prototype board.
- **Cinematic rescue arrow + ambient presence** (`7777055`): the post-rescue confirmation
  draws in, holds, then settles to a fraction of peak rather than holding at full strength.
- **Editorial Home** (`b7fd660`): Home rebuilt as a calm daily-rescue surface — hero CTA and
  essential nav, secondary density removed.
- **Calm victory flow** (`1531859`) and **editorial gameplay HUD** (`7009274`).

### Piece identity — the premium overhaul

- **Optical-scale body stroke + small-size sharpening** (`cf16be8`, "PR-14"): stroke width now
  scales with rendered size (1.15px at ≥48px → ~1.27px at 32px); knight, queen, bishop, and
  rook silhouettes retuned for recognition on small boards.
- **Single-silhouette piece family** (`0638c21`, "PR-16"): every piece is now **one** primary
  path (single fill + single stroke) plus at most two internal detail strokes, replacing the
  previous 4–7 separately filled-and-stroked sub-paths whose outlines fought at every seam.
  Base, foot, and rim collapsed into one shared beveled platform. Material de-glossed —
  gradient lerp factors halved, top sheen shrunk 28×10 → 22×6 at α×0.55 — reading as carved
  matte rather than glazed ceramic. Lift-shadow and optical-scale stroke both preserved.
  **APK delta: 0 bytes** (no new assets or dependencies; SVG migration was evaluated and
  rejected).

### Motion and tactility

- Refined rescue animation curves (`a9e6f85`), softened tap-model piece feel (`6248ed4`),
  subtle selection focus hierarchy (`ad299ea`), release settle + arrival memory (`888885e`),
  and selection continuity across the board (`966a6ad`, `87cdbd9`).

### Content

- **Episode 6 — Pin the Threat** (`70a8234`): 5 new canonical pin-defense positions, the
  strongest previously-uncovered classical motif. Unlocks in parallel with Episodes 4 and 5
  after Episode 3. Brings the roster to **6 episodes / 16 hand-authored positions** (14 wired
  into episodes) and the record library to **14**.

### Progression and ritual

- **Daily ritual acknowledgment** (`a5ea46d`): a single quiet line on Home when you have
  already rescued today. Derived from the existing recently-solved ring — no new storage, no
  streak counter, no gamification.
- **Latest-milestone recognition** (`2b6a85e`): the most recent unlocked record surfaces on
  Home with its unlock date, tapping through to the Records journal.

### Accessibility

- **Screen-reader pass** (`110f82a`, "PR-15"): board squares now carry per-square semantic
  labels (`e4, light knight`), with the piece-rendering layer excluded so screen readers get
  one clean announcement per square instead of duplicates. Home CTA, episode cards, records
  and milestone lines, the Records/Signatures tab toggle, the footer button, and the intro CTA
  are all labeled. Small-device, locale, and text-scale robustness is covered by tests.
  **No visible tap-target sizes changed** — labels only.

## Verification (2026-08-29)

- `dart format --output=none --set-exit-if-changed lib test` → **clean** (139 files, 0 changed).
- `flutter analyze` → **No issues found**.
- `flutter test --concurrency=1` → **620/620 passed** (66 test files).
- `flutter build appbundle --release` → built, upload-key signed (see below).
- **Manual on-device smoke test: PENDING (user).** Required before promoting. This build is the
  first artifact ever to contain the PR-16 piece redesign, so the on-device pass should
  specifically judge whether the pieces read as premium at real board scale — that judgment is
  the input to the next PR.

## Artifact

- Path: `build/app/outputs/bundle/release/app-release.aab`
- Size: **41,978,338 bytes (42.0 MB)** AAB — up from ~40 MB at 1.0.0. This is the bundle, **not**
  the user download; Play generates per-device splits (ABI + density), so the actual install is
  materially smaller.
- Signed with the **upload keystore** via `android/key.properties`
  (alias `chess_rescue_upload`) — verified `CN=Lunexa Games, O=Lunexa, C=TR`, SHA-256
  `77:40:63:16:B2:AE:74:84:F3:91:95:4B:38:8D:EC:2D:40:48:95:16:1A:57:40:FA:C0:66:1C:3F:33:90:85:E4`.
  **Not** the debug fallback.
- `MaterialIcons-Regular.otf` tree-shaken 1,645,184 → 3,492 bytes (99.8%).

## Unchanged in this release

Still fully **offline**, **zero runtime permissions**, **no data collected** (local
`shared_preferences` only — 17 `cr_*` keys). No ads, no IAP, no analytics, no network. No new
dependencies were added; the 19 packages reported as outdated are constraint-pinned
deliberately and were not upgraded.

## Known limitations (communicate to testers)

- No sound or music. No settings screen beyond the language picker (deliberate — see
  `product-vision.md`).
- Replay variety is **curated-finite** (rescue families × mirror/decoy/scenery variation), not
  infinite — by design.
- `cc2-bishop-captures-shield` and `cam1-knight-takes-bishop` are authored and validated but
  not wired into any episode; they appear only via the endless composer pool.
- Accessibility labels cover the core surfaces; the Signatures collection, completion sheet,
  and record-unlock overlay are not yet labeled.

## Closed-test status

Installed audience is **10**. This account's Play Console requires **12** opted-in testers for
**14 continuous days** before production promotion — **2 short**, and the 14-day clock does not
meaningfully advance on a two-month-old build. Recruiting testers and shipping this artifact are
the two gating actions for production.
