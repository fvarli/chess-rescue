import 'package:flutter/widgets.dart';

/// Player's chosen language behaviour. [system] defers to the device locale
/// (which then runs through `resolveAppLocale` for the tr/es/en mapping); the
/// other modes force the app into a specific locale regardless of device.
///
/// Persisted by [ProgressStore] as the lowercase enum name under
/// `cr_language_mode`.
enum AppLanguageMode { system, en, tr, es }

extension AppLanguageModeX on AppLanguageMode {
  /// `null` for [system] so `MaterialApp.locale = null` defers to the device
  /// locale + `localeResolutionCallback`. Otherwise returns a const Locale
  /// that the resolver passes through unchanged.
  Locale? get locale => switch (this) {
    AppLanguageMode.system => null,
    AppLanguageMode.en => const Locale('en'),
    AppLanguageMode.tr => const Locale('tr'),
    AppLanguageMode.es => const Locale('es'),
  };
}

/// Parses a persisted string into an [AppLanguageMode]. Unknown / null values
/// resolve to [AppLanguageMode.system] — the safe default that preserves the
/// existing device-locale behaviour.
AppLanguageMode parseAppLanguageMode(String? raw) {
  switch (raw) {
    case 'en':
      return AppLanguageMode.en;
    case 'tr':
      return AppLanguageMode.tr;
    case 'es':
      return AppLanguageMode.es;
    default:
      return AppLanguageMode.system;
  }
}
