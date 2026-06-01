import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/episode.dart';
import '../../core/models/episode_library.dart';
import '../../core/models/piece.dart';
import '../../core/models/signature_entry.dart';
import '../../core/models/square.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../rescue_game/game_state.dart';
import '../rescue_game/widgets/board_widget.dart';
import 'signature_lookup.dart';

/// PR 2 — opens the signature expansion sheet as a modal bottom sheet
/// from any context where a [ProgressStore] is available. Returns a
/// `Future<bool>` that resolves to `true` if the entry was removed from
/// the collection during the session, `false` otherwise (sheet was
/// dismissed by drag / backdrop / Cancel).
Future<bool> showSignatureExpandSheet(
  BuildContext context,
  ProgressStore store,
  SignatureEntry entry,
) async {
  final removed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    isScrollControlled: true,
    builder: (ctx) => SignatureExpandSheet(store: store, entry: entry),
  );
  return removed ?? false;
}

/// The viewing surface for a saved Signature. The body is intentionally
/// quiet — board + title + two journal sentences. **Remove is NOT a
/// primary visible action**; it lives behind a three-dot overflow menu
/// in the header per the lead's directive (the sheet is a viewing
/// surface, not a delete dialog). Tapping the menu → confirmation
/// dialog → on confirm, calls `removeSignature` and pops `true`.
class SignatureExpandSheet extends StatelessWidget {
  const SignatureExpandSheet({
    super.key,
    required this.store,
    required this.entry,
  });

  final ProgressStore store;
  final SignatureEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    final puzzle = resolvePuzzleFor(entry.encounteredPuzzleId);
    final title = localizedPuzzleTitle(entry.canonicalPuzzleId);
    final episode = EpisodeLibrary.byId(entry.episodeId);
    final height = MediaQuery.of(context).size.height * 0.78;

    // Reconstruct the rescued-state pieces: replace the mover (the piece
    // on `puzzle.tappableSquare`) with a copy moved to rescueTo, and
    // drop any captured piece at the destination. Same pattern as the
    // live GameController's _commitMove.
    final reconstructed = puzzle == null
        ? const <Piece>[]
        : _rescuedPieces(puzzle.pieces, puzzle.tappableSquare, puzzle.rescueTo);

    return Container(
      key: const ValueKey('signature-expand-sheet'),
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header row: drag handle (centered) + three-dot menu (right).
            // The menu is intentionally placed beside the drag handle so the
            // viewing surface keeps no other action chrome anywhere visible.
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  const SizedBox(width: 48), // mirror the menu's right inset
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.hairline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    key: const ValueKey('signature-expand-sheet-menu'),
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    tooltip: l.signaturesMenuRemove,
                    onSelected: (value) async {
                      if (value == 'remove') {
                        await _confirmAndRemove(context, l);
                      }
                    },
                    itemBuilder: (ctx) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text(l.signaturesMenuRemove),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Board — full width, rescued state with the mover at
                    // rescueTo. The BoardWidget's built-in rescue glow on
                    // the destination square plays the move-highlight role.
                    Center(
                      child: LayoutBuilder(
                        builder: (ctx, c) {
                          final size = c.maxWidth.clamp(220.0, 360.0);
                          if (puzzle == null) {
                            return SizedBox(
                              width: size,
                              height: size,
                              child: const _Fallback(),
                            );
                          }
                          return IgnorePointer(
                            child: BoardWidget(
                              size: size,
                              pieces: reconstructed,
                              selected: null,
                              legalSquares: const [],
                              state: GameState.rescued,
                              threatenedKing: puzzle.threatenedKing,
                              rescueTo: puzzle.rescueTo,
                              commitInFlight: true,
                              resetInFlight: false,
                              onTapSquare: _noop,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(title, style: AppText.headline.copyWith(fontSize: 22)),
                    const SizedBox(height: 14),
                    Text(
                      _journalLineOne(l, episode),
                      style: AppText.body.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDim,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.signaturesJournalRememberedDetail,
                      style: AppText.body.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDim,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _journalLineOne(AppL10n l, Episode? episode) {
    if (episode == null) return entry.episodeId;
    return episode.kind == EpisodeKind.endless
        ? l.signaturesJournalEndlessDetail
        : l.signaturesJournalCanonicalDetail(episode.number);
  }

  Future<void> _confirmAndRemove(BuildContext context, AppL10n l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l.signaturesRemoveDialogTitle),
        content: Text(l.signaturesRemoveDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.signaturesRemoveDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.signaturesRemoveDialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await store.removeSignature(entry.canonicalPuzzleId);
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  static void _noop(int file, int rank) {}
}

List<Piece> _rescuedPieces(
  List<Piece> base,
  Square movedFromSquare,
  Square rescueDestination,
) {
  // The piece on the tappable (origin) square is the mover.
  Piece? mover;
  for (final p in base) {
    if (p.file == movedFromSquare.file && p.rank == movedFromSquare.rank) {
      mover = p;
      break;
    }
  }
  if (mover == null) return base;
  return <Piece>[
    for (final p in base)
      if (p.id != mover.id &&
          !(p.file == rescueDestination.file &&
              p.rank == rescueDestination.rank))
        p,
    mover.copyWith(file: rescueDestination.file, rank: rescueDestination.rank),
  ];
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.question_mark,
        size: 32,
        color: AppColors.textMuted,
      ),
    );
  }
}
