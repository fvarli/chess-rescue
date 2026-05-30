import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Verifies every translatable key present in app_en.arb also exists in app_tr.arb
// and app_es.arb (and vice versa). Catches the common regression of forgetting
// to translate a newly added EN string into TR/ES.
//
// Considered "translatable": any top-level key that is not `@@locale` and does
// not start with `@` (which marks ARB metadata, not a translatable value).
void main() {
  test('ARB key parity — EN, TR, ES share the same translatable key set', () {
    final enKeys = _translatableKeys('lib/l10n/app_en.arb');
    final trKeys = _translatableKeys('lib/l10n/app_tr.arb');
    final esKeys = _translatableKeys('lib/l10n/app_es.arb');

    expect(
      trKeys,
      equals(enKeys),
      reason:
          'app_tr.arb is missing or extra keys vs. app_en.arb.\n'
          'Missing in TR: ${enKeys.difference(trKeys)}\n'
          'Extra in TR:   ${trKeys.difference(enKeys)}',
    );
    expect(
      esKeys,
      equals(enKeys),
      reason:
          'app_es.arb is missing or extra keys vs. app_en.arb.\n'
          'Missing in ES: ${enKeys.difference(esKeys)}\n'
          'Extra in ES:   ${esKeys.difference(enKeys)}',
    );
  });
}

Set<String> _translatableKeys(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((k) => k != '@@locale' && !k.startsWith('@')).toSet();
}
