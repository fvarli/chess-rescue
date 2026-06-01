import 'package:flutter/material.dart';

import '../../core/models/recently_solved_entry.dart';
import '../../core/theme/app_theme.dart';
import 'signature_lookup.dart';

/// Single hairline-bordered row in the RECENTLY SOLVED section of the
/// SIGNATURES tab. Lighter event-log register (not journal-weighted) —
/// the section header carries the "solved" context, so the row drops
/// the verb. Title only + a bookmark-add icon on the right edge.
///
/// One tap (anywhere on the row) commits the save. No confirmation
/// prompt — low-ceremony register, matching the bookmark glyph on the
/// rescue screen.
class RecentlySolvedRow extends StatelessWidget {
  const RecentlySolvedRow({
    super.key,
    required this.entry,
    required this.onSaveTap,
  });

  final RecentlySolvedEntry entry;
  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    final title = localizedPuzzleTitle(entry.canonicalPuzzleId);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSaveTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppText.body.copyWith(
                  fontSize: 14,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.bookmark_add_outlined,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
