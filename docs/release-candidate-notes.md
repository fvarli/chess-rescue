# Release-Candidate Notes — Chess Rescue 1.2.0 (+6)

Snapshot of the current release candidate. See `release-notes-1.2.0.md` for what shipped,
`closed-test-checklist.md` for the go-to-test runbook, `release-build.md` for build/signing,
`versioning-notes.md` for bumps.

> Supersedes the previous 1.0.0 (RC1) snapshot from 2026-05-29. That snapshot went stale by five
> build revisions and still listed the launcher icon as an open blocker long after it shipped.

## Build identity

| Field | Value |
|---|---|
| Version name | `1.2.0` |
| Version code | `6` (pubspec `1.2.0+6`) |
| Previous release | `1.1.1+5` (`1b4dd44`, 2026-06-06) |
| Commits since previous release | 19 (`4115c61` … `70a8234`) |
| applicationId | `com.lunexa.games.chessrescue` |
| App label | Chess Rescue |
| minSdk / targetSdk / compileSdk | 24 / 36 / 36 |
| Toolchain | Flutter 3.41.1 · Dart 3.11.0 · Java 17 |
| Release optimization | R8 `minifyEnabled` + `shrinkResources` + ProGuard rules |

## Signing

Release-signed with the **upload keystore** via `android/key.properties` → user-owned `.jks`
outside the repo (**git-ignored**, never committed — confirmed absent from `git ls-files`).
The `release` build type uses the release signing config when `key.properties` is present
(it is), else falls back to debug.

Verified on this artifact:

| Field | Value |
|---|---|
| Owner / Issuer | `CN=Lunexa Games, OU=Mobile Games, O=Lunexa, L=Istanbul, ST=Istanbul, C=TR` |
| Key alias | `chess_rescue_upload` |
| Valid until | 2053-10-13 |
| Algorithm | SHA384withRSA, 2048-bit RSA |
| SHA-256 | `77:40:63:16:B2:AE:74:84:F3:91:95:4B:38:8D:EC:2D:40:48:95:16:1A:57:40:FA:C0:66:1C:3F:33:90:85:E4` |

Confirmed **not** the debug fallback key.

## Artifact

- Path: `build/app/outputs/bundle/release/app-release.aab`
- Size: **41,978,338 bytes (42.0 MB)** AAB — up ~2 MB from 1.0.0's ~40 MB. This is the bundle,
  **not** the user download; Play generates per-device splits (ABI + density), so the actual
  install is materially smaller. (Future option if size matters: per-ABI APK splits.)
- `MaterialIcons-Regular.otf` tree-shaken 1,645,184 → 3,492 bytes (99.8% reduction).
- No new dependencies or bundled assets since 1.1.1; the piece redesign added **0 bytes**
  (pure `CustomPainter` geometry).

## Verification (2026-08-29, v1.2.0)

- `dart format --output=none --set-exit-if-changed lib test` → **clean** (139 files, 0 changed).
- `flutter analyze` → **No issues found**.
- `flutter test --concurrency=1` → **620/620 passed** (66 test files, 0 skipped).
- `flutter build appbundle --release` → built (above), upload-key signed.
- **Manual on-device smoke test:** PENDING (user) — run the internal-test list in
  `play-store-checklist.md` + the `android-layout-qa.md` device matrix on a real phone before
  promoting. This is the **first artifact ever to contain the PR-16 piece redesign**, so the
  piece-premium judgment on that list is the load-bearing item.

## What's in 1.2.0

See `release-notes-1.2.0.md` for the full breakdown. In short: the Threshold visual foundation
and premium board materials; the cinematic rescue arrow; the editorial Home and HUD; the
single-silhouette premium piece redesign (PR-14 + PR-16); motion and selection-continuity
polish; the screen-reader accessibility pass (PR-15); the quiet daily-ritual acknowledgment;
latest-milestone recognition; and **Episode 6 — Pin the Threat** (5 new canonical pin-defense
positions).

Current content roster: **6 episodes**, **16 hand-authored positions** (14 wired into episodes),
**14 rescue records**, **3 locales** (en/tr/es) at 220 keys each with parity enforced by test.

## Known limitations (acceptable for a closed test; communicate to testers)

- No sound or music. No settings screen beyond the language picker (deliberate — see
  `product-vision.md`).
- Replay variety is **curated-finite** (rescue families × mirror/decoy/scenery variation), not
  infinite — by design.
- `cc2-bishop-captures-shield` and `cam1-knight-takes-bishop` are authored and validated but not
  wired into any episode; they surface only through the endless composer pool.
- Accessibility labels cover the core surfaces; the Signatures collection, completion sheet, and
  record-unlock overlay are not yet labeled.
- Store screenshots predate the 1.2.0 visuals — accurate as to flow and copy, but they do not
  show the new board materials or piece treatment. Re-capture after the on-device pass.

## Crash-risk audit

- **Storage init:** a failure degrades to a no-save mode rather than crashing (progress just
  doesn't persist). No required-permission paths that could deny.
- **No network / no plugins beyond `shared_preferences` + `cupertino_icons`** → no
  network-failure, auth, or SDK-init crash surface.
- **Release R8:** `minify` + `shrink` are on, so a **release-artifact smoke test is required** to
  confirm nothing was stripped (puzzle data is plain Dart const, low risk).
- **Debug-only affordances** (long-press SAVED reset, instance gallery, screenshot harness) are
  gated out of release builds — the debug entrypoints are separate `main()` files never imported
  by `lib/main.dart`.

## Promotion blockers

1. **On-device smoke test** — not yet run against this artifact.
2. **Tester count: 10 installed vs 12 required** for 14 continuous days. Two short, and the
   14-day clock does not meaningfully advance while testers are on a two-month-old build.
