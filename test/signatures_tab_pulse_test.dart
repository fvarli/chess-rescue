import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/signatures/signatures_tab_pulse.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignaturesTabPulse — gating', () {
    testWidgets(
      'no pulse when player has never bookmarked (first-bookmark flag false)',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(
          _wrap(
            SignaturesTabPulse(
              store: store,
              child: const Text('SIGNATURES', key: ValueKey('child')),
            ),
          ),
        );
        await tester.pump();
        // The decoration only mounts when pulse is active. With no pulse,
        // no DecoratedBox wraps the child.
        expect(find.byType(DecoratedBox), findsNothing);
        // Sanity: tab pulse flag was NOT marked because the first-bookmark
        // hint flag is the gate.
        final fresh = await ProgressStore.create();
        expect(fresh.hasSeenSignaturesTabPulse, isFalse);
      },
    );

    testWidgets(
      'no pulse when both flags are already true (single-fire history)',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_signatures_first_bookmark_hint_seen': true,
          'flutter.cr_signatures_tab_pulse_seen': true,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(
          _wrap(
            SignaturesTabPulse(store: store, child: const Text('SIGNATURES')),
          ),
        );
        await tester.pump();
        expect(find.byType(DecoratedBox), findsNothing);
      },
    );

    testWidgets(
      'pulse fires when first-bookmark hint has been seen and tab pulse has not',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'flutter.cr_signatures_first_bookmark_hint_seen': true,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(
          _wrap(
            SignaturesTabPulse(store: store, child: const Text('SIGNATURES')),
          ),
        );
        // Frame 1: post-frame callback fires forward().
        await tester.pump();
        // Pump a quarter cycle to verify the animation runs.
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(DecoratedBox), findsOneWidget);
        // Pulse seen flag is marked on initialization (not on animation end).
        final fresh = await ProgressStore.create();
        expect(fresh.hasSeenSignaturesTabPulse, isTrue);
      },
    );

    testWidgets('decorates whatever child is passed in (extractability)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_signatures_first_bookmark_hint_seen': true,
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(
        _wrap(
          SignaturesTabPulse(
            store: store,
            // Arbitrary child — not a tab button.
            child: const Icon(Icons.bookmark, key: ValueKey('arbitrary-child')),
          ),
        ),
      );
      await tester.pump();
      // Child is still rendered, untouched.
      expect(find.byKey(const ValueKey('arbitrary-child')), findsOneWidget);
    });

    testWidgets('null store: never pulses, no crash', (tester) async {
      await tester.pumpWidget(
        _wrap(const SignaturesTabPulse(store: null, child: Text('SIGNATURES'))),
      );
      await tester.pump();
      expect(find.byType(DecoratedBox), findsNothing);
    });
  });
}
