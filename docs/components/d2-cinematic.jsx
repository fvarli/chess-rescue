// d2-cinematic.jsx — Direction 2: CINEMATIC SURVIVAL
// Dramatic, letterboxed, vignetted. The board is staged like a film frame:
// spotlit pieces, deep shadows, single-word copy ("RESCUED."), high contrast
// between tension and relief. Optimized for Play Store stop-scroll energy.

const T2 = {
  bg: '#0b0807',
  bgWarm: '#1a0f0c',
  surface: '#160e0c',
  text: '#f4ece0',
  textDim: 'rgba(244,236,224,0.55)',
  textMute: 'rgba(244,236,224,0.32)',
  light: '#5b4a3e',
  dark: '#1f1612',
  danger: '#ef3a2a',
  rescue: '#7adfb4',
  display: '"Inter Tight", Inter, -apple-system, system-ui, sans-serif',
  sans: '"Inter Tight", Inter, -apple-system, system-ui, sans-serif',
};
// Cinematic tone is carried by weight (700/800), tight letter-spacing,
// and italic — no serif. Pieces and HUD never use italic.

const t2Theme = {
  light: T2.light,
  dark: T2.dark,
  danger: T2.danger,
  rescue: T2.rescue,
  select: '#bda58c',
  boardShadow: '0 24px 60px rgba(0,0,0,0.65), 0 0 0 1px rgba(255,255,255,0.04)',
  squareInset: 'inset 0 1px 0 rgba(255,255,255,0.04)',
  piecePalette: {
    light: '#f0e6d2',
    dark: '#160e0c',
    lightStroke: 'rgba(0,0,0,0.6)',
    darkStroke: 'rgba(244,236,224,0.18)',
    boardLight: T2.light,
    sw: 1.0,
  },
};

// Vignette overlay you can drop into any phone
function T2Vignette({ intensity = 0.7, color = '#000', radial = true }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, pointerEvents: 'none',
      background: radial
        ? `radial-gradient(120% 100% at 50% 60%, transparent 30%, ${color}${Math.floor(intensity*180).toString(16).padStart(2,'0')} 100%)`
        : `linear-gradient(180deg, ${color}80 0%, transparent 25%, transparent 75%, ${color}80 100%)`,
    }} />
  );
}

function T2Letterbox() {
  return (
    <>
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, height: 36,
        background: '#000', zIndex: 3,
      }} />
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, height: 36,
        background: '#000', zIndex: 3,
      }} />
    </>
  );
}

// ── 2A · HOME ────────────────────────────────────────────────
function T2Home() {
  return (
    <Phone bg={T2.bg} statusBarColor={T2.textDim}>
      {/* atmospheric backdrop */}
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(80% 60% at 50% 30%, ${T2.bgWarm} 0%, ${T2.bg} 70%)`,
      }} />
      <T2Vignette intensity={0.6} />

      <div style={{
        position: 'absolute', inset: 0, padding: '120px 32px 0',
        display: 'flex', flexDirection: 'column', color: T2.text, fontFamily: T2.sans,
      }}>
        <div style={{
          fontFamily: T2.sans, fontSize: 11, letterSpacing: '0.32em',
          color: T2.textMute, textTransform: 'uppercase',
        }}>
          chapter four
        </div>
        <div style={{
          fontFamily: T2.display, fontSize: 50, fontWeight: 700,
          lineHeight: 0.92, letterSpacing: '-0.035em', marginTop: 14,
          fontStyle: 'italic',
        }}>
          The trap<br/>is set.
        </div>

        {/* spotlit board preview */}
        <div style={{ marginTop: 40, alignSelf: 'center', position: 'relative' }}>
          <div style={{
            position: 'absolute', inset: -50, borderRadius: '50%',
            background: `radial-gradient(50% 50% at 50% 50%, ${T2.danger}33 0%, transparent 60%)`,
            filter: 'blur(20px)',
          }} />
          <Board size={220} theme={t2Theme} state="danger" />
        </div>

        <div style={{ marginTop: 28, fontSize: 13, lineHeight: 1.6, color: T2.textDim, textAlign: 'center' }}>
          One move stands between<br/>your king and defeat.
        </div>

        <button style={{
          marginTop: 'auto', marginBottom: 80,
          padding: '18px',
          background: 'transparent',
          color: T2.text,
          border: `1px solid ${T2.text}`,
          borderRadius: 0,
          fontFamily: T2.sans,
          fontSize: 12,
          fontWeight: 500,
          letterSpacing: '0.32em',
          textTransform: 'uppercase',
          cursor: 'pointer',
        }}>
          Begin rescue
        </button>
      </div>
    </Phone>
  );
}

// ── 2B · GAMEPLAY / DANGER ───────────────────────────────────
function T2Gameplay() {
  return (
    <Phone bg={T2.bg} statusBarColor={T2.textDim}>
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(70% 50% at 50% 50%, ${T2.bgWarm} 0%, ${T2.bg} 80%)`,
      }} />
      <T2Letterbox />

      <div style={{
        position: 'absolute', top: 44, left: 0, right: 0, textAlign: 'center',
        fontFamily: T2.sans, fontSize: 10.5, letterSpacing: '0.32em', color: T2.textMute,
        textTransform: 'uppercase', zIndex: 4,
      }}>
        Puzzle 014 · 00:23
      </div>

      <div style={{
        position: 'absolute', top: 100, left: 0, right: 0,
        textAlign: 'center', fontFamily: T2.display, fontStyle: 'italic', fontWeight: 600,
        fontSize: 28, color: T2.text, letterSpacing: '-0.02em',
      }}>
        Your king is trapped.
      </div>

      {/* board with spotlight on attacker→king */}
      <div style={{
        position: 'absolute', top: 168, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ position: 'relative' }}>
          <div style={{
            position: 'absolute', inset: -32, borderRadius: 12,
            background: `radial-gradient(60% 40% at 75% 80%, ${T2.danger}3a 0%, transparent 70%)`,
            filter: 'blur(18px)',
          }} />
          <Board
            size={324} theme={t2Theme} state="danger"
            showThreatLines pieceOutline="rgba(0,0,0,0.7)"
          />
        </div>
      </div>

      {/* tension copy */}
      <div style={{
        position: 'absolute', top: 510, left: 0, right: 0, textAlign: 'center',
        fontFamily: T2.sans, fontSize: 11.5, letterSpacing: '0.22em',
        color: T2.danger, textTransform: 'uppercase',
      }}>
        ✦  black threatens mate  ✦
      </div>

      <div style={{
        position: 'absolute', bottom: 70, left: 32, right: 32, textAlign: 'center',
        fontFamily: T2.display, fontStyle: 'italic',
        fontSize: 18, color: T2.textDim,
      }}>
        Find the move.
      </div>
    </Phone>
  );
}

// ── 2C · RESCUE ──────────────────────────────────────────────
function T2Rescue() {
  const post = PUZZLE.pieces
    .filter(p => !(p.file === 4 && p.rank === 3))
    .concat([{ type: 'N', color: 'light', file: 5, rank: 5 }]);
  return (
    <Phone bg={T2.bg} statusBarColor={T2.textDim}>
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(70% 50% at 50% 50%, #143028 0%, ${T2.bg} 80%)`,
      }} />
      <T2Letterbox />

      <div style={{
        position: 'absolute', top: 44, left: 0, right: 0, textAlign: 'center',
        fontFamily: T2.sans, fontSize: 10.5, letterSpacing: '0.32em', color: T2.rescue,
        textTransform: 'uppercase', zIndex: 4,
      }}>
        Nf6+ · the attack is broken
      </div>

      <div style={{
        position: 'absolute', top: 92, left: 0, right: 0,
        textAlign: 'center', fontFamily: T2.display, fontStyle: 'italic', fontWeight: 700,
        fontSize: 68, color: T2.text, letterSpacing: '-0.045em',
        lineHeight: 0.95,
      }}>
        Rescued.
      </div>

      <div style={{
        position: 'absolute', top: 188, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ position: 'relative' }}>
          <div style={{
            position: 'absolute', inset: -40, borderRadius: 12,
            background: `radial-gradient(50% 40% at 60% 45%, ${T2.rescue}40 0%, transparent 70%)`,
            filter: 'blur(20px)',
          }} />
          <Board size={300} theme={t2Theme} position={post} state="rescue" />
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 84, left: 32, right: 32, textAlign: 'center',
        fontFamily: T2.sans, fontSize: 13, color: T2.textDim, lineHeight: 1.6,
      }}>
        You survived the attack.<br/>
        <span style={{ color: T2.rescue, letterSpacing: '0.22em', textTransform: 'uppercase',
          fontSize: 10.5 }}>
          Streak  ·  3
        </span>
      </div>

      <button style={{
        position: 'absolute', bottom: 30, left: 32, right: 32,
        padding: '14px',
        background: T2.text,
        color: T2.bg,
        border: 'none',
        fontFamily: T2.sans,
        fontSize: 12,
        fontWeight: 500,
        letterSpacing: '0.28em',
        textTransform: 'uppercase',
        cursor: 'pointer',
      }}>
        Next chapter
      </button>
    </Phone>
  );
}

// ── 2D · RETRY ───────────────────────────────────────────────
function T2Retry() {
  return (
    <Phone bg={T2.bg} statusBarColor={T2.textDim}>
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(60% 40% at 50% 40%, ${T2.bgWarm} 0%, ${T2.bg} 80%)`,
      }} />
      <T2Letterbox />
      <T2Vignette intensity={0.8} />

      <div style={{
        position: 'absolute', top: 92, left: 0, right: 0,
        textAlign: 'center', fontFamily: T2.display, fontStyle: 'italic', fontWeight: 700,
        fontSize: 54, color: T2.text, letterSpacing: '-0.04em',
        lineHeight: 0.95,
      }}>
        Still<br/>trapped.
      </div>

      <div style={{
        position: 'absolute', top: 250, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
        opacity: 0.65,
      }}>
        <Board size={240} theme={t2Theme} state="failed" />
      </div>

      <div style={{
        position: 'absolute', bottom: 110, left: 32, right: 32, textAlign: 'center',
        fontFamily: T2.sans, fontSize: 13, color: T2.textDim, lineHeight: 1.6,
      }}>
        The danger remains.<br/>
        One move can still save you.
      </div>

      <button style={{
        position: 'absolute', bottom: 30, left: 32, right: 32,
        padding: '14px',
        background: 'transparent',
        color: T2.text,
        border: `1px solid ${T2.text}`,
        fontFamily: T2.sans,
        fontSize: 12,
        fontWeight: 500,
        letterSpacing: '0.28em',
        textTransform: 'uppercase',
        cursor: 'pointer',
      }}>
        Try again
      </button>
    </Phone>
  );
}

// ── 2E · ONBOARDING ──────────────────────────────────────────
function T2Onboarding() {
  return (
    <Phone bg={T2.bg} statusBarColor={T2.textDim}>
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(70% 50% at 50% 50%, ${T2.bgWarm} 0%, ${T2.bg} 80%)`,
      }} />
      <T2Letterbox />

      <div style={{
        position: 'absolute', top: 78, left: 0, right: 0,
        textAlign: 'center', fontFamily: T2.display, fontStyle: 'italic', fontWeight: 600,
        fontSize: 32, color: T2.text, letterSpacing: '-0.03em',
      }}>
        First, the danger.
      </div>

      <div style={{
        position: 'absolute', top: 158, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ position: 'relative' }}>
          {/* dim everything */}
          <div style={{
            position: 'absolute', inset: -30,
            background: 'rgba(0,0,0,0.55)',
            zIndex: 2, pointerEvents: 'none',
            // cutout for danger square
            clipPath: 'polygon(0 0, 100% 0, 100% 100%, 0 100%, 0 0, 86% 90%, 100% 90%, 100% 100%, 86% 100%, 86% 90%)',
          }} />
          <Board size={300} theme={t2Theme} state="danger" showThreatLines />
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 110, left: 36, right: 36, textAlign: 'center',
        fontFamily: T2.sans, fontSize: 14, color: T2.text, lineHeight: 1.55,
      }}>
        The black queen is one move from mate.<br/>
        <span style={{ color: T2.textDim }}>You have one move to stop it.</span>
      </div>

      <div style={{
        position: 'absolute', bottom: 56, left: 0, right: 0,
        textAlign: 'center', display: 'flex', justifyContent: 'center', gap: 8,
      }}>
        {[0,1,2,3].map(i => (
          <span key={i} style={{
            width: 6, height: 6, borderRadius: '50%',
            background: i === 0 ? T2.text : 'rgba(244,236,224,0.2)',
          }} />
        ))}
      </div>
    </Phone>
  );
}

// ── 2F · PLAY STORE SCREENSHOT ───────────────────────────────
function T2Screenshot() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(80% 60% at 30% 40%, ${T2.bgWarm} 0%, ${T2.bg} 60%, #000 100%)`,
      padding: '52px',
      fontFamily: T2.sans,
      color: T2.text,
      position: 'relative',
      overflow: 'hidden',
    }}>
      {/* film grain */}
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.06, mixBlendMode: 'overlay' }}>
        <filter id="t2noise"><feTurbulence type="fractalNoise" baseFrequency="0.9" /></filter>
        <rect width="100%" height="100%" filter="url(#t2noise)" />
      </svg>

      <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div style={{
          fontFamily: T2.sans, fontSize: 13, letterSpacing: '0.38em',
          color: T2.textMute, textTransform: 'uppercase',
        }}>
          a comeback puzzle game
        </div>
        <div style={{
          fontFamily: T2.display, fontStyle: 'italic', fontWeight: 800,
          fontSize: 92, lineHeight: 0.88, letterSpacing: '-0.045em', marginTop: 16,
        }}>
          Survive<br/>
          <span style={{ color: T2.rescue }}>the attack.</span>
        </div>

        <div style={{ marginTop: 'auto', display: 'flex', gap: 36, alignItems: 'flex-end' }}>
          <div style={{ width: 300, transform: 'rotate(-3deg)' }}>
            <Phone width={300} height={620} bg={T2.bg} statusBarColor={T2.textDim}>
              <div style={{
                position: 'absolute', inset: 0,
                background: `radial-gradient(70% 50% at 50% 50%, ${T2.bgWarm} 0%, ${T2.bg} 80%)`,
              }} />
              <div style={{
                position: 'absolute', top: 56, left: 0, right: 0, textAlign: 'center',
                fontFamily: T2.display, fontStyle: 'italic', fontWeight: 600, fontSize: 24, color: T2.text, letterSpacing: '-0.025em',
              }}>
                Your king is trapped.
              </div>
              <div style={{
                position: 'absolute', top: 112, left: 0, right: 0,
                display: 'flex', justifyContent: 'center',
              }}>
                <Board size={264} theme={t2Theme} state="danger" showThreatLines />
              </div>
            </Phone>
          </div>
          <div style={{ flex: 1, paddingBottom: 18 }}>
            <div style={{ fontFamily: T2.sans, fontSize: 14, color: T2.textDim, lineHeight: 1.7 }}>
              30-second rescue puzzles.<br/>
              One move. One king.<br/>
              One chance to survive.
            </div>
            <div style={{
              marginTop: 20, padding: '12px 16px',
              border: `1px solid ${T2.text}`,
              display: 'inline-block',
              fontFamily: T2.sans, fontSize: 11.5, letterSpacing: '0.28em',
              textTransform: 'uppercase',
            }}>
              Free · Offline · No ads
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── 2G · APP ICON ────────────────────────────────────────────
function T2Icon() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(60% 60% at 50% 35%, ${T2.bgWarm} 0%, ${T2.bg} 75%)`,
      borderRadius: 36,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(40% 40% at 50% 50%, ${T2.danger}30 0%, transparent 60%)`,
      }} />
      <div style={{ position: 'relative', color: T2.text, filter: `drop-shadow(0 8px 20px ${T2.danger}66)` }}>
        <Piece type="K" color="light" size={104} palette={t2Theme.piecePalette} />
      </div>
      <div style={{
        position: 'absolute', bottom: 22, left: 0, right: 0,
        textAlign: 'center', fontFamily: T2.display, fontStyle: 'italic',
        fontSize: 14, color: T2.textDim, letterSpacing: '0.04em',
      }}>
        Chess Rescue
      </div>
    </div>
  );
}

window.D2 = { T2Home, T2Gameplay, T2Rescue, T2Retry, T2Onboarding, T2Screenshot, T2Icon, T2 };
