import 'package:arb_translate/src/flutter_tools/localizations_utils.dart';
import 'package:arb_translate/src/translation_delegates/translation_delegate.dart';
import 'package:test/test.dart';

class NoOpTranslationDelegate extends TranslationDelegate {
  const NoOpTranslationDelegate()
      : super(
          context: null,
          useEscaping: false,
          relaxSyntax: false,
        );

  @override
  Future<Map<String, String>> translate(
    Map<String, Object?> resources,
    LocaleInfo locale,
  ) {
    throw UnimplementedError();
  }
}

void main() {
  group(
    'TranslationDelegate',
    () {
      final delegate = NoOpTranslationDelegate();

      test(
        'validateResults returns true for resources without placeholers',
        () {
          final resources = {'key': 'value'};
          final results = {'key': 'translateValue'};

          expect(delegate.validateResults(resources, results), isTrue);
        },
      );

      test(
        'validateResults returns true for resources with valid placeholers',
        () {
          final resources = {
            'key': 'value {count, plural, other{{count} items}}',
            '@key': {
              'placeholders': {
                'count': {
                  'type': 'int',
                },
              },
            },
          };
          final results = {
            'key': 'value {count, plural, other{{count} items}}'
          };

          expect(delegate.validateResults(resources, results), isTrue);
        },
      );

      test(
        'validateResults returns false for resources with invalid placeholers',
        () {
          final resources = {
            'key': 'value {count, plural, one{1 item} other{{count} items}}',
            '@key': {
              'placeholders': {
                'count': {
                  'type': 'int',
                },
              },
            },
          };
          final results = {'key': 'value {count, plural, one{item item}}'};

          expect(delegate.validateResults(resources, results), isFalse);
        },
      );
    },
  );
}
