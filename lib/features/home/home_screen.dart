import 'package:flutter/material.dart';

import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../rescue_game/rescue_screen.dart';
import '../settings/language_picker.dart';

/// P1 — Home screen + progress shell. New first surface of the app.
///
/// Top to bottom: title → tagline → progress card (current run + lifetime) →
/// mint CTA → settings affordance in the corner. The Phase-35 intro overlay
/// still gates the cold open on RescueScreen; Home wraps it, doesn't replace
/// it.
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
    // Refresh on return so the progress card reflects any newly saved rescues.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    final store = widget.store;
    // The session counter is per-current-run (puzzleIndex + 1 of session
    // length). When store is null (degraded boot), we surface the canonical
    // first run so Home still renders meaningfully.
    final puzzleIndex = store?.puzzleIndex ?? 0;
    const sessionLength = 5;
    final current = (puzzleIndex + 1).clamp(1, sessionLength);
    final lifetime = store?.lifetimeSaved ?? 0;
    final introSeen = store?.introSeen ?? false;
    final ctaLabel = introSeen ? t.homeContinue : t.homeStart;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
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
                    t.introTitle,
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(
                      fontSize: 16,
                      color: AppColors.textDim,
                    ),
                  ),
                  const Spacer(),
                  _ProgressCard(
                    eyebrow: t.homeCurrentRun,
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
            const Positioned(top: 12, right: 12, child: LanguagePickerButton()),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.eyebrow,
    required this.counter,
    required this.lifetime,
  });

  final String eyebrow;
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
          Text(
            eyebrow.toUpperCase(),
            style: AppText.mono.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
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
