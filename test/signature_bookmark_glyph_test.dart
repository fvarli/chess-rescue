import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_rescue/core/theme/app_theme.dart';
import 'package:chess_rescue/features/signatures/signature_bookmark_glyph.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('SignatureBookmarkGlyph', () {
    testWidgets(
      'empty state renders Icons.bookmark_border, low-alpha dim color',
      (tester) async {
        await tester.pumpWidget(
          _wrap(SignatureBookmarkGlyph(isSaved: false, onTap: () {})),
        );
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.icon, Icons.bookmark_border);
        // Not mint, not rescue — secondary register.
        expect(icon.color, isNot(AppColors.rescue));
        // Verify alpha is below textMuted's full alpha (0.55 attenuation).
        expect(icon.color!.a, lessThan(AppColors.textMuted.a));
      },
    );

    testWidgets('filled state renders Icons.bookmark, AppColors.textDim', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SignatureBookmarkGlyph(isSaved: true, onTap: () {})),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.bookmark);
      expect(icon.color, AppColors.textDim);
      // Critically NOT mint — bookmark stays in the muted register.
      expect(icon.color, isNot(AppColors.rescue));
    });

    testWidgets('tap invokes onTap callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(SignatureBookmarkGlyph(isSaved: false, onTap: () => taps += 1)),
      );
      await tester.tap(find.byType(SignatureBookmarkGlyph));
      expect(taps, 1);
    });

    testWidgets('icon size is the secondary ~14sp', (tester) async {
      await tester.pumpWidget(
        _wrap(SignatureBookmarkGlyph(isSaved: false, onTap: () {})),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 14);
    });
  });
}
