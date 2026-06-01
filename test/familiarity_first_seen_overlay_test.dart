import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/features/familiarity/familiarity_first_seen_overlay.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FamiliarityFirstSeenOverlay', () {
    testWidgets(
      'renders both lines: FAMILIAR cue label + the short body line',
      (tester) async {
        await tester.pumpWidget(
          _wrap(FamiliarityFirstSeenOverlay(onDismissed: () {})),
        );
        await tester.pump(const Duration(milliseconds: 280));
        expect(find.text('FAMILIAR'), findsOneWidget);
        // The player's-internal-voice body line — short, no
        // "the game notices" framing.
        expect(find.text('You know this one.'), findsOneWidget);
      },
    );

    testWidgets('mounts under the familiarity-first-seen-overlay ValueKey', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(FamiliarityFirstSeenOverlay(onDismissed: () {})),
      );
      await tester.pump(const Duration(milliseconds: 280));
      expect(
        find.byKey(const ValueKey('familiarity-first-seen-overlay')),
        findsOneWidget,
      );
    });

    testWidgets('is non-interactive (no tap dismissal)', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        _wrap(FamiliarityFirstSeenOverlay(onDismissed: () => dismissed = true)),
      );
      await tester.pump(const Duration(milliseconds: 280));
      await tester.tap(
        find.byKey(const ValueKey('familiarity-first-seen-overlay')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(dismissed, isFalse);
    });

    testWidgets('auto-dismisses after fade-in + hold + fade-out (~3 seconds)', (
      tester,
    ) async {
      var dismissed = false;
      await tester.pumpWidget(
        _wrap(FamiliarityFirstSeenOverlay(onDismissed: () => dismissed = true)),
      );
      // Fade-in (240ms) + hold (2500ms) + fade-out (240ms) ≈ 2980ms.
      await tester.pump(const Duration(milliseconds: 240));
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(dismissed, isTrue);
    });
  });
}
