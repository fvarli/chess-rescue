// d3-calm.jsx — Direction 3: CALM DANGER / RESTRAINED DRAMA
// Quiet, muted, mature. Danger reads as inward pressure (deep slate + amber
// warm pulse) rather than alarm red. Retention-optimized: long sessions don't
// fatigue the eye. Decompression-first.

const T3 = {
  bg: '#171a1c',          // soft warm-charcoal
  bgRaise: '#1f2326',
  surface: '#252a2d',
  text: '#ece4d4',        // warm bone
  textDim: 'rgba(236,228,212,0.55)',
  textMute: 'rgba(236,228,212,0.35)',
  light: '#cfc6b2',       // warm stone
  dark: '#3a4146',        // muted slate
  danger: '#e5a64b',      // amber, not red
  dangerDeep: '#c97e2c',
  rescue: '#94c4a3',      // sage
  rescueDeep: '#5d9f74',
  sans: '"Inter Tight", Inter, -apple-system, system-ui, sans-serif',
};

const t3Theme = {
  light: T3.light,
  dark: T3.dark,
  danger: T3.danger,
  rescue: T3.rescue,
  select: '#a7b5c4',
  boardShadow: '0 8px 24px rgba(0,0,0,0.3)',
  piecePalette: {
    light: '#ece4d4',
    dark: '#1f2326',
    lightStroke: 'rgba(31,35,38,0.5)',
    darkStroke: 'rgba(236,228,212,0.18)',
    boardLight: T3.light,
    sw: 1.1,
  },
};

// ── 3A · HOME ────────────────────────────────────────────────
function T3Home() {
  return (
    <Phone bg={T3.bg} statusBarColor={T3.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `linear-gradient(180deg, ${T3.bg} 0%, ${T3.bgRaise} 100%)` }} />

      <div style={{ position: 'absolute', top: 56, left: 0, right: 0,
        textAlign: 'center', fontFamily: T3.sans, fontSize: 11, letterSpacing: '0.24em',
        color: T3.textMute, textTransform: 'uppercase' }}>
        chess rescue
      </div>

      <div style={{
        position: 'absolute', top: 110, left: 28, right: 28,
        fontFamily: T3.sans, color: T3.text,
      }}>
        <div style={{ fontSize: 32, fontWeight: 500, lineHeight: 1.1, letterSpacing: '-0.02em' }}>
          A small puzzle<br/>
          <span style={{ color: T3.danger, fontWeight: 400, fontStyle: 'italic' }}>that wants out.</span>
        </div>
        <div style={{ marginTop: 14, fontSize: 14, color: T3.textDim, lineHeight: 1.55 }}>
          Today's rescue is ready.<br/>
          One move. About a minute of your day.
        </div>
      </div>

      {/* card with mini board */}
      <div style={{
        position: 'absolute', top: 264, left: 24, right: 24,
        background: T3.surface,
        borderRadius: 18,
        padding: 22,
        display: 'flex', flexDirection: 'column', gap: 16,
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
          fontFamily: T3.sans }}>
          <div style={{ color: T3.text }}>
            <div style={{ fontSize: 12, letterSpacing: '0.16em', color: T3.textMute, textTransform: 'uppercase' }}>
              today's rescue
            </div>
            <div style={{ fontSize: 18, fontWeight: 500, marginTop: 4 }}>Puzzle 014</div>
          </div>
          <span style={{
            fontSize: 11, letterSpacing: '0.16em', color: T3.danger,
            textTransform: 'uppercase',
          }}>
            ◑ pressure
          </span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <Board size={200} theme={t3Theme} state="danger" />
        </div>
      </div>

      <button style={{
        position: 'absolute', bottom: 100, left: 24, right: 24,
        padding: '16px',
        background: T3.text,
        color: T3.bg,
        border: 'none',
        borderRadius: 999,
        fontFamily: T3.sans,
        fontSize: 14,
        fontWeight: 500,
        cursor: 'pointer',
      }}>
        Begin
      </button>

      <div style={{
        position: 'absolute', bottom: 60, left: 0, right: 0,
        textAlign: 'center', fontFamily: T3.sans, fontSize: 11, color: T3.textMute,
        letterSpacing: '0.08em',
      }}>
        streak · 3 days  ·  no account needed
      </div>
    </Phone>
  );
}

// ── 3B · GAMEPLAY / DANGER ───────────────────────────────────
function T3Gameplay() {
  return (
    <Phone bg={T3.bg} statusBarColor={T3.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `linear-gradient(180deg, ${T3.bg} 0%, ${T3.bgRaise} 100%)` }} />

      {/* header */}
      <div style={{
        position: 'absolute', top: 44, left: 24, right: 24,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        fontFamily: T3.sans,
      }}>
        <button style={{
          background: 'transparent', border: 'none', color: T3.textDim,
          fontSize: 16, padding: 0, cursor: 'pointer',
        }}>×</button>
        <div style={{ fontSize: 11, letterSpacing: '0.18em', color: T3.textMute,
          textTransform: 'uppercase' }}>
          puzzle 014
        </div>
        <div style={{ fontSize: 11, letterSpacing: '0.1em', color: T3.danger,
          display: 'flex', gap: 4, alignItems: 'center' }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: T3.danger,
            animation: 'cr-dangerPulse 1.8s ease-in-out infinite' }} />
          0:23
        </div>
      </div>

      {/* subtle pressure ring around the board area */}
      <div style={{
        position: 'absolute', top: 120, left: 16, right: 16,
        padding: 14,
        borderRadius: 14,
        background: T3.surface,
        boxShadow: `0 0 0 1px rgba(229,166,75,0.08), 0 24px 60px rgba(0,0,0,0.4)`,
      }}>
        <div style={{
          display: 'flex', justifyContent: 'space-between',
          fontFamily: T3.sans, fontSize: 11.5, color: T3.textDim, marginBottom: 12,
        }}>
          <span>black</span>
          <span style={{ color: T3.danger }}>threatens mate</span>
        </div>
        <Board size={296} theme={t3Theme} state="danger" />
        <div style={{
          display: 'flex', justifyContent: 'space-between', marginTop: 12,
          fontFamily: T3.sans, fontSize: 11.5, color: T3.text,
        }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: T3.text }} />
            white (you)
          </span>
          <span style={{ color: T3.textDim }}>to move</span>
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 502, left: 24, right: 24,
        fontFamily: T3.sans, color: T3.text,
      }}>
        <div style={{ fontSize: 18, fontWeight: 500, lineHeight: 1.3,
          letterSpacing: '-0.01em' }}>
          One move can hold the line.
        </div>
        <div style={{ marginTop: 4, fontSize: 13, color: T3.textDim }}>
          Tap a piece to see where it can go.
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 28, left: 24, right: 24,
        display: 'flex', gap: 10,
      }}>
        <button style={{
          flex: 1, padding: '14px', background: 'transparent',
          color: T3.textDim, border: `1px solid rgba(236,228,212,0.12)`,
          borderRadius: 999, fontFamily: T3.sans, fontSize: 13,
        }}>Hint</button>
        <button style={{
          flex: 1, padding: '14px', background: 'transparent',
          color: T3.textDim, border: `1px solid rgba(236,228,212,0.12)`,
          borderRadius: 999, fontFamily: T3.sans, fontSize: 13,
        }}>Reset</button>
      </div>
    </Phone>
  );
}

// ── 3C · RESCUE ──────────────────────────────────────────────
function T3Rescue() {
  const post = PUZZLE.pieces
    .filter(p => !(p.file === 4 && p.rank === 3))
    .concat([{ type: 'N', color: 'light', file: 5, rank: 5 }]);
  return (
    <Phone bg={T3.bg} statusBarColor={T3.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `linear-gradient(180deg, #1b2421 0%, ${T3.bg} 100%)` }} />

      <div style={{
        position: 'absolute', top: 88, left: 28, right: 28,
        fontFamily: T3.sans, color: T3.text,
      }}>
        <div style={{ fontSize: 11, letterSpacing: '0.22em', color: T3.rescue,
          textTransform: 'uppercase' }}>
          ◐ attack broken
        </div>
        <div style={{ fontSize: 38, fontWeight: 500, lineHeight: 1, letterSpacing: '-0.02em',
          marginTop: 8 }}>
          You held<br/>
          <span style={{ fontStyle: 'italic', fontWeight: 400, color: T3.rescue }}>
            the line.
          </span>
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 240, left: 16, right: 16,
        padding: 14,
        borderRadius: 14,
        background: T3.surface,
      }}>
        <Board size={296} theme={t3Theme} position={post} state="rescue" />
      </div>

      <div style={{
        position: 'absolute', top: 568, left: 28, right: 28,
        fontFamily: T3.sans, fontSize: 13, color: T3.textDim, lineHeight: 1.55,
      }}>
        Knight to f6 — a check that forks the king and queen.
        The attack is over.
      </div>

      <button style={{
        position: 'absolute', bottom: 28, left: 24, right: 24,
        padding: '16px',
        background: T3.rescue,
        color: '#0e1a14',
        border: 'none',
        borderRadius: 999,
        fontFamily: T3.sans,
        fontSize: 14,
        fontWeight: 500,
        cursor: 'pointer',
      }}>
        Next rescue
      </button>
    </Phone>
  );
}

// ── 3D · RETRY ───────────────────────────────────────────────
function T3Retry() {
  return (
    <Phone bg={T3.bg} statusBarColor={T3.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `linear-gradient(180deg, ${T3.bg} 0%, ${T3.bgRaise} 100%)` }} />

      <div style={{
        position: 'absolute', top: 88, left: 28, right: 28,
        fontFamily: T3.sans, color: T3.text,
      }}>
        <div style={{ fontSize: 11, letterSpacing: '0.22em', color: T3.danger,
          textTransform: 'uppercase' }}>
          ◑ the pressure holds
        </div>
        <div style={{ fontSize: 34, fontWeight: 500, lineHeight: 1.05, letterSpacing: '-0.02em',
          marginTop: 8 }}>
          Not the move,<br/>
          <span style={{ fontStyle: 'italic', fontWeight: 400, color: T3.textDim }}>
            but you're close.
          </span>
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 252, left: 16, right: 16,
        padding: 14,
        borderRadius: 14,
        background: T3.surface,
      }}>
        <Board size={296} theme={t3Theme} state="failed" />
      </div>

      <div style={{
        position: 'absolute', top: 568, left: 28, right: 28,
        fontFamily: T3.sans, fontSize: 13, color: T3.textDim, lineHeight: 1.55,
      }}>
        The king is still in check. Look for a move that attacks back —
        sometimes the rescue is offense.
      </div>

      <div style={{
        position: 'absolute', bottom: 28, left: 24, right: 24,
        display: 'flex', gap: 10,
      }}>
        <button style={{
          flex: 1, padding: '14px', background: 'transparent',
          color: T3.text, border: `1px solid rgba(236,228,212,0.18)`,
          borderRadius: 999, fontFamily: T3.sans, fontSize: 13,
        }}>Show hint</button>
        <button style={{
          flex: 1.6, padding: '14px', background: T3.text, color: T3.bg,
          border: 'none', borderRadius: 999, fontFamily: T3.sans, fontSize: 13, fontWeight: 500,
        }}>Try again</button>
      </div>
    </Phone>
  );
}

// ── 3E · ONBOARDING ──────────────────────────────────────────
function T3Onboarding() {
  return (
    <Phone bg={T3.bg} statusBarColor={T3.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `linear-gradient(180deg, ${T3.bg} 0%, ${T3.bgRaise} 100%)` }} />

      <div style={{
        position: 'absolute', top: 72, left: 28, right: 28,
        fontFamily: T3.sans, color: T3.text,
      }}>
        <div style={{ fontSize: 11, letterSpacing: '0.22em', color: T3.textMute,
          textTransform: 'uppercase' }}>
          step one of three
        </div>
        <div style={{ fontSize: 26, fontWeight: 500, lineHeight: 1.2,
          letterSpacing: '-0.01em', marginTop: 8 }}>
          You start in trouble.
        </div>
        <div style={{ marginTop: 8, fontSize: 13, color: T3.textDim, lineHeight: 1.55 }}>
          Every puzzle drops you into danger.
          The dot below is your king. The orange glow is the threat.
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 252, left: 16, right: 16,
        padding: 14,
        borderRadius: 14,
        background: T3.surface,
        position: 'relative',
      }}>
        <Board size={296} theme={t3Theme} state="danger" showThreatLines />
        {/* coachmark */}
        <div style={{
          position: 'absolute', top: 220, right: -8,
          padding: '8px 12px',
          background: T3.danger,
          color: '#1a120a',
          borderRadius: 8,
          fontFamily: T3.sans, fontSize: 11, fontWeight: 500,
          boxShadow: '0 6px 18px rgba(0,0,0,0.4)',
        }}>
          ← your king
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 100, left: 28, right: 28, textAlign: 'center',
        fontFamily: T3.sans, fontSize: 12, color: T3.textMute,
      }}>
        no signups · no jargon · no tutorials longer than this
      </div>

      <div style={{
        position: 'absolute', bottom: 28, left: 24, right: 24,
        display: 'flex', gap: 6, alignItems: 'center',
      }}>
        <div style={{ display: 'flex', gap: 6, flex: 1 }}>
          {[0,1,2].map(i => (
            <span key={i} style={{
              flex: 1, height: 3,
              background: i === 0 ? T3.text : 'rgba(236,228,212,0.18)',
              borderRadius: 2,
            }} />
          ))}
        </div>
        <span style={{ fontFamily: T3.sans, fontSize: 12, color: T3.textDim,
          marginLeft: 16 }}>Continue →</span>
      </div>
    </Phone>
  );
}

// ── 3F · PLAY STORE SCREENSHOT ───────────────────────────────
function T3Screenshot() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `linear-gradient(160deg, ${T3.bg} 0%, ${T3.bgRaise} 60%, #2a2418 100%)`,
      padding: '60px 56px',
      fontFamily: T3.sans,
      color: T3.text,
      position: 'relative',
      overflow: 'hidden',
    }}>
      <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div style={{ fontSize: 13, letterSpacing: '0.28em', color: T3.textMute,
          textTransform: 'uppercase' }}>
          a short comeback every day
        </div>
        <div style={{ fontSize: 60, fontWeight: 500, lineHeight: 1.02,
          letterSpacing: '-0.025em', marginTop: 18 }}>
          One puzzle.<br/>
          One minute.<br/>
          <span style={{ color: T3.danger, fontStyle: 'italic', fontWeight: 400 }}>
            One way out.
          </span>
        </div>

        <div style={{ marginTop: 'auto', display: 'flex', gap: 36, alignItems: 'flex-end' }}>
          <div style={{ width: 290, transform: 'rotate(-1.5deg)' }}>
            <Phone width={290} height={600} bg={T3.bg} statusBarColor={T3.textDim}>
              <div style={{ position: 'absolute', inset: 0,
                background: `linear-gradient(180deg, ${T3.bg} 0%, ${T3.bgRaise} 100%)` }} />
              <div style={{
                position: 'absolute', top: 60, left: 0, right: 0, textAlign: 'center',
                fontFamily: T3.sans, fontSize: 11, letterSpacing: '0.2em', color: T3.danger,
                textTransform: 'uppercase',
              }}>
                ◑ pressure
              </div>
              <div style={{ position: 'absolute', top: 96, left: 14, right: 14,
                padding: 12, borderRadius: 12, background: T3.surface }}>
                <Board size={250} theme={t3Theme} state="danger" />
              </div>
              <div style={{
                position: 'absolute', bottom: 80, left: 24, right: 24, textAlign: 'center',
                fontFamily: T3.sans, fontSize: 14, color: T3.text, fontStyle: 'italic',
              }}>
                Find the one move.
              </div>
            </Phone>
          </div>
          <div style={{ flex: 1, paddingBottom: 20 }}>
            <div style={{ fontSize: 15, color: T3.textDim, lineHeight: 1.7 }}>
              Comeback chess puzzles<br/>
              for short, calm sessions.<br/><br/>
              No tournaments. No rating.<br/>
              Just one rescue at a time.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── 3G · APP ICON ────────────────────────────────────────────
function T3Icon() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `linear-gradient(155deg, ${T3.bgRaise} 0%, #2a1d10 100%)`,
      borderRadius: 36,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
    }}>
      {/* warm pulse */}
      <div style={{
        position: 'absolute', inset: 0,
        background: `radial-gradient(50% 50% at 50% 60%, ${T3.danger}30 0%, transparent 70%)`,
      }} />
      <div style={{ color: T3.text }}>
        <Piece type="K" color="light" size={100} palette={t3Theme.piecePalette} />
      </div>
    </div>
  );
}

window.D3 = { T3Home, T3Gameplay, T3Rescue, T3Retry, T3Onboarding, T3Screenshot, T3Icon, T3 };
