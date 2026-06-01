import 'package:flutter/material.dart';

import '../../core/models/recently_solved_entry.dart';
import '../../core/models/signature_entry.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'recently_solved_row.dart';
import 'signature_card.dart';
import 'signature_expand_sheet.dart';

/// PR 2 — body of the SIGNATURES tab inside the Records modal.
/// Self-contained: takes [store] via constructor injection so it can be
/// mounted in any future host (home tile, dedicated modal, full-screen
/// page) without Records-modal-specific coupling
/// (see §4 of the PR 2 plan — *extractability*).
///
/// Layout:
///
/// - If signatures non-empty: 2-column grid of [SignatureCard]s
///   followed by the RECENTLY SOLVED section (filtered to exclude
///   already-saved canonical ids)
/// - If signatures empty: two-line empty-state copy ("Some rescues
///   stay with you." / "This is where you keep them.") followed by
///   the RECENTLY SOLVED section (no filtering — nothing to filter)
///
/// Tap a card → opens [SignatureExpandSheet] via
/// `showModalBottomSheet`. Tap a recently-solved row → adds it to the
/// collection (no confirmation prompt) and re-renders with the row
/// filtered out and a new card present.
class SignaturesTab extends StatefulWidget {
  const SignaturesTab({super.key, required this.store});

  final ProgressStore? store;

  @override
  State<SignaturesTab> createState() => _SignaturesTabState();
}

class _SignaturesTabState extends State<SignaturesTab> {
  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    final store = widget.store;
    final signatures = store?.signatures ?? const <SignatureEntry>[];
    final savedIds = store?.signaturesCanonicalIds ?? const <String>{};
    final recently =
        store?.recentlySolved.visibleExcluding(savedIds) ??
        const <RecentlySolvedEntry>[];

    return SingleChildScrollView(
      key: const ValueKey('signatures-tab'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (signatures.isEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l.signaturesEmptyStateLine1,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textDim,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.signaturesEmptyStateLine2,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textDim,
              ),
            ),
            const SizedBox(height: 28),
          ] else ...[
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: signatures.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                // The card content is roughly thumbnail (110dp) + 8dp gap +
                // ~36dp text block. Aspect 0.72 leaves room without
                // clipping at the default modal width.
                childAspectRatio: 0.72,
              ),
              itemBuilder: (ctx, i) {
                final entry = signatures[i];
                return SignatureCard(
                  entry: entry,
                  onTap: () => _onCardTap(entry),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (recently.isNotEmpty) ...[
            _RecentlySolvedHeader(label: l.signaturesRecentlySolvedHeader),
            for (final entry in recently)
              RecentlySolvedRow(
                entry: entry,
                onSaveTap: () => _onRecentlySolvedTap(entry),
              ),
          ],
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Future<void> _onCardTap(SignatureEntry entry) async {
    final store = widget.store;
    if (store == null) return;
    final removed = await showSignatureExpandSheet(context, store, entry);
    if (!mounted) return;
    if (removed) setState(() {});
  }

  Future<void> _onRecentlySolvedTap(RecentlySolvedEntry entry) async {
    final store = widget.store;
    if (store == null) return;
    await store.addSignature(
      SignatureEntry(
        canonicalPuzzleId: entry.canonicalPuzzleId,
        encounteredPuzzleId: entry.encounteredPuzzleId,
        episodeId: entry.episodeId,
        adoptedAt: DateTime.now(),
        endlessSeed: entry.endlessSeed,
        endlessMirrored: entry.endlessMirrored,
      ),
    );
    if (!mounted) return;
    setState(() {});
  }
}

class _RecentlySolvedHeader extends StatelessWidget {
  const _RecentlySolvedHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: AppColors.hairline)),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppText.mono.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: AppColors.hairline)),
        ],
      ),
    );
  }
}
