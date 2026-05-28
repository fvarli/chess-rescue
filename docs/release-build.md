# Release Build

How to produce signed, store-ready Android artifacts for Chess Rescue.

- **applicationId:** `com.lunexa.games.chessrescue` (permanent Play identity — do not change after first release)
- **Display name:** Chess Rescue
- **Publisher namespace:** Lunexa Games
- **SDK (via `flutter.*`):** minSdk 24 · targetSdk 36 · compileSdk 36
- **Permissions:** none (fully offline)

## 1. Signing (one-time, user-owned)

Release builds are signed from `android/key.properties`, which is **git-ignored** (`.gitignore`). Until it exists, release builds fall back to the debug key (so dev `--release` works but the artifact is **not** uploadable to Play).

Create an upload keystore:
```bash
keytool -genkey -v -keystore ~/chess-rescue-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Then create `android/key.properties` (never commit it):
```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=upload
storeFile=/absolute/path/to/chess-rescue-upload.jks
```
Recommended: enroll in **Play App Signing** — you upload with this *upload key*; Google manages the final app-signing key. Keep the keystore + passwords backed up securely; losing them blocks future updates.

## 2. Build commands

| Goal | Command | Output |
|------|---------|--------|
| **Play upload** (recommended) | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| Direct-install, per-ABI | `flutter build apk --release --split-per-abi` | per-ABI APKs in `build/app/outputs/flutter-apk/` |
| Direct-install, single fat APK | `flutter build apk --release` | `app-release.apk` (all ABIs) |

The **AAB** is what goes to Play — Google generates per-device APKs from it, so end-user downloads are a fraction of the AAB size. Use split-per-abi only for sideloading/direct distribution.

## 3. Size / R8

Release builds enable R8 code shrinking + resource shrinking (`isMinifyEnabled` / `isShrinkResources` in `android/app/build.gradle.kts`) and tree-shake icon fonts automatically. The Flutter Gradle plugin contributes the required keep rules; `android/app/proguard-rules.pro` is a placeholder for any app-specific rules. **Always smoke-test a release build on a device** after dependency changes (R8 can rarely strip something needed).

Current sizes: fat release APK ≈ 44MB; AAB ≈ 40MB (per-device download materially smaller).

## 4. App icon (release blocker — needs art)

The launcher icon is still the Flutter default. Before shipping, generate real icons:
1. Add a dev dependency: `flutter_launcher_icons`.
2. Provide a 1024×1024 source PNG (e.g. `assets/icon/icon.png`).
3. Configure it in `pubspec.yaml` and run `dart run flutter_launcher_icons`.

Not done here (no source art). The dark launch background (`#0D0E12`, no white flash) and the "Chess Rescue" label are already set.

## 5. Versioning

See `docs/versioning-notes.md`. Bump `version:` in `pubspec.yaml` before each Play upload (the `+n` build number must strictly increase).
