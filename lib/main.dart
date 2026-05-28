import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/storage/progress_store.dart';
import 'core/theme/app_theme.dart';
import 'features/rescue_game/rescue_screen.dart';

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
  final store = await ProgressStore.create();
  runApp(ChessRescueApp(store: store));
}

class ChessRescueApp extends StatelessWidget {
  const ChessRescueApp({super.key, required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Rescue',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
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
