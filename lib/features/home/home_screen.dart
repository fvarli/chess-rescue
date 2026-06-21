import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/episode.dart';
import '../../core/models/episode_library.dart';
import '../../core/models/rescue_record_library.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../records/record_symbols.dart';
import '../records/records_sheet.dart';
import 'daily_ritual.dart';
import '../rescue_game/rescue_screen.dart';
import '../rescue_game/rescue_screen_pop_result.dart';
import '../settings/language_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final ProgressStore? store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Episode _focused;
  String? _newlyUnlockedId;
  Timer? _pulseTimer;
  bool _sessionJustUnlockedRecords = false;

  @override
  void initState() {
    super.initState();
    _focused = _deriveInitialFocus();
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  Episode _deriveInitialFocus() {
    final store = widget.store;
    if (store == null) return EpisodeLibrary.first;
    final persistedId = store.currentEpisodeId;
    if (persistedId != null) {
      final ep = EpisodeLibrary.byId(persistedId);
      if (ep != null) return ep;
    }
    final fallback = EpisodeLibrary.firstNonCompleteFor(store.completedIds);
    unawaited(store.setCurrentEpisodeId(fallback.id));
    return fallback;
  }

  void _setFocus(Episode ep) {
    if (ep.id == _focused.id) return;
    setState(() {
      _focused = ep;
      _sessionJustUnlockedRecords = false;
    });
    unawaited(widget.store?.setCurrentEpisodeId(ep.id));
  }

  Future<void> _openRescue(BuildContext context) async {
    final justCompletedEp = _focused;
    _sessionJustUnlockedRecords = false;
    final result = await Navigator.of(context).push<RescueScreenPopResult>(
      MaterialPageRoute<RescueScreenPopResult>(
        builder: (_) => RescueScreen(store: widget.store, episode: _focused),
      ),
    );
    if (!mounted) return;

    final earnedRecords = result?.newlyUnlockedRecordIds ?? const <String>[];
    if (earnedRecords.isNotEmpty) {
      _sessionJustUnlockedRecords = true;
    }

    if (result?.finishedEpisode == true) {
      _handleEpisodeCompleted(justCompletedEp);
    } else {
      setState(() {});
    }
  }

  void _openRecordsSheet() {
    setState(() {
      _sessionJustUnlockedRecords = false;
    });
    showRecordsSheet(context, widget.store);
  }

  void _handleEpisodeCompleted(Episode justCompletedEp) {
    final next = EpisodeLibrary.nextAfter(justCompletedEp);
    if (next == null) {
      setState(() {});
      return;
    }
    setState(() {
      _focused = next;
      _newlyUnlockedId = next.id;
    });
    unawaited(widget.store?.setCurrentEpisodeId(next.id));
    _pulseTimer?.cancel();
    _pulseTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _newlyUnlockedId = null);
    });
  }

  void _showLockedSnack(String label) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    final store = widget.store;
    final completedIds = store?.completedIds ?? const <String>{};
    final bestEndless = store?.bestEndlessStreak ?? 0;

    final progress = EpisodeLibrary.progressFor(_focused, completedIds);
    final puzzleCount = _focused.puzzleCount;
    final currentInEpisode = progress.completedCount + 1 > puzzleCount
        ? puzzleCount
        : progress.completedCount + 1;
    final unlockedRecords = store?.unlockedRecords ?? const <String>[];
    final recordsUnlocked = unlockedRecords.length;
    final recordsTotal = RescueRecordLibrary.all.length;
    // PR-12 — last-unlocked record title for the quiet Lately line. Null
    // on fresh installs (no unlocks yet) or when the id no longer
    // resolves (library mutated underneath stored ids).
    final latestMilestoneId = unlockedRecords.isEmpty
        ? null
        : unlockedRecords.last;
    final latestMilestoneTitle =
        latestMilestoneId != null &&
            RescueRecordLibrary.byId(latestMilestoneId) != null
        ? recordTitleFor(latestMilestoneId, t)
        : null;

    return Scaffold(
      backgroundColor: ColorTokens.surfacePrimary,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: SpacingTokens.s64,
                bottom: SpacingTokens.s32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero block ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.s24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.homeDailyRescueEyebrow,
                          style: TextTokens.label.copyWith(
                            color: ColorTokens.coordinateAccent,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.s16),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${t.homeHeroLine1}\n${t.homeHeroLine2}',
                            style: TextTokens.displayMedium.copyWith(
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.s16),
                        Text(t.homeSupportingLine1, style: TextTokens.body),
                        Text(t.homeSupportingLine2, style: TextTokens.body),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.s48),
                  // ── Primary CTA ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.s24,
                    ),
                    child: _PrimaryCta(
                      label: t.homePrimaryCta,
                      onTap: () => _openRescue(context),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.s64),
                  // ── Quiet secondary block ────────────────────────────
                  _EpisodeCardList(
                    focused: _focused,
                    completedIds: completedIds,
                    newlyUnlockedId: _newlyUnlockedId,
                    onTapEpisode: _setFocus,
                    onTapLocked: () => _showLockedSnack(t.episodeLockedLabel),
                  ),
                  const SizedBox(height: SpacingTokens.s24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.s24,
                    ),
                    child: _QuietProgressBlock(
                      badge: t.episodeBadge(_focused.number),
                      title: _titleFor(_focused, t),
                      subLabel: t.homeCurrentRun,
                      counter: t.homeRescueCounter(
                        currentInEpisode,
                        puzzleCount,
                      ),
                      bestRunLabel:
                          _focused.kind == EpisodeKind.endless &&
                              bestEndless > 0
                          ? t.episodeBestRun(bestEndless)
                          : null,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.s24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.s24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (latestMilestoneTitle != null) ...[
                          _LatestMilestoneLine(
                            label: t.homeLatestMilestoneLabel,
                            title: latestMilestoneTitle,
                            justUnlocked: _sessionJustUnlockedRecords,
                            onTap: _openRecordsSheet,
                          ),
                          const SizedBox(height: SpacingTokens.s4),
                        ],
                        _RecordsLine(
                          label: t.homeRecordsLabel,
                          countLabel: t.recordsCount(
                            recordsUnlocked,
                            recordsTotal,
                          ),
                          justUnlocked: _sessionJustUnlockedRecords,
                          onTap: _openRecordsSheet,
                        ),
                        // PR-13 — quiet observational journal line at
                        // the absolute bottom of Home, shown when the
                        // player has commit at least one rescue today.
                        // No animation, no glow, no icon, no tap target.
                        if (solvedToday(store)) ...[
                          const SizedBox(height: SpacingTokens.s4),
                          Text(
                            t.homeRescuedTodayLine,
                            key: const ValueKey('home-rescued-today-line'),
                            style: TextTokens.mono.copyWith(
                              color: ColorTokens.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(top: 12, right: 12, child: LanguagePickerButton()),
          ],
        ),
      ),
    );
  }
}

String _titleFor(Episode ep, AppL10n l) {
  switch (ep.id) {
    case 'ep1-strike-back':
      return l.episodeEp1Title;
    case 'ep2-end-the-threat':
      return l.episodeEp2Title;
    case 'ep3-hold-the-line':
      return l.episodeEp3Title;
    case 'ep4-the-other-side':
      return l.episodeEp4Title;
    case 'ep5-endless-rescue':
      return l.episodeEp5Title;
  }
  return '';
}

class _QuietProgressBlock extends StatelessWidget {
  const _QuietProgressBlock({
    required this.badge,
    required this.title,
    required this.subLabel,
    required this.counter,
    required this.bestRunLabel,
  });

  final String badge;
  final String title;
  final String subLabel;
  final String counter;
  final String? bestRunLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$badge · $title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextTokens.label.copyWith(color: ColorTokens.textSecondary),
        ),
        const SizedBox(height: SpacingTokens.s8),
        Text(
          subLabel,
          style: TextTokens.bodySmall.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
        const SizedBox(height: SpacingTokens.s4),
        Text(
          counter,
          style: TextTokens.title.copyWith(color: ColorTokens.textPrimary),
        ),
        if (bestRunLabel != null) ...[
          const SizedBox(height: SpacingTokens.s8),
          Text(
            bestRunLabel!,
            style: TextTokens.bodySmall.copyWith(
              color: ColorTokens.reliefPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

// PR-12 — quiet "lately" line above the RECORDS count, naming the most
// recently unlocked record. Same visual register, same glow window, same
// tap target as [_RecordsLine]. Rendered only when at least one record
// has been unlocked; absent on fresh installs so Home stays at its
// current density and the CTA keeps full attention.
class _LatestMilestoneLine extends StatelessWidget {
  const _LatestMilestoneLine({
    required this.label,
    required this.title,
    required this.justUnlocked,
    required this.onTap,
  });

  final String label;
  final String title;
  final bool justUnlocked;
  final VoidCallback onTap;

  static const Duration _pulseDuration = Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $title',
      excludeSemantics: true,
      child: GestureDetector(
        key: const ValueKey('home-latest-milestone-line'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: justUnlocked ? 1.0 : 0.0, end: 0.0),
          duration: _pulseDuration,
          curve: Curves.easeOut,
          builder: (context, glow, _) {
            final accentColor = Color.lerp(
              ColorTokens.textSecondary,
              ColorTokens.reliefPrimary,
              glow,
            )!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    label,
                    style: TextTokens.label.copyWith(color: accentColor),
                  ),
                  Text(
                    '  ·  ',
                    style: TextTokens.label.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      title,
                      style: TextTokens.body.copyWith(color: accentColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecordsLine extends StatelessWidget {
  const _RecordsLine({
    required this.label,
    required this.countLabel,
    required this.justUnlocked,
    required this.onTap,
  });

  final String label;
  final String countLabel;
  final bool justUnlocked;
  final VoidCallback onTap;

  static const Duration _pulseDuration = Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $countLabel',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: justUnlocked ? 1.0 : 0.0, end: 0.0),
          duration: _pulseDuration,
          curve: Curves.easeOut,
          builder: (context, glow, _) {
            final accentColor = Color.lerp(
              ColorTokens.textSecondary,
              ColorTokens.reliefPrimary,
              glow,
            )!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    label,
                    style: TextTokens.label.copyWith(color: accentColor),
                  ),
                  Text(
                    '  ·  ',
                    style: TextTokens.label.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                  Text(
                    countLabel,
                    style: TextTokens.mono.copyWith(color: accentColor),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EpisodeCardList extends StatefulWidget {
  const _EpisodeCardList({
    required this.focused,
    required this.completedIds,
    required this.newlyUnlockedId,
    required this.onTapEpisode,
    required this.onTapLocked,
  });

  final Episode focused;
  final Set<String> completedIds;
  final String? newlyUnlockedId;
  final ValueChanged<Episode> onTapEpisode;
  final VoidCallback onTapLocked;

  // Smaller than the legacy 120×116 so the strip reads as quiet secondary
  // nav rather than competing with the hero block.
  static const double cardWidth = 104;
  static const double cardHeight = 100;
  static const double gap = SpacingTokens.s12;
  static const double listPaddingHorizontal = SpacingTokens.s24;

  @override
  State<_EpisodeCardList> createState() => _EpisodeCardListState();
}

class _EpisodeCardListState extends State<_EpisodeCardList> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centerOn(widget.focused, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant _EpisodeCardList old) {
    super.didUpdateWidget(old);
    if (old.focused.id != widget.focused.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _centerOn(widget.focused, animate: true);
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _centerOn(Episode ep, {required bool animate}) {
    final index = EpisodeLibrary.all.indexOf(ep);
    if (index < 0 || !_scroll.hasClients) return;
    final viewport = _scroll.position.viewportDimension;
    final raw =
        _EpisodeCardList.listPaddingHorizontal +
        index * (_EpisodeCardList.cardWidth + _EpisodeCardList.gap) +
        _EpisodeCardList.cardWidth / 2 -
        viewport / 2;
    final target = raw.clamp(
      _scroll.position.minScrollExtent,
      _scroll.position.maxScrollExtent,
    );
    if (animate) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('home-episode-card-list'),
      height: _EpisodeCardList.cardHeight,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: _EpisodeCardList.listPaddingHorizontal,
        ),
        child: Row(
          children: [
            for (var i = 0; i < EpisodeLibrary.all.length; i++) ...[
              if (i > 0) const SizedBox(width: _EpisodeCardList.gap),
              () {
                final ep = EpisodeLibrary.all[i];
                final progress = EpisodeLibrary.progressFor(
                  ep,
                  widget.completedIds,
                );
                return _EpisodeCard(
                  episode: ep,
                  progress: progress,
                  isFocused: ep.id == widget.focused.id,
                  isNewlyUnlocked: ep.id == widget.newlyUnlockedId,
                  onTap: () {
                    if (!progress.isUnlocked) {
                      widget.onTapLocked();
                      return;
                    }
                    widget.onTapEpisode(ep);
                  },
                );
              }(),
            ],
          ],
        ),
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.episode,
    required this.progress,
    required this.isFocused,
    required this.isNewlyUnlocked,
    required this.onTap,
  });

  final Episode episode;
  final EpisodeProgress progress;
  final bool isFocused;
  final bool isNewlyUnlocked;
  final VoidCallback onTap;

  static const Duration _pulseDuration = Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    final title = _titleFor(episode, t);

    final bg = isFocused
        ? ColorTokens.surfaceElevated
        : ColorTokens.surfaceSecondary;
    final border = isFocused
        ? ColorTokens.reliefPrimary.withValues(alpha: 0.45)
        : (progress.isComplete && episode.kind == EpisodeKind.canonical
              ? ColorTokens.reliefPrimary.withValues(alpha: 0.30)
              : AppColors.hairline);
    final borderWidth = isFocused ? 1.5 : 1.0;
    final eyebrowColor = isFocused
        ? ColorTokens.coordinateAccent
        : ColorTokens.textSecondary;
    final titleColor = progress.isUnlocked
        ? ColorTokens.textPrimary
        : ColorTokens.disabled;

    final badge = t.episodeBadge(episode.number);
    final a11yLabel = progress.isUnlocked
        ? '$badge, $title'
        : '$badge, $title, ${t.episodeLockedLabel}';

    return Semantics(
      button: true,
      label: a11yLabel,
      selected: isFocused,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: isNewlyUnlocked ? 1.0 : 0.0, end: 0.0),
          duration: _pulseDuration,
          curve: Curves.easeOut,
          builder: (context, glow, _) {
            return Container(
              key: ValueKey('home-episode-card-${episode.number}'),
              width: _EpisodeCardList.cardWidth,
              height: _EpisodeCardList.cardHeight,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: RadiusTokens.brMedium,
                border: Border.all(color: border, width: borderWidth),
                boxShadow: glow > 0
                    ? [
                        BoxShadow(
                          color: ColorTokens.reliefPrimary.withValues(
                            alpha: 0.30 * glow,
                          ),
                          blurRadius: 14 * glow,
                          spreadRadius: 2 * glow,
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.s12,
                vertical: SpacingTokens.s12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.episodeBadge(episode.number),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextTokens.mono.copyWith(
                      color: eyebrowColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.s8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextTokens.title.copyWith(
                      fontSize: 16,
                      height: 1.05,
                      color: titleColor,
                    ),
                  ),
                  const Spacer(),
                  _CardProgressRow(episode: episode, progress: progress),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardProgressRow extends StatelessWidget {
  const _CardProgressRow({required this.episode, required this.progress});

  final Episode episode;
  final EpisodeProgress progress;

  @override
  Widget build(BuildContext context) {
    if (!progress.isUnlocked) {
      return Text(
        '🔒',
        style: TextTokens.mono.copyWith(
          color: ColorTokens.disabled,
          fontSize: 11,
        ),
      );
    }
    switch (episode.kind) {
      case EpisodeKind.canonical:
        return Text(
          _canonicalPipString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextTokens.mono.copyWith(
            color: progress.isComplete
                ? ColorTokens.reliefPrimary
                : ColorTokens.textSecondary,
            fontSize: 10,
          ),
        );
      case EpisodeKind.master:
        return Text(
          '★  ▮▮▮',
          maxLines: 1,
          style: TextTokens.mono.copyWith(
            color: ColorTokens.coordinateAccent,
            fontSize: 10,
          ),
        );
      case EpisodeKind.endless:
        return Text(
          '∞',
          style: TextTokens.mono.copyWith(
            color: ColorTokens.reliefPrimary,
            fontSize: 14,
          ),
        );
    }
  }

  String _canonicalPipString() {
    final total = episode.canonicalPuzzleIds.length;
    final done = progress.completedCount.clamp(0, total);
    final filled = '▮' * done;
    final empty = '▯' * (total - done);
    if (done == 0) return empty;
    return '$filled$empty  $done/$total';
  }
}

class _PrimaryCta extends StatefulWidget {
  const _PrimaryCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: ColorTokens.reliefPrimary,
              borderRadius: RadiusTokens.brMedium,
              boxShadow: [
                BoxShadow(
                  color: ColorTokens.reliefPrimary.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextTokens.button.copyWith(color: AppColors.onRescue),
            ),
          ),
        ),
      ),
    );
  }
}
