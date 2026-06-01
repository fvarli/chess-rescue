import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/recently_solved_entry.dart';
import 'package:chess_rescue/core/theme/app_theme.dart';
import 'package:chess_rescue/features/signatures/recently_solved_row.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: child),
  );
}

RecentlySolvedEntry _entry({String id = 'p2-take-the-checker'}) =>
    RecentlySolvedEntry(
      canonicalPuzzleId: id,
      encounteredPuzzleId: id,
      episodeId: 'ep1-strike-back',
      solvedAt: DateTime.now(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecentlySolvedRow', () {
    testWidgets(
      'renders the puzzle title only (no time fragment, no "solved" verb)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(RecentlySolvedRow(entry: _entry(), onSaveTap: () {})),
        );
        await tester.pump();
        expect(find.text('Take the checker'), findsOneWidget);
        // Critically: no "solved" verb, no time fragment.
        expect(find.textContaining('solved'), findsNothing);
        expect(find.textContaining('today'), findsNothing);
      },
    );

    testWidgets('bookmark icon visible on the right edge in textMuted color', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(RecentlySolvedRow(entry: _entry(), onSaveTap: () {})),
      );
      await tester.pump();
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.bookmark_add_outlined);
      expect(icon.color, AppColors.textMuted);
    });

    testWidgets('tap on row invokes onSaveTap callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(RecentlySolvedRow(entry: _entry(), onSaveTap: () => taps += 1)),
      );
      await tester.pump();
      await tester.tap(find.byType(RecentlySolvedRow));
      expect(taps, 1);
    });
  });
}
