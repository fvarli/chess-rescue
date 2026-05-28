import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// Quiet top-right motivation: how many kings you've saved this session.
// Long-press is a hidden debug reset (wired via onReset) — it knows nothing
// about storage.
class SavedBadge extends StatelessWidget {
  const SavedBadge({super.key, required this.count, required this.onReset});

  final int count;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onReset,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          '$count SAVED',
          style: AppText.mono.copyWith(
            color: AppColors.textMuted,
            fontSize: 9.5,
          ),
        ),
      ),
    );
  }
}
