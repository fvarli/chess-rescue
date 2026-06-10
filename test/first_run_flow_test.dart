import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/game_controller.dart';
import 'package:chess_rescue/features/rescue_game/rescue_screen.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';
import 'package:chess_rescue/main.dart';

// PR-11 — pins the first-30-seconds path for a brand-new player. The flow
// is composed of pieces already covered in isolation (Home CTA in
// home_screen_test, intro lifecycle in intro_overlay_test, focus cue in
// focus_cue_test). This file guards the seams these older tests don't:
//
//   • The new Home invitation copy renders on a fresh-install boot.
//   • Tapping the Home CTA reaches the IntroOverlay (premise screen).
//   • On the first puzzle's danger cold-open, the player reads the new
//     singular hint, not the old plural verb-instruction copy.
//
// The first-rescue commit + onboardingSeen flip is already exercised by
// focus_cue_test (which programmatically taps via GameController and
// verifies state transitions). We do not re-pump that path here.

void useLargePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PR-11 — first 30 seconds: Home → IntroOverlay', () {
    testWidgets(
      'fresh install Home renders the new invitational subhead and CTA reaches IntroOverlay',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();

        // Sanity: fresh install — neither flag set.
        expect(store.introSeen, isFalse);
        expect(store.onboardingSeen, isFalse);

        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();

        // ── Home: PR-11 Item 2 — Home is now invitation, not premise.
        expect(find.text('A quiet moment.'), findsOneWidget);
        expect(find.text('Begin when ready.'), findsOneWidget);
        // Old premise-restating subhead must not appear.
        expect(find.text("You'll start in trouble."), findsNothing);
        expect(find.text('One move will get you out.'), findsNothing);

        // CTA still single, single-state across first-time / returning.
        final cta = find.text("Begin today's rescue  ↦");
        expect(cta, findsOneWidget);

        // ── Tap CTA → RescueScreen route → IntroOverlay carries premise.
        await tester.tap(cta);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('One move saves the king.'), findsOneWidget);
        expect(find.text('Start rescue'), findsOneWidget);
      },
    );
  });

  group('PR-11 — first puzzle danger hint copy', () {
    // These mount RescueScreen directly with introSeen=true to land on
    // the danger cold-open in the same way intro_overlay_test does for
    // its dismiss assertion. Onboarding flag is left at fresh-install
    // defaults so the focus cue is loud and the onboarding hint branch
    // (hintOnboardingOneMoveSaves) is exercised — that's the string a
    // brand-new player actually reads on the first puzzle.
    testWidgets(
      'onboarding (fresh) danger state shows the new singular hint copy',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({'flutter.cr_intro_seen': true});
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        expect(game.isOnboarding, isTrue);

        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        // One settle frame past the AnimatedOpacity fade-in.
        await tester.pump(const Duration(milliseconds: 250));

        expect(
          find.text('One piece can answer this. Find it.'),
          findsOneWidget,
          reason:
              'onboarding danger hint (hintOnboardingOneMoveSaves) must '
              'render the new singular phrasing',
        );
        // Old premise-restating onboarding hint must not appear.
        expect(find.text('One move saves the game.'), findsNothing);
        // Old plural verb-instruction copy must not appear either.
        expect(find.text('Tap a white piece to see its moves.'), findsNothing);
      },
    );

    testWidgets(
      'post-onboarding (returning) danger state on P1 also shows the new copy',
      (tester) async {
        // Pre-flip both flags — returning player path uses puzzleCopy.dangerHint.
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_intro_seen': true,
          'flutter.cr_onboarding_seen': true,
        });
        final store = await ProgressStore.create();
        final game = GameController(store: store);
        expect(game.isOnboarding, isFalse);

        await tester.pumpWidget(
          _wrap(RescueScreen(store: store, controller: game)),
        );
        await tester.pump(const Duration(milliseconds: 250));

        // Same string is the right answer for both branches now.
        expect(
          find.text('One piece can answer this. Find it.'),
          findsOneWidget,
          reason:
              'returning-player danger hint (puzzleCopy.dangerHint) must '
              'render the new singular phrasing on P1',
        );
        expect(find.text('Tap a white piece to see its moves.'), findsNothing);
      },
    );
  });
}
