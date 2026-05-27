// d4-converge.jsx — Direction 4: CONVERGENCE (Tactical × Cinematic)
// The recommended hybrid. Tactical HUD discipline during gameplay; cinematic
// emotional flourish on rescue/onboarding moments. Optimized for BOTH
// gameplay clarity AND Play Store stop-scroll.

const T4 = {
  bg: '#0d0e12',
  surface: '#161821',
  surface2: '#1d2030',
  hairline: 'rgba(255,255,255,0.07)',
  text: '#eaeaf2',
  textDim: 'rgba(234,234,242,0.55)',
  textMute: 'rgba(234,234,242,0.32)',
  light: '#3a3e4c',
  dark: '#1a1c26',
  danger: '#ff5a4c',
  dangerGlow: '#ff6b5e',
  rescue: '#5ee2c0',
  rescueGlow: '#88f0d0',
  accent: '#8aa1ff',
  display: '"Inter Tight", Inter, system-ui, sans-serif',
  mono: 'ui-monospace, "JetBrains Mono", monospace',
};

const t4Theme = {
  light: T4.light,
  dark: T4.dark,
  danger: T4.danger,
  rescue: T4.rescue,
  select: T4.accent,
  gridLines: true,
  squareInset: 'inset 0 0 0 0.5px rgba(255,255,255,0.025)',
  boardShadow: '0 30px 60px rgba(0,0,0,0.55), 0 0 0 1px rgba(255,255,255,0.04)',
  piecePalette: {
    light: '#eaeaf2',
    dark: '#0c0d14',
    lightStroke: 'rgba(12,13,20,0.55)',
    darkStroke: 'rgba(234,234,242,0.22)',
    boardLight: T4.light,
    sw: 1.15,
  },
};

function T4Status({ label, time, accent }) {
  return (
    <div style={{
      position: 'absolute', top: 32, left: 16, right: 16,
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '8px 14px',
      background: 'rgba(13,14,18,0.7)',
      backdropFilter: 'blur(10px)',
      border: `1px solid ${T4.hairline}`,
      borderRadius: 999,
      fontFamily: T4.mono, fontSize: 10.5, letterSpacing: '0.14em', color: T4.textDim,
      textTransform: 'uppercase',
      zIndex: 4,
    }}>
      <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', background: accent || T4.text,
          boxShadow: accent ? `0 0 8px ${accent}` : 'none' }} />
        {label}
      </span>
      <span style={{ color: accent || T4.textDim }}>{time}</span>
    </div>
  );
}

// ── 4A · HOME ────────────────────────────────────────────────
function T4Home() {
  return (
    <Phone bg={T4.bg} statusBarColor={T4.textDim}>
      {/* atmospheric backdrop */}
      <div style={{ position: 'absolute', inset: 0,
        background: `radial-gradient(90% 60% at 50% 18%, #1a1e2c 0%, ${T4.bg} 70%)` }} />
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.05 }}>
        <pattern id="t4g" width="32" height="32" patternUnits="userSpaceOnUse">
          <path d="M32 0H0V32" fill="none" stroke="#fff" strokeWidth="0.5" />
        </pattern>
        <rect width="100%" height="100%" fill="url(#t4g)" />
      </svg>

      <div style={{ position: 'absolute', top: 60, left: 0, right: 0,
        textAlign: 'center', fontFamily: T4.mono, fontSize: 10, letterSpacing: '0.32em',
        color: T4.textMute, textTransform: 'uppercase' }}>
        chess rescue
      </div>

      <div style={{
        position: 'absolute', top: 102, left: 0, right: 0, textAlign: 'center',
        fontFamily: T4.display, color: T4.text,
      }}>
        <div style={{ fontSize: 42, fontWeight: 600, lineHeight: 0.98, letterSpacing: '-0.025em' }}>
          Your king<br/>
          <span style={{ color: T4.danger }}>is cornered.</span>
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 240, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ position: 'relative' }}>
          <div style={{
            position: 'absolute', inset: -40,
            background: `radial-gradient(50% 50% at 50% 50%, ${T4.danger}33 0%, transparent 65%)`,
            filter: 'blur(20px)',
          }} />
          <Board size={224} theme={t4Theme} state="danger" />
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 504, left: 32, right: 32, textAlign: 'center',
        fontFamily: T4.display, fontSize: 13.5, color: T4.textDim, lineHeight: 1.55,
      }}>
        Find the one move that saves the game.
      </div>

      <button style={{
        position: 'absolute', bottom: 92, left: 24, right: 24,
        padding: '17px',
        background: `linear-gradient(180deg, ${T4.text} 0%, #c8c8d6 100%)`,
        color: T4.bg,
        border: 'none',
        borderRadius: 12,
        fontFamily: T4.display, fontSize: 15, fontWeight: 600,
        letterSpacing: '0.02em',
        cursor: 'pointer',
        boxShadow: `0 8px 24px rgba(0,0,0,0.4)`,
      }}>
        Enter the rescue
      </button>

      <div style={{
        position: 'absolute', bottom: 30, left: 0, right: 0, textAlign: 'center',
        fontFamily: T4.mono, fontSize: 10, letterSpacing: '0.18em', color: T4.textMute,
        textTransform: 'uppercase',
      }}>
        014  ·  streak 3  ·  offline
      </div>
    </Phone>
  );
}

// ── 4B · GAMEPLAY / DANGER ───────────────────────────────────
function T4Gameplay() {
  return (
    <Phone bg={T4.bg} statusBarColor={T4.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `radial-gradient(80% 50% at 50% 40%, #1a1c28 0%, ${T4.bg} 80%)` }} />

      <T4Status label="▮ ACTIVE THREAT · Qg2#" time="00:23" accent={T4.danger} />

      <div style={{
        position: 'absolute', top: 96, left: 0, right: 0, textAlign: 'center',
        fontFamily: T4.display, fontSize: 22, fontWeight: 600, color: T4.text,
        letterSpacing: '-0.01em',
      }}>
        Save the king.
      </div>

      <div style={{
        position: 'absolute', top: 142, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ position: 'relative' }}>
          <div style={{
            position: 'absolute', inset: -16,
            background: `radial-gradient(50% 40% at 75% 80%, ${T4.danger}3a 0%, transparent 65%)`,
            filter: 'blur(16px)',
          }} />
          <Board size={324} theme={t4Theme} state="danger" showThreatLines showCoords />
        </div>
      </div>

      {/* threat read */}
      <div style={{
        position: 'absolute', top: 492, left: 16, right: 16,
        padding: '12px 16px',
        background: T4.surface,
        border: `1px solid ${T4.hairline}`,
        borderRadius: 12,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        fontFamily: T4.display, color: T4.text,
      }}>
        <div>
          <div style={{ fontSize: 11, fontFamily: T4.mono, letterSpacing: '0.14em',
            color: T4.danger, textTransform: 'uppercase' }}>
            mate threat
          </div>
          <div style={{ fontSize: 14, marginTop: 2, fontWeight: 500 }}>
            One move stops it.
          </div>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          {['HINT', 'UNDO'].map(t => (
            <button key={t} style={{
              padding: '8px 10px',
              background: 'transparent',
              border: `1px solid ${T4.hairline}`,
              color: T4.textDim,
              borderRadius: 8,
              fontFamily: T4.mono, fontSize: 9.5, letterSpacing: '0.14em',
            }}>{t}</button>
          ))}
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 30, left: 24, right: 24, height: 3,
        background: 'rgba(255,255,255,0.08)', borderRadius: 2, overflow: 'hidden',
      }}>
        <div style={{ width: '38%', height: '100%', background: T4.danger,
          boxShadow: `0 0 8px ${T4.danger}` }} />
      </div>
    </Phone>
  );
}

// ── 4C · RESCUE (cinematic moment) ──────────────────────────
function T4Rescue() {
  const post = PUZZLE.pieces
    .filter(p => !(p.file === 4 && p.rank === 3))
    .concat([{ type: 'N', color: 'light', file: 5, rank: 5 }]);
  return (
    <Phone bg={T4.bg} statusBarColor={T4.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `radial-gradient(70% 50% at 50% 38%, #0e2a23 0%, ${T4.bg} 80%)` }} />

      <T4Status label="◐ ATTACK BROKEN · Nf6+" time="RESCUED" accent={T4.rescue} />

      <div style={{
        position: 'absolute', top: 90, left: 0, right: 0,
        textAlign: 'center', fontFamily: T4.display,
        color: T4.text,
      }}>
        <div style={{ fontSize: 56, fontWeight: 700, lineHeight: 0.95, letterSpacing: '-0.03em' }}>
          Rescued.
        </div>
        <div style={{ marginTop: 8, fontFamily: T4.mono, fontSize: 11, letterSpacing: '0.2em',
          color: T4.rescue, textTransform: 'uppercase' }}>
          knight to f6 · check & fork
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 220, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ position: 'relative' }}>
          <div style={{
            position: 'absolute', inset: -20,
            background: `radial-gradient(50% 40% at 60% 40%, ${T4.rescue}40 0%, transparent 70%)`,
            filter: 'blur(20px)',
          }} />
          <Board size={300} theme={t4Theme} position={post} state="rescue" />
        </div>
      </div>

      {/* streak stat */}
      <div style={{
        position: 'absolute', top: 540, left: 16, right: 16,
        padding: 14,
        background: T4.surface,
        border: `1px solid ${T4.hairline}`,
        borderRadius: 12,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        fontFamily: T4.display, color: T4.text,
      }}>
        <div>
          <div style={{ fontSize: 10, fontFamily: T4.mono, letterSpacing: '0.14em',
            color: T4.textMute, textTransform: 'uppercase' }}>streak</div>
          <div style={{ fontSize: 22, fontWeight: 600, marginTop: 2 }}>3 rescues</div>
        </div>
        <div style={{ display: 'flex', gap: 6 }}>
          {[1,1,1,0,0].map((on, i) => (
            <span key={i} style={{
              width: 14, height: 14, borderRadius: 3,
              background: on ? T4.rescue : 'rgba(255,255,255,0.08)',
              boxShadow: on ? `0 0 6px ${T4.rescue}77` : 'none',
            }} />
          ))}
        </div>
      </div>

      <button style={{
        position: 'absolute', bottom: 28, left: 16, right: 16,
        padding: '17px',
        background: T4.rescue,
        color: '#062019',
        border: 'none',
        borderRadius: 12,
        fontFamily: T4.display, fontSize: 14, fontWeight: 600,
        letterSpacing: '0.04em',
        cursor: 'pointer',
        boxShadow: `0 12px 28px ${T4.rescue}44`,
      }}>
        Next rescue ↦
      </button>
    </Phone>
  );
}

// ── 4D · RETRY ───────────────────────────────────────────────
function T4Retry() {
  return (
    <Phone bg={T4.bg} statusBarColor={T4.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `radial-gradient(70% 50% at 50% 38%, #2a1410 0%, ${T4.bg} 80%)` }} />

      <T4Status label="▮ STILL TRAPPED" time="0:08" accent={T4.danger} />

      <div style={{
        position: 'absolute', top: 90, left: 0, right: 0,
        textAlign: 'center', fontFamily: T4.display, color: T4.text,
      }}>
        <div style={{ fontSize: 46, fontWeight: 700, lineHeight: 0.98, letterSpacing: '-0.03em' }}>
          Not yet.
        </div>
        <div style={{ marginTop: 6, fontFamily: T4.display, fontSize: 13, color: T4.textDim }}>
          The king is still in check.
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 198, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <Board size={300} theme={t4Theme} state="failed" showThreatLines />
      </div>

      <div style={{
        position: 'absolute', top: 520, left: 24, right: 24, textAlign: 'center',
        fontFamily: T4.display, fontSize: 13.5, color: T4.textDim, lineHeight: 1.55,
      }}>
        Try a counter-attack. The rescue is often the most aggressive move.
      </div>

      <div style={{
        position: 'absolute', bottom: 28, left: 16, right: 16,
        display: 'flex', gap: 10,
      }}>
        <button style={{
          flex: 1, padding: '15px', background: 'transparent',
          color: T4.text, border: `1px solid ${T4.hairline}`,
          borderRadius: 12, fontFamily: T4.display, fontSize: 13, fontWeight: 500,
        }}>Hint</button>
        <button style={{
          flex: 2, padding: '15px', background: T4.text, color: T4.bg,
          border: 'none', borderRadius: 12, fontFamily: T4.display, fontSize: 13, fontWeight: 600,
        }}>Try again ↺</button>
      </div>
    </Phone>
  );
}

// ── 4E · ONBOARDING ──────────────────────────────────────────
function T4Onboarding() {
  return (
    <Phone bg={T4.bg} statusBarColor={T4.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `radial-gradient(80% 50% at 50% 40%, #1a1c28 0%, ${T4.bg} 80%)` }} />

      <div style={{
        position: 'absolute', top: 60, left: 0, right: 0, textAlign: 'center',
        fontFamily: T4.mono, fontSize: 10, letterSpacing: '0.28em', color: T4.textMute,
        textTransform: 'uppercase',
      }}>
        first rescue · 1 of 3
      </div>

      <div style={{
        position: 'absolute', top: 96, left: 0, right: 0, textAlign: 'center',
        fontFamily: T4.display, fontSize: 26, fontWeight: 600, color: T4.text,
        letterSpacing: '-0.015em',
      }}>
        Your knight has a move.
      </div>

      <div style={{
        position: 'absolute', top: 162, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
        position: 'relative',
      }}>
        <Board
          size={300}
          theme={t4Theme}
          state="danger"
          showThreatLines
          showRescueArrow
        />
      </div>

      <div style={{
        position: 'absolute', top: 502, left: 28, right: 28, textAlign: 'center',
        fontFamily: T4.display, fontSize: 14, color: T4.textDim, lineHeight: 1.55,
      }}>
        Tap the highlighted knight, then tap the green square.
        That's your rescue.
      </div>

      <div style={{
        position: 'absolute', bottom: 28, left: 24, right: 24,
        display: 'flex', gap: 6, alignItems: 'center',
      }}>
        <div style={{ display: 'flex', gap: 6, flex: 1 }}>
          {[0,1,2].map(i => (
            <span key={i} style={{
              flex: 1, height: 3,
              background: i === 0 ? T4.rescue : 'rgba(255,255,255,0.12)',
              borderRadius: 2,
              boxShadow: i === 0 ? `0 0 6px ${T4.rescue}77` : 'none',
            }} />
          ))}
        </div>
      </div>
    </Phone>
  );
}

// ── 4F · PLAY STORE SCREENSHOT ───────────────────────────────
function T4Screenshot() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(60% 50% at 25% 25%, #2a1916 0%, ${T4.bg} 60%, #050608 100%)`,
      padding: '48px 52px',
      fontFamily: T4.display,
      color: T4.text,
      position: 'relative',
      overflow: 'hidden',
    }}>
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.06 }}>
        <pattern id="t4sg" width="40" height="40" patternUnits="userSpaceOnUse">
          <path d="M40 0H0V40" fill="none" stroke="#fff" strokeWidth="0.5" />
        </pattern>
        <rect width="100%" height="100%" fill="url(#t4sg)" />
      </svg>

      <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div style={{ fontFamily: T4.mono, fontSize: 13, letterSpacing: '0.22em',
          color: T4.danger, textTransform: 'uppercase' }}>
          ▮ ACTIVE THREAT
        </div>
        <div style={{ fontSize: 76, fontWeight: 700, lineHeight: 0.92,
          letterSpacing: '-0.035em', marginTop: 14 }}>
          One move.<br/>
          <span style={{ color: T4.rescue }}>Or you lose.</span>
        </div>

        <div style={{ marginTop: 'auto', display: 'flex', gap: 32, alignItems: 'flex-end' }}>
          <div style={{ width: 300, transform: 'rotate(-2.5deg)' }}>
            <Phone width={300} height={620} bg={T4.bg} statusBarColor={T4.textDim}>
              <div style={{ position: 'absolute', inset: 0,
                background: `radial-gradient(80% 50% at 50% 40%, #1a1c28 0%, ${T4.bg} 80%)` }} />
              <T4Status label="▮ THREAT" time="00:23" accent={T4.danger} />
              <div style={{ position: 'absolute', top: 100, left: 0, right: 0,
                textAlign: 'center', fontSize: 18, fontWeight: 600, color: T4.text }}>
                Save the king.
              </div>
              <div style={{ position: 'absolute', top: 140, left: 0, right: 0,
                display: 'flex', justifyContent: 'center' }}>
                <Board size={272} theme={t4Theme} state="danger" showThreatLines />
              </div>
            </Phone>
          </div>
          <div style={{ flex: 1, paddingBottom: 20 }}>
            <div style={{ fontFamily: T4.mono, fontSize: 11.5, letterSpacing: '0.18em',
              color: T4.textDim, textTransform: 'uppercase', marginBottom: 12 }}>
              30-second comeback puzzles
            </div>
            <div style={{ fontSize: 16, lineHeight: 1.5, color: T4.text }}>
              Drop into danger.<br/>
              Find the clutch move.<br/>
              Survive.
            </div>
            <div style={{ display: 'flex', gap: 8, marginTop: 24 }}>
              {['OFFLINE', 'NO ADS', 'NO ACCOUNT'].map(t => (
                <span key={t} style={{
                  padding: '8px 12px',
                  border: `1px solid ${T4.hairline}`,
                  borderRadius: 999,
                  fontFamily: T4.mono, fontSize: 9, letterSpacing: '0.18em',
                  color: T4.textDim,
                }}>{t}</span>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── 4G · APP ICON ────────────────────────────────────────────
function T4Icon() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(70% 70% at 50% 45%, #20242e 0%, ${T4.bg} 80%)`,
      borderRadius: 36,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
    }}>
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.08 }}>
        <pattern id="t4ig" width="16" height="16" patternUnits="userSpaceOnUse">
          <path d="M16 0H0V16" fill="none" stroke="#fff" strokeWidth="0.5" />
        </pattern>
        <rect width="100%" height="100%" fill="url(#t4ig)" />
      </svg>
      {/* danger pulse */}
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(36% 36% at 50% 60%, ${T4.danger}44 0%, transparent 65%)`,
      }} />
      <div style={{ position: 'relative', color: T4.text,
        filter: `drop-shadow(0 6px 16px rgba(0,0,0,0.6))` }}>
        <Piece type="K" color="light" size={108} palette={t4Theme.piecePalette} />
      </div>
      {/* small rescue accent square in bottom-right */}
      <div style={{
        position: 'absolute', bottom: 22, right: 22,
        width: 16, height: 16, borderRadius: 4, background: T4.rescue,
        boxShadow: `0 0 14px ${T4.rescue}aa`,
      }} />
    </div>
  );
}

window.D4 = { T4Home, T4Gameplay, T4Rescue, T4Retry, T4Onboarding, T4Screenshot, T4Icon, T4 };
