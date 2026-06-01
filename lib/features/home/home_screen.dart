import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/episode.dart';
import '../../core/models/episode_library.dart';
import '../../core/models/piece.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';
import '../../l10n/gen/app_localizations.dart';
import '../records/records_preview.dart';
import '../records/records_sheet.dart';
import '../rescue_game/rescue_screen.dart';
import '../rescue_game/rescue_screen_pop_result.dart';
import '../rescue_game/widgets/piece_widget.dart';
import '../settings/language_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final ProgressStore? store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Episode _focused;
  // P3.1 — the chip currently rendering the one-shot "just unlocked" mint
  // glow. Set when auto-focus fires after an episode completion; cleared by a
  // 1500ms post-frame timer. Null in steady state.
  String? _newlyUnlockedId;
  Timer? _pulseTimer;
  // R1B — set by the new RescueScreenPopResult when the just-popped rescue
  // session unlocked at least one record. Drives the mint glow pulse on the
  // RecordsPreview's open-page row. Cleared on any chip tap / focus change /
  // next rescue push / preview tap.
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
    // Persist the derived default so subsequent boots skip derivation.
    unawaited(store.setCurrentEpisodeId(fallback.id));
    return fallback;
  }

  void _setFocus(Episode ep) {
    if (ep.id == _focused.id) return;
    setState(() {
      _focused = ep;
      _sessionJustUnlockedRecords = false; // R1B — clear glow on focus change
    });
    unawaited(widget.store?.setCurrentEpisodeId(ep.id));
  }

  Future<void> _openRescue(BuildContext context) async {
    final justCompletedEp = _focused;
    // R1B — clear the just-unlocked glow on re-entering a rescue (the player
    // has acknowledged the prior recognition).
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
      _sessionJustUnlockedRecords = false; // R1B — tap acknowledges
    });
    showRecordsSheet(context, widget.store);
  }

  void _handleEpisodeCompleted(Episode justCompletedEp) {
    // G1.1 — the EpisodeCompletionSheet on RescueScreen has already delivered
    // the celebration. Home's job after the pop is just auto-focus + persist
    // + light a brief mint glow on the newly unlocked card.
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
    final lifetime = store?.lifetimeSaved ?? 0;
    final introSeen = store?.introSeen ?? false;
    final bestEndless = store?.bestEndlessStreak ?? 0;

    final progress = EpisodeLibrary.progressFor(_focused, completedIds);
    final puzzleCount = _focused.puzzleCount;
    final currentInEpisode = progress.completedCount + 1 > puzzleCount
        ? puzzleCount
        : progress.completedCount + 1;

    final ctaLabel = introSeen ? t.homeContinue : t.homeStart;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          // G1.5 — radius 1.1 → 1.35 and stops [0, 0.85] → [0, 1.0] so the
          // backdrop coral haze reaches further down the screen, ending at
          // the viewport edge instead of fading to solid black at 85%.
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.35,
            colors: [AppColors.backdropDanger, AppColors.bg],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // G1.5 — weighted spacers pull the eye to the hero block on
                  // first render; hero side heavier than progress-card side.
                  const Spacer(flex: 13),
                  const _ThreatenedKingHero(key: ValueKey('home-king-hero')),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      t.appTitle,
                      textAlign: TextAlign.center,
                      // G1.5 — letter-spacing −0.22 → −0.6 sculpts the title
                      // slightly more, gives it logo-weight on Home.
                      style: AppText.headline.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  // R1B — title-tagline gap reverted from G1.5's 18dp to 14dp
                  // to free vertical budget for the Records preview card on
                  // the 800dp test viewport.
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      t.homeTagline,
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(
                        fontSize: 16,
                        color: AppColors.textDim,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const Spacer(flex: 10),
                  _EpisodeCardList(
                    focused: _focused,
                    completedIds: completedIds,
                    newlyUnlockedId: _newlyUnlockedId,
                    onTapEpisode: _setFocus,
                    onTapLocked: () => _showLockedSnack(t.episodeLockedLabel),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _EpisodeProgressCard(
                      episode: _focused,
                      title: _titleFor(_focused, t),
                      tagline: _taglineFor(_focused, t),
                      subLabel: t.homeCurrentRun,
                      counter: t.homeRescueCounter(
                        currentInEpisode,
                        puzzleCount,
                      ),
                      lifetime: t.homeTotalRescues(lifetime),
                      badge: t.episodeBadge(_focused.number),
                      bestRunLabel: bestEndless > 0
                          ? t.episodeBestRun(bestEndless)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: RecordsPreview(
                      unlockedRecords:
                          widget.store?.unlockedRecords ?? const <String>[],
                      justUnlocked: _sessionJustUnlockedRecords,
                      onTap: _openRecordsSheet,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _PrimaryCta(
                      label: ctaLabel,
                      onTap: () => _openRescue(context),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const Positioned(
                top: 12,
                right: 12,
                child: LanguagePickerButton(),
              ),
            ],
          ),
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

String _taglineFor(Episode ep, AppL10n l) {
  switch (ep.id) {
    case 'ep1-strike-back':
      return l.episodeEp1Tagline;
    case 'ep2-end-the-threat':
      return l.episodeEp2Tagline;
    case 'ep3-hold-the-line':
      return l.episodeEp3Tagline;
    case 'ep4-the-other-side':
      return l.episodeEp4Tagline;
    case 'ep5-endless-rescue':
      return l.episodeEp5Tagline;
  }
  return '';
}

class _ThreatenedKingHero extends StatefulWidget {
  const _ThreatenedKingHero({super.key});

  @override
  State<_ThreatenedKingHero> createState() => _ThreatenedKingHeroState();
}

class _ThreatenedKingHeroState extends State<_ThreatenedKingHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // R1B — reverted from G1.5's 118dp to 110dp to make room for the Records
  // preview card on the 800dp test viewport. Spanish locale was 16px over
  // at 118 with the preview added; 110 leaves enough headroom across all
  // locales. Still well above the pre-G1.5 baseline composition.
  static const double _kingSize = 110;
  static const Piece _king = Piece(
    id: 'home-hero-king',
    type: PieceType.king,
    color: PieceColor.light,
    file: 4,
    rank: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.dangerPulse,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kingSize * 1.6,
      height: _kingSize * 1.25,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glow = 0.12 + (_controller.value * 0.10);
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.danger.withValues(alpha: glow),
                        AppColors.danger.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.75],
                    ),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: const PieceWidget(piece: _king, size: _kingSize),
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

  static const double cardWidth = 120;
  // Trimmed from 132 → 116 so the 5-card Home composition fits the
  // 800dp test-viewport vertical budget across all locales (Spanish was
  // overflowing by 21px at 132). Eyebrow + 2-line title + progress row
  // still fits with comfortable padding.
  static const double cardHeight = 116;
  static const double gap = 12;
  static const double listPaddingHorizontal = 28;

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
    // SingleChildScrollView + Row is intentional over ListView.builder: the
    // 5-episode roster is small + bounded, eager build keeps test-finders
    // discovering off-screen cards by ValueKey, and the horizontal-scroll
    // peek affordance still works identically.
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

    final bg = isFocused ? AppColors.surface2 : AppColors.surface;
    final border = isFocused
        ? AppColors.danger
        : (progress.isComplete && episode.kind == EpisodeKind.canonical
              ? AppColors.rescue.withValues(alpha: 0.30)
              : AppColors.hairline);
    final borderWidth = isFocused ? 2.0 : 1.5;
    final eyebrowColor = isFocused ? AppColors.danger : AppColors.textMuted;
    final titleColor = progress.isUnlocked
        ? AppColors.text
        : AppColors.textMuted.withValues(alpha: 0.55);

    return GestureDetector(
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: borderWidth),
              boxShadow: glow > 0
                  ? [
                      BoxShadow(
                        color: AppColors.rescue.withValues(alpha: 0.4 * glow),
                        blurRadius: 14 * glow,
                        spreadRadius: 2 * glow,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.episodeBadge(episode.number),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono.copyWith(
                    color: eyebrowColor,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headline.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    letterSpacing: -0.4,
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
        style: AppText.mono.copyWith(color: AppColors.textMuted, fontSize: 12),
      );
    }
    switch (episode.kind) {
      case EpisodeKind.canonical:
        return Text(
          _canonicalPipString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.mono.copyWith(
            color: progress.isComplete ? AppColors.rescue : AppColors.textDim,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        );
      case EpisodeKind.master:
        return Text(
          '★  ▮▮▮',
          maxLines: 1,
          style: AppText.mono.copyWith(
            color: AppColors.accent,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        );
      case EpisodeKind.endless:
        return Text(
          '∞',
          style: AppText.mono.copyWith(color: AppColors.rescue, fontSize: 16),
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

class _EpisodeProgressCard extends StatelessWidget {
  const _EpisodeProgressCard({
    required this.episode,
    required this.title,
    required this.tagline,
    required this.subLabel,
    required this.counter,
    required this.lifetime,
    required this.badge,
    required this.bestRunLabel,
  });

  final Episode episode;
  final String title;
  final String tagline;
  final String subLabel;
  final String counter;
  final String lifetime;
  final String badge;
  final String? bestRunLabel;

  @override
  Widget build(BuildContext context) {
    final showBestRun =
        episode.kind == EpisodeKind.endless && bestRunLabel != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$badge · $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tagline,
            style: AppText.body.copyWith(
              fontSize: 13.5,
              color: AppColors.textDim,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subLabel,
            style: AppText.body.copyWith(
              fontSize: 13,
              color: AppColors.textDim,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            counter,
            style: AppText.headline.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showBestRun) ...[
            const SizedBox(height: 6),
            Text(
              bestRunLabel!,
              style: AppText.body.copyWith(
                fontSize: 13,
                color: AppColors.rescue,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.hairline),
          const SizedBox(height: 14),
          Text(
            lifetime,
            style: AppText.body.copyWith(
              fontSize: 15,
              color: AppColors.textDim,
            ),
          ),
        ],
      ),
    );
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
    return GestureDetector(
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
            color: AppColors.rescue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.rescue.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppText.button.copyWith(color: AppColors.onRescue),
          ),
        ),
      ),
    );
  }
}
