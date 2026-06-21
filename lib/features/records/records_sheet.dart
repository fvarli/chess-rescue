import 'package:flutter/material.dart';

import '../../core/models/rescue_record.dart';
import '../../core/models/rescue_record_evaluator.dart';
import '../../core/models/rescue_record_library.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/relative_time.dart';
import '../../l10n/gen/app_localizations.dart';
import '../signatures/signatures_tab.dart';
import '../signatures/signatures_tab_pulse.dart';
import 'record_symbols.dart';

/// R1B / PR 2 — opens the modal Records Sheet over the host. The sheet
/// now hosts two tabs: RECORDS (the original journal) and SIGNATURES
/// (PR 2 player-curated collection). Default tab is RECORDS for
/// backward compatibility with existing flows.
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

/// PR 2 — what tab is active inside [RecordsSheet]. Default: records.
enum _RecordsSheetTab { records, signatures }

/// R1B + PR 2 — the Records modal. Hosts two tabs (RECORDS / SIGNATURES)
/// behind a hand-rolled segmented control. The RECORDS body retains the
/// original behaviour: 4 category sections in book order, hairline
/// dividers, mystery visibility, count line at the top of the body
/// (`"5 / 13"` / `"Every page has been written."`). The SIGNATURES body
/// is delegated to [SignaturesTab] — fully self-contained, store
/// injected via constructor, no Records-modal-specific coupling
/// (extractability — see PR 2 plan §4).
class RecordsSheet extends StatefulWidget {
  const RecordsSheet({super.key, this.store});

  final ProgressStore? store;

  @override
  State<RecordsSheet> createState() => _RecordsSheetState();
}

class _RecordsSheetState extends State<RecordsSheet> {
  _RecordsSheetTab _activeTab = _RecordsSheetTab.records;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
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
            const SizedBox(height: 14),
            // PR 2 — segmented tab control. The SIGNATURES button is
            // wrapped by SignaturesTabPulse, which animates a one-time
            // mint border-glow when the player opens the modal for the
            // first time after their first bookmark.
            _SegmentedTabs(
              activeTab: _activeTab,
              store: widget.store,
              onSelect: (tab) => setState(() => _activeTab = tab),
              recordsLabel: l.recordsSheetEyebrow,
              signaturesLabel: l.signaturesTabLabel,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _activeTab == _RecordsSheetTab.records
                  ? _RecordsBody(l: l, store: widget.store)
                  : SignaturesTab(store: widget.store),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.activeTab,
    required this.store,
    required this.onSelect,
    required this.recordsLabel,
    required this.signaturesLabel,
  });

  final _RecordsSheetTab activeTab;
  final ProgressStore? store;
  final ValueChanged<_RecordsSheetTab> onSelect;
  // The records-tab label here reuses the existing `recordsSheetEyebrow`
  // ("RESCUE RECORDS") so the eyebrow + the tab are visually consistent.
  final String recordsLabel;
  final String signaturesLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TabButton(
          label: 'RECORDS',
          isActive: activeTab == _RecordsSheetTab.records,
          onTap: () => onSelect(_RecordsSheetTab.records),
        ),
        const SizedBox(width: 28),
        SignaturesTabPulse(
          store: store,
          child: _TabButton(
            label: signaturesLabel,
            isActive: activeTab == _RecordsSheetTab.signatures,
            onTap: () => onSelect(_RecordsSheetTab.signatures),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.rescue : Colors.transparent,
                width: 1,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppText.mono.copyWith(
              fontSize: 10,
              letterSpacing: 1.2,
              color: isActive ? AppColors.text : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordsBody extends StatelessWidget {
  const _RecordsBody({required this.l, required this.store});

  final AppL10n l;
  final ProgressStore? store;

  @override
  Widget build(BuildContext context) {
    final completedIds = store?.completedIds ?? const <String>{};
    final unlocked = store?.unlockedRecordsSet ?? const <String>{};
    final unlockDates =
        store?.unlockedRecordDates ?? const <String, DateTime>{};
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Count line (lifted from the modal top into the RECORDS body
          // per PR 2 — SIGNATURES is curated, not counted).
          Center(
            child: Text(
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
          ),
          const SizedBox(height: 18),
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
          ..._buildCategorySections(l, states, unlockDates),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections(
    AppL10n l,
    List<RescueRecordState> states,
    Map<String, DateTime> unlockDates,
  ) {
    final widgets = <Widget>[];
    for (final category in RescueRecordCategory.values) {
      final categoryStates = states
          .where((s) => s.record.category == category && s.isVisible)
          .toList();
      if (categoryStates.isEmpty) continue;
      widgets.add(_CategoryHeader(label: _categoryLabel(l, category)));
      for (final state in categoryStates) {
        widgets.add(
          _RecordRow(
            l: l,
            state: state,
            unlockedAt: unlockDates[state.record.id],
          ),
        );
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
  const _RecordRow({required this.l, required this.state, this.unlockedAt});

  final AppL10n l;
  final RescueRecordState state;
  // PR-12 — when present, the moment this record was unlocked. Used to
  // surface a quiet "Today" trailer on unlock day. Null for legacy
  // (pre-PR-12) unlocks; no trailer rendered.
  final DateTime? unlockedAt;

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
                // PR-12 — quiet "Today" trailer on the day of unlock.
                // Older / undated unlocks render no trailer; the grid
                // settles into a clean title-and-description journal.
                if (state.isUnlocked &&
                    unlockedAt != null &&
                    isToday(unlockedAt!)) ...[
                  const SizedBox(height: 4),
                  Text(
                    l.recordsUnlockedTodayTrailer,
                    key: ValueKey('records-sheet-row-today-${state.record.id}'),
                    style: AppText.mono.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
