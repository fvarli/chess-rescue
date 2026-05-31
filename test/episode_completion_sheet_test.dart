import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/features/rescue_game/episode_completion_sheet.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrapInTestApp({required Widget child}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Material(child: SizedBox(width: 360, height: 800, child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EpisodeCompletionSheet — canonical / master variant', () {
    testWidgets(
      'renders eyebrow + episode label + title + count + Continue CTA',
      (tester) async {
        await tester.pumpWidget(
          _wrapInTestApp(
            child: EpisodeCompletionSheet(
              eyebrow: '✓ EPISODE COMPLETE',
              episodeLabel: 'Episode 1',
              title: 'STRIKE BACK',
              rescuesCount: '3 rescues completed',
              continueLabel: 'Continue',
              onContinue: () {},
            ),
          ),
        );
        // Pump past the 280ms fade-in.
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('✓ EPISODE COMPLETE'), findsOneWidget);
        expect(find.text('Episode 1'), findsOneWidget);
        expect(find.text('STRIKE BACK'), findsOneWidget);
        expect(find.text('3 rescues completed'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
        // No trilogy unlock line on the canonical variant.
        expect(find.text('Master and Endless unlocked'), findsNothing);
      },
    );

    testWidgets('tapping Continue fires onContinue', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrapInTestApp(
          child: EpisodeCompletionSheet(
            eyebrow: '✓ EPISODE COMPLETE',
            episodeLabel: 'Episode 1',
            title: 'STRIKE BACK',
            rescuesCount: '3 rescues completed',
            continueLabel: 'Continue',
            onContinue: () => taps += 1,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('tapping the backdrop dim does NOT fire onContinue', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrapInTestApp(
          child: EpisodeCompletionSheet(
            eyebrow: '✓ EPISODE COMPLETE',
            episodeLabel: 'Episode 1',
            title: 'STRIKE BACK',
            rescuesCount: '3 rescues completed',
            continueLabel: 'Continue',
            onContinue: () => taps += 1,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      // Tap a corner of the backdrop (the ColoredBox layer).
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      expect(taps, 0);
    });
  });

  group('EpisodeCompletionSheet — Ep3 trilogy variant', () {
    testWidgets(
      'renders trilogy eyebrow + the Master and Endless unlock line',
      (tester) async {
        await tester.pumpWidget(
          _wrapInTestApp(
            child: EpisodeCompletionSheet(
              eyebrow: '✓ TRILOGY COMPLETE',
              episodeLabel: 'Episode 3',
              title: 'HOLD THE LINE',
              rescuesCount: '3 rescues completed',
              trilogyUnlockLabel: 'Master and Endless unlocked',
              continueLabel: 'Continue',
              onContinue: () {},
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('✓ TRILOGY COMPLETE'), findsOneWidget);
        expect(find.text('Episode 3'), findsOneWidget);
        expect(find.text('HOLD THE LINE'), findsOneWidget);
        expect(find.text('Master and Endless unlocked'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
      },
    );
  });

  group('EpisodeCompletionSheet — root key + accessibility', () {
    testWidgets('mounts under the episode-completion-sheet ValueKey', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInTestApp(
          child: EpisodeCompletionSheet(
            eyebrow: '✓ EPISODE COMPLETE',
            episodeLabel: 'Episode 1',
            title: 'STRIKE BACK',
            rescuesCount: '3 rescues completed',
            continueLabel: 'Continue',
            onContinue: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('episode-completion-sheet')),
        findsOneWidget,
      );
    });
  });
}
