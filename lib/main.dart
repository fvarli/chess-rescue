import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/storage/progress_store.dart';
import 'core/theme/app_theme.dart';
import 'features/rescue_game/rescue_screen.dart';
import 'l10n/gen/app_localizations.dart';
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

class ChessRescueApp extends StatelessWidget {
  const ChessRescueApp({super.key, required this.store});

  final ProgressStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Rescue',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Localization: AppL10n is the code-generated class produced from
      // lib/l10n/*.arb (C1). Device-locale → tr/es/en mapping lives in
      // lib/l10n/locale_resolution.dart as a pure, tested helper (C4).
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      localeResolutionCallback: resolveAppLocale,
      // Board-dominant single screen — clamp accessibility text scaling so the
      // fixed composition stays stable (no scroll by design).
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.35,
        child: child!,
      ),
      home: RescueScreen(store: store),
    );
  }
}
