# Closed-Test Checklist — Chess Rescue

The runbook to take Chess Rescue from "builds locally" to a **Google Play closed test**.
Companion docs (don't duplicate — follow the links):
- `play-store-checklist.md` — master store-readiness + internal-testing checklist.
- `release-candidate-notes.md` — what's in this RC + verification results.
- `play-store-metadata-draft.md` — **finalized** listing copy (EN/TR/ES short + full).
- `brand-direction.md` — brand strategy + art direction.
- `store-assets-spec.md` — **production spec** for the icon (The Trajectory), feature graphic (FG-1), and the 6-screen screenshot system (headlines + composition).
- `privacy-policy.md` — privacy index + hosting plan; page now implemented in `lunexa-web` (source copy in its `seo/content.ts`; `privacy-policy-{en,tr,es}.md` are the drafts).
- `play-console-data-safety.md` — exact Data Safety + content-rating answers.
- `android-layout-qa.md` — on-device layout/QA matrix.

Track order on Play: **internal → closed → production.** Do an internal test first; this list
gets you cleanly to **closed**.

## Blocker gate (must clear before uploading to a public-facing track)

| # | Item | State | Owner |
|---|---|---|---|
| 1 | **Real launcher icon** (replace default Flutter logo) | ✅ **rendered + wired** — "The Trajectory" (`assets/app_icon/`, adaptive icon generated) | done (refine vector later, optional) |
| 2 | **Privacy-policy URL** | 🎨 **page implemented in `lunexa-web`** (mirrors RPS Duel → `https://uselunexa.com/privacy/chess-rescue`; source copy in its `seo/content.ts`) — deploy site + paste URL | deploy + paste URL (last hard blocker) |
| 3 | **Store listing** (title, short/full, EN/TR/ES) | ✅ **finalized + email/URL filled** (`play-store-metadata-draft.md`; support `hello@uselunexa.com`, privacy URL set) — paste as-is | paste into Console |
| 4 | **≥ 2 phone screenshots** (6-screen system) | 🎨 **harness ready** (`screenshot-capture.md` — deterministic, < 10 min) — capture + composite pending | capture on device |
| 5 | **Feature graphic** 1024×500 (FG-1) | 🎨 **v1 rendered** (`assets/store/feature-graphic-1024x500.png`, text-free) — add wordmark overlay | design-tool type pass |
| 6 | **Data Safety form** (none collected/shared) | ✅ **answers ready** (`play-console-data-safety.md`) | fill Console form |
| 7 | **Content rating** questionnaire (expect Everyone) | ✅ **answers ready** (`play-console-data-safety.md`) | fill Console form |
| — | Release signing + keystore | ✅ done | — |
| — | `versionCode`/`versionName` set (1 / 1.0.0) | ✅ done | — |
| — | Zero permissions / offline / no data | ✅ done | — |

### Replacing the launcher icon — ✅ DONE (Phase 28)
Icon "The Trajectory" is rendered by `tool/generate_store_assets.dart` and wired via
`flutter_launcher_icons` (config in `pubspec.yaml`). To re-render after a tweak:
`dart run tool/generate_store_assets.dart && dart run flutter_launcher_icons`. (Generic recipe
kept below for reference.)

### Generic icon recipe (reference)
1. Add a 1024×1024 source PNG (e.g. `assets/branding/icon.png`).
2. `dart pub add --dev flutter_launcher_icons` and add a `flutter_launcher_icons:` block
   (android true, `image_path`, optional `adaptive_icon_background`/`_foreground`).
3. `dart run flutter_launcher_icons` → regenerates `mipmap-*`; rebuild the AAB.
4. Also export a 512×512 PNG for the Play listing icon.

## Build & sign (mostly done — confirm)

1. Bump `versionCode` for **every** Play upload (`versioning-notes.md`). RC1 is `1` / `1.0.0`.
2. `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`.
3. Confirm it's the **release** signing config (it is, via `android/key.properties`).

## Play Console setup (one-time)

1. Create the app (Lunexa Games account); set default language, app/game type, free.
2. **Enroll in Play App Signing** (let Google manage the app signing key; you keep the upload key).
3. Complete **Data Safety** (answers in `play-store-metadata-draft.md`: nothing collected/shared).
4. Complete the **content rating** questionnaire (no violence/ads/UGC → Everyone).
5. Fill the **store listing** (title, short + full description, icon 512², feature graphic,
   screenshots) and the **privacy-policy URL**.

## Create the closed test

1. Testing → **Closed testing** → create a track (e.g. "alpha").
2. Add testers: an email list or a **Google Group** (recommended — easier to manage).
3. Upload the **AAB** to the track; add a short release note (what to try, known limits from
   `release-candidate-notes.md`).
4. Save → review → **roll out to closed testing**.
5. Share the **opt-in URL** with testers; each must accept the invite before installing.

## On-device smoke test (before rollout)

Run on ≥1 real device (ideally a 1080×2400 and a small 360dp profile). Execute the
**internal-testing checklist** in `play-store-checklist.md` (cold open, core loop, sequence,
persistence, debug-gating, crash-safety, haptics, 60fps, **release-artifact smoke test**) plus
the layout matrix in `android-layout-qa.md`. The replayability-specific check: complete a
session, tap **Again ↻** several times — sessions should feel fresh-but-curated (occasional
mirror/expansion/decoy/scenery), never random or cluttered; the first run must be the canonical
knight cold open.

## What to ask closed testers

- Did making the rescue move feel **satisfying / relieving**? (the core question)
- After "Again," did replays feel **fresh but still crafted** — or repetitive / random?
- Any **crashes, jank, or layout problems** on your device/orientation/text-size?
- Was the board **readable at a glance** (danger, what to do)?
- Feedback channel: `<email / form / Google Group thread>`.

## Do NOT yet

Promote to production, or submit for full review, until closed-test feedback is in and the
blocker gate is fully green.

## Final upload package (RC1) — exact values

The copy-paste sheet for the submission session. Verified **RC1, 2026-05-29**: `dart format` 0
changed · `flutter analyze` "No issues found!" · **76/76 tests pass** · release AAB built.

**Upload artifact**
- AAB: `build/app/outputs/bundle/release/app-release.aab` — **40.1 MB** (40,056,575 bytes)
- versionCode **1** / versionName **1.0.0** (first upload; bump versionCode ≥ 2 for any re-upload)
- Release-signed via `android/key.properties` (Play App Signing: let Google manage the app key)

**App identity**
- Title: `Chess Rescue` · Package: `com.lunexa.games.chessrescue`
- Developer / publisher: **Lunexa Games** · Category: **Games → Puzzle** (alt: Casual)
- Contains ads: **No** · In-app purchases: **No** · Permissions: **none** (offline)

**Store listing copy** (full text in `play-store-metadata-draft.md` — paste as-is)
- Short (EN, 65 chars): `One move saves the king. A calm, offline 90-second rescue ritual.`
- Short (TR): `Tek hamle şahı kurtarır. Sakin, çevrimdışı, 90 saniyelik bir kurtarış.`
- Short (ES): `Un movimiento salva al rey. Un ritual de rescate tranquilo y sin conexión.`
- Full (EN/TR/ES): see `play-store-metadata-draft.md`

**Privacy & contact**
- Privacy policy URL: `https://uselunexa.com/privacy/chess-rescue`
  (per-locale: `…/tr/privacy/chess-rescue`, `…/es/privacy/chess-rescue`)
- Support email: `hello@uselunexa.com`

**Data Safety** (`play-console-data-safety.md`): collects **No** data · shares **No** data ·
encryption-in-transit **N/A** (no network) · deletion request **N/A** (on-device only; clear via
system app-storage / uninstall) · permissions **none**.

**Content rating**: questionnaire answers all "no" → expect **Everyone / PEGI 3**.

**Graphics**
- App icon (Play 512²): `assets/store/play-icon-512.png` ✅
- Feature graphic 1024×500: `assets/store/feature-graphic-1024x500.png` ✅ (text-free v1; wordmark
  overlay is an optional polish pass)
- Phone screenshots: `assets/store/screenshots/` is **EMPTY** — capture **≥ 2** at 1080×2400 via the
  `screenshot-capture.md` harness before the listing can be published.

**Remaining true blockers before the listing can go live** (both manual, neither is code):
1. **Deploy** the privacy page in `lunexa-web` and confirm `https://uselunexa.com/privacy/chess-rescue`
   is publicly reachable (Play validates it on submission).
2. **Capture ≥ 2 phone screenshots** (harness ready).
