import 'package:flutter/material.dart';

import '../../core/models/episode.dart';
import '../../core/models/episode_library.dart';
import '../../core/models/signature_entry.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/relative_time.dart';
import '../../l10n/gen/app_localizations.dart';
import '../rescue_game/game_state.dart';
import '../rescue_game/widgets/board_widget.dart';
import 'signature_lookup.dart';

/// A single saved-Signature grid card. Renders a small board thumbnail
/// in its danger state, the puzzle title, and a journal-register
/// fragment under it ("From Episode 1 · today" or just "From Episode 1"
/// when not adopted today). Tap target wraps the whole card.
///
/// Journal register per the plan §3: one line, no period (fragment
/// cadence), provenance + optional today freshness signal. See
/// [[feedback-journal-register-vs-stat-register]].
class SignatureCard extends StatelessWidget {
  const SignatureCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.thumbnailSize = 110,
  });

  final SignatureEntry entry;
  final VoidCallback onTap;
  final double thumbnailSize;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    final puzzle = resolvePuzzleFor(entry.encounteredPuzzleId);
    final title = localizedPuzzleTitle(entry.canonicalPuzzleId);
    final episode = EpisodeLibrary.byId(entry.episodeId);
    final today = isToday(entry.adoptedAt);
    final journalLine = _journalLineFor(l, episode, today);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Board thumbnail — danger state, no input, no legal-move dots.
          // commitInFlight + resetInFlight both true to block any latent
          // gesture, plus IgnorePointer for double safety.
          IgnorePointer(
            child: SizedBox(
              width: thumbnailSize,
              height: thumbnailSize,
              child: puzzle == null
                  ? _Fallback(canonicalId: entry.canonicalPuzzleId)
                  : BoardWidget(
                      size: thumbnailSize,
                      pieces: puzzle.pieces,
                      selected: null,
                      legalSquares: const [],
                      state: GameState.danger,
                      threatenedKing: puzzle.threatenedKing,
                      rescueTo: puzzle.rescueTo,
                      commitInFlight: true,
                      resetInFlight: false,
                      onTapSquare: _noop,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppText.body.copyWith(
              fontSize: 14,
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            journalLine,
            style: AppText.body.copyWith(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textDim,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _journalLineFor(AppL10n l, Episode? episode, bool today) {
    if (episode == null) {
      // Defensive: episode no longer in the library. Fall back to the
      // generic "From Episode N" style with the raw id. Should never
      // happen in practice.
      return entry.episodeId;
    }
    final isEndless = episode.kind == EpisodeKind.endless;
    if (isEndless) {
      return today
          ? l.signaturesJournalLineEndlessToday
          : l.signaturesJournalLineEndless;
    }
    return today
        ? l.signaturesJournalLineCanonicalToday(episode.number)
        : l.signaturesJournalLineCanonical(episode.number);
  }

  static void _noop(int file, int rank) {}
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.canonicalId});
  final String canonicalId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        canonicalId,
        style: AppText.mono.copyWith(fontSize: 9, color: AppColors.textMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}
