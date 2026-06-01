import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Quiet bookmark affordance shown beside the SavedBadge on the rescued
/// status row. Two states (empty / filled). **Visually secondary to
/// SAVED** — smaller than the badge text, dim color in both states, no
/// mint accent. Mint is reserved for SAVED.
///
/// The widget knows nothing of storage — the host (RescueScreen) provides
/// [isSaved] and [onTap].
class SignatureBookmarkGlyph extends StatelessWidget {
  const SignatureBookmarkGlyph({
    super.key,
    required this.isSaved,
    required this.onTap,
  });

  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          size: 14,
          color: isSaved
              ? AppColors.textDim
              // Empty register: fainter than textMuted (~0.32 alpha). The
              // bookmark sits below SavedBadge in visual hierarchy — very
              // faint until the player chooses to engage with it.
              : AppColors.text.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}
