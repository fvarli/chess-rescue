import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';

/// R1B — single-row records preview card on Home.
///
/// The Home composition is vertically tight (G1.5 left only ~10dp slack on
/// the 800dp test viewport); a multi-row preview overflows. The book's
/// *open page* lives inside the sheet itself — Home just acknowledges the
/// book exists, names it, and ledgers the count. Tapping opens the sheet.
///
/// The "just unlocked" pulse renders as a mint border glow rather than a
/// content row, so the height stays single-line.
class RecordsPreview extends StatelessWidget {
  const RecordsPreview({
    super.key,
    required this.unlockedRecords,
    required this.justUnlocked,
    required this.onTap,
  });

  final List<String> unlockedRecords;
  final bool justUnlocked;
  final VoidCallback onTap;

  static const Duration _pulseDuration = Duration(milliseconds: 1500);
  static const int _totalRecords = 13;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    final isAllUnlocked = unlockedRecords.length >= _totalRecords;
    final countText = isAllUnlocked
        ? '${unlockedRecords.length} / $_totalRecords'
        : l.recordsCount(unlockedRecords.length, _totalRecords);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: justUnlocked ? 1.0 : 0.0, end: 0.0),
        duration: _pulseDuration,
        curve: Curves.easeOut,
        builder: (context, glow, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: glow > 0
                  ? [
                      BoxShadow(
                        color: AppColors.rescue.withValues(alpha: 0.35 * glow),
                        blurRadius: 14 * glow,
                        spreadRadius: 1 * glow,
                      ),
                    ]
                  : null,
            ),
            child: child,
          );
        },
        child: Container(
          key: const ValueKey('home-records-preview'),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.hairline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.recordsSheetEyebrow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                countText,
                style: AppText.mono.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '↦',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
