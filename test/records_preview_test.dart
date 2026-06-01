import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/features/records/records_preview.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(
      body: SizedBox(width: 360, height: 200, child: Center(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'fresh install: eyebrow + 0 / 13 + chevron, no open-page row content',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          RecordsPreview(
            unlockedRecords: const <String>[],
            justUnlocked: false,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('home-records-preview')),
        findsOneWidget,
      );
      expect(find.text('RESCUE RECORDS'), findsOneWidget);
      expect(find.text('0 / 13'), findsOneWidget);
      expect(find.text('↦'), findsOneWidget);
      // No record-title text (we don't expose any unlocked record here).
      expect(find.text('First Rescue'), findsNothing);
    },
  );

  testWidgets(
    'mid-journey: count reflects unlocked count, no header label like "Recently Written"',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          RecordsPreview(
            unlockedRecords: const <String>[
              'first-rescue',
              'ep1-strike-back',
              'endless-spark',
            ],
            justUnlocked: false,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('3 / 13'), findsOneWidget);
      // Confirm no achievement-feed labels leak in.
      expect(find.text('Recently Written'), findsNothing);
      expect(find.text('Latest'), findsNothing);
      expect(find.text('Coming Up'), findsNothing);
    },
  );

  testWidgets('all 13 unlocked: count reads 13 / 13', (tester) async {
    final unlocked = List<String>.generate(13, (i) => 'record-$i');
    await tester.pumpWidget(
      _wrap(
        RecordsPreview(
          unlockedRecords: unlocked,
          justUnlocked: false,
          onTap: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('13 / 13'), findsOneWidget);
  });

  testWidgets('tap fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        RecordsPreview(
          unlockedRecords: const <String>[],
          justUnlocked: false,
          onTap: () => taps += 1,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('home-records-preview')));
    await tester.pump();
    expect(taps, 1);
  });
}
