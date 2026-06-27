import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/records/records_sheet.dart';
import 'package:chess_rescue/features/signatures/signatures_tab.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrapWithSheet(ProgressStore? store) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Builder(
      builder: (context) {
        return Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(size: Size(420, 800)),
            child: RecordsSheet(store: store),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecordsSheet — PR 2 segmented tabs', () {
    testWidgets(
      'fresh install: segmented control renders both labels; default tab is RECORDS',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(_wrapWithSheet(store));
        await tester.pump();

        // Both tab buttons exist.
        expect(find.text('RECORDS'), findsOneWidget);
        expect(find.text('SIGNATURES'), findsOneWidget);
        // Default tab: RECORDS — count line and category sections visible.
        expect(find.text('0 / 14'), findsOneWidget);
        expect(find.text('First Rescue'), findsOneWidget);
        // SignaturesTab is NOT mounted on the default tab.
        expect(find.byType(SignaturesTab), findsNothing);
      },
    );

    testWidgets(
      'tap SIGNATURES → body switches to SignaturesTab; count line not visible',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(_wrapWithSheet(store));
        await tester.pump();

        await tester.tap(find.text('SIGNATURES'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(SignaturesTab), findsOneWidget);
        // Count line and category sections do NOT render on SIGNATURES.
        expect(find.text('0 / 14'), findsNothing);
        expect(find.text('First Rescue'), findsNothing);
        // Empty-state copy IS visible (no signatures saved on fresh install).
        expect(find.text('Some rescues stay with you.'), findsOneWidget);
      },
    );

    testWidgets(
      'tap RECORDS after SIGNATURES → body switches back, count line returns',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(_wrapWithSheet(store));
        await tester.pump();
        await tester.tap(find.text('SIGNATURES'));
        await tester.pump();
        await tester.tap(find.text('RECORDS'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(SignaturesTab), findsNothing);
        expect(find.text('0 / 14'), findsOneWidget);
      },
    );
  });
}
