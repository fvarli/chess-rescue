import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'core/storage/progress_store.dart';
import 'core/theme/app_theme.dart';
import 'features/rescue_game/rescue_screen.dart';
import 'l10n/app_language_mode.dart';
import 'l10n/gen/app_localizations.dart';
import 'l10n/language_scope.dart';
import 'l10n/locale_resolution.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
    ),
  );
  // Never fail to launch because local storage init threw — fall back to a
  // degraded, no-persistence session instead of crashing.
  ProgressStore? store;
  try {
    store = await ProgressStore.create();
  } catch (_) {
    store = null;
  }
  runApp(ChessRescueApp(store: store));
}

class ChessRescueApp extends StatefulWidget {
  const ChessRescueApp({super.key, required this.store});

  final ProgressStore? store;

  @override
  State<ChessRescueApp> createState() => _ChessRescueAppState();
}

class _ChessRescueAppState extends State<ChessRescueApp> {
  late AppLanguageMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = parseAppLanguageMode(widget.store?.languageMode);
  }

  void _handleChangeMode(AppLanguageMode mode) {
    if (mode == _mode) return;
    setState(() => _mode = mode);
    // Persist the choice; fire-and-forget. The in-memory state already drives
    // the next frame so the UI updates immediately.
    unawaited(widget.store?.setLanguageMode(mode.name));
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      mode: _mode,
      onChange: _handleChangeMode,
      child: MaterialApp(
        title: 'Chess Rescue',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        // Localization: AppL10n is the code-generated class produced from
        // lib/l10n/*.arb (C1). Device-locale → tr/es/en mapping lives in
        // lib/l10n/locale_resolution.dart as a pure, tested helper (C4).
        // `locale` is null for system mode (defers to the device locale +
        // resolver) or a const Locale for a manual override (C5).
        locale: _mode.locale,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        localeResolutionCallback: resolveAppLocale,
        // Board-dominant single screen — clamp accessibility text scaling so the
        // fixed composition stays stable (no scroll by design).
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.35,
          child: child!,
        ),
        home: RescueScreen(store: widget.store),
      ),
    );
  }
}
