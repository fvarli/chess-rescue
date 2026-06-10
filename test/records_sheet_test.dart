import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/records/records_sheet.dart';
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
            data: const MediaQueryData(size: Size(360, 800)),
            child: RecordsSheet(store: store),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'fresh install: sheet shows 0 / 13 + intro line + 3 revealed entry-level rows',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await tester.pumpWidget(_wrapWithSheet(store));
      await tester.pump();

      expect(find.byKey(const ValueKey('records-sheet')), findsOneWidget);
      expect(find.text('RESCUE RECORDS'), findsOneWidget);
      expect(find.text('0 / 13'), findsOneWidget);
      expect(
        find.text('These pages will fill themselves.'),
        findsAtLeastNWidgets(1),
      );
      // Three revealed entry-level rows.
      expect(find.text('First Rescue'), findsOneWidget);
      expect(find.text('Strike Back'), findsOneWidget);
      expect(find.text('Endless Spark'), findsOneWidget);
      // Chained-mystery rows below those entries are NOT yet visible.
      expect(find.text('The Rescuer'), findsNothing);
      expect(find.text('End the Threat'), findsNothing);
      expect(find.text('Endless Focus'), findsNothing);
      // Mastery section is entirely hidden.
      expect(find.text('Mastery'), findsNothing);
      expect(find.text('Unshaken'), findsNothing);
    },
  );

  testWidgets(
    'after First Rescue unlocks: The Rescuer becomes a mystery row (??? / Unknown Record.)',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_lifetime_saved': 1,
        'flutter.cr_unlocked_records': '["first-rescue"]',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(_wrapWithSheet(store));
      await tester.pump();

      expect(find.text('1 / 13'), findsOneWidget);
      expect(find.text('First Rescue'), findsOneWidget);
      // The Rescuer row appears, but as mystery.
      expect(find.text('The Rescuer'), findsNothing);
      expect(find.text('???'), findsAtLeastNWidgets(1));
      expect(find.text('Unknown Record.'), findsAtLeastNWidgets(1));
      // The intro line is gone once any record is unlocked.
      expect(find.text('These pages will fill themselves.'), findsNothing);
    },
  );

  testWidgets('Mastery section appears the moment Unshaken is earned', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'flutter.cr_unlocked_records': '["first-rescue","unshaken"]',
    });
    final store = await ProgressStore.create();
    await tester.pumpWidget(_wrapWithSheet(store));
    await tester.pump();

    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('Unshaken'), findsOneWidget);
    // Unshaken's row shows the unlocked past-tense description.
    expect(find.text('Unshaken throughout.'), findsOneWidget);
  });

  group('PR-12 — RECORDS tab "Today" trailer', () {
    testWidgets('today-dated unlock shows the "Today" trailer under the row', (
      tester,
    ) async {
      // Seed an unlock whose date is "now" — Today should render.
      final now = DateTime.now().toUtc();
      SharedPreferences.setMockInitialValues({
        'flutter.cr_lifetime_saved': 1,
        'flutter.cr_unlocked_records': '["first-rescue"]',
        'flutter.cr_unlocked_record_dates':
            '{"first-rescue":"${now.toIso8601String()}"}',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(_wrapWithSheet(store));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('records-sheet-row-today-first-rescue')),
        findsOneWidget,
      );
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('legacy unlock (no date stored) renders no "Today" trailer', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_lifetime_saved': 1,
        'flutter.cr_unlocked_records': '["first-rescue"]',
        // Intentionally NO cr_unlocked_record_dates key.
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(_wrapWithSheet(store));
      await tester.pump();

      expect(find.text('First Rescue'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('records-sheet-row-today-first-rescue')),
        findsNothing,
      );
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('older-dated unlock (last year) renders no "Today" trailer', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_lifetime_saved': 1,
        'flutter.cr_unlocked_records': '["first-rescue"]',
        'flutter.cr_unlocked_record_dates':
            '{"first-rescue":"2025-01-01T12:00:00.000Z"}',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(_wrapWithSheet(store));
      await tester.pump();

      expect(find.text('First Rescue'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
    });
  });

  testWidgets(
    'all 13 unlocked: count line swaps to "Every page has been written."',
    (tester) async {
      // Records with derived (non-eventOnly) sources require their
      // underlying signals to be satisfied. Set lifetime/streak/completedIds
      // high enough that every derived record evaluates to unlocked, and
      // include event-only ids in the unlockedRecords set.
      SharedPreferences.setMockInitialValues({
        'flutter.cr_lifetime_saved': 100,
        'flutter.cr_best_endless_streak': 15,
        'flutter.cr_completed_ids': [
          'p1-knight-rescue',
          'a4-the-breakaway',
          'b4-the-cross-check',
          'p2-take-the-checker',
          'p5-win-the-queen',
          'b3-remove-the-defender',
          'p3-block-the-file',
          'p4-seal-the-diagonal',
          'b1-the-martyr',
        ],
        'flutter.cr_unlocked_records':
            '["ep4-the-other-side","against-the-odds","unshaken"]',
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(_wrapWithSheet(store));
      await tester.pump();
      expect(
        find.text('Every page has been written.'),
        findsAtLeastNWidgets(1),
      );
    },
  );
}
