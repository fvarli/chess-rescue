import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/episode.dart';
import '../../core/models/episode_library.dart';
import '../../core/models/piece.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';
import '../../l10n/gen/app_localizations.dart';
import '../rescue_game/rescue_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _focused = _deriveInitialFocus();
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
    setState(() => _focused = ep);
    unawaited(widget.store?.setCurrentEpisodeId(ep.id));
  }

  Future<void> _openRescue(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RescueScreen(store: widget.store, episode: _focused),
      ),
    );
    if (mounted) setState(() {});
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
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.1,
            colors: [AppColors.backdropDanger, AppColors.bg],
            stops: [0.0, 0.85],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const _ThreatenedKingHero(key: ValueKey('home-king-hero')),
                    const SizedBox(height: 24),
                    Text(
                      t.appTitle,
                      textAlign: TextAlign.center,
                      style: AppText.headline.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      t.homeTagline,
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(
                        fontSize: 16,
                        color: AppColors.textDim,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    _EpisodeStrip(
                      focused: _focused,
                      completedIds: completedIds,
                      onTapEpisode: _setFocus,
                      onTapLocked: () => _showLockedSnack(t.episodeLockedLabel),
                    ),
                    const SizedBox(height: 18),
                    _EpisodeProgressCard(
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
                    const SizedBox(height: 28),
                    _PrimaryCta(
                      label: ctaLabel,
                      onTap: () => _openRescue(context),
                    ),
                    const Spacer(),
                  ],
                ),
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

class _EpisodeStrip extends StatelessWidget {
  const _EpisodeStrip({
    required this.focused,
    required this.completedIds,
    required this.onTapEpisode,
    required this.onTapLocked,
  });

  final Episode focused;
  final Set<String> completedIds;
  final ValueChanged<Episode> onTapEpisode;
  final VoidCallback onTapLocked;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('home-episode-strip'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final ep in EpisodeLibrary.all)
          _EpisodeChip(
            episode: ep,
            progress: EpisodeLibrary.progressFor(ep, completedIds),
            isFocused: ep.id == focused.id,
            onTap: () {
              final p = EpisodeLibrary.progressFor(ep, completedIds);
              if (!p.isUnlocked) {
                onTapLocked();
                return;
              }
              onTapEpisode(ep);
            },
          ),
      ],
    );
  }
}

class _EpisodeChip extends StatelessWidget {
  const _EpisodeChip({
    required this.episode,
    required this.progress,
    required this.isFocused,
    required this.onTap,
  });

  final Episode episode;
  final EpisodeProgress progress;
  final bool isFocused;
  final VoidCallback onTap;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final glyph = _resolveGlyph();
    final bg = isFocused ? AppColors.danger : AppColors.surface;
    final border = isFocused
        ? AppColors.danger
        : (progress.isUnlocked ? AppColors.hairline : AppColors.hairline);
    final fg = isFocused
        ? AppColors.text
        : (progress.isUnlocked ? AppColors.text : AppColors.textMuted);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: ValueKey('home-episode-chip-${episode.number}'),
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          glyph,
          style: AppText.mono.copyWith(
            color: fg,
            fontSize: 13,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  String _resolveGlyph() {
    if (!progress.isUnlocked) return '🔒';
    if (progress.isComplete) return '✓${episode.number}';
    if (episode.kind == EpisodeKind.master) return '★${episode.number}';
    if (episode.kind == EpisodeKind.endless) return '∞${episode.number}';
    return '${episode.number}';
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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
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
