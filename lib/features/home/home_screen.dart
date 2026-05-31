import 'package:flutter/material.dart';

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
  Future<void> _openRescue(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RescueScreen(store: widget.store),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    final store = widget.store;
    final puzzleIndex = store?.puzzleIndex ?? 0;
    const sessionLength = 5;
    final current = (puzzleIndex + 1).clamp(1, sessionLength);
    final lifetime = store?.lifetimeSaved ?? 0;
    final introSeen = store?.introSeen ?? false;
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
                    _ProgressCard(
                      panelTitle: t.homeRescueMission,
                      subLabel: t.homeCurrentRun,
                      counter: t.homeRescueCounter(current, sessionLength),
                      lifetime: t.homeTotalRescues(lifetime),
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.panelTitle,
    required this.subLabel,
    required this.counter,
    required this.lifetime,
  });

  final String panelTitle;
  final String subLabel;
  final String counter;
  final String lifetime;

  @override
  Widget build(BuildContext context) {
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
              Text(
                panelTitle,
                style: AppText.mono.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
