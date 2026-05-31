import 'package:flutter/widgets.dart';

import 'app_language_mode.dart';

/// Exposes the current [AppLanguageMode] + an [onChange] callback to
/// descendants of `ChessRescueApp`. The picker reads `LanguageScope.of(context)`
/// to flip the app's locale; the scope is placed **above** the `MaterialApp`
/// so the lookup still works from any route or bottom sheet.
class LanguageScope extends InheritedWidget {
  const LanguageScope({
    super.key,
    required this.mode,
    required this.onChange,
    required super.child,
  });

  final AppLanguageMode mode;
  final ValueChanged<AppLanguageMode> onChange;

  static LanguageScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    assert(
      scope != null,
      'LanguageScope.of() called from a context without a LanguageScope '
      'ancestor. Ensure ChessRescueApp (which provides it) wraps the widget '
      'tree that touches the language picker.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(LanguageScope old) => mode != old.mode;
}
