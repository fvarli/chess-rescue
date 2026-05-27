import 'package:flutter/services.dart';

// Centralized haptic language. One method per moment so the tactile
// vocabulary is consistent and tunable. All calls are fire-and-forget;
// HapticFeedback no-ops silently on platforms that don't support it.
class Haptics {
  Haptics._();

  // Piece selection — light, immediate.
  static void select() => HapticFeedback.selectionClick();

  // The instant the player taps a destination square — fires before any
  // visual reaction so the touch feels acknowledged immediately.
  static void commitTap() => HapticFeedback.selectionClick();

  // Rescue arrival — the emotional confirmation.
  static void rescue() => HapticFeedback.mediumImpact();

  // Failed arrival — heavier, the wince.
  static void fail() => HapticFeedback.heavyImpact();

  // Footer button press on tap-down (not on action complete).
  static void tapButton() => HapticFeedback.selectionClick();
}
