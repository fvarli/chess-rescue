// playable.jsx — Interactive rescue sandbox using D4's tactical-cinematic look.
// Real tap-piece → show-moves → tap-square interaction, win/lose state.

function PlayableRescue() {
  const T = window.D4.T4;
  const [pieces, setPieces] = React.useState(PUZZLE.pieces);
  const [selected, setSelected] = React.useState(null);
  const [state, setState] = React.useState('danger'); // danger | rescue | failed
  const [statusMsg, setStatusMsg] = React.useState('▮ Active threat · Qg2#');
  const [showLegal, setShowLegal] = React.useState(false);

  // Hard-coded "legal" moves per piece for the puzzle (tactical exploration only)
  // — we don't run a chess engine, we whitelist the rescue + a few decoys.
  const legalFor = (p) => {
    if (!p) return [];
    if (p.type === 'N' && p.file === 4 && p.rank === 3) {
      // Knight on e4 — all 8 knight moves
      return [
        { file: 5, rank: 5 },   // f6 — RESCUE
        { file: 3, rank: 5 },   // d6
        { file: 2, rank: 4 },   // c5
        { file: 2, rank: 2 },   // c3
        { file: 3, rank: 1 },   // d2 (own pawn — capture self disallowed, but show)
        { file: 5, rank: 1 },   // f2 (own pawn)
        { file: 6, rank: 2 },   // g3
        { file: 6, rank: 4 },   // g5
      ];
    }
    if (p.type === 'K' && p.file === 6 && p.rank === 0) {
      return [
        { file: 5, rank: 0 },  // f1 (still in check — fail)
        { file: 7, rank: 0 },  // h1 (still in check — fail)
      ];
    }
    if (p.type === 'P' && p.file === 6 && p.rank === 1) {
      return [{ file: 6, rank: 2 }, { file: 6, rank: 3 }];
    }
    if (p.type === 'P' && p.file === 7 && p.rank === 1) {
      return [{ file: 7, rank: 2 }];
    }
    return [];
  };

  const legal = selected ? legalFor(selected) : [];

  const handleSquare = (file, rank, e) => {
    e?.stopPropagation();
    if (state !== 'danger') return;
    const piece = pieces.find(p => p.file === file && p.rank === rank);

    if (selected) {
      // If clicked own piece, reselect
      if (piece && piece.color === 'light') {
        setSelected(piece);
        setShowLegal(true);
        return;
      }
      // Check legal
      const ok = legal.some(s => s.file === file && s.rank === rank);
      if (!ok) {
        setSelected(null);
        setShowLegal(false);
        return;
      }
      // Make the move
      const moved = { ...selected, file, rank };
      const next = pieces
        .filter(p => p !== selected && !(p.file === file && p.rank === rank))
        .concat(moved);
      // Win condition: knight to f6 (the rescue)
      if (selected.type === 'N' && selected.file === 4 && selected.rank === 3 &&
          file === 5 && rank === 5) {
        setPieces(next);
        setSelected(null);
        setShowLegal(false);
        setState('rescue');
        setStatusMsg('◐ Attack broken · Nf6+');
      } else {
        // Wrong move — show failed flash, then reset
        setPieces(next);
        setSelected(null);
        setShowLegal(false);
        setState('failed');
        setStatusMsg('▮ Still trapped');
      }
    } else {
      if (piece && piece.color === 'light') {
        setSelected(piece);
        setShowLegal(true);
      }
    }
  };

  const reset = () => {
    setPieces(PUZZLE.pieces);
    setSelected(null);
    setShowLegal(false);
    setState('danger');
    setStatusMsg('▮ Active threat · Qg2#');
  };

  // Render a tappable board overlay over a styled board background
  const size = 324;
  const sq = size / 8;
  const t4Theme = {
    light: T.light, dark: T.dark, danger: T.danger, rescue: T.rescue,
    select: T.accent, gridLines: true,
    piecePalette: {
      light: '#eaeaf2',
      dark: '#0c0d14',
      lightStroke: 'rgba(12,13,20,0.55)',
      darkStroke: 'rgba(234,234,242,0.22)',
      boardLight: T.light,
      sw: 1.15,
    },
  };
  const selectedSq = selected ? { file: selected.file, rank: selected.rank } : null;
  const stateAccent = state === 'rescue' ? T.rescue : T.danger;

  return (
    <Phone bg={T.bg} statusBarColor={T.textDim}>
      <div style={{ position: 'absolute', inset: 0,
        background: `radial-gradient(80% 50% at 50% 40%, ${state === 'rescue' ? '#0e2a23' : '#1a1c28'} 0%, ${T.bg} 80%)` }} />

      <div style={{
        position: 'absolute', top: 32, left: 16, right: 16,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        padding: '8px 14px',
        background: 'rgba(13,14,18,0.7)',
        backdropFilter: 'blur(10px)',
        border: `1px solid ${T.hairline}`,
        borderRadius: 999,
        fontFamily: T.mono, fontSize: 10.5, letterSpacing: '0.14em',
        color: stateAccent, textTransform: 'uppercase',
      }}>
        <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%',
            background: stateAccent, boxShadow: `0 0 8px ${stateAccent}` }} />
          {statusMsg}
        </span>
        <span style={{ fontSize: 9.5 }}>LIVE DEMO</span>
      </div>

      <div style={{
        position: 'absolute', top: 96, left: 0, right: 0, textAlign: 'center',
        fontFamily: T.display, fontSize: 22, fontWeight: 600,
        color: state === 'rescue' ? T.rescue : T.text,
        letterSpacing: '-0.01em',
      }}>
        {state === 'rescue' ? 'Rescued.' :
         state === 'failed' ? 'Not the move.' :
         selected ? 'Where will it go?' :
         'Save the king.'}
      </div>

      <div style={{ position: 'absolute', top: 142, left: 0, right: 0,
        display: 'flex', justifyContent: 'center' }}>
        <div style={{ position: 'relative', width: size, height: size }}>
          <Board
            size={size}
            theme={t4Theme}
            position={pieces}
            state={state}
            showThreatLines={state === 'danger' && !selected}
            showCoords
            selectedSquare={selectedSq}
            legalSquares={showLegal ? legal : []}
            showLegalDots={showLegal}
          />
          {/* tap layer */}
          <div style={{ position: 'absolute', inset: 0,
            display: 'grid',
            gridTemplateColumns: 'repeat(8, 1fr)',
            gridTemplateRows: 'repeat(8, 1fr)',
          }}>
            {[...Array(64)].map((_, idx) => {
              const i = idx % 8;
              const j = Math.floor(idx / 8);
              const file = i;
              const rank = 7 - j;
              return (
                <div
                  key={idx}
                  onClick={(e) => handleSquare(file, rank, e)}
                  style={{ cursor: state === 'danger' ? 'pointer' : 'default' }}
                />
              );
            })}
          </div>
        </div>
      </div>

      {/* footer with reset/next */}
      <div style={{
        position: 'absolute', bottom: 28, left: 16, right: 16,
        display: 'flex', gap: 10,
      }}>
        <button onClick={reset} style={{
          flex: 1, padding: '15px',
          background: state === 'rescue' ? T.rescue : 'transparent',
          color: state === 'rescue' ? '#062019' : T.text,
          border: state === 'rescue' ? 'none' : `1px solid ${T.hairline}`,
          borderRadius: 12, fontFamily: T.display, fontSize: 13, fontWeight: 600,
          letterSpacing: '0.04em',
          cursor: 'pointer',
        }}>{state === 'rescue' ? 'Next puzzle ↦' : state === 'failed' ? 'Try again ↺' : 'Reset'}</button>
      </div>

      {/* hint */}
      {state === 'danger' && !selected && (
        <div style={{
          position: 'absolute', top: 488, left: 24, right: 24, textAlign: 'center',
          fontFamily: T.display, fontSize: 12.5, color: T.textDim,
        }}>
          Tap a white piece to see its moves.
        </div>
      )}
      {state === 'danger' && selected && (
        <div style={{
          position: 'absolute', top: 488, left: 24, right: 24, textAlign: 'center',
          fontFamily: T.display, fontSize: 12.5, color: T.textDim,
        }}>
          Tap a highlighted square to move.
        </div>
      )}
      {state === 'rescue' && (
        <div style={{
          position: 'absolute', top: 488, left: 24, right: 24, textAlign: 'center',
          fontFamily: T.mono, fontSize: 10.5, color: T.rescue, letterSpacing: '0.2em',
          textTransform: 'uppercase',
        }}>
          knight to f6 · check &amp; fork
        </div>
      )}
      {state === 'failed' && (
        <div style={{
          position: 'absolute', top: 488, left: 24, right: 24, textAlign: 'center',
          fontFamily: T.display, fontSize: 12.5, color: T.textDim,
        }}>
          That move doesn't break the attack. Look for a check.
        </div>
      )}
    </Phone>
  );
}

window.PlayableRescue = PlayableRescue;
