import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/l10n/gen/app_localizations.dart';
import 'package:chess_rescue/l10n/locale_resolution.dart';

void main() {
  group('resolveAppLocale', () {
    const supported = <Locale>[Locale('en'), Locale('tr'), Locale('es')];

    test('Locale("tr") resolves to Turkish', () {
      expect(
        resolveAppLocale(const Locale('tr'), supported),
        const Locale('tr'),
      );
    });

    test('Locale("tr","TR") resolves to Turkish (country subtag ignored)', () {
      expect(
        resolveAppLocale(const Locale('tr', 'TR'), supported),
        const Locale('tr'),
      );
    });

    test('Locale("es") resolves to Spanish', () {
      expect(
        resolveAppLocale(const Locale('es'), supported),
        const Locale('es'),
      );
    });

    test('Locale("es","MX") resolves to Spanish (regional variant)', () {
      expect(
        resolveAppLocale(const Locale('es', 'MX'), supported),
        const Locale('es'),
      );
    });

    test('Locale("en") resolves to English', () {
      expect(
        resolveAppLocale(const Locale('en'), supported),
        const Locale('en'),
      );
    });

    test('Locale("fr") falls back to English (unsupported)', () {
      expect(
        resolveAppLocale(const Locale('fr'), supported),
        const Locale('en'),
      );
    });

    test('null device locale falls back to English', () {
      expect(resolveAppLocale(null, supported), const Locale('en'));
    });
  });

  group('MaterialApp locale resolution end-to-end', () {
    // Pumps the same delegate / supportedLocales / localeResolutionCallback
    // wiring as main.dart, with a Builder that reads AppL10n in a Scaffold so
    // we can find.text(...) the locale-specific headline.
    Widget harness(Locale? testLocale) {
      return MaterialApp(
        locale: testLocale,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        localeResolutionCallback: resolveAppLocale,
        home: Builder(
          builder: (context) {
            final t = AppL10n.of(context)!;
            return Scaffold(body: Text(t.headlineSaveTheKing));
          },
        ),
      );
    }

    testWidgets('Turkish locale renders Turkish text', (tester) async {
      await tester.pumpWidget(harness(const Locale('tr')));
      await tester.pumpAndSettle();
      expect(find.text('Şahı kurtar.'), findsOneWidget);
    });

    testWidgets('Spanish locale renders Spanish text', (tester) async {
      await tester.pumpWidget(harness(const Locale('es')));
      await tester.pumpAndSettle();
      expect(find.text('Salva al rey.'), findsOneWidget);
    });

    testWidgets('Unsupported locale (fr) falls back to English text', (
      tester,
    ) async {
      await tester.pumpWidget(harness(const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.text('Save the king.'), findsOneWidget);
    });
  });
}
