# Play Store Checklist

Submission readiness for Chess Rescue. See `release-build.md` for build/signing
and `versioning-notes.md` for version bumps. To actually launch a closed test, follow
`closed-test-checklist.md` (the go-to-test runbook); `release-candidate-notes.md` records the
current RC; listing copy/assets live in `play-store-metadata-draft.md` + `privacy-policy.md`.

> **Status 2026-08-29 (v1.2.0+6).** Trued up against the repository. The launcher-icon and
> screenshot items below were still marked as open blockers long after the work shipped —
> both are now confirmed done in-tree. The app is **live in Closed testing** with an installed
> audience of **10**; this account requires **12** opted-in testers for **14 continuous days**
> before production promotion.

## App identity

- [x] applicationId `com.lunexa.games.chessrescue` (permanent)
- [x] Display name "Chess Rescue"
- [x] Publisher: Lunexa Games (Play Console account)
- [x] Launcher icon (real art) — shipped in `f41a448`; adaptive icon wired via
      `flutter_launcher_icons` (`assets/app_icon/app_icon.png` + `app_icon_foreground.png`,
      background `#0D0E12`), generated into `mipmap-anydpi-v26/ic_launcher.xml` and all
      density buckets. No longer a blocker.
- [x] Dark launch background (no white flash)

## Data safety / privacy (this app is simple here)

- [x] **No data collected, no data shared** — fully offline.
- [x] **Zero runtime permissions** (release manifest has none; INTERNET is debug/profile-only).
- [x] Local storage only (`shared_preferences`: 17 `cr_*` keys — session/progress, records, signatures, one-time hint flags — on-device, never leaves the device).
- [x] **Privacy policy URL** — drafted in all 3 locales (`privacy-policy-{en,tr,es}.md`), hosted via `lunexa-web` at `https://uselunexa.com/privacy/chess-rescue`. *(Verify the URL resolves before each submission.)*
- [x] Data safety form filled to match the above — answers recorded in `play-console-data-safety.md`.

## Content & audience

- [x] Content rating questionnaire (no violence/ads/UGC → "Everyone").
- [x] Target audience / "designed for families" as desired.
- [x] No ads (declare "contains ads = No").
- [x] No in-app purchases.

## Signing & artifact

- [x] Upload keystore created + `android/key.properties` set (release-build.md §1) — done; release AAB is upload-key signed (verified `CN=Lunexa Games`, alias `chess_rescue_upload`).
- [x] Enroll in Play App Signing.
- [x] Upload **AAB**: `flutter build appbundle --release`.
- [x] `versionCode` increased since last upload — `6` (was `5`). **Note:** `versionCode` sat at `5` for 19 commits; always confirm the bump before building.

## Store listing

- [x] Short + full description — finalized EN/TR/ES in `play-store-metadata-draft.md`.
- [x] Screenshots (phone) — 12 final PNGs in `assets/store/screenshots/final/` (hook, danger + ambient cue, one-move/move clarity, rescue success, trilogy finale/completion, rescue records, home journey, everyday comeback). Produced via the harness in `screenshot-capture.md`. No longer a blocker.
- [x] Feature graphic (`assets/store/feature-graphic/feature-graphic-1024x500.png`) / hi-res icon (`assets/store/play-icon-512.png`).

> Screenshots currently depict **pre-1.2.0** visuals. They remain accurate as to flow and copy,
> but predate the Threshold board materials and the PR-16 piece redesign. Re-capture via
> `screenshot-capture.md` once the 1.2.0 on-device pass confirms the new piece treatment.

## Release tracks

- [x] **Internal testing** → **closed** (current track, audience 10) → **production** (blocked: needs 12 testers × 14 continuous days).

---

## Internal testing checklist

Run on a real device / emulator (1080×2400 + a small 360dp profile). Layout
specifics live in `docs/android-layout-qa.md`.

- [ ] **First run** (clear storage): intro overlay appears once, dismisses on CTA; cold-open focus cue on the rescue piece; no white flash on launch.
- [ ] **Core loop:** select → dots **fan out** (not pop) → commit → "Rescued." + cinematic rescue arrow (draws in, holds, **settles to a fraction of peak** — it must not hold at full strength); wrong move → flash + retry.
- [ ] **Episodes:** all **6** are reachable — Ep1→2→3 sequential, then Ep4 (master/mirrored), Ep5 (endless), Ep6 (pin-defense) unlocking in parallel off Ep3. Locked cards show the unlock affordance. Completion sheet fires on episode finish and focus advances to the next episode.
- [ ] **Episode 6:** all 5 pin-defense positions read clearly; the pin is legible before the rescue.
- [ ] **Endless (Ep5):** a session composes 5 puzzles, ≥3 canonical, opener/finale clean, no repeated position within a session.
- [ ] **Records:** the Records journal opens from Home; the latest-milestone line shows the most recent unlock with its date; the unlock overlay fires on a new record.
- [ ] **Signatures:** bookmark a rescue → it appears in the Signatures tab; expand sheet reads in journal register ("First saved in Episode 3"), not label-value register.
- [ ] **Familiarity:** re-solving a previously-completed position shows the quiet familiar cue **only on the rescued state**, never during danger.
- [ ] **Daily ritual:** after one rescue, Home shows the quiet "rescued today" line; it is one plain line with no streak, icon, or tap target.
- [ ] **Persistence:** quit + relaunch resumes correctly; completed ids, lifetime count, records, signatures, and focused episode all persist; intro does not reappear.
- [ ] **Localization:** switch to TR and ES via the language picker — no overflow, no truncation, no missing strings on Home, board, Records, Signatures, and completion sheet.
- [ ] **Accessibility:** with TalkBack on, board squares announce once each (`e4, light knight` — not duplicated); Home CTA, episode cards, records line, and tab toggle are all labeled.
- [ ] **Text scale / small device:** 360dp profile and largest system font — no clipping (see `android-layout-qa.md`).
- [ ] **Debug reset gating:** in a **debug** build, long-press SAVED resets; in a **release** build it does nothing (no handler).
- [ ] **Crash-safety:** app launches normally (degraded no-save mode only if storage init ever fails).
- [ ] **Haptics:** selection on tap, medium on rescue, heavy on fail (system haptics on).
- [ ] **Performance:** 60fps with danger pulse + ambient breath + rescue glow (DevTools performance overlay); no jank on crossfade.
- [ ] **Release artifact smoke test:** install the actual `--release` build and replay the loop (confirms R8 didn't strip anything).
- [ ] **PR-16 piece judgment (v1.2.0 — the reason this build exists):** at real board scale, do the pieces read as *premium carved material* rather than flat or plastic? Check the knight profile, the queen crown spread, and the rook notches specifically, on both light and dark pieces, at the smallest board size the device produces. **Record the verdict — it is the input to the next PR.**
