import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_rescue/core/models/signature_entry.dart';
import 'package:chess_rescue/core/storage/progress_store.dart';
import 'package:chess_rescue/features/rescue_game/widgets/board_widget.dart';
import 'package:chess_rescue/features/signatures/signature_expand_sheet.dart';
import 'package:chess_rescue/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: child),
  );
}

SignatureEntry _canonicalEntry() => SignatureEntry(
  canonicalPuzzleId: 'p1-knight-rescue',
  encounteredPuzzleId: 'p1-knight-rescue',
  episodeId: 'ep1-strike-back',
  adoptedAt: DateTime.now(),
);

SignatureEntry _endlessEntry() => SignatureEntry(
  canonicalPuzzleId: 'b1-the-martyr',
  encounteredPuzzleId: 'b1-the-martyr',
  episodeId: 'ep5-endless-rescue',
  adoptedAt: DateTime.now(),
  endlessSeed: 42,
  endlessMirrored: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignatureExpandSheet — viewing surface (canonical)', () {
    testWidgets(
      'renders BoardWidget (rescued state) + title + canonical journal line + remembered line',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(
          _wrap(SignatureExpandSheet(store: store, entry: _canonicalEntry())),
        );
        await tester.pump();

        expect(find.byType(BoardWidget), findsOneWidget);
        expect(find.text('Knight rescue'), findsOneWidget);
        expect(find.text('From Episode 1.'), findsOneWidget);
        expect(find.text('Still remembered.'), findsOneWidget);
      },
    );

    testWidgets(
      'does NOT render any time fragment (no "today", no "yesterday")',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(
          _wrap(SignatureExpandSheet(store: store, entry: _canonicalEntry())),
        );
        await tester.pump();

        expect(find.textContaining('today'), findsNothing);
        expect(find.textContaining('yesterday'), findsNothing);
      },
    );

    testWidgets(
      'does NOT render a visible primary Remove button (Remove is in the overflow menu)',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await tester.pumpWidget(
          _wrap(SignatureExpandSheet(store: store, entry: _canonicalEntry())),
        );
        await tester.pump();

        // The popup menu item is in a popup that isn't expanded by default,
        // so "Remove from Signatures" should not be visible in the tree.
        expect(find.text('Remove from Signatures'), findsNothing);
        // No ElevatedButton / OutlinedButton labeled with the menu copy.
        expect(find.widgetWithText(ElevatedButton, 'Remove'), findsNothing);
      },
    );

    testWidgets('three-dot menu icon visible in the header', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await tester.pumpWidget(
        _wrap(SignatureExpandSheet(store: store, entry: _canonicalEntry())),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('signature-expand-sheet-menu')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });

  group('SignatureExpandSheet — viewing surface (endless)', () {
    testWidgets('endless entry renders journal line 1 as "From Endless."', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await tester.pumpWidget(
        _wrap(SignatureExpandSheet(store: store, entry: _endlessEntry())),
      );
      await tester.pump();

      expect(find.text('From Endless.'), findsOneWidget);
      expect(find.text('Still remembered.'), findsOneWidget);
    });
  });

  group('SignatureExpandSheet — remove flow', () {
    testWidgets(
      'tap menu → popup item appears → tap Cancel keeps the signature',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await store.addSignature(_canonicalEntry());
        expect(store.signatures.length, 1);

        await tester.pumpWidget(
          _wrap(SignatureExpandSheet(store: store, entry: _canonicalEntry())),
        );
        await tester.pump();

        await tester.tap(
          find.byKey(const ValueKey('signature-expand-sheet-menu')),
        );
        // PopupMenu animation is ~300ms; BoardWidget's breath never settles
        // so pumpAndSettle would hang. Use timed pump() calls instead.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Remove from Signatures'), findsOneWidget);

        await tester.tap(find.text('Remove from Signatures'));
        // Wait for popup to close + dialog to open.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Remove from Signatures?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));

        final fresh = await ProgressStore.create();
        expect(fresh.signatures.length, 1);
      },
    );

    testWidgets(
      'tap menu → popup item → confirmation dialog → tap Remove → signature is removed',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final store = await ProgressStore.create();
        await store.addSignature(_canonicalEntry());

        await tester.pumpWidget(
          _wrap(SignatureExpandSheet(store: store, entry: _canonicalEntry())),
        );
        await tester.pump();

        await tester.tap(
          find.byKey(const ValueKey('signature-expand-sheet-menu')),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text('Remove from Signatures'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text('Remove'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));

        final fresh = await ProgressStore.create();
        expect(fresh.signatures, isEmpty);
      },
    );

    testWidgets('NO snackbar appears at any point in the remove flow', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final store = await ProgressStore.create();
      await store.addSignature(_canonicalEntry());

      await tester.pumpWidget(
        _wrap(SignatureExpandSheet(store: store, entry: _canonicalEntry())),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('signature-expand-sheet-menu')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Remove from Signatures'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Remove'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      // No SnackBar / SnackBarAction anywhere in the tree.
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(SnackBarAction), findsNothing);
      expect(find.text('UNDO'), findsNothing);
    });
  });
}
