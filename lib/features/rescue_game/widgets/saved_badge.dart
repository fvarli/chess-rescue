import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';

// Quiet top-right motivation: how many kings you've saved this session.
// Long-press is a hidden debug reset (wired via onReset) — it knows nothing
// about storage.
class SavedBadge extends StatelessWidget {
  const SavedBadge({
    super.key,
    required this.count,
    required this.onReset,
    this.complete = false,
  });

  final int count;

  // Debug-only reset (null in release → no long-press handler).
  final VoidCallback? onReset;

  // Once every puzzle is saved, the badge gently shifts to the rescue color —
  // a quiet, persistent pride marker.
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onReset,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          'SAVED · $count',
          style: AppText.mono.copyWith(
            color: complete
                ? ColorTokens.reliefPrimary
                : ColorTokens.textSecondary,
            fontSize: 9.5,
          ),
        ),
      ),
    );
  }
}
