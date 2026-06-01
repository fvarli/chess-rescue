import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/features/records/record_unlock_overlay.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: SizedBox(width: 360, height: 200, child: Center(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('standard variant renders eyebrow + title + description', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RecordUnlockOverlay(
          eyebrow: '✓ RECORD UNLOCKED',
          eyebrowIsFirstEver: false,
          title: 'First Rescue',
          description: 'Your first rescue.',
          onDismissed: () {},
        ),
      ),
    );
    // Pump fade-in.
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('✓ RECORD UNLOCKED'), findsOneWidget);
    expect(find.text('First Rescue'), findsOneWidget);
    expect(find.text('Your first rescue.'), findsOneWidget);
  });

  testWidgets(
    'first-ever variant uses italic sentence eyebrow ("A page has been written.")',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          RecordUnlockOverlay(
            eyebrow: 'A page has been written.',
            eyebrowIsFirstEver: true,
            title: 'First Rescue',
            description: 'Your first rescue.',
            onDismissed: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('A page has been written.'), findsOneWidget);
      // Verify the eyebrow Text widget has italic style.
      final eyebrowFinder = find.text('A page has been written.');
      final widget = tester.widget<Text>(eyebrowFinder);
      expect(widget.style?.fontStyle, FontStyle.italic);
    },
  );

  testWidgets('auto-dismisses after the full lifecycle', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      _wrap(
        RecordUnlockOverlay(
          eyebrow: '✓ RECORD UNLOCKED',
          eyebrowIsFirstEver: false,
          title: 'First Rescue',
          description: 'Your first rescue.',
          onDismissed: () => dismissed = true,
        ),
      ),
    );
    // Pump through each lifecycle phase. fade-in 240 + hold 2500 + fade-out
    // 200 = 2940ms total. Pumping in chunks lets the controller's
    // animateTo Future + the scheduled Timer fire in sim time.
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 250));
    expect(dismissed, isTrue);
  });

  testWidgets('tap dismisses early', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      _wrap(
        RecordUnlockOverlay(
          eyebrow: '✓ RECORD UNLOCKED',
          eyebrowIsFirstEver: false,
          title: 'First Rescue',
          description: 'Your first rescue.',
          onDismissed: () => dismissed = true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const ValueKey('record-unlock-overlay')));
    // Allow the fade-out animateTo Future to complete + onDismissed to fire.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(dismissed, isTrue);
  });
}
