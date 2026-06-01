import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/features/signatures/first_bookmark_hint_overlay.dart';
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

  group('FirstBookmarkHintOverlay', () {
    testWidgets('renders both relationship-naming lines', (tester) async {
      await tester.pumpWidget(
        _wrap(FirstBookmarkHintOverlay(onDismissed: () {})),
      );
      // Pump past the fade-in.
      await tester.pump(const Duration(milliseconds: 280));
      expect(find.text('Saved.'), findsOneWidget);
      expect(find.text('Keep the rescues that stay with you.'), findsOneWidget);
    });

    testWidgets('mounts under the first-bookmark-hint-overlay ValueKey', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(FirstBookmarkHintOverlay(onDismissed: () {})),
      );
      await tester.pump(const Duration(milliseconds: 280));
      expect(
        find.byKey(const ValueKey('first-bookmark-hint-overlay')),
        findsOneWidget,
      );
    });

    testWidgets('is non-interactive (no tap dismissal)', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        _wrap(FirstBookmarkHintOverlay(onDismissed: () => dismissed = true)),
      );
      await tester.pump(const Duration(milliseconds: 280));
      // Tap the banner; it should NOT dismiss early.
      await tester.tap(
        find.byKey(const ValueKey('first-bookmark-hint-overlay')),
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
        _wrap(FirstBookmarkHintOverlay(onDismissed: () => dismissed = true)),
      );
      // Pump enough time for fade-in (240ms) + hold (2500ms) + fade-out
      // (240ms) ≈ 2980ms. Add slack.
      await tester.pump(const Duration(milliseconds: 240));
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(dismissed, isTrue);
    });
  });
}
