import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../game_state.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.state, required this.message});

  final GameState state;
  final String message;

  @override
  Widget build(BuildContext context) {
    final accent = switch (state) {
      GameState.rescued => AppColors.rescue,
      _ => AppColors.danger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xB30D0E12),
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
                BoxShadow(color: accent.withValues(alpha: 0.7), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message.toUpperCase(),
            style: AppText.mono.copyWith(color: accent),
          ),
          const SizedBox(width: 14),
          Text(
            'LIVE DEMO',
            style: AppText.mono.copyWith(
              color: AppColors.textMuted,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}
