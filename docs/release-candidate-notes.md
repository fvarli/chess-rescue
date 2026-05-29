# Release-Candidate Notes — Chess Rescue 1.0.0 (RC1)

Snapshot of the first closed-test release candidate. See `closed-test-checklist.md` for the
go-to-test runbook, `release-build.md` for build/signing, `versioning-notes.md` for bumps.

## Build identity

| Field | Value |
|---|---|
| Version name | `1.0.0` |
| Version code | `1` (pubspec `1.0.0+1`) |
| applicationId | `com.lunexa.games.chessrescue` |
| App label | Chess Rescue |
| minSdk / targetSdk / compileSdk | 24 / 36 / 36 |
| Toolchain | Flutter 3.41.1 · Dart 3.11 · AGP 8.11.1 · Kotlin 2.2.20 · Gradle 8.14 · NDK 28.2.x · Java 17 |
| Release optimization | R8 `minifyEnabled` + `shrinkResources` + ProGuard rules |

## Signing

Release-signed with the **upload keystore** via `android/key.properties` →
`~/upload-keystores/chess_rescue_upload.jks` (user-owned, **git-ignored**, never committed).
The `release` build type uses the release signing config when `key.properties` is present
(it is), else falls back to debug. **Enroll in Play App Signing** on first upload.

## Artifact

- Path: `build/app/outputs/bundle/release/app-release.aab`
- Size: **39,963,349 bytes (~40 MB)** AAB. Note: this is the bundle, **not** the user download —
  Play generates per-device splits (ABI + density), so the actual install is materially
  smaller. (Future option if size matters: per-ABI APK splits / leaner assets.)

## Verification (2026-05-29, RC1)

- `dart format --set-exit-if-changed lib/ test/` → clean (35 files, 0 changed).
- `flutter analyze` → **No issues**.
- `flutter test` → **76/76 passed**.
- `flutter build appbundle --release` → built (above).
- **Manual on-device smoke test:** PENDING (user) — run `play-store-checklist.md` internal-test
  list + `android-layout-qa.md` device matrix on a real phone before promoting.

## What's in 1.0.0

- The full core loop (danger → select → commit → rescue/fail → retry) with D4 visual direction,
  tactile motion, and haptics.
- **Replayability stack** (Phases 19–24), canonical-anchored and audited:
  curated 5-puzzle sessions; **seed-0 onboarding locked** (identical first run); replay variety
  from mirror + expansion families + decoy texture + scenery texture; ≥3/5 canonical per
  session; clean opener/finale; 50/50 distinct sessions in the seed audit.
- Fully **offline**, **zero runtime permissions**, **no data collected** (local `shared_preferences`
  progress only).

## Known limitations (acceptable for a closed test; communicate to testers)

- ⚠️ **Launcher icon is still the default Flutter logo** — must be replaced before any public
  track (blocker for production; tolerable for an internal/closed test but should be fixed).
- No sound/music. No settings screen, no stats/streak UI (deliberate — see `product-vision.md`).
- Replay variety is **curated-finite** (5 rescue families × variations), not infinite — by design.
- Store assets (real icon, feature graphic, screenshots) and a hosted privacy-policy URL are not
  yet produced — see `closed-test-checklist.md`.

## Crash-risk audit

- **Storage init:** a failure degrades to a no-save mode rather than crashing (progress just
  doesn't persist). No required-permission paths that could deny.
- **No network / no plugins beyond `shared_preferences` + `cupertino_icons`** → no
  network-failure, auth, or SDK-init crash surface.
- **Release R8:** `minify`+`shrink` are on, so a **release-artifact smoke test is required** to
  confirm nothing was stripped (curated puzzle data is plain Dart const, low risk).
- **Debug-only affordances** (e.g. long-press SAVED reset, instance gallery) are gated out of
  release builds.
