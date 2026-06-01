import 'package:flutter/material.dart';

import '../../core/models/rescue_record.dart';
import '../../core/models/rescue_record_evaluator.dart';
import '../../core/models/rescue_record_library.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'record_symbols.dart';

/// R1B — opens the modal Records Sheet over the host. Returns the
/// `Future<void>` that completes when the sheet is dismissed.
Future<void> showRecordsSheet(BuildContext context, ProgressStore? store) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    isScrollControlled: true,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 240),
    ),
    builder: (ctx) => RecordsSheet(store: store),
  );
}

/// R1B — the Record Book sheet. Renders 4 category sections in book order
/// (Rescue → Episodes → Endless → Mastery) with hairline dividers,
/// typographic rows, chained mystery visibility, and the Mastery
/// hiddenCategory rule. No boxed-card styling, no progress bars, no
/// percentage, no "claim" CTAs.
class RecordsSheet extends StatelessWidget {
  const RecordsSheet({super.key, this.store});

  final ProgressStore? store;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    final completedIds = store?.completedIds ?? const <String>{};
    final unlocked = store?.unlockedRecordsSet ?? const <String>{};
    final snapshot = RescueRecordSnapshot(
      lifetimeSaved: store?.lifetimeSaved ?? 0,
      bestEndlessStreak: store?.bestEndlessStreak ?? 0,
      currentEndlessStreakPeak: 0,
      completedIds: completedIds,
      unlockedRecords: unlocked,
    );
    final states = evaluateRecords(snapshot);
    final unlockedCount = states.where((s) => s.isUnlocked).length;
    final isFreshInstall = unlocked.isEmpty;
    final isAllUnlocked = unlockedCount == RescueRecordLibrary.all.length;

    final height = MediaQuery.of(context).size.height * 0.88;

    return Container(
      key: const ValueKey('records-sheet'),
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l.recordsSheetEyebrow,
              style: AppText.mono.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAllUnlocked
                  ? l.recordsAllPagesWritten
                  : l.recordsCount(
                      unlockedCount,
                      RescueRecordLibrary.all.length,
                    ),
              style: AppText.body.copyWith(
                fontSize: isAllUnlocked ? 14 : 14,
                fontStyle: isAllUnlocked ? FontStyle.italic : FontStyle.normal,
                color: AppColors.textDim,
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isFreshInstall) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          l.recordsSheetIntro,
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textDim,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    ..._buildCategorySections(l, states),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySections(
    AppL10n l,
    List<RescueRecordState> states,
  ) {
    final widgets = <Widget>[];
    for (final category in RescueRecordCategory.values) {
      final categoryStates = states
          .where((s) => s.record.category == category && s.isVisible)
          .toList();
      if (categoryStates.isEmpty) continue;
      widgets.add(_CategoryHeader(label: _categoryLabel(l, category)));
      for (final state in categoryStates) {
        widgets.add(_RecordRow(l: l, state: state));
      }
      widgets.add(const SizedBox(height: 18));
    }
    return widgets;
  }

  String _categoryLabel(AppL10n l, RescueRecordCategory c) {
    switch (c) {
      case RescueRecordCategory.rescue:
        return l.recordCategoryRescue;
      case RescueRecordCategory.episodes:
        return l.recordCategoryEpisodes;
      case RescueRecordCategory.endless:
        return l.recordCategoryEndless;
      case RescueRecordCategory.mastery:
        return l.recordCategoryMastery;
    }
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
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

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.l, required this.state});

  final AppL10n l;
  final RescueRecordState state;

  @override
  Widget build(BuildContext context) {
    final isMystery =
        !state.isUnlocked && state.record.reveal == RescueRecordReveal.chained;

    final title = isMystery
        ? l.recordsMysteryTitle
        : recordTitleFor(state.record.id, l);
    final description = isMystery
        ? l.recordsMysteryDescription
        : (state.isUnlocked
              ? recordDescriptionUnlockedFor(state.record.id, l)
              : recordDescriptionLockedFor(state.record.id, l));
    final progressText =
        !isMystery && !state.isUnlocked && state.targetProgress > 0
        ? '${state.currentProgress} / ${state.targetProgress}'
        : null;

    final symbolIcon = isMystery ? null : symbolFor(state.record.id);
    final symbolColor = state.isUnlocked
        ? AppColors.textDim
        : AppColors.textMuted.withValues(alpha: 0.6);
    final titleColor = state.isUnlocked
        ? AppColors.text
        : (isMystery
              ? AppColors.textMuted
              : AppColors.text.withValues(alpha: 0.65));
    final descColor = state.isUnlocked
        ? AppColors.textDim
        : AppColors.textMuted.withValues(alpha: 0.6);

    return Container(
      key: ValueKey('records-sheet-row-${state.record.id}'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: symbolIcon == null
                ? Text(
                    '○',
                    style: AppText.mono.copyWith(
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  )
                : Icon(symbolIcon, size: 18, color: symbolColor),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppText.body.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                    if (state.isUnlocked)
                      Text(
                        '✓',
                        style: AppText.body.copyWith(
                          color: AppColors.rescue,
                          fontSize: 14,
                        ),
                      ),
                    if (progressText != null)
                      Text(
                        progressText,
                        style: AppText.mono.copyWith(
                          color: AppColors.textDim,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppText.body.copyWith(fontSize: 12, color: descColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
