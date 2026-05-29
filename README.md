# Chess Rescue

A mobile-first **emotional comeback puzzle game** built on chess rules — *not* a chess
trainer. Every puzzle starts in visible danger; you look for the one move that rescues the
king. Find it and the board answers with a quiet breath of relief; miss it and it resets,
calmly, without shame. Fully offline, no accounts, no ads, no tracking.

> Chess is the medium. Relief is the product. — see `docs/product-vision.md`.

## Develop

```sh
flutter pub get
flutter run                 # debug on a connected device/emulator
flutter test                # unit/widget tests
flutter analyze             # static analysis
dart format lib/ test/      # formatting
```

Debug-only puzzle/variation gallery (separate entrypoint, tree-shaken from release):

```sh
flutter run -t lib/debug/instance_gallery.dart -d linux
```

## Release (Android)

```sh
flutter build appbundle --release   # → build/app/outputs/bundle/release/app-release.aab
```

Signing, versioning, and store steps live in `docs/`:
- `release-build.md` — build & signing.
- `versioning-notes.md` — version bumps.
- `release-candidate-notes.md` — current RC snapshot.
- `closed-test-checklist.md` / `play-store-checklist.md` — Play readiness.
- `play-store-metadata-draft.md`, `privacy-policy.md` — listing assets.

## Docs

Design and architecture notes are in `docs/` — start with `product-vision.md`,
`visual-direction.md`, `interaction-language.md`, then `replayability-architecture.md` and
`rescue-archetypes.md`.
