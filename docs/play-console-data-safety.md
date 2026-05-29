# Play Console — Data Safety & Rating Answers

Exact answers for the Google Play Console forms. Matches app reality (verified): fully offline,
no account/ads/analytics/network, no runtime permissions, progress stored locally only
(`shared_preferences`). Nothing here is a repo artifact — fill these into the Console UI.

## Data safety form

- **Does your app collect or share any of the required user data types?** → **No.**
  (No data is collected or shared, so the per-type tables stay empty.)
- **Data collected:** None.
- **Data shared:** None.
- **Is all of the user data collected by your app encrypted in transit?** → **N/A** — no data is
  collected or transmitted (the app makes no network requests).
- **Do you provide a way for users to request that their data be deleted?** → **N/A** — there is no
  account and no off-device data; on-device progress is removed by uninstalling or clearing the
  app's storage in system Settings.
- **Permissions:** none (the release `AndroidManifest.xml` declares no `<uses-permission>`).
- **Privacy policy URL:** the hosted page (see `privacy-policy.md` → publishing plan).

## App content

- **Contains ads:** No.
- **In-app purchases:** No.
- **Content rating (IARC questionnaire):** answer no violence, no sexual content, no profanity, no
  controlled substances, no user interaction/UGC, no ads, no data sharing → expect **Everyone
  (ESRB) / PEGI 3 / "3+"**.
- **Target audience & content:** general audiences; the app is safe to mark family-friendly
  (no data collection, no ads, no external links inside gameplay).
- **Government app / financial / health:** No.
- **News app:** No.

## Why this is safe to declare

The app ships all content in the APK, has no networking code or third-party data SDKs (only
`shared_preferences` for on-device progress and `cupertino_icons`), and requests no permissions in
release. See `release-candidate-notes.md` for the crash-risk/permissions audit.
