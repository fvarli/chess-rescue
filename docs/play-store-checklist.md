# Play Store Checklist

Submission readiness for Chess Rescue. See `release-build.md` for build/signing
and `versioning-notes.md` for version bumps.

## App identity

- [x] applicationId `com.lunexa.games.chessrescue` (permanent)
- [x] Display name "Chess Rescue"
- [ ] Publisher: Lunexa Games (Play Console account)
- [ ] Launcher icon (real art — see release-build.md §4; **blocker**)
- [x] Dark launch background (no white flash)

## Data safety / privacy (this app is simple here)

- [x] **No data collected, no data shared** — fully offline.
- [x] **Zero runtime permissions** (release manifest has none; INTERNET is debug/profile-only).
- [x] Local storage only (`shared_preferences`: current puzzle index + completed ids + onboarding flag — on-device, never leaves the device).
- [ ] **Privacy policy URL** — Play requires one even for no-data apps (**blocker**: host a short policy stating no collection).
- [ ] Data safety form filled to match the above.

## Content & audience

- [ ] Content rating questionnaire (no violence/ads/UGC → expect "Everyone").
- [ ] Target audience / "designed for families" as desired.
- [x] No ads (declare "contains ads = No").
- [x] No in-app purchases.

## Signing & artifact

- [ ] Upload keystore created + `android/key.properties` set (release-build.md §1).
- [ ] Enroll in Play App Signing.
- [ ] Upload **AAB**: `flutter build appbundle --release`.
- [ ] `versionCode` increased since last upload.

## Store listing

- [ ] Short + full description.
- [ ] Screenshots (phone): danger, selected (dots), rescued, completion finale.
- [ ] Feature graphic / hi-res icon (1024px).

## Release tracks

- [ ] **Internal testing** first (run the checklist below) → **closed** → **production**.

---

## Internal testing checklist

Run on a real device / emulator (1080×2400 + a small 360dp profile). Layout
specifics live in `docs/android-layout-qa.md`.

- [ ] **First run** (clear storage): cold-open focus pulse on the knight, "One move saves the game.", full interface, no white flash on launch.
- [ ] **Core loop:** select → dots **fan out** (not pop) → commit f6 → "Rescued." (ring scaled in on select); wrong move → flash + "Try again ↺" → retry.
- [ ] **Sequence:** Next puzzle crossfade; counter `PUZZLE n/5`; complete all five → "The board is quiet now." footnote + mint SAVED badge; Start over.
- [ ] **Persistence:** quit + relaunch resumes the saved puzzle in danger; SAVED count persists; onboarding does not reappear.
- [ ] **Debug reset gating:** in a **debug** build, long-press SAVED resets; in a **release** build it does nothing (no handler).
- [ ] **Crash-safety:** app launches normally (degraded no-save mode only if storage init ever fails).
- [ ] **Haptics:** selection on tap, medium on rescue, heavy on fail (system haptics on).
- [ ] **Performance:** 60fps with danger pulse + ambient breath + rescue glow (DevTools performance overlay); no jank on crossfade.
- [ ] **Release artifact smoke test:** install the actual `--release` APK and replay the loop (confirms R8 didn't strip anything).
