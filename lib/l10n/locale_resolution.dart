import 'package:flutter/widgets.dart';

/// Resolves the active app locale from the device's preferred locale.
///
/// Maps device languages to the app's supported set:
/// - `tr` → Turkish
/// - `es` → Spanish
/// - everything else (including `null`) → English
///
/// Country / script subtags on the device locale are intentionally ignored —
/// only the language code matters for our copy (e.g. `es_MX` and `es_ES` both
/// resolve to [Locale('es')]).
///
/// The signature matches [MaterialApp.localeResolutionCallback] so it can be
/// passed directly as a tear-off:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   localeResolutionCallback: resolveAppLocale,
///   // …
/// )
/// ```
Locale resolveAppLocale(Locale? device, Iterable<Locale> supported) {
  return switch (device?.languageCode) {
    'tr' => const Locale('tr'),
    'es' => const Locale('es'),
    _ => const Locale('en'),
  };
}
