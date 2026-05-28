# Versioning

A single source of truth: the `version:` line in `pubspec.yaml`.

```
version: 1.0.0+1
         ^^^^^ ^
         |     └── build number  → Android versionCode
         └──────── semantic name → Android versionName
```

Flutter maps `x.y.z+n` to `versionName = x.y.z` and `versionCode = n` (via `flutter.versionName` / `flutter.versionCode` in `android/app/build.gradle.kts` — do not hardcode them there).

## Rules

- **`versionCode` (`+n`) must strictly increase** on every artifact uploaded to Play, even for the same `x.y.z`. Play rejects a re-used or lower code.
- **`versionName` (`x.y.z`)** is the user-visible version; bump per semantic meaning:
  - `z` (patch): bug fixes / content tweaks, no new mechanics.
  - `y` (minor): additive changes (e.g. more puzzles) that keep the shell.
  - `x` (major): a substantial product shift.
- Bump in **one place** (`pubspec.yaml`) — never edit `versionCode`/`versionName` in Gradle.

## Cadence example

| Upload | pubspec | versionName | versionCode |
|--------|---------|-------------|-------------|
| First internal test | `1.0.0+1` | 1.0.0 | 1 |
| Fix found in testing | `1.0.0+2` | 1.0.0 | 2 |
| Production launch | `1.0.0+3` | 1.0.0 | 3 |
| Add puzzles later | `1.1.0+4` | 1.1.0 | 4 |

Current: **`1.0.0+1`**.
