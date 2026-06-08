import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/tokens.dart';
import '../game_state.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.state,
    required this.message,
    required this.counter,
  });

  final GameState state;
  final String message;
  final String counter; // e.g. 'PUZZLE 2/5'

  @override
  Widget build(BuildContext context) {
    final accent = switch (state) {
      GameState.rescued => ColorTokens.reliefPrimary,
      _ => ColorTokens.dangerPrimary,
    };
    // Hug content when short; when the row is given a bounded width (the
    // header wraps this in an Expanded), the message ellipsizes instead of
    // overflowing the right edge. Align keeps the pill left within that width.
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pillFill,
          border: Border.all(color: AppColors.hairline, width: 1),
          borderRadius: BorderRadius.circular(999),
        ),
        // PR-9A — smooth color interpolation across state changes.
        // TweenAnimationBuilder rebuilds the dot + message text with the
        // lerped accent over statusPillTransitionDuration; no flash, no
        // new state, no new Timer. The counter color is state-invariant
        // and renders outside the tween.
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: accent),
          duration: MotionTokens.statusPillTransitionDuration,
          curve: MotionTokens.standard,
          builder: (context, lerpedColor, _) {
            final c = lerpedColor ?? accent;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.mono.copyWith(color: c),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  counter,
                  style: AppText.mono.copyWith(
                    color: ColorTokens.textSecondary,
                    fontSize: 9.5,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
