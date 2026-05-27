// d1-tactical.jsx — Direction 1: TACTICAL SCI-FI RESTRAINT
// Dark matte neutrals, precise typography, restrained tactical accents.
// The board is treated as a HUD: minimal chrome, monospace captions,
// surgical red/cyan accents, no chrome decoration.

const T1 = {
  bg: '#0a0c10',
  surface: '#11141a',
  surfaceHi: '#171b22',
  hairline: 'rgba(255,255,255,0.06)',
  text: '#e8e6df',
  textDim: 'rgba(232,230,223,0.55)',
  textMute: 'rgba(232,230,223,0.35)',
  light: '#2d3038',     // light board square
  dark: '#161922',      // dark board square
  danger: '#ff4538',
  dangerSoft: '#ff6f4e',
  rescue: '#6fe0c0',
  rescueSoft: '#9ff0d8',
  accent: '#7b9cff',    // selection
  mono: 'ui-monospace, "JetBrains Mono", "SF Mono", monospace',
  sans: 'Inter, -apple-system, system-ui, sans-serif',
};

const t1Theme = {
  light: T1.light,
  dark: T1.dark,
  danger: T1.danger,
  rescue: T1.rescue,
  select: T1.accent,
  gridLines: true,
  squareInset: 'inset 0 0 0 0.5px rgba(255,255,255,0.02)',
  piecePalette: {
    light: '#e8e6df',
    dark: '#0c0d12',
    lightStroke: 'rgba(10,12,16,0.55)',
    darkStroke: 'rgba(232,230,223,0.22)',
    boardLight: T1.light,
    sw: 1.1,
  },
};

// Shared chrome row — top status bar inside phone content
function T1TopBar({ left = 'PUZZLE 014', right = '00:23', glow }) {
  return (
    <div style={{
      position: 'absolute', top: 32, left: 0, right: 0,
      height: 40, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 20px', fontFamily: T1.mono, fontSize: 10.5, letterSpacing: '0.14em',
      color: T1.textDim, textTransform: 'uppercase', zIndex: 4,
    }}>
      <span>{left}</span>
      <span style={{ color: glow || T1.textDim }}>{right}</span>
    </div>
  );
}

function T1ChipRow({ items }) {
  return (
    <div style={{
      display: 'flex', gap: 6, justifyContent: 'center',
      fontFamily: T1.mono, fontSize: 9.5, letterSpacing: '0.12em',
      color: T1.textMute, textTransform: 'uppercase',
    }}>
      {items.map((it, i) => (
        <span key={i} style={{
          padding: '4px 8px', border: `1px solid ${T1.hairline}`, borderRadius: 3,
          background: 'rgba(255,255,255,0.02)',
        }}>{it}</span>
      ))}
    </div>
  );
}

// ── 1A · HOME ────────────────────────────────────────────────
function T1Home() {
  return (
    <Phone bg={T1.bg} statusBarColor={T1.textDim}>
      <T1TopBar left="CHESS RESCUE" right="OFFLINE" />
      <div style={{
        position: 'absolute', inset: 0, padding: '90px 28px 0',
        display: 'flex', flexDirection: 'column', gap: 24,
        fontFamily: T1.sans, color: T1.text,
      }}>
        <div>
          <div style={{ fontFamily: T1.mono, fontSize: 10, letterSpacing: '0.16em', color: T1.danger, marginBottom: 8 }}>
            ▮ ACTIVE THREAT
          </div>
          <div style={{ fontSize: 34, fontWeight: 600, lineHeight: 1.05, letterSpacing: '-0.02em' }}>
            Your king<br/>is in danger.
          </div>
          <div style={{ marginTop: 12, fontSize: 13, color: T1.textDim, lineHeight: 1.45 }}>
            One move can rescue the position. 30 seconds on the clock.
          </div>
        </div>

        {/* Mini situation tile */}
        <div style={{
          background: T1.surface, border: `1px solid ${T1.hairline}`,
          borderRadius: 10, padding: 14, display: 'flex', gap: 14, alignItems: 'center',
        }}>
          <div style={{
            width: 80, height: 80, background: T1.dark, borderRadius: 6,
            position: 'relative', overflow: 'hidden',
          }}>
            <Board size={80} theme={t1Theme} state="danger" />
          </div>
          <div>
            <div style={{ fontSize: 10, fontFamily: T1.mono, letterSpacing: '0.14em', color: T1.textMute }}>RESUME</div>
            <div style={{ fontSize: 15, fontWeight: 500, marginTop: 2 }}>Puzzle 014</div>
            <div style={{ fontSize: 11, color: T1.textDim, marginTop: 2 }}>Mate in 1 — White to save</div>
          </div>
        </div>

        <button style={{
          marginTop: 'auto',
          marginBottom: 88,
          width: '100%',
          padding: '18px',
          background: T1.text,
          color: T1.bg,
          border: 'none',
          borderRadius: 8,
          fontFamily: T1.sans,
          fontSize: 14,
          fontWeight: 600,
          letterSpacing: '0.04em',
          textTransform: 'uppercase',
          cursor: 'pointer',
        }}>
          Enter rescue ↦
        </button>
      </div>

      {/* bottom tab strip */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, height: 64,
        background: T1.surface, borderTop: `1px solid ${T1.hairline}`,
        display: 'flex', justifyContent: 'space-around', alignItems: 'center',
        fontFamily: T1.mono, fontSize: 9.5, letterSpacing: '0.14em', color: T1.textMute,
        textTransform: 'uppercase',
      }}>
        <span style={{ color: T1.text }}>● RESCUE</span>
        <span>○ STREAK</span>
        <span>○ ARCHIVE</span>
      </div>
    </Phone>
  );
}

// ── 1B · GAMEPLAY / DANGER ───────────────────────────────────
function T1Gameplay({ selected, legal, state = 'danger', showThreatLines = true }) {
  return (
    <Phone bg={T1.bg} statusBarColor={T1.textDim}>
      <T1TopBar left="PUZZLE 014" right="00:23" glow={T1.dangerSoft} />
      <div style={{ position: 'absolute', top: 78, left: 0, right: 0, padding: '0 16px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          fontFamily: T1.mono, fontSize: 10.5, letterSpacing: '0.14em', color: T1.textDim,
        }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: T1.danger,
              boxShadow: `0 0 10px ${T1.danger}` }} />
            CHECK · WHITE TO MOVE
          </span>
          <span style={{ color: T1.textMute }}>MATE-IN-1</span>
        </div>
      </div>

      {/* board */}
      <div style={{ position: 'absolute', top: 120, left: 16, right: 16 }}>
        <Board
          size={328}
          theme={t1Theme}
          state={state}
          showThreatLines={showThreatLines}
          showCoords
          selectedSquare={selected}
          legalSquares={legal || []}
          showLegalDots={!!legal}
        />
      </div>

      {/* threat readout */}
      <div style={{
        position: 'absolute', top: 470, left: 16, right: 16,
        padding: 14, background: T1.surface, border: `1px solid ${T1.hairline}`,
        borderRadius: 8, fontFamily: T1.sans, color: T1.text,
      }}>
        <div style={{ fontSize: 10, fontFamily: T1.mono, letterSpacing: '0.14em', color: T1.danger }}>
          ▮ THREAT · Qg2#
        </div>
        <div style={{ marginTop: 4, fontSize: 13, lineHeight: 1.4, color: T1.text }}>
          Black queen threatens mate. Find the one move that breaks the attack.
        </div>
      </div>

      {/* bottom action chips */}
      <div style={{ position: 'absolute', bottom: 92, left: 0, right: 0 }}>
        <T1ChipRow items={['HINT', 'UNDO', 'RESET']} />
      </div>

      {/* bottom strip */}
      <div style={{
        position: 'absolute', bottom: 24, left: 24, right: 24, height: 4,
        background: 'rgba(255,255,255,0.08)', borderRadius: 2, overflow: 'hidden',
      }}>
        <div style={{ width: '38%', height: '100%', background: T1.danger,
          boxShadow: `0 0 8px ${T1.danger}` }} />
      </div>
    </Phone>
  );
}

// ── 1C · SELECTED (interaction) ──────────────────────────────
function T1Selected() {
  return (
    <T1Gameplay
      selected={SQ(4, 3)}
      legal={[SQ(5, 5), SQ(3, 5), SQ(5, 1), SQ(3, 1), SQ(6, 4), SQ(2, 4), SQ(6, 2), SQ(2, 2)]}
      showThreatLines={false}
      state="selected"
    />
  );
}

// ── 1D · RESCUE ──────────────────────────────────────────────
function T1Rescue() {
  // After move: knight has moved from e4 to f6
  const post = PUZZLE.pieces
    .filter(p => !(p.file === 4 && p.rank === 3))
    .concat([{ type: 'N', color: 'light', file: 5, rank: 5 }]);
  return (
    <Phone bg={T1.bg} statusBarColor={T1.textDim}>
      <T1TopBar left="PUZZLE 014" right="RESCUED" glow={T1.rescue} />
      <div style={{ position: 'absolute', top: 78, left: 0, right: 0, padding: '0 16px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          fontFamily: T1.mono, fontSize: 10.5, letterSpacing: '0.14em', color: T1.rescue,
        }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: T1.rescue,
            boxShadow: `0 0 10px ${T1.rescue}` }} />
          ATTACK BROKEN · Nf6+
        </div>
      </div>

      <div style={{ position: 'absolute', top: 120, left: 16, right: 16 }}>
        <Board
          size={328}
          theme={t1Theme}
          position={post}
          state="rescue"
          showCoords
        />
      </div>

      <div style={{ position: 'absolute', top: 480, left: 16, right: 16, color: T1.text, fontFamily: T1.sans }}>
        <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.01em' }}>Rescued.</div>
        <div style={{ marginTop: 6, fontSize: 13, color: T1.textDim, lineHeight: 1.45 }}>
          Nf6+ forks the king and queen. The attack is broken.
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 24, left: 16, right: 16,
        display: 'flex', gap: 8,
      }}>
        <button style={{
          flex: 1, padding: '16px', background: 'transparent', color: T1.text,
          border: `1px solid ${T1.hairline}`, borderRadius: 8, fontFamily: T1.sans,
          fontSize: 12, fontWeight: 500, letterSpacing: '0.06em', textTransform: 'uppercase',
        }}>Review</button>
        <button style={{
          flex: 2, padding: '16px', background: T1.rescue, color: T1.bg,
          border: 'none', borderRadius: 8, fontFamily: T1.sans,
          fontSize: 12, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase',
        }}>Next rescue ↦</button>
      </div>
    </Phone>
  );
}

// ── 1E · RETRY ───────────────────────────────────────────────
function T1Retry() {
  return (
    <Phone bg={T1.bg} statusBarColor={T1.textDim}>
      <T1TopBar left="PUZZLE 014" right="STILL TRAPPED" glow={T1.dangerSoft} />
      <div style={{ position: 'absolute', top: 78, left: 0, right: 0, padding: '0 16px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          fontFamily: T1.mono, fontSize: 10.5, letterSpacing: '0.14em', color: T1.dangerSoft,
        }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: T1.danger,
            boxShadow: `0 0 10px ${T1.danger}` }} />
          THE DANGER REMAINS
        </div>
      </div>

      <div style={{ position: 'absolute', top: 120, left: 16, right: 16 }}>
        <Board size={328} theme={t1Theme} state="failed" showCoords />
      </div>

      <div style={{ position: 'absolute', top: 480, left: 16, right: 16, color: T1.text, fontFamily: T1.sans }}>
        <div style={{ fontSize: 24, fontWeight: 600, letterSpacing: '-0.01em' }}>Still trapped.</div>
        <div style={{ marginTop: 6, fontSize: 13, color: T1.textDim, lineHeight: 1.45 }}>
          Your king is still in check. Look again — there's one move.
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 24, left: 16, right: 16,
        display: 'flex', gap: 8,
      }}>
        <button style={{
          flex: 1, padding: '16px', background: 'transparent', color: T1.textDim,
          border: `1px solid ${T1.hairline}`, borderRadius: 8, fontFamily: T1.sans,
          fontSize: 12, fontWeight: 500, letterSpacing: '0.06em', textTransform: 'uppercase',
        }}>Show hint</button>
        <button style={{
          flex: 2, padding: '16px', background: T1.text, color: T1.bg,
          border: 'none', borderRadius: 8, fontFamily: T1.sans,
          fontSize: 12, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase',
        }}>Try again ↺</button>
      </div>
    </Phone>
  );
}

// ── 1F · ONBOARDING ──────────────────────────────────────────
function T1Onboarding() {
  return (
    <Phone bg={T1.bg} statusBarColor={T1.textDim}>
      <div style={{
        position: 'absolute', top: 78, left: 0, right: 0,
        textAlign: 'center', fontFamily: T1.mono, fontSize: 10, letterSpacing: '0.18em',
        color: T1.textMute, textTransform: 'uppercase',
      }}>
        FIRST RESCUE · 1 / 5
      </div>

      <div style={{
        position: 'absolute', top: 120, left: 16, right: 16,
        position: 'relative',
      }}>
        <Board size={328} theme={t1Theme} state="danger" showThreatLines showRescueArrow />
        {/* dim overlay everywhere except attacker → king beam — already drawn */}
      </div>

      <div style={{ position: 'absolute', top: 472, left: 24, right: 24, color: T1.text, fontFamily: T1.sans }}>
        <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.01em' }}>
          Your king is under attack.
        </div>
        <div style={{ marginTop: 6, fontSize: 13, color: T1.textDim, lineHeight: 1.45 }}>
          Tap the highlighted knight — it has a move that saves the position.
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 24, left: 24, right: 24,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <div style={{ display: 'flex', gap: 6 }}>
          {[0,1,2,3,4].map(i => (
            <span key={i} style={{
              width: 16, height: 2,
              background: i === 0 ? T1.text : 'rgba(255,255,255,0.18)',
            }} />
          ))}
        </div>
        <span style={{ fontFamily: T1.mono, fontSize: 11, color: T1.textDim, letterSpacing: '0.1em' }}>
          SKIP →
        </span>
      </div>
    </Phone>
  );
}

// ── 1G · PLAY STORE SCREENSHOT ───────────────────────────────
function T1Screenshot() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `radial-gradient(120% 80% at 80% 0%, #1a1e26 0%, ${T1.bg} 55%, #050608 100%)`,
      padding: '52px 48px',
      fontFamily: T1.sans,
      color: T1.text,
      position: 'relative',
      overflow: 'hidden',
    }}>
      {/* subtle grid backdrop */}
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.08 }}>
        <defs>
          <pattern id="t1grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M40 0H0V40" fill="none" stroke={T1.text} strokeWidth="0.5" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#t1grid)" />
      </svg>

      <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div style={{ fontFamily: T1.mono, fontSize: 13, letterSpacing: '0.18em',
          color: T1.danger, textTransform: 'uppercase' }}>
          ▮ MATE IN 1 · 30 SECONDS
        </div>
        <div style={{ fontSize: 56, fontWeight: 700, lineHeight: 1, letterSpacing: '-0.025em', marginTop: 14 }}>
          Find the<br/>one move<br/>
          <span style={{ color: T1.rescue }}>that saves you.</span>
        </div>

        <div style={{ marginTop: 'auto', display: 'flex', gap: 32, alignItems: 'flex-end' }}>
          <div style={{ width: 280, transform: 'rotate(-2deg)' }}>
            <Phone width={280} height={580} bg={T1.bg} statusBarColor={T1.textDim}>
              <T1TopBar left="PUZZLE 014" right="00:23" glow={T1.dangerSoft} />
              <div style={{ position: 'absolute', top: 92, left: 12, right: 12 }}>
                <Board size={256} theme={t1Theme} state="danger" showThreatLines showCoords />
              </div>
              <div style={{
                position: 'absolute', bottom: 60, left: 16, right: 16,
                padding: 10, background: T1.surface, border: `1px solid ${T1.hairline}`,
                borderRadius: 6, color: T1.text,
              }}>
                <div style={{ fontFamily: T1.mono, fontSize: 9, letterSpacing: '0.14em', color: T1.danger }}>
                  ▮ THREAT · Qg2#
                </div>
                <div style={{ fontSize: 11, marginTop: 2, color: T1.textDim }}>One move breaks the attack.</div>
              </div>
            </Phone>
          </div>
          <div style={{ flex: 1, paddingBottom: 12 }}>
            <div style={{
              fontFamily: T1.mono, fontSize: 11, letterSpacing: '0.14em', color: T1.textDim,
              textTransform: 'uppercase', marginBottom: 8,
            }}>NOT A CHESS APP.</div>
            <div style={{ fontSize: 18, lineHeight: 1.35, color: T1.text }}>
              Comeback puzzles<br/>for 30-second sessions.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── 1H · APP ICON ────────────────────────────────────────────
function T1Icon() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: T1.bg,
      borderRadius: 36,
      padding: 24,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: 'inset 0 0 0 1px rgba(255,255,255,0.06)',
      overflow: 'hidden',
      position: 'relative',
    }}>
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0, opacity: 0.1 }}>
        <pattern id="t1ig" width="20" height="20" patternUnits="userSpaceOnUse">
          <path d="M20 0H0V20" fill="none" stroke="#fff" strokeWidth="0.5" />
        </pattern>
        <rect width="100%" height="100%" fill="url(#t1ig)" />
      </svg>
      <div style={{ position: 'relative', color: T1.text }}>
        <Piece type="K" color="light" size={96} palette={t1Theme.piecePalette} />
      </div>
      {/* corner targeting reticle */}
      <div style={{
        position: 'absolute', inset: 18,
        border: `1px solid ${T1.danger}`, borderRadius: 4,
        clipPath: 'polygon(0 0,28% 0,28% 4%,4% 4%,4% 28%,0 28%,0 0, 100% 0,72% 0,72% 4%,96% 4%,96% 28%,100% 28%,100% 0, 0 100%,28% 100%,28% 96%,4% 96%,4% 72%,0 72%,0 100%, 100% 100%,72% 100%,72% 96%,96% 96%,96% 72%,100% 72%,100% 100%)',
      }} />
    </div>
  );
}

window.D1 = { T1Home, T1Gameplay, T1Selected, T1Rescue, T1Retry, T1Onboarding, T1Screenshot, T1Icon, T1 };
