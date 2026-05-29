import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
      GameState.rescued => AppColors.rescue,
      _ => AppColors.danger,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.toUpperCase(),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: AppText.mono.copyWith(color: accent),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              counter,
              style: AppText.mono.copyWith(
                color: AppColors.textMuted,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
