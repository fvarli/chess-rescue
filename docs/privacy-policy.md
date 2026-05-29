# Privacy Policy — index & hosting plan

Chess Rescue needs **one publicly hosted privacy-policy URL** for Google Play (required even for a
zero-data app). The host-ready content lives in three language files; this doc is the publishing hub.

## Host-ready pages (content)

- 🇬🇧 English — `privacy-policy-en.md` (canonical)
- 🇹🇷 Türkçe — `privacy-policy-tr.md`
- 🇪🇸 Español — `privacy-policy-es.md`

All three say the same thing (app reality): offline; no account/ads/analytics/network; no runtime
permissions; progress stored on-device only. Publisher: **Lunexa Games**. Before publishing,
replace the `<support email>` placeholder and set the "Last updated" date.

## Suggested URL structure (UseLunexa site)

Confirm the real domain (`<uselunexa-domain>` is a placeholder):

- Canonical: `https://<uselunexa-domain>/chess-rescue/privacy`
- Localized: `…/privacy/en` · `…/privacy/tr` · `…/privacy/es`

(A single page with a language switcher works too — Play only requires the URL to resolve.)

## Manual deploy (the only human steps)

1. Publish the 3 pages on the UseLunexa site (GitHub Pages / Netlify / Google Sites / existing CMS;
   render the Markdown as HTML). Set `<support email>` + the "Last updated" date; confirm publisher.
2. Confirm each URL is **publicly reachable** (Play validates it on submission).
3. **Play Console linking:** Store settings → **Privacy policy** → paste the canonical URL. If you
   add `tr-TR` / `es-ES` store locales, set each locale listing's privacy URL to the matching
   language page. One global URL is required; per-locale URLs are optional but tidy.

See `play-store-checklist.md` / `closed-test-checklist.md` for where this fits in the launch flow,
and `play-console-data-safety.md` for the Data Safety answers that must match this policy.
