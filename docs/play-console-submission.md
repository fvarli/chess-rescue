# Chess Rescue — Play Console submission sheet

Exact, copy-paste values for every required Play Console field. Sourced from already-verified
project facts: `play-store-metadata-draft.md`, `play-console-data-safety.md`, `privacy-policy.md`,
`closed-test-checklist.md`, `android/app/build.gradle.kts`, `AndroidManifest.xml`, and the assets
audit. Paste these into the Console during submission; do not invent new values.

## App identity

- **App name** (≤30): `Chess Rescue`
- **Developer / publisher:** `Lunexa Games`
- **Package name:** `com.lunexa.games.chessrescue`
- **Default language:** English (United States) — `en-US`
- **Application type:** Game
- **Free or paid:** Free
- **versionCode / versionName:** `1` / `1.0.0` (from `pubspec.yaml` `1.0.0+1`)
- **Upload artifact (AAB):** `build/app/outputs/bundle/release/app-release.aab` (40.1 MB,
  release-signed via `android/key.properties`)

## 1) App category, tags

- **App category:** **Games → Puzzle** *(recommendation — final)*
  - *Why:* the core loop is one-move chess puzzles with no opponent/clock; "Puzzle" matches better
    than Casual or Board. (Alt if Play's UI requires a sub-pick: leave secondary blank.)
- **Tags (pick up to 5 from Play's curated list):** `Brain games`, `Puzzle`, `Casual`, `Logic`,
  `Single player` — closest matches to the spec tags (`puzzle, casual, brain, relax, chess`).
- **Store listing contact category:** Single player game · Offline play supported.

## 2) Target audience and content

Play Console form: "Target audience and content".

- **Target age groups (check):** **13–15**, **16–17**, **18 and over**.
  *(Do NOT check under-13 ranges. The app's content is family-safe, but selecting under-13 enrolls
  Chess Rescue into the Designed for Families / Families policy with extra developer requirements;
  we don't need that scope for this title.)*
- **Does your app unintentionally appeal to children?** No.
- **Is your app primarily child-directed?** No.
- **Designed for Families program:** No (do not opt in).
- **Store presence:** Standard (not in the Families section).

## 3) App access

Play Console form: "App access".

- **Is all functionality available without special access?** **Yes — all functionality is available
  without any special access.** *(No login, no region lock, no paywall, no membership, no time gate.)*
- **Login credentials to provide:** None.

## 4) Ads declaration

- **Does your app contain ads?** **No.**

## 5) Content rating (IARC questionnaire)

Pick the **"Reference app / All other app types"** path → **Game** → answer every question **No**:

| Question | Answer |
|---|---|
| Violence (cartoon / fantasy / realistic) | **No** |
| Sexual content / nudity / suggestive themes | **No** |
| Profanity, crude humor | **No** |
| Controlled substances (alcohol, tobacco, drugs) | **No** |
| Gambling (simulated or real) | **No** |
| Horror / fear-inducing content | **No** |
| Mature / sensitive themes | **No** |
| User-generated content | **No** |
| Users interact, share, communicate | **No** |
| Shares user location | **No** |
| Allows digital purchases | **No** |
| Unrestricted internet / web-browser feature | **No** |
| Miniaturized / unmoderated content | **No** |

Expected outcome: **ESRB Everyone / PEGI 3 / IARC 3+** (all regions).

## 6) Data safety

Play Console form: "Data safety". Source: `play-console-data-safety.md`.

- **Does your app collect or share any of the required user data types?** **No.**
- **Data collected:** *(table stays empty)*
- **Data shared:** *(table stays empty)*
- **Is all of the user data collected by your app encrypted in transit?** **N/A — no data is
  collected or transmitted.**
- **Do you provide a way for users to request that their data be deleted?** **N/A — there is no
  account and no off-device data; on-device progress is removed by uninstalling the app or clearing
  its storage in system Settings.**
- **Security practices declared:** *none required* (no data collected).
- **Independent security review:** No.

## 7) Other Console declarations

- **Government app?** No
- **Financial features / loans / investments / crypto?** No
- **News app?** No
- **Health / medical app?** No
- **COVID-19 contact tracing / status?** No
- **Sensitive permissions / APIs (background location, SMS, call log, accessibility,
  all-files-access, …)?** **None used.** Release `AndroidManifest.xml` declares **zero**
  `<uses-permission>`; no high-risk APIs.
- **Advertising ID declaration:** Not used.
- **Cleartext traffic / network security:** Not applicable — app is fully offline (no network code).

## 8) Privacy & contact

- **Privacy policy URL:** `https://uselunexa.com/privacy/chess-rescue`
  - *Per-locale (optional, recommended for the TR/ES store locales):*
    `https://uselunexa.com/tr/privacy/chess-rescue` ·
    `https://uselunexa.com/es/privacy/chess-rescue`
- **Support email (publicly visible):** `hello@uselunexa.com`
- **Website (optional):** `https://uselunexa.com`
- **Phone (optional):** *leave blank*

## 9) Store listing — Main (English, en-US)

- **App name (≤30):** `Chess Rescue`
- **Short description (≤80, current 65):**
  ```
  One move saves the king. A calm, offline 90-second rescue ritual.
  ```
- **Full description (≤4000):**
  ```
  Chess Rescue is a calm, offline puzzle game about one feeling: the relief of saving a
  position that looked lost.

  It is not a chess trainer. No openings, no ratings, no opponents, no clocks. Every puzzle
  drops you into visible danger — your king is under threat — and asks for a single move: the
  rescue. Find it, commit, and the board answers with a quiet breath of relief. Miss it, and
  there's no loss screen and no shame — just a soft reset and another try.

  A 90-second ritual for when a small fight in your day didn't go your way. A reminder that a
  position that looks lost is sometimes one move from rescued.

  • One move, one rescue, one feeling — repeated.
  • Gentle by design: failure just resets, calmly.
  • Fully offline. No accounts, no ads, no tracking, no network.
  • No chess knowledge required — if you can see the danger, you can find the move.
  • Short sessions that stay fresh without ever feeling random.

  Chess is the medium. Relief is the product.
  ```

### Graphics (already produced — paths confirmed by the asset audit)

- **App icon (Play 512²):** `assets/store/play-icon-512.png`
- **Feature graphic (1024×500):** `assets/store/feature-graphic-1024x500.png`
- **Phone screenshots (upload 4–8, 9:16, 1080×2400) — upload all 6 in this order:**
  1. `assets/store/screenshots/final/01-hook.png`
  2. `assets/store/screenshots/final/02-danger.png`
  3. `assets/store/screenshots/final/03-one-move.png`
  4. `assets/store/screenshots/final/04-rescue.png`
  5. `assets/store/screenshots/final/05-completion.png`
  6. `assets/store/screenshots/final/06-everyday-comeback.png`
- **7" tablet / 10" tablet screenshots:** *leave blank* (optional; not produced; we target phones).
- **Promo / TV / Wear assets:** *leave blank* (not applicable).

## 10) Store listing — Türkçe (tr-TR)

- **Title:** `Chess Rescue`
- **Short description (≤80):**
  ```
  Tek hamle şahı kurtarır. Sakin, çevrimdışı, 90 saniyelik bir kurtarış.
  ```
- **Full description:**
  ```
  Chess Rescue, tek bir duyguyla ilgili sakin, çevrimdışı bir bulmaca oyunudur: kaybedilmiş
  görünen bir konumu kurtarmanın rahatlığı.

  Bu bir satranç eğitmeni değildir. Açılış yok, puan yok, rakip yok, saat yok. Her bulmaca sizi
  görünür bir tehlikenin içine bırakır — şahınız tehdit altındadır — ve tek bir hamle ister:
  kurtarış. Onu bulun, oynayın; tahta sessiz bir rahatlama nefesiyle yanıt verir. Kaçırırsanız,
  kayıp ekranı ve utanç yoktur — yalnızca yumuşak bir sıfırlama ve yeni bir deneme.

  Gününüzdeki küçük bir mücadele istediğiniz gibi gitmediğinde, 90 saniyelik bir ritüel. Kaybedilmiş
  görünen bir konumun bazen tek bir hamlelik uzaklıkta kurtarıldığını hatırlatır.

  • Tek hamle, tek kurtarış, tek duygu — tekrar tekrar.
  • Tasarım gereği nazik: başarısızlık sakince sıfırlanır.
  • Tamamen çevrimdışı. Hesap yok, reklam yok, takip yok, ağ yok.
  • Satranç bilgisi gerekmez — tehlikeyi görebiliyorsanız, hamleyi bulabilirsiniz.
  • Asla rastgele hissettirmeden taze kalan kısa seanslar.

  Satranç araçtır. Ürün rahatlamadır.
  ```
- **Graphics:** same files as EN (reuse).
- **Privacy policy URL for tr-TR locale:** `https://uselunexa.com/tr/privacy/chess-rescue`

## 11) Store listing — Español (es-ES)

- **Title:** `Chess Rescue`
- **Short description (≤80):**
  ```
  Un movimiento salva al rey. Un ritual de rescate tranquilo y sin conexión.
  ```
- **Full description:**
  ```
  Chess Rescue es un juego de rompecabezas tranquilo y sin conexión sobre una sola sensación: el
  alivio de salvar una posición que parecía perdida.

  No es un entrenador de ajedrez. Sin aperturas, sin puntuaciones, sin rivales, sin relojes. Cada
  rompecabezas te coloca en peligro visible — tu rey está amenazado — y pide un solo movimiento: el
  rescate. Encuéntralo, confírmalo y el tablero responde con un tranquilo respiro de alivio. Si
  fallas, no hay pantalla de derrota ni vergüenza: solo un reinicio suave y otro intento.

  Un ritual de 90 segundos para cuando una pequeña batalla de tu día no salió como querías. Un
  recordatorio de que una posición que parece perdida a veces está a un movimiento de ser rescatada.

  • Un movimiento, un rescate, una sensación — una y otra vez.
  • Amable por diseño: el fallo simplemente se reinicia, con calma.
  • Totalmente sin conexión. Sin cuentas, sin anuncios, sin seguimiento, sin red.
  • No se requieren conocimientos de ajedrez: si ves el peligro, puedes encontrar el movimiento.
  • Sesiones cortas que se mantienen frescas sin sentirse nunca aleatorias.

  El ajedrez es el medio. El alivio es el producto.
  ```
- **Graphics:** same files as EN.
- **Privacy policy URL for es-ES locale:** `https://uselunexa.com/es/privacy/chess-rescue`

## 12) Pricing & distribution

- **Free or paid:** Free.
- **Countries:** All available (no exclusions).
- **Contains ads label on the listing:** No.
- **Pre-registration:** No.

## 13) Release management — Closed testing (first track)

- **Track:** **Closed testing** (e.g. "alpha").
- **Testers:** Google Group recommended (easier to manage).
- **Release name:** `1.0.0 (1)`
- **Release notes (EN):**
  ```
  First closed-test build. The full one-move rescue loop: danger → focus → relief.
  Five hand-authored puzzles per session, fresh-but-curated replays after that.
  ```
- **Release notes (TR):**
  ```
  İlk kapalı test sürümü. Tam tek hamlelik kurtarış döngüsü: tehlike → odak → rahatlama.
  Oturum başına beş elle yazılmış bulmaca, sonrasında taze ama özenli tekrar oynamalar.
  ```
- **Release notes (ES):**
  ```
  Primer build de prueba cerrada. El bucle completo de rescate en un solo movimiento:
  peligro → foco → alivio. Cinco puzles autorales por sesión, repeticiones frescas pero
  curadas después de eso.
  ```
- **Rollout %:** 100% to the closed track.

---

## Single-sentence summary

> Chess Rescue 1.0.0 (1) — a calm, offline single-player puzzle game by Lunexa Games
> (`com.lunexa.games.chessrescue`); Games → Puzzle; 13+; no ads, no IAP, no data collected, no
> permissions; ESRB Everyone / PEGI 3 expected; privacy at
> `https://uselunexa.com/privacy/chess-rescue`; support `hello@uselunexa.com`.
