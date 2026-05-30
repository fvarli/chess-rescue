import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/storage/progress_store.dart';
import 'core/theme/app_theme.dart';
import 'features/rescue_game/rescue_screen.dart';
import 'l10n/gen/app_localizations.dart';

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
      // Localization scaffolding (Phase C1). Strings live in lib/l10n/*.arb and
      // the generated AppL10n class. Real string extraction lands in C2.
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      // Device language → tr or es when matched; everything else falls to en.
      localeResolutionCallback: (device, supported) {
        final code = device?.languageCode;
        if (code == 'tr' || code == 'es') return Locale(code!);
        return const Locale('en');
      },
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
