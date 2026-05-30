# Chess Rescue — Closed-test operations runbook

Operational runbook for the 14-day closed test on Google Play (package
`com.lunexa.games.chessrescue`) and the immediate transition to production access. Companion to
`closed-test-checklist.md` (upload-ready) and `play-console-submission.md` (Console field values).

Google's requirement on **this account's Play Console dashboard** (verbatim):
> *"Have at least 12 testers opted-in to your closed test."*
> *"Run your closed test with at least 12 testers, for at least 14 days."*

Every eligibility number in this runbook is **12 / 14**.

## 1) Closed-testing rollout checklist (T-3 → T+14 → Production access)

The minimum viable timeline to unlock production as fast as possible. **Day 0 = the day you
roll out to the closed track.**

### T-3 → T-1 (prep, 3 days before rollout)
- [ ] Closed-track AAB is uploaded to Play Console → **Testing → Closed testing → "alpha"** track
      (versionCode 1, versionName 1.0.0). Release notes pasted (EN/TR/ES) from
      `play-console-submission.md` §13.
- [ ] Store listing 100% green (all fields from `play-console-submission.md` §1–9).
- [ ] Privacy URL reachable: `https://uselunexa.com/privacy/chess-rescue` (curl it).
- [ ] Create the **Google Group** `chess-rescue-testers@googlegroups.com` (recommended over a raw
      email list — easier to add/remove members, easier to email).
- [ ] In Play Console → Closed testing → **Testers** → add the Google Group address as the tester
      list. Copy the **opt-in URL** Console gives you (looks like
      `https://play.google.com/apps/testing/com.lunexa.games.chessrescue`).
- [ ] Create the **Feedback** Google Form (template in §4) and the **Bug Report** Google Form
      (template in §5). Save the share URLs.
- [ ] Build the recruitment list — **invite 15–20 people to safely land ≥12 opt-ins** (rule of
      thumb: ~60–80% opt-in rate from a warm personal/network list, so 15–20 invites comfortably
      clears the 12-tester bar with buffer for stragglers). Sources: founder personal network,
      Discord/Slack solo-dev groups, /r/incremental_games, /r/IndieDev, X game-dev community,
      any RPS Duel friends list. Avoid public broadcast on big chess subs — they expect a trainer
      and will misjudge it.
- [ ] Set up a **tester tracking spreadsheet** (cols: name · email · invited · opted-in · feedback
      submitted · bugs filed · notes).

### T-0 (rollout day)
- [ ] Console → Closed testing → **Review release** → **Start rollout** (100% of the closed track).
- [ ] Send the **tester invitation email** (template in §3) to all recruits with the opt-in URL +
      feedback/bug form links + Play Store install link.
- [ ] Post a one-line announcement in any private dev groups you've cleared.
- [ ] Confirm Play Console shows the build live; do a real install on your own device via the
      opt-in URL to sanity-check the user journey end-to-end.

### T+1 → T+3 (early signal)
- [ ] Daily check: Console → Closed testing → Testers tab → opt-in count. **Target ≥12 by T+3.**
- [ ] If <10 by T+2, send a friendly nudge to non-opted-in invitees; recruit 3–5 more so you clear
      the 12-tester bar with margin.
- [ ] Triage every reported bug within 24h: assign severity, decide hotfix vs. defer.

### T+4 → T+7 (active)
- [ ] Mid-week check-in email (template in §3, "Day 5 nudge" variant) — thank early players,
      surface one new ask (e.g. "try Again ↻ five times — does it feel fresh?").
- [ ] Address any **P0/P1 bug** with a patch: bump `versionCode` to ≥2, rebuild AAB, upload to the
      **same** closed track (don't open a new one — the 14-day clock continues if you stay on the
      same track).
- [ ] Watch Console → Statistics → **Android vitals**: crash-free sessions, ANR rate.

### T+8 → T+13 (final stretch)
- [ ] Final feedback push (template in §3, "Day 10 nudge").
- [ ] Compile a feedback summary from form responses (one doc; one-page table of themes).
- [ ] Pre-fill the production-access application (template in §6).

### T+14 → production access (eligibility day + apply)
- [ ] Verify Console → Closed testing → Testers shows **≥12 testers opted-in for the full 14 days
      continuously** (the clock requires continuous opt-in, not just total — Google's stated
      minimum on this account's dashboard).
- [ ] Verify Android vitals: **crash-free sessions ≥ 99%**, ANR ≤ 0.47%.
- [ ] Console → **Publishing overview** → **Production access** card → **Apply for production
      access**. Submit the application from §6.
- [ ] **Keep the closed test running** during Google's review (do NOT halt the track or
      reassign testers; that can reset the clock).
- [ ] On approval: build production-track release (bump versionCode), promote to **Production**
      with **staged rollout 20%** for the first 48h, then expand to 100%.

## 2) Tester onboarding flow

What a tester goes through, end-to-end (this is also the "Quick start" section of the
invitation email):

1. **Receive the invitation email** (with opt-in URL, install URL, feedback/bug form URLs).
2. **Click the opt-in URL** → sign in with the same Google account that owns their Android device
   → tap "Become a tester".
3. **Wait ~10 minutes** (sometimes up to 30) for Play to propagate the tester status.
4. **Install** via the Play Store install link in the email (the listing shows
   "Tester" badge if the opt-in is live).
5. **Play 1–3 sessions** (each ~90s, including the one-time intro + 5 rescues + "Again ↻"
   replays).
6. **Submit feedback** via the Google Form (≤3 min).
7. **Report bugs** via the bug form **only if** something broke or felt wrong.
8. **Stay opted-in for the full 14 days** — do not leave the closed-test program during the test
   window (Google counts continuous days).
9. Optional: open the app again on day 7 / day 12 to confirm no regressions on their device.

Common gotchas to call out in the invite:
- Must use the **same Google account** on the device as the one that opts in.
- If the Play listing still shows "Install" with no Tester badge after 30 min, the opt-in didn't
  take — re-click the opt-in URL.
- Closed-test builds **don't** auto-update if a user opts out; tell them not to opt out.

## 3) Tester invitation email — templates

All three are designed for direct paste into the Google Group "Send email to group" composer
(or any mail client). Replace `[opt-in URL]`, `[install URL]`, `[feedback form URL]`, `[bug form
URL]` with the real links from Play Console / Google Forms before sending.

### 3a) Initial invitation (Day 0)

> **Subject:** You're invited — help test Chess Rescue (14-day closed test)
>
> Hi,
>
> I'm sending the first private build of **Chess Rescue** to a small group of testers, and
> you're one of them. It's a calm, one-move puzzle game from Lunexa Games — not a chess trainer.
> Every board drops you into visible danger, and there's exactly one move that saves the king.
> Find it, and the board breathes relief.
>
> **What I need from you, in ~10 minutes total:**
> 1. Tap to opt in: **[opt-in URL]**
> 2. Wait ~10 minutes, then install Chess Rescue here: **[install URL]**
> 3. Play 2–3 sessions (each ~90 seconds, fully offline, no account, no ads).
> 4. Tell me how it felt — quick form: **[feedback form URL]**
> 5. If anything breaks, file a quick report: **[bug form URL]**
>
> **What I'm listening for:**
> - Did making the rescue move feel **satisfying / relieving**?
> - After "Again ↻", did replays feel **fresh** or **repetitive**?
> - Did anything crash, lag, or look wrong on your device?
>
> The closed test runs for **14 days**. Please **stay opted in** until I email you that we're
> done — that's the Google requirement that unlocks production launch.
>
> No data is collected. No ads. No accounts. Fully offline.
> Privacy: https://uselunexa.com/privacy/chess-rescue
> Anything weird, just reply to this email or write to hello@uselunexa.com.
>
> Thank you — your feedback is what unlocks our launch.
>
> — Ferzender, Lunexa Games

### 3b) Day-5 nudge (sent ~Day 5 to non-responders)

> **Subject:** Quick favor — your Chess Rescue feedback?
>
> Hi,
>
> Just a soft nudge — if you've had 2 minutes to play **Chess Rescue** this week, I'd love your
> read on it. Even one line helps:
>
> - Feedback (1 minute): **[feedback form URL]**
> - Install link (if you haven't yet): **[install URL]** (must opt in first via **[opt-in URL]**)
>
> One specific thing I'm curious about this week: tap **Again ↻** five times in a row — do the
> replays feel **fresh** or **repetitive**? That signal matters for whether we ship.
>
> Thank you, truly.
> — Ferzender

### 3c) Day-10 final push

> **Subject:** Closed test wraps in 4 days — last call for thoughts
>
> Hi,
>
> The Chess Rescue closed test wraps on **[date]**, four days from now, then we apply for
> Google's production review. If you've played even a little, your feedback would make this
> launch stronger:
>
> - Feedback form: **[feedback form URL]**
> - Bug report (only if you saw something broken): **[bug form URL]**
>
> If you haven't been able to test, no worries — but please **stay opted-in** for four more
> days (just don't tap "Leave program" in the Play Store). That keeps the closed-test clock
> alive on Google's side.
>
> Thank you for being part of this.
> — Ferzender

## 4) Feedback Google Form — exact fields

Build a **single Google Form** at `forms.google.com` → New form. Title: **"Chess Rescue —
Closed Test Feedback"**. Description: *"~3 minutes. No data collected by the app itself; this
form is only for your reply to us."*

Use these fields verbatim (type → field name → options):

| # | Type | Question | Options / notes | Required |
|---|---|---|---|---|
| 1 | Short answer | Your name (or alias) | optional context | No |
| 2 | Short answer | Email (only if you want a reply) | — | No |
| 3 | Short answer | Device model | e.g. "OPPO A91", "Pixel 6" | Yes |
| 4 | Short answer | Android version | e.g. "11", "14" | Yes |
| 5 | Multiple choice | System font size you use | Default · Larger · Largest · Don't know | Yes |
| 6 | Multiple choice | How many sessions did you play? | 1 · 2–3 · 4–6 · 7+ | Yes |
| 7 | Linear scale 1–5 | The first 10 seconds — was the **danger** clear? | 1 = very unclear · 5 = instantly obvious | Yes |
| 8 | Linear scale 1–5 | Did making the rescue move feel **satisfying / relieving**? | 1 = flat · 5 = real relief | Yes |
| 9 | Linear scale 1–5 | After "Again ↻", how did replays feel? | 1 = very repetitive · 5 = very fresh | Yes |
| 10 | Multiple choice | The intro screen ("One move saves the king") | Loved it · Felt right · Skippable · Cheesy / off-tone | Yes |
| 11 | Linear scale 0–10 | How likely are you to recommend Chess Rescue to a friend? | NPS | Yes |
| 12 | Paragraph | Anything that confused, frustrated, or annoyed you? | — | No |
| 13 | Paragraph | Anything that surprised or delighted you? | — | No |
| 14 | Paragraph | Anything else? | — | No |

Settings:
- Responses → Linked to a **Google Sheet** (`Chess Rescue — Feedback Responses`).
- Notifications: email me on each submission.
- "Collect email addresses" = **Off** (we ask explicitly in field 2; respect privacy).
- "Limit to 1 response" = **Off** (testers may submit again after a patch).

## 5) Bug-report Google Form — exact fields

Build a **second Google Form**. Title: **"Chess Rescue — Closed Test Bug Report"**.
Description: *"Use this only when something broke or felt wrong. For general impressions, use
the Feedback form instead."*

| # | Type | Question | Options / notes | Required |
|---|---|---|---|---|
| 1 | Short answer | Your name (or alias) | optional | No |
| 2 | Short answer | Email (so we can ask follow-ups) | — | No |
| 3 | Short answer | Device model | e.g. "OPPO A91" | Yes |
| 4 | Short answer | Android version | e.g. "11" | Yes |
| 5 | Multiple choice | System font size | Default · Larger · Largest · Don't know | Yes |
| 6 | Short answer | Build version | "1.0.0 (1)" unless told otherwise | Yes |
| 7 | Multiple choice | **Severity** | **Crash** · **Blocker (can't play)** · **Major (broke a session)** · **Minor (annoying)** · **Polish (cosmetic)** | Yes |
| 8 | Multiple choice | Frequency | Always · Often · Sometimes · Once | Yes |
| 9 | Paragraph | What did you do? (steps to reproduce) | — | Yes |
| 10 | Paragraph | What did you expect to happen? | — | Yes |
| 11 | Paragraph | What actually happened? | — | Yes |
| 12 | File upload | Screenshot or short screen recording | Allow image + video, ≤ 10 MB | No |
| 13 | Paragraph | Any extra context (orientation, multitasking, low battery, …) | — | No |

Settings:
- Responses → Linked to a **Google Sheet** (`Chess Rescue — Bug Reports`).
- Notifications: **on every submission** (we triage within 24h).
- "Collect email addresses" = **Off**.

Triage rubric (in your head, when each report lands):
- **Crash / Blocker** → patch in <72h (bump versionCode, re-upload to the same closed track).
- **Major** → patch within the 14-day window if reproducible.
- **Minor / Polish** → log; address post-production unless trivial.

## 6) Production-access readiness checklist + application template

### Eligibility (must all be true on T+14)
- [ ] **≥12 testers opted-in for 14 consecutive days** (Console → Closed testing → Testers) —
      Google's stated minimum on this account's Console dashboard.
- [ ] No **Crash / Blocker** bugs outstanding.
- [ ] **Crash-free sessions ≥ 99%** (Console → Statistics → Android vitals).
- [ ] **ANR rate ≤ 0.47%** (Google's "bad behavior" threshold).
- [ ] **All store listing fields green** (Data Safety, Content Rating, Privacy URL approved — no
      open Console warnings).
- [ ] Closed-track build's `versionCode` matches what testers are actually running.
- [ ] At least **5 distinct devices** represented across testers (Vitals → device tab) — Google
      uses device-spread as a quality signal.

### How to apply (Console steps)
1. Console → **Publishing overview** → **Production access** card → **Apply for production access**.
2. Fill in the four sections (template copy in §6a). Be specific; concrete numbers beat platitudes.
3. Submit. Google's typical review window is **2–14 days**.
4. **Do not stop** the closed test. Keep the same track live until production access is granted.
5. While waiting, draft the production release (versionCode ≥ 2 if any patch shipped during the
   closed test) but **don't promote yet**.

### 6a) Application form — copy-paste template

(Replace `[N]`, `[date]`, `[summary]` etc. with the real values from your tracking sheet on T+14.)

> **How did you test your app?**
> We ran a 14-day closed test on Google Play (track "alpha") between **[start date]** and
> **[end date]**. Testers were invited from our personal network and small private dev/game
> communities, opted in via the Play Console-issued opt-in URL, installed via the closed-track
> Play Store link, and submitted feedback through two dedicated Google Forms — one for general
> feedback (13 fields covering device, session count, clarity, satisfaction, replay freshness,
> NPS, and free text) and one for bug reports (severity-tagged with reproduction steps and
> file-upload). Tester comms went out as a recruitment email on Day 0, a Day-5 nudge, and a
> Day-10 final push.
>
> **How many testers did you have, and how long did you test?**
> **[N]** testers (above the **12-tester minimum** stated in our Play Console dashboard) were
> opted in for the full **14 days** (Console → Closed testing → Testers shows continuous
> opt-in). Builds tested: versionCode **[1, 2, …]** on the same closed track. Devices
> represented: **[N]** distinct device models across **[N]** Android versions.
>
> **What did you learn?**
> Top feedback themes:
> 1. [theme — e.g. "Cold-open clarity is strong; testers consistently understood 'I'm in
>    danger, one move saves me' within the first 10 seconds."]
> 2. [theme — replay freshness signal]
> 3. [theme — UI / readability]
>
> Bugs filed: **[N]** total — [N] Crash/Blocker, [N] Major, [N] Minor/Polish.
> All Crash/Blocker and Major bugs were resolved within the test window (see versionCode
> bumps). Outstanding items are Minor/Polish and tracked for the next release.
>
> **Why is your app ready for production?**
> - The core loop works reliably on real devices: crash-free sessions **[X]%**, ANR rate
>   **[X]%**, both inside Google's recommended thresholds.
> - The full store listing is complete (title, descriptions in EN/TR/ES, icon, feature graphic,
>   6 phone screenshots), Data Safety form filed (no data collected/shared), content rating
>   **Everyone / PEGI 3**, privacy policy live at
>   `https://uselunexa.com/privacy/chess-rescue`.
> - Zero runtime permissions, no network requests, no ads, no IAP, no analytics, no SDKs with
>   data collection — minimal surface area for compliance issues.
> - Tester sentiment is positive (NPS average **[X]**, satisfaction average **[X]/5**) with no
>   open complaints about safety, abuse, or content.

### After approval
1. Console → Production → **Create new release** (versionCode current+1; production track).
2. Paste the same EN/TR/ES release notes from `play-console-submission.md` §13 (lightly
   adjusted: "First public release" instead of "First closed-test build").
3. **Staged rollout 20%** for 48h, then 50%, then 100% (catches a late regression on a wider
   device pool before everyone gets it).
4. Watch Android vitals for the first 72h; pause rollout if crash-free drops below 99%.

## 7) Track-record artifacts to keep (Google may ask)

- Tester tracking spreadsheet with invite/opt-in/feedback/bugs columns.
- All Google Form responses (auto-saved in the linked Sheets).
- Bug triage log: severity → resolution version → notes.
- A 1-page **closed-test summary** dated T+14 (paste into the production-access application).
