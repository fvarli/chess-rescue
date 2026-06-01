import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';

/// PR 3 Familiarity — the bare ambient recognition cue. Quiet mono
/// small-caps text reading the localized [familiarCueLabel]
/// (`FAMILIAR` / `AŞİNA` / `FAMILIAR`). Rendered on the rescued
/// screen for any puzzle the player has solved before.
///
/// The widget knows nothing of storage or the controller — the host
/// (RescueScreen) decides when it's mounted. No animation, no haptic,
/// no icon. Visually quieter than SavedBadge (`AppColors.textDim`
/// instead of `AppColors.textMuted` → `rescue` on completion).
class FamiliarCue extends StatelessWidget {
  const FamiliarCue({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        l.familiarCueLabel,
        style: AppText.mono.copyWith(fontSize: 10, color: AppColors.textDim),
      ),
    );
  }
}
