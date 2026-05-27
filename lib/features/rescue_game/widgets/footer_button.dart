import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../game_state.dart';

class FooterButton extends StatelessWidget {
  const FooterButton({super.key, required this.state, required this.onTap});

  final GameState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRescued = state == GameState.rescued;
    final label = switch (state) {
      GameState.rescued => 'Reset',
      GameState.failed => 'Try again  ↺',
      _ => 'Reset',
    };
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: isRescued ? AppColors.rescue : Colors.transparent,
              border: Border.all(
                color: isRescued ? Colors.transparent : AppColors.hairline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isRescued
                  ? [
                      BoxShadow(
                        color: AppColors.rescue.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: AppText.button.copyWith(
                  color: isRescued ? const Color(0xFF062019) : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
