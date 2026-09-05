# Android Device Workflow

How Chess Rescue is developed and tested on a physical Android phone. This is a **local development
convention, not product architecture** — nothing here affects the shipped app.

See `release-build.md` for build/signing, `versioning-notes.md` for version bumps,
`play-store-checklist.md` for the on-device test list.

## 1. Application identities

| Build | Application ID | Launcher label |
|---|---|---|
| **release** (Google Play) | `com.lunexa.games.chessrescue` | Chess Rescue |
| **debug** | `com.lunexa.games.chessrescue.dev` | Chess Rescue Dev |
| **profile** | `com.lunexa.games.chessrescue.dev` | Chess Rescue Dev |

Debug/profile and release use **different application identities by design**. The local build is a
separate package, so it installs *beside* the Google Play build instead of replacing or deleting it,
and the two are distinguishable on the phone by their launcher labels.

Why this exists: a debug APK is signed with the local debug key. Under the production application ID
it collides with the Play-signed install, `adb install` fails with
`INSTALL_FAILED_UPDATE_INCOMPATIBLE`, and `flutter_tools` responds by uninstalling the existing app
and retrying (`android_device.dart` → `installApp` → `uninstallApp` → `adb uninstall`, no `-k`).
That would take the Play build's data directory with it — completed ids, lifetime count, unlocked
records and dates, signatures, recently-solved ring, episode seeds. **The suffix is load-bearing;
do not remove it as cleanup.**

Configured in `android/app/build.gradle.kts` via `applicationIdSuffix` on the `debug` and `profile`
buildTypes, with the labels overridden in `android/app/src/{debug,profile}/AndroidManifest.xml`.
`profile` declares the suffix **explicitly** rather than inheriting it: the Flutter Gradle plugin
creates that buildType with `initWith(getByName("debug"))` while the plugin is applied, before the
`buildTypes` block is evaluated — verified, without the explicit declaration
`flutter build apk --profile` produces the production application ID.

`namespace` stays `com.lunexa.games.chessrescue`, so `MainActivity.kt` and the generated
`R`/`BuildConfig` classes are unaffected.

## 2. Connecting the device

Use **Android 11+ Developer Options → Wireless debugging** with paired ADB. Do not use legacy
`adb tcpip 5555` unless there is a documented compatibility reason.

Discover the current transport — never assume or reuse a previous address:

```sh
adb devices -l
adb mdns services   # optional; an already-connected device is not re-advertised
```

Pair only when the phone asks for it. The pairing code is entered interactively by the developer and
is **never** written into repository files, logs, or chat transcripts:

```sh
adb pair <host>:<pairing-port>
adb connect <host>:<connect-port>
```

Never hardcode or commit IP addresses, ports, device serials, or pairing codes. They are transient —
the wireless port changes whenever Wireless debugging is toggled or the phone reconnects.

This machine also exposes `linux` and `chrome` targets, so **always name the device explicitly**:

```sh
adb -s <device> …
flutter run -d <device>
```

## 3. Normal iteration

```sh
flutter run -d <wireless-device>     # then: r = hot reload, R = hot restart
flutter run --profile -d <wireless-device>   # performance review (DevTools overlay)
```

Profile mode is safe here because it is isolated under `com.lunexa.games.chessrescue.dev`.

Do **not** repeatedly run `flutter build apk` and install by hand for ordinary UI, painter, or
layout iteration — that is what hot reload is for.

## 4. Protecting the Google Play install

Never uninstall, downgrade, clear, overwrite, or otherwise disturb `com.lunexa.games.chessrescue`
merely to enable local development. No `adb uninstall`, no `pm clear` against that package.

> **If `flutter run` ever prints `Uninstalling old version...`, stop immediately** and investigate the
> package identity before continuing. That line means the debug build is claiming the production
> application ID and the isolation has regressed.

A signature mismatch is fixed by correcting the debug identity — never by uninstalling the Play build.

## 5. What to test where

**Fine on the `.dev` build with hot reload:** piece painter geometry (knight profile, queen crown
spread, rook notches, light/dark contrast, carved/matte material impression), board materials,
HUD and layout, Home / Episodes / Endless / Records / Signatures UI, typography and theme tokens,
localization copy, Semantics labels, animation and motion tuning.

**Needs hot restart (`R`) rather than hot reload:** `main.dart` bootstrap, `GameController`
construction and wiring, `ProgressStore` initialization, startup and session-composition behavior,
and motion values captured during controller or widget construction.

**Cannot use hot reload or hot restart — needs a real lifecycle and the production identity:**

| Test | Why |
|---|---|
| Play upgrade 1.1.1+5 → 1.2.0+6 | Requires the production package and the real prior install |
| Production persistence / existing-user data | The `.dev` install has no production data |
| Release signing | Debug/profile use the debug key |
| R8 / minification / resource shrinking | Release-only |
| True cold start, process death | Hot restart is not a process restart |
| Clean-install first-run (intro overlay, seed-0 verbatim order) | Needs a genuine fresh install |
| Play delivery, final release artifact verification | Play Console and the release AAB |

**Chess Rescue Dev is the iteration environment. Chess Rescue from Google Play is the
production/reference environment.** Keep the two straight when reporting results.

The `.dev` install has its own empty package-scoped persistence — `shared_preferences` is scoped per
application ID, so it starts with no progress and shares nothing with production. It therefore
**cannot** validate production migration or existing-user upgrade behavior.

## 6. Troubleshooting

A dropped connection is a **tooling/environment issue first**, not an app defect. Before suspecting
the app:

- Re-check `adb devices -l`.
- Confirm the phone is on the same network and Wireless debugging is still enabled.
- Expect the advertised port to have changed after a toggle or reconnect; re-discover, don't reuse.

Do not classify transport loss as an application defect without evidence.

No `adb reverse`, tunnels, or port mappings are needed — Chess Rescue is fully offline with no
backend and no localhost dependency.
