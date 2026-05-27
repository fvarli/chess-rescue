// primitives.jsx — shared chess pieces, board, phone frame, puzzle data
// All directions consume these and re-skin via CSS variables / props.

// ──────────────────────────────────────────────────────────────
// CHESS PIECE SYSTEM
// Authentic chess silhouettes — refined, modern, side-profile. Each piece
// preserves its iconic identity (king with cross + finial, queen with
// crown points, rook with battlements, bishop with mitre slit, knight as
// horse-head profile, pawn with spherical head) but reduces ornament.
// viewBox 0 0 100 100. Pieces are built from multiple primitive shapes so
// edges stay crisp at small sizes and silhouettes remain readable.
// ──────────────────────────────────────────────────────────────

const PIECE_RENDERERS = {
  // KING ─ cross on a finial, tapered body, two-band collar/foot
  K: ({ fill, stroke, sw }) => (
    <g fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round" strokeLinecap="round">
      {/* cross */}
      <path d="M47 4 H53 V12 H60 V18 H53 V26 H47 V18 H40 V12 H47 Z" />
      {/* finial bead */}
      <ellipse cx="50" cy="30" rx="5.5" ry="4" />
      {/* body */}
      <path d="M38 34 Q33 46 36 60 Q34 64 32 68 H68 Q66 64 64 60 Q67 46 62 34 Q56 38 50 38 Q44 38 38 34 Z" />
      {/* collar band */}
      <path d="M31 68 H69 V75 H31 Z" />
      {/* lower base */}
      <path d="M24 75 H76 L82 87 H18 Z" />
      {/* foot ellipse */}
      <ellipse cx="50" cy="87" rx="32" ry="3" />
    </g>
  ),

  // QUEEN ─ five-point crown over band, slender tapered body
  Q: ({ fill, stroke, sw }) => (
    <g fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round" strokeLinecap="round">
      {/* five crown beads — outer ones tilted outward, center tallest */}
      <circle cx="28" cy="16" r="3.6" />
      <circle cx="39" cy="11" r="3.6" />
      <circle cx="50" cy="8"  r="4.0" />
      <circle cx="61" cy="11" r="3.6" />
      <circle cx="72" cy="16" r="3.6" />
      {/* crown band */}
      <path d="M26 18 H74 L70 26 H30 Z" />
      {/* neck */}
      <path d="M33 26 H67 V32 H33 Z" />
      {/* body */}
      <path d="M37 32 Q31 46 34 60 Q32 64 30 68 H70 Q68 64 66 60 Q69 46 63 32 Z" />
      {/* collar */}
      <path d="M31 68 H69 V75 H31 Z" />
      {/* base */}
      <path d="M24 75 H76 L82 87 H18 Z" />
      <ellipse cx="50" cy="87" rx="32" ry="3" />
    </g>
  ),

  // ROOK ─ four battlements, cylindrical body, broad base
  R: ({ fill, stroke, sw }) => (
    <g fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round" strokeLinecap="round">
      {/* battlements as a single notched shape */}
      <path d="
        M24 6 H34 V14 H40 V6 H47 V14 H53 V6 H60 V14 H66 V6 H76 V24 H24 Z
      " />
      {/* collar under battlements */}
      <path d="M28 24 H72 V32 H28 Z" />
      {/* body */}
      <path d="M32 32 H68 L70 42 V58 L68 68 H32 L30 58 V42 Z" />
      {/* collar */}
      <path d="M28 68 H72 V75 H28 Z" />
      {/* base */}
      <path d="M22 75 H78 L82 87 H18 Z" />
      <ellipse cx="50" cy="87" rx="32" ry="3" />
    </g>
  ),

  // BISHOP ─ pointed head with single diagonal mitre slit
  B: ({ fill, stroke, sw }) => (
    <g fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round" strokeLinecap="round">
      {/* head */}
      <path d="M50 5 Q40 14 38 28 Q40 34 50 35 Q60 34 62 28 Q60 14 50 5 Z" />
      {/* mitre slit */}
      <path d="M52 8 L57 13" stroke={stroke} strokeWidth={sw * 1.4} fill="none" strokeLinecap="round" />
      {/* collar bead */}
      <ellipse cx="50" cy="37" rx="11" ry="3" />
      {/* body */}
      <path d="M40 38 Q33 52 36 64 Q34 66 32 68 H68 Q66 66 64 64 Q67 52 60 38 Q55 40 50 40 Q45 40 40 38 Z" />
      {/* collar */}
      <path d="M31 68 H69 V75 H31 Z" />
      {/* base */}
      <path d="M24 75 H76 L82 87 H18 Z" />
      <ellipse cx="50" cy="87" rx="32" ry="3" />
    </g>
  ),

  // KNIGHT ─ horse head in profile, facing left. The iconic piece.
  N: ({ fill, stroke, sw }) => (
    <g fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round" strokeLinecap="round">
      {/* horse-head silhouette: snout left, mane right */}
      <path d="
        M 30 24
        Q 36 14 48 12
        Q 60 10 68 16
        Q 76 24 76 36
        L 76 46
        Q 78 54 76 62
        L 79 68
        L 30 68
        L 30 62
        Q 27 60 26 56
        L 18 54
        L 14 48
        L 18 44
        L 22 38
        L 14 36
        L 18 30
        L 28 30
        Z
      " />
      {/* mane crease */}
      <path d="M58 18 Q66 30 70 50" stroke={stroke} strokeWidth={sw} fill="none" opacity="0.4" />
      {/* eye */}
      <ellipse cx="38" cy="28" rx="1.6" ry="2" fill={stroke} stroke="none" />
      {/* nostril */}
      <ellipse cx="20" cy="40" rx="1.2" ry="1.6" fill={stroke} stroke="none" opacity="0.6" />
      {/* collar */}
      <path d="M28 68 H72 V75 H28 Z" />
      {/* base */}
      <path d="M22 75 H78 L82 87 H18 Z" />
      <ellipse cx="50" cy="87" rx="32" ry="3" />
    </g>
  ),

  // PAWN ─ spherical head, slim neck, soft body, broad base
  P: ({ fill, stroke, sw }) => (
    <g fill={fill} stroke={stroke} strokeWidth={sw} strokeLinejoin="round" strokeLinecap="round">
      {/* head */}
      <circle cx="50" cy="22" r="10" />
      {/* neck */}
      <path d="M44 31 H56 L58 38 H42 Z" />
      {/* body */}
      <path d="M40 40 Q34 52 38 64 Q36 66 34 68 H66 Q64 66 62 64 Q66 52 60 40 Q55 43 50 43 Q45 43 40 40 Z" />
      {/* collar */}
      <path d="M32 68 H68 V75 H32 Z" />
      {/* base */}
      <path d="M24 75 H76 L82 87 H18 Z" />
      <ellipse cx="50" cy="87" rx="32" ry="3" />
    </g>
  ),
};

function Piece({ type, color = 'light', size = 32, outline, style, palette }) {
  const upper = type.toUpperCase();
  const render = PIECE_RENDERERS[upper];
  if (!render) return null;
  // palette can override the default light/dark fills
  const fill = palette
    ? (color === 'light' ? palette.light : palette.dark)
    : (color === 'light' ? 'var(--piece-light, #ece6d4)' : 'var(--piece-dark, #14161b)');
  const stroke = outline || (palette
    ? (color === 'light' ? palette.lightStroke : palette.darkStroke)
    : (color === 'light' ? 'var(--piece-light-stroke, rgba(0,0,0,0.4))'
                          : 'var(--piece-dark-stroke, rgba(0,0,0,0.65))'));
  const sw = palette?.sw ?? 1.2;
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" style={{ display: 'block', ...style }}>
      {render({ fill, stroke, sw })}
    </svg>
  );
}

// Back-compat shim — some code may still import PIECE_PATHS
const PIECE_PATHS = {};

// ──────────────────────────────────────────────────────────────
// PUZZLE: "Knight rescue"
// White (player, bottom) is being attacked. Black queen threatens mate next
// move. White's rescue move is Nf6+ — a knight check that defuses the attack.
// We show a small portion of the board with these pieces.
// ──────────────────────────────────────────────────────────────
const SQ = (file, rank) => ({ file, rank }); // a=0..h=7, 1=0..8=7
const PUZZLE = {
  // Player at bottom = white (per chess convention but we render orientation flippable)
  pieces: [
    { type: 'K', color: 'light', file: 6, rank: 0 }, // g1 — player king
    { type: 'P', color: 'light', file: 5, rank: 1 }, // f2
    { type: 'P', color: 'light', file: 6, rank: 1 }, // g2
    { type: 'P', color: 'light', file: 7, rank: 1 }, // h2
    { type: 'N', color: 'light', file: 4, rank: 3 }, // e4 — the rescuing knight
    { type: 'B', color: 'light', file: 2, rank: 0 }, // c1
    { type: 'R', color: 'light', file: 0, rank: 0 }, // a1
    { type: 'P', color: 'light', file: 0, rank: 1 }, // a2
    { type: 'P', color: 'light', file: 1, rank: 1 }, // b2

    { type: 'K', color: 'dark', file: 6, rank: 7 }, // g8
    { type: 'P', color: 'dark', file: 5, rank: 6 }, // f7
    { type: 'P', color: 'dark', file: 7, rank: 6 }, // h7
    { type: 'Q', color: 'dark', file: 7, rank: 2 }, // h3 — threatening Qg2#
    { type: 'R', color: 'dark', file: 4, rank: 6 }, // e7
    { type: 'P', color: 'dark', file: 0, rank: 6 }, // a7
    { type: 'P', color: 'dark', file: 1, rank: 6 }, // b7
    { type: 'P', color: 'dark', file: 2, rank: 5 }, // c6
    { type: 'B', color: 'dark', file: 5, rank: 4 }, // f5
  ],
  threatenedKing: SQ(6, 0),    // g1
  attackingPiece: SQ(7, 2),    // h3 - black queen
  rescueFrom: SQ(4, 3),        // e4 - knight
  rescueTo: SQ(5, 5),          // f6 - knight check
  attackLines: [               // squares projected onto by the attacker
    SQ(7, 1), SQ(6, 0), SQ(6, 1), SQ(6, 2), SQ(5, 0), SQ(5, 2), SQ(4, 6),
  ],
};

// ──────────────────────────────────────────────────────────────
// BOARD
// theme controls colors. Decorations (danger glow, rescue glow, dots) are
// rendered via additional overlays so each direction can swap behavior.
// ──────────────────────────────────────────────────────────────
function Board({
  size = 320,
  position = PUZZLE.pieces,
  theme = {},
  state = 'danger',           // 'idle' | 'danger' | 'selected' | 'rescue' | 'failed'
  showCoords = false,
  showThreatLines = false,
  showRescueArrow = false,
  showLegalDots = false,
  selectedSquare = null,
  legalSquares = [],
  flipped = false,
  pieceOutline,
}) {
  const sq = size / 8;
  const {
    light = '#dcd2c2',
    dark = '#5a5447',
    boardBg = 'transparent',
    danger = '#e8553c',
    rescue = '#5ec9a3',
    select = '#a0c4ff',
    grid = 'rgba(255,255,255,0.04)',
  } = theme;

  const fileOf = (i) => (flipped ? 7 - i : i);
  const rankOf = (j) => (flipped ? j : 7 - j);

  // squares list, top to bottom
  const squares = [];
  for (let j = 0; j < 8; j++) {
    for (let i = 0; i < 8; i++) {
      const file = fileOf(i);
      const rank = rankOf(j);
      const isLight = (file + rank) % 2 === 1;
      squares.push({ i, j, file, rank, isLight });
    }
  }

  const pieceAt = (file, rank) => position.find(p => p.file === file && p.rank === rank);
  const eqSq = (a, b) => a && b && a.file === b.file && a.rank === b.rank;

  const danger_sq = state === 'danger' && PUZZLE.threatenedKing;
  const rescue_sq = state === 'rescue' && PUZZLE.rescueTo;
  const failed_sq = state === 'failed' && PUZZLE.threatenedKing;

  return (
    <div
      style={{
        width: size,
        height: size,
        position: 'relative',
        background: boardBg,
        borderRadius: 4,
        overflow: 'hidden',
        boxShadow: theme.boardShadow || 'none',
      }}
    >
      {/* squares */}
      {squares.map(({ i, j, file, rank, isLight }) => (
        <div
          key={`${i}-${j}`}
          style={{
            position: 'absolute',
            left: i * sq,
            top: j * sq,
            width: sq,
            height: sq,
            background: isLight ? light : dark,
            boxShadow: theme.squareInset || 'none',
          }}
        />
      ))}

      {/* subtle grid lines */}
      {theme.gridLines && (
        <svg width={size} height={size} style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          {[...Array(7)].map((_, k) => (
            <g key={k} stroke={grid} strokeWidth={0.5}>
              <line x1={(k + 1) * sq} y1={0} x2={(k + 1) * sq} y2={size} />
              <line x1={0} y1={(k + 1) * sq} x2={size} y2={(k + 1) * sq} />
            </g>
          ))}
        </svg>
      )}

      {/* danger zone — square glow on king */}
      {danger_sq && (
        <div
          style={{
            position: 'absolute',
            left: (flipped ? 7 - danger_sq.file : danger_sq.file) * sq,
            top: (flipped ? danger_sq.rank : 7 - danger_sq.rank) * sq,
            width: sq,
            height: sq,
            boxShadow: `inset 0 0 0 2px ${danger}, 0 0 ${sq * 0.8}px ${danger}aa`,
            background: `${danger}33`,
            animation: 'cr-dangerPulse 1.8s ease-in-out infinite',
            pointerEvents: 'none',
          }}
        />
      )}

      {/* threat lines from attacking piece(s) */}
      {showThreatLines && state !== 'rescue' && (
        <svg width={size} height={size} style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          {PUZZLE.attackLines.map((s, idx) => {
            const x = ((flipped ? 7 - s.file : s.file) + 0.5) * sq;
            const y = ((flipped ? s.rank : 7 - s.rank) + 0.5) * sq;
            return (
              <circle key={idx} cx={x} cy={y} r={sq * 0.06} fill={danger} opacity={0.55} />
            );
          })}
          {/* attacker → king line */}
          <line
            x1={((flipped ? 7 - PUZZLE.attackingPiece.file : PUZZLE.attackingPiece.file) + 0.5) * sq}
            y1={((flipped ? PUZZLE.attackingPiece.rank : 7 - PUZZLE.attackingPiece.rank) + 0.5) * sq}
            x2={((flipped ? 7 - PUZZLE.threatenedKing.file : PUZZLE.threatenedKing.file) + 0.5) * sq}
            y2={((flipped ? PUZZLE.threatenedKing.rank : 7 - PUZZLE.threatenedKing.rank) + 0.5) * sq}
            stroke={danger}
            strokeWidth={1.5}
            strokeDasharray="3 4"
            opacity={0.7}
          />
        </svg>
      )}

      {/* selected square */}
      {selectedSquare && (
        <div
          style={{
            position: 'absolute',
            left: (flipped ? 7 - selectedSquare.file : selectedSquare.file) * sq,
            top: (flipped ? selectedSquare.rank : 7 - selectedSquare.rank) * sq,
            width: sq,
            height: sq,
            boxShadow: `inset 0 0 0 2px ${select}`,
            background: `${select}25`,
            pointerEvents: 'none',
          }}
        />
      )}

      {/* legal-move dots */}
      {showLegalDots && legalSquares.map((s, idx) => {
        const occupied = pieceAt(s.file, s.rank);
        const x = ((flipped ? 7 - s.file : s.file) + 0.5) * sq;
        const y = ((flipped ? s.rank : 7 - s.rank) + 0.5) * sq;
        return (
          <div
            key={idx}
            style={{
              position: 'absolute',
              left: x - sq * 0.5,
              top: y - sq * 0.5,
              width: sq,
              height: sq,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              pointerEvents: 'none',
            }}
          >
            {occupied ? (
              <div
                style={{
                  width: sq * 0.86,
                  height: sq * 0.86,
                  borderRadius: '50%',
                  border: `2px solid ${select}cc`,
                }}
              />
            ) : (
              <div
                style={{
                  width: sq * 0.28,
                  height: sq * 0.28,
                  borderRadius: '50%',
                  background: `${select}cc`,
                }}
              />
            )}
          </div>
        );
      })}

      {/* rescue square glow */}
      {rescue_sq && (
        <div
          style={{
            position: 'absolute',
            left: (flipped ? 7 - rescue_sq.file : rescue_sq.file) * sq,
            top: (flipped ? rescue_sq.rank : 7 - rescue_sq.rank) * sq,
            width: sq,
            height: sq,
            boxShadow: `inset 0 0 0 2px ${rescue}, 0 0 ${sq}px ${rescue}aa`,
            background: `${rescue}33`,
            pointerEvents: 'none',
          }}
        />
      )}

      {/* failed indicator — red flash on the king */}
      {failed_sq && (
        <div
          style={{
            position: 'absolute',
            left: (flipped ? 7 - failed_sq.file : failed_sq.file) * sq,
            top: (flipped ? failed_sq.rank : 7 - failed_sq.rank) * sq,
            width: sq,
            height: sq,
            boxShadow: `inset 0 0 0 3px ${danger}`,
            background: `${danger}55`,
            pointerEvents: 'none',
          }}
        />
      )}

      {/* rescue arrow: from rescueFrom to rescueTo */}
      {showRescueArrow && (
        <svg width={size} height={size} style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          <defs>
            <marker id="cr-arrow" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="5" markerHeight="5" orient="auto">
              <path d="M0,0 L10,5 L0,10 z" fill={rescue} />
            </marker>
          </defs>
          <line
            x1={((flipped ? 7 - PUZZLE.rescueFrom.file : PUZZLE.rescueFrom.file) + 0.5) * sq}
            y1={((flipped ? PUZZLE.rescueFrom.rank : 7 - PUZZLE.rescueFrom.rank) + 0.5) * sq}
            x2={((flipped ? 7 - PUZZLE.rescueTo.file : PUZZLE.rescueTo.file) + 0.5) * sq}
            y2={((flipped ? PUZZLE.rescueTo.rank : 7 - PUZZLE.rescueTo.rank) + 0.5) * sq}
            stroke={rescue}
            strokeWidth={3}
            strokeLinecap="round"
            markerEnd="url(#cr-arrow)"
            opacity={0.95}
          />
        </svg>
      )}

      {/* pieces */}
      {position.map((p, idx) => {
        const x = (flipped ? 7 - p.file : p.file) * sq;
        const y = (flipped ? p.rank : 7 - p.rank) * sq;
        const ps = sq * 0.94;
        return (
          <div
            key={idx}
            style={{
              position: 'absolute',
              left: x,
              top: y,
              width: sq,
              height: sq,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              pointerEvents: 'none',
              filter: eqSq(p, PUZZLE.threatenedKing) && state === 'danger'
                ? `drop-shadow(0 0 4px ${danger})`
                : eqSq(p, PUZZLE.rescueFrom) && state === 'rescue'
                ? `drop-shadow(0 0 4px ${rescue})`
                : 'none',
            }}
          >
            <Piece type={p.type} color={p.color} size={ps} outline={pieceOutline} palette={theme.piecePalette} />
          </div>
        );
      })}

      {/* coordinates */}
      {showCoords && (
        <>
          {[...Array(8)].map((_, k) => (
            <span
              key={`r${k}`}
              style={{
                position: 'absolute',
                left: 3,
                top: k * sq + 2,
                fontSize: 8,
                fontFamily: 'ui-monospace, monospace',
                color: 'rgba(255,255,255,0.45)',
              }}
            >
              {flipped ? k + 1 : 8 - k}
            </span>
          ))}
          {[...Array(8)].map((_, k) => (
            <span
              key={`f${k}`}
              style={{
                position: 'absolute',
                right: k === 7 ? 3 : 'auto',
                left: k === 7 ? 'auto' : k * sq + sq - 9,
                bottom: 1,
                fontSize: 8,
                fontFamily: 'ui-monospace, monospace',
                color: 'rgba(255,255,255,0.45)',
              }}
            >
              {'abcdefgh'[flipped ? 7 - k : k]}
            </span>
          ))}
        </>
      )}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────
// PHONE FRAME — lightweight portrait device
// ──────────────────────────────────────────────────────────────
function Phone({ children, width = 360, height = 740, bg = '#000', radius = 36, statusBarColor = '#fff', label }) {
  return (
    <div
      style={{
        width,
        height,
        background: bg,
        borderRadius: radius,
        padding: 8,
        boxShadow: '0 18px 60px rgba(0,0,0,0.18), 0 0 0 1px rgba(0,0,0,0.25)',
        position: 'relative',
        overflow: 'hidden',
        fontFamily: 'Inter, -apple-system, system-ui, sans-serif',
      }}
    >
      <div style={{
        width: '100%',
        height: '100%',
        borderRadius: radius - 8,
        overflow: 'hidden',
        position: 'relative',
        background: bg,
      }}>
        {/* status bar */}
        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: 28,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0 22px',
          fontSize: 11,
          fontFamily: 'ui-monospace, monospace',
          color: statusBarColor,
          letterSpacing: '0.02em',
          zIndex: 5,
          mixBlendMode: 'normal',
        }}>
          <span>9:41</span>
          <div style={{ display: 'flex', gap: 5, alignItems: 'center', opacity: 0.85 }}>
            <span style={{ width: 14, height: 8, border: `1px solid ${statusBarColor}`, borderRadius: 2, position: 'relative' }}>
              <span style={{ position: 'absolute', inset: 1, background: statusBarColor, width: '70%' }} />
            </span>
          </div>
        </div>
        {/* notch indicator */}
        <div style={{
          position: 'absolute',
          top: 6,
          left: '50%',
          transform: 'translateX(-50%)',
          width: 76,
          height: 18,
          background: '#000',
          borderRadius: 12,
          zIndex: 6,
        }} />
        <div style={{ position: 'relative', width: '100%', height: '100%' }}>
          {children}
        </div>
        {label && (
          <div style={{
            position: 'absolute',
            bottom: 4,
            left: '50%',
            transform: 'translateX(-50%)',
            width: 100,
            height: 4,
            background: statusBarColor,
            opacity: 0.7,
            borderRadius: 2,
          }} />
        )}
      </div>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────
// NOTES BLOCK — formatted designer notes for each direction
// ──────────────────────────────────────────────────────────────
function Notes({ title, subtitle, why, feeling, signal, risks, attracts, palette, accent = '#c96442' }) {
  return (
    <div style={{
      width: '100%',
      height: '100%',
      padding: '36px 32px',
      background: '#f8f6f1',
      fontFamily: 'Inter, system-ui, sans-serif',
      fontSize: 12.5,
      lineHeight: 1.6,
      color: '#1d1b18',
      overflow: 'hidden',
      display: 'flex',
      flexDirection: 'column',
      gap: 14,
    }}>
      <div>
        <div style={{ fontSize: 10, letterSpacing: '0.16em', textTransform: 'uppercase', opacity: 0.55 }}>{subtitle}</div>
        <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.01em', marginTop: 4, color: accent }}>{title}</div>
      </div>
      {palette && (
        <div style={{ display: 'flex', gap: 6 }}>
          {palette.map((c, i) => (
            <div key={i} style={{
              width: 36, height: 24, borderRadius: 4, background: c,
              border: '1px solid rgba(0,0,0,0.08)',
            }} />
          ))}
        </div>
      )}
      <div>
        <div style={{ fontWeight: 600, fontSize: 11, letterSpacing: '0.08em', textTransform: 'uppercase', opacity: 0.7 }}>Why it works</div>
        <div>{why}</div>
      </div>
      <div>
        <div style={{ fontWeight: 600, fontSize: 11, letterSpacing: '0.08em', textTransform: 'uppercase', opacity: 0.7 }}>Emotional feeling</div>
        <div>{feeling}</div>
      </div>
      <div>
        <div style={{ fontWeight: 600, fontSize: 11, letterSpacing: '0.08em', textTransform: 'uppercase', opacity: 0.7 }}>Acquisition signal</div>
        <div>{signal}</div>
      </div>
      <div>
        <div style={{ fontWeight: 600, fontSize: 11, letterSpacing: '0.08em', textTransform: 'uppercase', opacity: 0.7 }}>Readability risk</div>
        <div>{risks}</div>
      </div>
      <div>
        <div style={{ fontWeight: 600, fontSize: 11, letterSpacing: '0.08em', textTransform: 'uppercase', opacity: 0.7 }}>Who it attracts</div>
        <div>{attracts}</div>
      </div>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────
// PIECE STUDY — showcases the full set at multiple sizes/states.
// Used in the Piece System section. Tests touch-target legibility.
// ──────────────────────────────────────────────────────────────
function PieceStudy({ palette, bg = '#171a20', accent = '#ff5a4c' }) {
  const order = ['K', 'Q', 'R', 'B', 'N', 'P'];
  const names = { K: 'KING', Q: 'QUEEN', R: 'ROOK', B: 'BISHOP', N: 'KNIGHT', P: 'PAWN' };
  return (
    <div style={{
      width: '100%', height: '100%',
      background: bg, padding: 32,
      color: palette?.lightStroke ? '#ece4d4' : '#f0ebe1',
      fontFamily: '"Inter Tight", Inter, system-ui, sans-serif',
      display: 'flex', flexDirection: 'column', gap: 24,
    }}>
      <div>
        <div style={{ fontFamily: 'ui-monospace, monospace', fontSize: 10,
          letterSpacing: '0.18em', textTransform: 'uppercase', opacity: 0.55 }}>
          chess piece system
        </div>
        <div style={{ fontSize: 22, fontWeight: 600, marginTop: 4, letterSpacing: '-0.01em' }}>
          The set, six silhouettes
        </div>
      </div>

      {/* Large size row — light pieces over dark surface */}
      <div>
        <div style={{ fontSize: 10, letterSpacing: '0.14em', textTransform: 'uppercase',
          opacity: 0.5, marginBottom: 8 }}>at 64px · light</div>
        <div style={{ display: 'flex', gap: 12, alignItems: 'flex-end' }}>
          {order.map(t => (
            <div key={t} style={{
              flex: 1, padding: 8, background: 'rgba(255,255,255,0.04)',
              border: '1px solid rgba(255,255,255,0.06)', borderRadius: 6,
              display: 'flex', flexDirection: 'column', alignItems: 'center',
            }}>
              <Piece type={t} color="light" size={64} palette={palette} />
              <div style={{ fontFamily: 'ui-monospace, monospace', fontSize: 9,
                letterSpacing: '0.14em', opacity: 0.55, marginTop: 6 }}>{names[t]}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Dark pieces over light surface (squares simulated) */}
      <div>
        <div style={{ fontSize: 10, letterSpacing: '0.14em', textTransform: 'uppercase',
          opacity: 0.5, marginBottom: 8 }}>at 64px · dark on light square</div>
        <div style={{ display: 'flex', gap: 12 }}>
          {order.map(t => (
            <div key={t} style={{
              flex: 1, padding: 8,
              background: palette?.boardLight || 'rgba(220,210,194,1)',
              borderRadius: 6,
              display: 'flex', justifyContent: 'center', alignItems: 'center',
              height: 80,
            }}>
              <Piece type={t} color="dark" size={64} palette={palette} />
            </div>
          ))}
        </div>
      </div>

      {/* Small size row — mobile fingertip test */}
      <div>
        <div style={{ fontSize: 10, letterSpacing: '0.14em', textTransform: 'uppercase',
          opacity: 0.5, marginBottom: 8 }}>at 36px · touch-target test (real gameplay size)</div>
        <div style={{ display: 'flex', gap: 8 }}>
          {order.map(t => (
            <div key={`s${t}`} style={{
              width: 44, height: 44,
              background: 'rgba(255,255,255,0.04)',
              border: '1px solid rgba(255,255,255,0.06)', borderRadius: 4,
              display: 'flex', justifyContent: 'center', alignItems: 'center',
            }}>
              <Piece type={t} color="light" size={36} palette={palette} />
            </div>
          ))}
          {order.map(t => (
            <div key={`sd${t}`} style={{
              width: 44, height: 44,
              background: palette?.boardLight || 'rgba(220,210,194,1)',
              borderRadius: 4,
              display: 'flex', justifyContent: 'center', alignItems: 'center',
            }}>
              <Piece type={t} color="dark" size={36} palette={palette} />
            </div>
          ))}
        </div>
      </div>

      {/* Danger king */}
      <div>
        <div style={{ fontSize: 10, letterSpacing: '0.14em', textTransform: 'uppercase',
          opacity: 0.5, marginBottom: 8 }}>danger state · king under threat</div>
        <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
          <div style={{ position: 'relative' }}>
            <div style={{ position: 'absolute', inset: -10, borderRadius: '50%',
              background: `radial-gradient(50% 50% at 50% 50%, ${accent}44 0%, transparent 70%)`,
              filter: 'blur(6px)' }} />
            <div style={{ position: 'relative', filter: `drop-shadow(0 0 4px ${accent}aa)` }}>
              <Piece type="K" color="light" size={80} palette={palette} />
            </div>
          </div>
          <div style={{ fontSize: 12, opacity: 0.7, lineHeight: 1.5, maxWidth: 240 }}>
            The king picks up a faint accent-color rim when threatened — visible at all sizes
            without changing the silhouette.
          </div>
        </div>
      </div>
    </div>
  );
}

// BOARD STUDY — shows board material variants side-by-side
function BoardStudy({ themes, bg = '#171a20' }) {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: bg, padding: 32,
      color: '#ece4d4',
      fontFamily: '"Inter Tight", Inter, system-ui, sans-serif',
    }}>
      <div style={{ fontFamily: 'ui-monospace, monospace', fontSize: 10,
        letterSpacing: '0.18em', textTransform: 'uppercase', opacity: 0.55 }}>
        board material studies
      </div>
      <div style={{ fontSize: 22, fontWeight: 600, marginTop: 4, letterSpacing: '-0.01em' }}>
        Same position, different surfaces
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 20, marginTop: 24 }}>
        {themes.map((t, i) => (
          <div key={i}>
            <Board size={180} theme={t.theme} state="danger" />
            <div style={{ marginTop: 10, fontSize: 11, letterSpacing: '0.12em',
              textTransform: 'uppercase', color: t.accent, fontWeight: 500 }}>
              {t.name}
            </div>
            <div style={{ fontSize: 11, color: 'rgba(236,228,212,0.6)', marginTop: 4, lineHeight: 1.45 }}>
              {t.note}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// Share with other JSX scripts
Object.assign(window, { Piece, Board, Phone, Notes, PUZZLE, PIECE_PATHS, SQ, PieceStudy, BoardStudy });
