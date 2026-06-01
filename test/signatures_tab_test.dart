import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/recently_solved_entry.dart';
import 'package:chess_rescue/core/models/signature_entry.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/signatures/recently_solved_row.dart';
import 'package:chess_rescue/features/signatures/signature_card.dart';
import 'package:chess_rescue/features/signatures/signatures_tab.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData(size: Size(420, 800)),
        child: child,
      ),
    ),
  );
}

SignatureEntry _sig(String canonicalId, {String episode = 'ep1-strike-back'}) =>
    SignatureEntry(
      canonicalPuzzleId: canonicalId,
      encounteredPuzzleId: canonicalId,
      episodeId: episode,
      adoptedAt: DateTime.now(),
    );

RecentlySolvedEntry _recent(String canonicalId) => RecentlySolvedEntry(
  canonicalPuzzleId: canonicalId,
  encounteredPuzzleId: canonicalId,
  episodeId: 'ep1-strike-back',
  solvedAt: DateTime.now(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignaturesTab — empty signatures', () {
    testWidgets(
      'empty signatures + empty recently-solved → both empty-state lines, no RECENTLY SOLVED header',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(_wrap(SignaturesTab(store: store)));
        await tester.pump();

        expect(find.text('Some rescues stay with you.'), findsOneWidget);
        expect(find.text('This is where you keep them.'), findsOneWidget);
        expect(find.text('RECENTLY SOLVED'), findsNothing);
        expect(find.byType(SignatureCard), findsNothing);
        expect(find.byType(RecentlySolvedRow), findsNothing);
      },
    );

    testWidgets(
      'empty signatures + 3 recently-solved → empty-state copy + header + 3 rows',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await store.recordRecentlySolved(_recent('p1-knight-rescue'));
        await store.recordRecentlySolved(_recent('p2-take-the-checker'));
        await store.recordRecentlySolved(_recent('p3-block-the-file'));
        await tester.pumpWidget(_wrap(SignaturesTab(store: store)));
        await tester.pump();

        expect(find.text('Some rescues stay with you.'), findsOneWidget);
        expect(find.text('RECENTLY SOLVED'), findsOneWidget);
        expect(find.byType(RecentlySolvedRow), findsNWidgets(3));
      },
    );
  });

  group('SignaturesTab — with signatures', () {
    testWidgets(
      '2 signatures + 3 recently-solved (1 overlapping) → 2 cards + 2 rows',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await store.addSignature(_sig('p1-knight-rescue'));
        await store.addSignature(_sig('p2-take-the-checker'));
        await store.recordRecentlySolved(_recent('p3-block-the-file'));
        // Recording one whose canonical id IS in signatures.
        await store.recordRecentlySolved(_recent('p1-knight-rescue'));
        await store.recordRecentlySolved(_recent('p4-seal-the-diagonal'));

        await tester.pumpWidget(_wrap(SignaturesTab(store: store)));
        await tester.pump();

        // 2 saved cards.
        expect(find.byType(SignatureCard), findsNWidgets(2));
        // RECENTLY SOLVED filters out p1-knight-rescue → 2 visible rows.
        expect(find.byType(RecentlySolvedRow), findsNWidgets(2));
        // The empty-state copy must NOT appear when signatures exist.
        expect(find.text('Some rescues stay with you.'), findsNothing);
      },
    );

    testWidgets(
      'tapping a recently-solved row adds the signature and re-renders',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await store.recordRecentlySolved(_recent('p2-take-the-checker'));
        await tester.pumpWidget(_wrap(SignaturesTab(store: store)));
        await tester.pump();

        expect(find.byType(SignatureCard), findsNothing);
        expect(find.byType(RecentlySolvedRow), findsOneWidget);

        await tester.tap(find.byType(RecentlySolvedRow));
        // Pump for setState after async addSignature.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // A card appears; the row is filtered out.
        expect(find.byType(SignatureCard), findsOneWidget);
        expect(find.byType(RecentlySolvedRow), findsNothing);
      },
    );
  });

  group('SignaturesTab — store-null defensive', () {
    testWidgets('null store renders empty-state copy without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SignaturesTab(store: null)));
      await tester.pump();
      expect(find.text('Some rescues stay with you.'), findsOneWidget);
      expect(find.byType(SignatureCard), findsNothing);
    });
  });
}
