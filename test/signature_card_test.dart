import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/models/signature_entry.dart';
import 'package:chess_rescue/features/rescue_game/widgets/board_widget.dart';
import 'package:chess_rescue/features/signatures/signature_card.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

SignatureEntry _canonicalToday() => SignatureEntry(
  canonicalPuzzleId: 'p1-knight-rescue',
  encounteredPuzzleId: 'p1-knight-rescue',
  episodeId: 'ep1-strike-back',
  adoptedAt: DateTime.now(),
);

SignatureEntry _canonicalOld() => SignatureEntry(
  canonicalPuzzleId: 'p1-knight-rescue',
  encounteredPuzzleId: 'p1-knight-rescue',
  episodeId: 'ep1-strike-back',
  adoptedAt: DateTime.now().subtract(const Duration(days: 7)),
);

SignatureEntry _endlessToday() => SignatureEntry(
  canonicalPuzzleId: 'b1-the-martyr',
  encounteredPuzzleId: 'b1-the-martyr#mirror',
  episodeId: 'ep5-endless-rescue',
  adoptedAt: DateTime.now(),
  endlessSeed: 4842,
  endlessMirrored: true,
);

SignatureEntry _endlessOld() => SignatureEntry(
  canonicalPuzzleId: 'b1-the-martyr',
  encounteredPuzzleId: 'b1-the-martyr',
  episodeId: 'ep5-endless-rescue',
  adoptedAt: DateTime.now().subtract(const Duration(days: 14)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignatureCard', () {
    testWidgets('renders a BoardWidget thumbnail (danger state)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SignatureCard(entry: _canonicalToday(), onTap: () {})),
      );
      await tester.pump();
      expect(find.byType(BoardWidget), findsOneWidget);
    });

    testWidgets('renders the puzzle title (no episode prefix on title)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SignatureCard(entry: _canonicalToday(), onTap: () {})),
      );
      await tester.pump();
      // Title renders as just the puzzle name — no "Episode 1 · ..."
      // composition. If the title had a prefix, this exact-match would
      // fail.
      expect(find.text('Knight rescue'), findsOneWidget);
    });

    testWidgets('canonical-today entry renders "From Episode 1 · today"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SignatureCard(entry: _canonicalToday(), onTap: () {})),
      );
      await tester.pump();
      expect(find.text('From Episode 1 · today'), findsOneWidget);
    });

    testWidgets(
      'canonical-old entry renders "From Episode 1" (no time suffix)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(SignatureCard(entry: _canonicalOld(), onTap: () {})),
        );
        await tester.pump();
        expect(find.text('From Episode 1'), findsOneWidget);
        expect(find.textContaining('today'), findsNothing);
      },
    );

    testWidgets('endless-today entry renders "From Endless · today"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SignatureCard(entry: _endlessToday(), onTap: () {})),
      );
      await tester.pump();
      expect(find.text('From Endless · today'), findsOneWidget);
    });

    testWidgets('endless-old entry renders "From Endless" (no time suffix)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SignatureCard(entry: _endlessOld(), onTap: () {})),
      );
      await tester.pump();
      expect(find.text('From Endless'), findsOneWidget);
      expect(find.textContaining('today'), findsNothing);
    });

    testWidgets('tap invokes onTap callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(SignatureCard(entry: _canonicalToday(), onTap: () => taps += 1)),
      );
      await tester.pump();
      await tester.tap(find.byType(SignatureCard));
      expect(taps, 1);
    });

    testWidgets(
      'unknown puzzle id renders the fallback placeholder, no crash',
      (tester) async {
        final orphan = SignatureEntry(
          canonicalPuzzleId: 'unknown-puzzle-id',
          encounteredPuzzleId: 'unknown-puzzle-id',
          episodeId: 'ep1-strike-back',
          adoptedAt: DateTime.now(),
        );
        await tester.pumpWidget(
          _wrap(SignatureCard(entry: orphan, onTap: () {})),
        );
        await tester.pump();
        // BoardWidget not rendered when resolvePuzzleFor returns null.
        expect(find.byType(BoardWidget), findsNothing);
        // The canonical id is surfaced as the placeholder content.
        expect(find.text('unknown-puzzle-id'), findsAtLeastNWidgets(1));
      },
    );
  });
}
