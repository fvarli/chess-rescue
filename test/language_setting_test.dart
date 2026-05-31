import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/l10n/app_language_mode.dart';
import 'package:chess_rescue/l10n/language_scope.dart';
import 'package:chess_rescue/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressStore.languageMode', () {
    test('default for an empty store is "system"', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await ProgressStore.create();
      expect(s.languageMode, 'system');
    });

    test('setLanguageMode("tr") round-trips on reload', () async {
      SharedPreferences.setMockInitialValues({});
      final s1 = await ProgressStore.create();
      await s1.setLanguageMode('tr');
      final s2 = await ProgressStore.create();
      expect(s2.languageMode, 'tr');
    });

    test('setLanguageMode("system") records the override clearance', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_language_mode': 'es',
      });
      final s1 = await ProgressStore.create();
      expect(s1.languageMode, 'es');
      await s1.setLanguageMode('system');
      final s2 = await ProgressStore.create();
      expect(s2.languageMode, 'system');
    });

    test('clear() removes the language override', () async {
      SharedPreferences.setMockInitialValues({
        'flutter.cr_language_mode': 'tr',
      });
      final s = await ProgressStore.create();
      expect(s.languageMode, 'tr');
      await s.clear();
      final s2 = await ProgressStore.create();
      expect(s2.languageMode, 'system');
    });
  });

  group('AppLanguageMode parsing + locale', () {
    test('parseAppLanguageMode handles all valid + invalid inputs', () {
      expect(parseAppLanguageMode('en'), AppLanguageMode.en);
      expect(parseAppLanguageMode('tr'), AppLanguageMode.tr);
      expect(parseAppLanguageMode('es'), AppLanguageMode.es);
      expect(parseAppLanguageMode('system'), AppLanguageMode.system);
      expect(parseAppLanguageMode(null), AppLanguageMode.system);
      expect(parseAppLanguageMode('fr'), AppLanguageMode.system);
      expect(parseAppLanguageMode(''), AppLanguageMode.system);
    });

    test('locale getter returns null for system, const Locale otherwise', () {
      expect(AppLanguageMode.system.locale, isNull);
      expect(AppLanguageMode.en.locale, const Locale('en'));
      expect(AppLanguageMode.tr.locale, const Locale('tr'));
      expect(AppLanguageMode.es.locale, const Locale('es'));
    });
  });

  group('ChessRescueApp end-to-end locale behaviour', () {
    void useLargePhoneViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> openRescue(WidgetTester tester, String continueLabel) async {
      // P1 added Home as the new root surface; drive into RescueScreen first.
      await tester.tap(find.text(continueLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('persisted Turkish mode renders Turkish headline', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'flutter.cr_language_mode': 'tr',
        // intro already seen so the rescue screen renders immediately after
        // tapping Continue
        'flutter.cr_intro_seen': true,
      });
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      await openRescue(tester, 'Devam et  ↦');
      expect(find.text('Şahı kurtar.'), findsOneWidget);
    });

    testWidgets('system mode with unsupported device locale falls back to en', (
      tester,
    ) async {
      useLargePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'flutter.cr_language_mode': 'system',
        'flutter.cr_intro_seen': true,
      });
      // Simulate a device whose language is unsupported (fr) — the resolver
      // must pick English per resolveAppLocale.
      tester.platformDispatcher.localeTestValue = const Locale('fr');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final store = await ProgressStore.create();
      await tester.pumpWidget(ChessRescueApp(store: store));
      await tester.pump();
      await openRescue(tester, 'Continue  ↦');
      expect(find.text('Save the king.'), findsOneWidget);
    });

    testWidgets(
      'LanguageScope.onChange(tr) flips the rendered headline to Turkish',
      (tester) async {
        useLargePhoneViewport(tester);
        SharedPreferences.setMockInitialValues({
          'flutter.cr_language_mode': 'en',
          'flutter.cr_intro_seen': true,
        });
        final store = await ProgressStore.create();
        await tester.pumpWidget(ChessRescueApp(store: store));
        await tester.pump();
        await openRescue(tester, 'Continue  ↦');
        expect(find.text('Save the king.'), findsOneWidget);

        // Reach the LanguageScope from any element below ChessRescueApp.
        final scope = LanguageScope.of(
          tester.element(find.text('Save the king.')),
        );
        scope.onChange(AppLanguageMode.tr);
        await tester.pump();
        expect(find.text('Şahı kurtar.'), findsOneWidget);
      },
    );
  });
}
