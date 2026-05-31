import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_language_mode.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../l10n/language_scope.dart';

/// Tiny header affordance that opens the language picker. Visual weight kept
/// to a mono micro-label tier (32 dp tap target, 18 dp glyph in textMuted) so
/// it never competes with the gameplay chrome.
class LanguagePickerButton extends StatelessWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    return SizedBox.square(
      dimension: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        color: AppColors.textMuted,
        tooltip: t.settingsLanguage,
        icon: const Icon(Icons.language),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: AppColors.bg,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _LanguagePickerSheet(),
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context)!;
    final scope = LanguageScope.of(context);

    Widget option(AppLanguageMode mode, String label) {
      final selected = scope.mode == mode;
      return InkWell(
        onTap: () => scope.onChange(mode),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.rescue : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: AppText.body)),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 6),
            child: Text(
              t.settingsLanguage,
              style: AppText.headline.copyWith(fontSize: 20),
            ),
          ),
          const SizedBox(height: 6),
          option(AppLanguageMode.system, t.settingsLanguageSystemDefault),
          option(AppLanguageMode.en, t.settingsLanguageEnglish),
          option(AppLanguageMode.tr, t.settingsLanguageTurkish),
          option(AppLanguageMode.es, t.settingsLanguageSpanish),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  t.settingsDone,
                  style: AppText.button.copyWith(color: AppColors.rescue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
