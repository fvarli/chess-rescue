// d5-daily.jsx — Direction 5: CONVERGENCE (Tactical × Calm Danger)
// The "daily-ritual" candidate. Tactical legibility, calm restraint, optimized
// for retention rather than acquisition spectacle. Frames each puzzle as a
// small daily event with stats — danger reads through tone and weight, not
// alarm color saturation.

const T5 = {
  bg: '#16161a',
  paper: '#1e1e23',
  paperHi: '#26262d',
  hairline: 'rgba(255,255,255,0.07)',
  hairlineHi: 'rgba(255,255,255,0.12)',
  text: '#f0ebe1',
  textDim: 'rgba(240,235,225,0.55)',
  textMute: 'rgba(240,235,225,0.32)',
  light: '#d4cab6',
  dark: '#403a35',
  danger: '#d96152',
  dangerSoft: '#e88675',
  rescue: '#7fc7a7',
  rescueDeep: '#56a884',
  // No serif. The editorial feel is carried by italic + a humanist sans
  // weight (400 italic for body, 500/600 for headlines), never serif.
  serif: '"Inter Tight", Inter, system-ui, sans-serif',
  sans: '"Inter Tight", Inter, system-ui, sans-serif',
  mono: 'ui-monospace, "JetBrains Mono", monospace',
};

const t5Theme = {
  light: T5.light,
  dark: T5.dark,
  danger: T5.danger,
  rescue: T5.rescue,
  select: '#c7b993',
  boardShadow: '0 12px 32px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.04)',
  piecePalette: {
    light: '#f0ebe1',
    dark: '#1a1614',
    lightStroke: 'rgba(26,22,20,0.5)',
    darkStroke: 'rgba(240,235,225,0.2)',
    boardLight: T5.light,
    sw: 1.1,
  },
};

function T5Header() {
  return (
    <div style={{
      position: 'absolute', top: 44, left: 24, right: 24,
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      fontFamily: T5.sans,
    }}>
      <div>
        <div style={{ fontFamily: T5.serif, fontSize: 12, fontStyle: 'italic',
          color: T5.textDim, letterSpacing: '0.02em' }}>
          Tuesday, Mar 5
        </div>
        <div style={{ fontSize: 14, fontWeight: 500, color: T5.text, marginTop: 1 }}>
          Daily Rescue
        </div>
      </div>
      <div style={{ fontFamily: T5.mono, fontSize: 11, letterSpacing: '0.14em',
        color: T5.textMute, textTransform: 'uppercase' }}>
        no. 014
      </div>
    </div>
  );
}

// ── 5A · HOME ────────────────────────────────────────────────
function T5Home() {
  return (
    <Phone bg={T5.bg} statusBarColor={T5.textDim}>
      <T5Header />

      <div style={{
        position: 'absolute', top: 110, left: 24, right: 24,
        fontFamily: T5.serif, color: T5.text,
      }}>
        <div style={{ fontSize: 40, fontWeight: 500, lineHeight: 1.0,
          letterSpacing: '-0.025em' }}>
          A short<br/>
          rescue<br/>
          for today.
        </div>
        <div style={{ marginTop: 14, fontSize: 14, fontFamily: T5.sans,
          color: T5.textDim, lineHeight: 1.6 }}>
          You'll start in trouble. One move<br/>
          will get you out.
        </div>
      </div>

      {/* card */}
      <div style={{
        position: 'absolute', top: 320, left: 16, right: 16,
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 14,
        padding: 16,
        display: 'flex', gap: 16, alignItems: 'center',
      }}>
        <Board size={120} theme={t5Theme} state="danger" />
        <div style={{ flex: 1, fontFamily: T5.sans }}>
          <div style={{ fontSize: 10.5, letterSpacing: '0.18em', color: T5.danger,
            textTransform: 'uppercase' }}>
            ◑ today's pressure
          </div>
          <div style={{ fontSize: 17, fontWeight: 500, color: T5.text, marginTop: 6 }}>
            Mate in 1
          </div>
          <div style={{ fontSize: 12, color: T5.textDim, marginTop: 2, lineHeight: 1.5 }}>
            White to move.<br/>
            ~30 seconds to find it.
          </div>
        </div>
      </div>

      {/* stats row */}
      <div style={{
        position: 'absolute', top: 482, left: 16, right: 16,
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 14,
        padding: '14px 18px',
        display: 'flex', justifyContent: 'space-between',
        fontFamily: T5.sans,
      }}>
        {[
          ['streak', '3 d', T5.rescue],
          ['solved', '11', T5.text],
          ['avg time', '0:18', T5.textDim],
        ].map(([label, val, color], i) => (
          <div key={i}>
            <div style={{ fontSize: 9.5, letterSpacing: '0.16em',
              color: T5.textMute, textTransform: 'uppercase' }}>{label}</div>
            <div style={{ fontSize: 18, fontWeight: 500, color,
              marginTop: 4, fontFamily: T5.serif, letterSpacing: '-0.01em' }}>{val}</div>
          </div>
        ))}
      </div>

      <button style={{
        position: 'absolute', bottom: 32, left: 16, right: 16,
        padding: '16px',
        background: T5.text, color: T5.bg,
        border: 'none', borderRadius: 12,
        fontFamily: T5.sans, fontSize: 14, fontWeight: 500,
        letterSpacing: '0.02em', cursor: 'pointer',
      }}>
        Begin today's rescue
      </button>
    </Phone>
  );
}

// ── 5B · GAMEPLAY ────────────────────────────────────────────
function T5Gameplay() {
  return (
    <Phone bg={T5.bg} statusBarColor={T5.textDim}>
      <T5Header />

      <div style={{
        position: 'absolute', top: 102, left: 0, right: 0,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        padding: '0 24px', fontFamily: T5.sans,
      }}>
        <div style={{ display: 'flex', gap: 6, alignItems: 'center',
          fontSize: 11, letterSpacing: '0.16em', color: T5.danger,
          textTransform: 'uppercase' }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: T5.danger,
            animation: 'cr-dangerPulse 1.8s ease-in-out infinite' }} />
          mate threatened
        </div>
        <div style={{ fontFamily: T5.serif, fontSize: 16, fontStyle: 'italic',
          color: T5.textDim }}>0:23</div>
      </div>

      {/* board in paper card */}
      <div style={{
        position: 'absolute', top: 140, left: 16, right: 16,
        padding: 14,
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 14,
      }}>
        <Board size={296} theme={t5Theme} state="danger" showCoords />
      </div>

      {/* hint card */}
      <div style={{
        position: 'absolute', top: 484, left: 16, right: 16,
        padding: '14px 18px',
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 14,
      }}>
        <div style={{ fontFamily: T5.serif, fontSize: 16, fontStyle: 'italic',
          color: T5.text, letterSpacing: '-0.01em' }}>
          Your king has nowhere to run.
        </div>
        <div style={{ marginTop: 6, fontFamily: T5.sans, fontSize: 12.5,
          color: T5.textDim, lineHeight: 1.55 }}>
          Find a move that attacks back.
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 28, left: 16, right: 16,
        display: 'flex', gap: 8,
      }}>
        {['Hint', 'Undo', 'Reset'].map((t, i) => (
          <button key={i} style={{
            flex: 1, padding: '13px',
            background: 'transparent', color: T5.textDim,
            border: `1px solid ${T5.hairline}`,
            borderRadius: 999, fontFamily: T5.sans, fontSize: 12.5,
          }}>{t}</button>
        ))}
      </div>
    </Phone>
  );
}

// ── 5C · RESCUE ──────────────────────────────────────────────
function T5Rescue() {
  const post = PUZZLE.pieces
    .filter(p => !(p.file === 4 && p.rank === 3))
    .concat([{ type: 'N', color: 'light', file: 5, rank: 5 }]);
  return (
    <Phone bg={T5.bg} statusBarColor={T5.textDim}>
      <T5Header />

      <div style={{
        position: 'absolute', top: 110, left: 24, right: 24,
        fontFamily: T5.serif, color: T5.text,
      }}>
        <div style={{ fontSize: 10.5, letterSpacing: '0.22em', color: T5.rescue,
          textTransform: 'uppercase', fontFamily: T5.sans }}>
          ◐ rescued
        </div>
        <div style={{ fontSize: 46, fontWeight: 500, lineHeight: 0.98, letterSpacing: '-0.03em',
          marginTop: 8, fontStyle: 'italic' }}>
          You held<br/>the line.
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 260, left: 16, right: 16,
        padding: 14,
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 14,
      }}>
        <Board size={296} theme={t5Theme} position={post} state="rescue" />
      </div>

      {/* result row */}
      <div style={{
        position: 'absolute', top: 600, left: 16, right: 16,
        display: 'flex', justifyContent: 'space-between',
        padding: '12px 18px',
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 12,
        fontFamily: T5.sans,
      }}>
        {[
          ['move', 'Nf6+'],
          ['time', '0:14'],
          ['streak', '4 d'],
        ].map(([k, v], i) => (
          <div key={i}>
            <div style={{ fontSize: 9.5, letterSpacing: '0.16em',
              color: T5.textMute, textTransform: 'uppercase' }}>{k}</div>
            <div style={{ fontSize: 16, fontFamily: T5.serif,
              color: T5.text, marginTop: 2, letterSpacing: '-0.01em' }}>{v}</div>
          </div>
        ))}
      </div>

      <button style={{
        position: 'absolute', bottom: 28, left: 16, right: 16,
        padding: '15px',
        background: 'transparent',
        color: T5.text,
        border: `1px solid ${T5.hairlineHi}`,
        borderRadius: 12,
        fontFamily: T5.sans, fontSize: 13, fontWeight: 500,
      }}>
        See tomorrow's puzzle preview →
      </button>
    </Phone>
  );
}

// ── 5D · RETRY ───────────────────────────────────────────────
function T5Retry() {
  return (
    <Phone bg={T5.bg} statusBarColor={T5.textDim}>
      <T5Header />

      <div style={{
        position: 'absolute', top: 110, left: 24, right: 24,
        fontFamily: T5.serif, color: T5.text,
      }}>
        <div style={{ fontSize: 10.5, letterSpacing: '0.22em', color: T5.danger,
          textTransform: 'uppercase', fontFamily: T5.sans }}>
          ◑ the pressure holds
        </div>
        <div style={{ fontSize: 40, fontWeight: 500, lineHeight: 1.0, letterSpacing: '-0.025em',
          marginTop: 8, fontStyle: 'italic' }}>
          A near miss.
        </div>
        <div style={{ marginTop: 8, fontSize: 13, fontFamily: T5.sans,
          color: T5.textDim, lineHeight: 1.55 }}>
          Your king is still in check.
          Take another look — no time penalty.
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 300, left: 16, right: 16,
        padding: 14,
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 14,
      }}>
        <Board size={296} theme={t5Theme} state="failed" />
      </div>

      <div style={{
        position: 'absolute', bottom: 28, left: 16, right: 16,
        display: 'flex', gap: 8,
      }}>
        <button style={{
          flex: 1, padding: '14px', background: 'transparent',
          color: T5.textDim, border: `1px solid ${T5.hairline}`,
          borderRadius: 999, fontFamily: T5.sans, fontSize: 13,
        }}>Show a hint</button>
        <button style={{
          flex: 1.4, padding: '14px', background: T5.text, color: T5.bg,
          border: 'none', borderRadius: 999, fontFamily: T5.sans, fontSize: 13, fontWeight: 500,
        }}>Look again</button>
      </div>
    </Phone>
  );
}

// ── 5E · ONBOARDING ──────────────────────────────────────────
function T5Onboarding() {
  return (
    <Phone bg={T5.bg} statusBarColor={T5.textDim}>
      <div style={{
        position: 'absolute', top: 56, left: 24, right: 24,
        fontFamily: T5.sans,
      }}>
        <div style={{ fontFamily: T5.serif, fontSize: 11, fontStyle: 'italic',
          color: T5.textMute }}>
          A quiet game about narrow escapes
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 100, left: 24, right: 24,
        fontFamily: T5.serif, color: T5.text,
      }}>
        <div style={{ fontSize: 32, fontWeight: 500, lineHeight: 1.06,
          letterSpacing: '-0.02em' }}>
          You won't play<br/>
          a full game of chess.<br/>
          <span style={{ fontStyle: 'italic', color: T5.danger }}>
            You'll arrive at the worst part.
          </span>
        </div>
      </div>

      <div style={{
        position: 'absolute', top: 318, left: 16, right: 16,
        padding: 14,
        background: T5.paper,
        border: `1px solid ${T5.hairline}`,
        borderRadius: 14,
      }}>
        <Board size={296} theme={t5Theme} state="danger" showThreatLines />
      </div>

      <div style={{
        position: 'absolute', bottom: 88, left: 28, right: 28, textAlign: 'center',
        fontFamily: T5.sans, fontSize: 12.5, color: T5.textDim, lineHeight: 1.6,
      }}>
        One move out. No accounts. No clocks ticking down.<br/>
        Just a small comeback, every day.
      </div>

      <button style={{
        position: 'absolute', bottom: 28, left: 24, right: 24,
        padding: '14px',
        background: T5.text, color: T5.bg,
        border: 'none', borderRadius: 999,
        fontFamily: T5.sans, fontSize: 13, fontWeight: 500,
      }}>
        Start
      </button>
    </Phone>
  );
}

// ── 5F · PLAY STORE SCREENSHOT ───────────────────────────────
function T5Screenshot() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: `linear-gradient(180deg, ${T5.bg} 0%, #1d1a17 100%)`,
      padding: '56px 56px',
      fontFamily: T5.sans,
      color: T5.text,
      position: 'relative',
      overflow: 'hidden',
    }}>
      <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div style={{ fontFamily: T5.serif, fontStyle: 'italic', fontSize: 17,
          color: T5.textDim }}>
          Chess Rescue · A daily puzzle
        </div>
        <div style={{ fontFamily: T5.serif, fontSize: 70, fontWeight: 600,
          lineHeight: 0.96, letterSpacing: '-0.035em', marginTop: 22 }}>
          The shortest<br/>
          game of chess<br/>
          you'll play today.
        </div>
        <div style={{ marginTop: 14, fontSize: 16, color: T5.textDim, lineHeight: 1.6, maxWidth: 480 }}>
          One puzzle. One move. About a minute.<br/>
          A small comeback, every day.
        </div>

        <div style={{ marginTop: 'auto', display: 'flex', gap: 32, alignItems: 'flex-end' }}>
          <div style={{ width: 280, transform: 'rotate(-1deg)' }}>
            <Phone width={280} height={580} bg={T5.bg} statusBarColor={T5.textDim}>
              <div style={{ position: 'absolute', top: 40, left: 20, right: 20,
                display: 'flex', justifyContent: 'space-between',
                fontFamily: T5.sans, color: T5.textDim, fontSize: 11 }}>
                <span style={{ fontFamily: T5.serif, fontStyle: 'italic' }}>Daily Rescue</span>
                <span style={{ fontFamily: T5.mono, letterSpacing: '0.14em' }}>No. 014</span>
              </div>
              <div style={{ position: 'absolute', top: 90, left: 14, right: 14,
                padding: 12, background: T5.paper,
                border: `1px solid ${T5.hairline}`, borderRadius: 12 }}>
                <Board size={250} theme={t5Theme} state="danger" />
              </div>
              <div style={{
                position: 'absolute', bottom: 90, left: 20, right: 20, textAlign: 'center',
                fontFamily: T5.serif, fontStyle: 'italic', fontSize: 17, color: T5.text,
              }}>
                Find the move.
              </div>
            </Phone>
          </div>
          <div style={{ flex: 1, paddingBottom: 20, fontFamily: T5.sans }}>
            <div style={{ fontSize: 15, color: T5.text, lineHeight: 1.6 }}>
              Every morning, a new puzzle.<br/>
              You start in trouble.<br/>
              One move gets you out.
            </div>
            <div style={{ marginTop: 22, display: 'flex', flexDirection: 'column', gap: 6 }}>
              {[
                ['~30 sec', 'per puzzle'],
                ['offline', 'forever'],
                ['no ads', 'no account'],
              ].map(([a, b], i) => (
                <div key={i} style={{
                  display: 'flex', justifyContent: 'space-between',
                  paddingBottom: 6,
                  borderBottom: i < 2 ? `1px solid ${T5.hairline}` : 'none',
                  fontSize: 13,
                }}>
                  <span style={{ fontFamily: T5.serif, fontStyle: 'italic',
                    color: T5.text }}>{a}</span>
                  <span style={{ color: T5.textDim }}>{b}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── 5G · APP ICON ────────────────────────────────────────────
function T5Icon() {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: T5.paper,
      borderRadius: 36,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
      boxShadow: `inset 0 0 0 1px ${T5.hairlineHi}`,
    }}>
      {/* small board fragment in background */}
      <div style={{
        position: 'absolute', inset: 28, opacity: 0.55,
      }}>
        <Board size={144} theme={t5Theme} state="danger"
          position={PUZZLE.pieces.filter(p =>
            p.file >= 4 && p.rank >= 0 && p.rank <= 3)} />
      </div>
      {/* foreground: bold K monogram */}
      <div style={{
        fontFamily: T5.serif, fontStyle: 'italic',
        fontSize: 90, fontWeight: 500, color: T5.text,
        letterSpacing: '-0.04em',
        textShadow: '0 6px 18px rgba(0,0,0,0.55)',
        position: 'relative',
      }}>
        K<span style={{ color: T5.danger }}>!</span>
      </div>
    </div>
  );
}

window.D5 = { T5Home, T5Gameplay, T5Rescue, T5Retry, T5Onboarding, T5Screenshot, T5Icon, T5 };
