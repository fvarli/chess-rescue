# Play Store Metadata — Finalized

Finalized listing copy for the Google Play Console (Phase 30). Paste as-is — support email
(`hello@uselunexa.com`) and the privacy URL (`https://uselunexa.com/privacy/chess-rescue`) are now
filled; only add graphics (`closed-test-checklist.md`). Data Safety answers live in
`play-console-data-safety.md`; privacy text + hosting in `privacy-policy.md`. Tone seeded from
`product-vision.md`: relief, calm, "not a chess trainer." Copy intentionally **motivates, not
describes** (see store-copy-voice guidance).

## Identity

- **App name / title** (≤30 chars): `Chess Rescue` (12)
- **Developer / publisher:** `<Lunexa Games>`
- **Package:** `com.lunexa.games.chessrescue`
- **Category:** Games → **Puzzle** (alt: Casual)
- **Tags:** puzzle, casual, brain, relax, chess
- **Contains ads:** No · **In-app purchases:** No

## Short description (≤80 chars)

```
One move saves the king. A calm, offline 90-second rescue ritual.
```
(65 chars)

## Full description (≤4000 chars)

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

## Content & audience

- **Content rating:** expect **Everyone** (no violence, no ads, no user-generated content,
  no shared data). Complete the IARC questionnaire in the Console.
- **Target audience:** general; optionally mark family-friendly.

## Data Safety + content rating

Exact Console answers in **`play-console-data-safety.md`** (summary: no data collected/shared,
no permissions, no ads, no IAP, rating Everyone/PEGI 3).

- **Privacy policy URL:** `https://uselunexa.com/privacy/chess-rescue` (live page implemented in
  the `lunexa-web` repo, mirrors RPS Duel; per-locale `…/tr/privacy/chess-rescue`,
  `…/es/privacy/chess-rescue` — see `privacy-policy.md`).

## Localized listings (EN / TR / ES)

Match the privacy-policy languages. Short ≤80 chars; full = faithful translation of the EN body.

- **TR title:** `Chess Rescue` · **TR short:** `Tek hamle şahı kurtarır. Sakin, çevrimdışı, 90 saniyelik bir kurtarış.`
- **ES title:** `Chess Rescue` · **ES short:** `Un movimiento salva al rey. Un ritual de rescate tranquilo y sin conexión.`

**TR full description:**
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

**ES full description:**
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

## Graphics required (capture before listing — see closed-test-checklist.md)

> Art direction + the icon/feature-graphic/screenshot concepts live in `brand-direction.md`
> (recommended icon: the abstract coral→mint "knight-leap").

- **App icon:** 512×512 PNG (32-bit) → `assets/store/play-icon-512.png` ✅ (launcher icon "The
  Trajectory" also wired into the app; default Flutter logo replaced).
- **Feature graphic:** 1024×500 → `assets/store/feature-graphic-1024x500.png` ✅ **(text-free v1)**;
  add the wordmark overlay in a design tool (see `store-assets-spec.md` → text-overlay spec).
- **Phone screenshots:** 2–8, 9:16 (1080×2400) — capture pending (see `screenshot-workflow.md`).
  Capture the signature states:
  1. danger (king glowing, threat named), 2. a piece selected (move dots fanned out),
  3. rescued (mint breath), 4. completion ("The board is quiet now." + SAVED badge).

## Contact

- **Support email:** `hello@uselunexa.com`
- **Website (optional):** `<url>`
