import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'features/rescue_game/rescue_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
    ),
  );
  runApp(const ChessRescueApp());
}

class ChessRescueApp extends StatelessWidget {
  const ChessRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Rescue',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RescueScreen(),
    );
  }
}
