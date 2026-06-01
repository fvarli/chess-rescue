import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/theme/app_theme.dart';
import 'package:chess_rescue/features/familiarity/familiar_cue.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FamiliarCue', () {
    testWidgets('renders the localized "FAMILIAR" text in English', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const FamiliarCue()));
      await tester.pump();
      expect(find.text('FAMILIAR'), findsOneWidget);
    });

    testWidgets('uses AppText.mono family + AppColors.textDim color', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const FamiliarCue()));
      await tester.pump();
      final text = tester.widget<Text>(find.text('FAMILIAR'));
      final style = text.style!;
      expect(style.fontFamily, AppText.mono.fontFamily);
      expect(style.color, AppColors.textDim);
      // Critically NOT mint — mint is reserved for SAVED.
      expect(style.color, isNot(AppColors.rescue));
    });

    testWidgets(
      'is not interactive (no GestureDetector / IconButton wrapper)',
      (tester) async {
        await tester.pumpWidget(_wrap(const FamiliarCue()));
        await tester.pump();
        expect(find.byType(GestureDetector), findsNothing);
        expect(find.byType(IconButton), findsNothing);
        expect(find.byType(InkWell), findsNothing);
      },
    );
  });
}
