import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

/// R1B — resolver for the symbolic mark drawn on each record row.
///
/// Each glyph is an OUTLINED Material Icon — never filled, never gold-tier
/// badge-y. Renders in `AppColors.textDim` at 18dp on unlocked rows,
/// `AppColors.textMuted` at 0.6α on locked rows. Mystery rows (chained-
/// not-yet-earned) receive `null` and the row renders a quiet `○`
/// placeholder instead — preserving the player's discovery.
IconData? symbolFor(String recordId) {
  switch (recordId) {
    case 'first-rescue':
      return Icons.bookmark_outline;
    case 'the-rescuer':
      return Icons.favorite_outline;
    case 'unbroken':
      return Icons.link;
    case 'ep1-strike-back':
      return Icons.bolt_outlined;
    case 'ep2-end-the-threat':
      return Icons.close;
    case 'ep3-hold-the-line':
      return Icons.horizontal_rule;
    case 'ep4-the-other-side':
      return Icons.flip;
    case 'against-the-odds':
      return Icons.auto_awesome_outlined;
    case 'endless-spark':
      return Icons.lens_outlined;
    case 'endless-focus':
      return Icons.adjust;
    case 'endless-master':
      return Icons.workspace_premium_outlined;
    case 'unshaken':
      return Icons.shield_outlined;
  }
  return null;
}

/// AppL10n title getter for a record id.
String recordTitleFor(String id, AppL10n l) {
  switch (id) {
    case 'first-rescue':
      return l.recordTitle_firstRescue;
    case 'the-rescuer':
      return l.recordTitle_theRescuer;
    case 'unbroken':
      return l.recordTitle_unbroken;
    case 'ep1-strike-back':
      return l.recordTitle_ep1StrikeBack;
    case 'ep2-end-the-threat':
      return l.recordTitle_ep2EndTheThreat;
    case 'ep3-hold-the-line':
      return l.recordTitle_ep3HoldTheLine;
    case 'ep4-the-other-side':
      return l.recordTitle_ep4TheOtherSide;
    case 'against-the-odds':
      return l.recordTitle_againstTheOdds;
    case 'endless-spark':
      return l.recordTitle_endlessSpark;
    case 'endless-focus':
      return l.recordTitle_endlessFocus;
    case 'endless-master':
      return l.recordTitle_endlessMaster;
    case 'unshaken':
      return l.recordTitle_unshaken;
  }
  return '';
}

/// Locked-state (imperative) description for a record id.
String recordDescriptionLockedFor(String id, AppL10n l) {
  switch (id) {
    case 'first-rescue':
      return l.recordDescriptionLocked_firstRescue;
    case 'the-rescuer':
      return l.recordDescriptionLocked_theRescuer;
    case 'unbroken':
      return l.recordDescriptionLocked_unbroken;
    case 'ep1-strike-back':
      return l.recordDescriptionLocked_ep1StrikeBack;
    case 'ep2-end-the-threat':
      return l.recordDescriptionLocked_ep2EndTheThreat;
    case 'ep3-hold-the-line':
      return l.recordDescriptionLocked_ep3HoldTheLine;
    case 'ep4-the-other-side':
      return l.recordDescriptionLocked_ep4TheOtherSide;
    case 'against-the-odds':
      return l.recordDescriptionLocked_againstTheOdds;
    case 'endless-spark':
      return l.recordDescriptionLocked_endlessSpark;
    case 'endless-focus':
      return l.recordDescriptionLocked_endlessFocus;
    case 'endless-master':
      return l.recordDescriptionLocked_endlessMaster;
    case 'unshaken':
      return l.recordDescriptionLocked_unshaken;
  }
  return '';
}

/// Unlocked-state (past-tense diary) description for a record id.
String recordDescriptionUnlockedFor(String id, AppL10n l) {
  switch (id) {
    case 'first-rescue':
      return l.recordDescriptionUnlocked_firstRescue;
    case 'the-rescuer':
      return l.recordDescriptionUnlocked_theRescuer;
    case 'unbroken':
      return l.recordDescriptionUnlocked_unbroken;
    case 'ep1-strike-back':
      return l.recordDescriptionUnlocked_ep1StrikeBack;
    case 'ep2-end-the-threat':
      return l.recordDescriptionUnlocked_ep2EndTheThreat;
    case 'ep3-hold-the-line':
      return l.recordDescriptionUnlocked_ep3HoldTheLine;
    case 'ep4-the-other-side':
      return l.recordDescriptionUnlocked_ep4TheOtherSide;
    case 'against-the-odds':
      return l.recordDescriptionUnlocked_againstTheOdds;
    case 'endless-spark':
      return l.recordDescriptionUnlocked_endlessSpark;
    case 'endless-focus':
      return l.recordDescriptionUnlocked_endlessFocus;
    case 'endless-master':
      return l.recordDescriptionUnlocked_endlessMaster;
    case 'unshaken':
      return l.recordDescriptionUnlocked_unshaken;
  }
  return '';
}
