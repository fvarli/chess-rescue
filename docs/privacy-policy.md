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

## Hosted URL (UseLunexa site)

The privacy page is **implemented in the `lunexa-web` repo** (Next.js App Router), mirroring the
sibling RPS Duel policy. The **source of truth for the page copy now lives in**
`lunexa-web/apps/web/src/seo/content.ts` (`CHESS_RESCUE_PRIVACY`, EN/TR/ES); the three
`privacy-policy-{en,tr,es}.md` files here are the original drafts those pages were authored from.
After deploy:

- Canonical (EN): `https://uselunexa.com/privacy/chess-rescue`
- Localized: `https://uselunexa.com/tr/privacy/chess-rescue` · `https://uselunexa.com/es/privacy/chess-rescue`

One `[locale]` page serves all three languages (the site's i18n + hreflang/sitemap handle it).
Contact email on the page is the site's `hello@uselunexa.com`.

## Manual deploy (the only human steps)

1. In `lunexa-web`: review the route locally (`npm run dev` → `/privacy/chess-rescue`, `/tr/…`,
   `/es/…`), then commit + push `main` → GitHub Actions builds and pm2-reloads the VPS.
2. Confirm `https://uselunexa.com/privacy/chess-rescue` is **publicly reachable** (Play validates
   it on submission).
3. **Play Console linking:** Store settings → **Privacy policy** → paste
   `https://uselunexa.com/privacy/chess-rescue`. If you add `tr-TR` / `es-ES` store locales, set
   each locale listing's privacy URL to the matching `…/tr/privacy/chess-rescue` /
   `…/es/privacy/chess-rescue` page. One global URL is required; per-locale URLs are optional but tidy.

See `play-store-checklist.md` / `closed-test-checklist.md` for where this fits in the launch flow,
and `play-console-data-safety.md` for the Data Safety answers that must match this policy.
