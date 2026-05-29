# Closed-Test Checklist — Chess Rescue

The runbook to take Chess Rescue from "builds locally" to a **Google Play closed test**.
Companion docs (don't duplicate — follow the links):
- `play-store-checklist.md` — master store-readiness + internal-testing checklist.
- `release-candidate-notes.md` — what's in this RC + verification results.
- `play-store-metadata-draft.md` — listing copy / Data Safety answers.
- `brand-direction.md` — brand strategy + art direction.
- `store-assets-spec.md` — **production spec** for the icon (The Trajectory), feature graphic (FG-1), and the 6-screen screenshot system (headlines + composition).
- `privacy-policy.md` — hostable policy text.
- `android-layout-qa.md` — on-device layout/QA matrix.

Track order on Play: **internal → closed → production.** Do an internal test first; this list
gets you cleanly to **closed**.

## Blocker gate (must clear before uploading to a public-facing track)

| # | Item | State | Owner |
|---|---|---|---|
| 1 | **Real launcher icon** (replace default Flutter logo) | 🎨 spec ready (`store-assets-spec.md` §27A — "The Trajectory") — needs render | render + wire |
| 2 | **Privacy-policy URL** (host `privacy-policy.md`) | ❌ BLOCKER | host + paste URL |
| 3 | **Store listing** (title, short/full desc from metadata draft) | ⬜ todo | fill placeholders |
| 4 | **≥ 2 phone screenshots** (6-screen system) | 🎨 spec ready (`store-assets-spec.md` §27C) — needs capture | capture on device |
| 5 | **Feature graphic** 1024×500 (FG-1) | 🎨 spec ready (`store-assets-spec.md` §27B) — needs render | render |
| 6 | **Data Safety form** (none collected/shared) | ⬜ Console | use metadata draft |
| 7 | **Content rating** questionnaire (expect Everyone) | ⬜ Console | — |
| — | Release signing + keystore | ✅ done | — |
| — | `versionCode`/`versionName` set (1 / 1.0.0) | ✅ done | — |
| — | Zero permissions / offline / no data | ✅ done | — |

### Replacing the launcher icon (recipe for when art exists)
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
