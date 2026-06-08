import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';

/// G1.1 — Episode Completion Sheet.
///
/// In-context modal sheet that appears ON the RescueScreen *before* the
/// navigator pop, anchored over a dimmed board. Renders the eyebrow,
/// the episode number, the pre-uppercased title, the rescue count, and
/// a mint Continue CTA that fires [onContinue] — which should call
/// `Navigator.maybePop<bool>(true)` to preserve the P3.1 completion-signal
/// protocol.
///
/// Fade-in + tiny slide-up (~280 ms) — relief, not victory royale.
/// One row in the R1B "RECORD UNLOCKED" inline section that the
/// EpisodeCompletionSheet renders above its Continue CTA.
class CompletionSheetRecordRow {
  const CompletionSheetRecordRow({
    required this.title,
    required this.description,
  });
  final String title;
  final String description;
}

class EpisodeCompletionSheet extends StatefulWidget {
  const EpisodeCompletionSheet({
    super.key,
    required this.eyebrow,
    required this.episodeLabel,
    required this.title,
    required this.rescuesCount,
    required this.continueLabel,
    required this.onContinue,
    this.trilogyUnlockLabel,
    this.recordUnlockEyebrow,
    this.unlockedRecords = const <CompletionSheetRecordRow>[],
  });

  final String eyebrow;
  final String episodeLabel;
  final String title;
  final String rescuesCount;
  final String continueLabel;
  final String? trilogyUnlockLabel;
  final VoidCallback onContinue;

  /// R1B — pre-resolved RECORD UNLOCKED eyebrow string for the inline
  /// section. Null when [unlockedRecords] is empty (no records earned at
  /// this finale).
  final String? recordUnlockEyebrow;

  /// R1B — records earned AT this finale moment. Rendered as an inline
  /// RECORD UNLOCKED section between the rescues-count line and the
  /// Continue button. Empty → no section rendered.
  final List<CompletionSheetRecordRow> unlockedRecords;

  @override
  State<EpisodeCompletionSheet> createState() => _EpisodeCompletionSheetState();
}

class _EpisodeCompletionSheetState extends State<EpisodeCompletionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTrilogy = widget.trilogyUnlockLabel != null;
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_enter.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            // PR-7 — backdrop 0.55 → 0.45 alpha; subtler dim per the
            // editorial-over-celebration register.
            ColoredBox(color: Colors.black.withValues(alpha: 0.45 * t)),
            Center(
              child: Transform.translate(
                // PR-7 — slide 12 → 8 dp; gentler settle.
                offset: Offset(0, 8 * (1 - t)),
                child: Opacity(opacity: t, child: child),
              ),
            ),
          ],
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.s24),
        child: Container(
          key: const ValueKey('episode-completion-sheet'),
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.s24,
            vertical: SpacingTokens.s24,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceElevated,
            borderRadius: RadiusTokens.brLarge,
            border: Border.all(color: AppColors.hairline, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59000000),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.eyebrow,
                textAlign: TextAlign.center,
                style: TextTokens.label.copyWith(
                  color: ColorTokens.dangerPrimary,
                ),
              ),
              const SizedBox(height: SpacingTokens.s24),
              Text(
                widget.episodeLabel,
                textAlign: TextAlign.center,
                style: TextTokens.label.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(height: SpacingTokens.s8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextTokens.headline,
              ),
              const SizedBox(height: SpacingTokens.s16),
              Text(
                widget.rescuesCount,
                textAlign: TextAlign.center,
                style: TextTokens.bodySmall.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
              if (hasTrilogy) ...[
                const SizedBox(height: SpacingTokens.s12),
                Text(
                  widget.trilogyUnlockLabel!,
                  textAlign: TextAlign.center,
                  style: TextTokens.label.copyWith(
                    color: ColorTokens.reliefPrimary,
                  ),
                ),
              ],
              if (widget.unlockedRecords.isNotEmpty) ...[
                const SizedBox(height: SpacingTokens.s24),
                _RecordUnlockInlineSection(
                  eyebrow: widget.recordUnlockEyebrow ?? '',
                  rows: widget.unlockedRecords,
                ),
              ],
              const SizedBox(height: SpacingTokens.s24),
              _ContinueButton(
                label: widget.continueLabel,
                onTap: widget.onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
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
    );
  }
}

/// R1B — the "RECORD UNLOCKED" inline section inside the EpisodeCompletionSheet.
/// Renders the eyebrow + one row per record. Hairline dividers between the
/// section and surrounding content; no boxed-card styling — the journal
/// register continues.
class _RecordUnlockInlineSection extends StatelessWidget {
  const _RecordUnlockInlineSection({required this.eyebrow, required this.rows});

  final String eyebrow;
  final List<CompletionSheetRecordRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('episode-sheet-records-section'),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: AppColors.hairline, width: 80),
        const SizedBox(height: SpacingTokens.s16),
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: TextTokens.label.copyWith(color: ColorTokens.reliefPrimary),
        ),
        const SizedBox(height: SpacingTokens.s12),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: SpacingTokens.s8),
          Text(
            rows[i].title,
            textAlign: TextAlign.center,
            style: TextTokens.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorTokens.textPrimary,
            ),
          ),
          Text(
            rows[i].description,
            textAlign: TextAlign.center,
            style: TextTokens.caption.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.s16),
        Container(height: 1, color: AppColors.hairline, width: 80),
      ],
    );
  }
}
