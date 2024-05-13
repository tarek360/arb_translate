import 'dart:io';

import 'package:arb_translate/arb_translate.dart';
import 'package:args/args.dart';
import 'package:collection/collection.dart';

/// Represents the result of parsing command-line arguments for the translation
/// options.
class TranslateArgResults {
  const TranslateArgResults({
    required this.help,
    required this.modelProvider,
    required this.apiKey,
    required this.vertexAiProjectUrl,
    required this.disableSafety,
    required this.context,
    required this.excludeLocales,
    required this.arbDir,
    required this.templateArbFile,
    required this.useEscaping,
    required this.relaxSyntax,
  });

  /// Indicates whether the help option was specified.
  final bool? help;

  /// The model provider for translation.
  final ModelProvider? modelProvider;

  /// The API key for translation.
  final String? apiKey;

  /// The URL of the Vertex AI project.
  final String? vertexAiProjectUrl;

  /// Indicates whether safety checks are disabled.
  final bool? disableSafety;

  /// The context for translation.
  final String? context;

  /// The list of locales to exclude from translation.
  final List<String>? excludeLocales;

  /// The directory containing the ARB files.
  final String? arbDir;

  /// The template ARB file.
  final String? templateArbFile;

  /// Indicates whether escaping is used in messages.
  final bool? useEscaping;

  /// Indicates whether relaxed syntax is used in messages.
  final bool? relaxSyntax;
}

/// A class that parses command-line arguments for translation options.
class TranslateArgParser {
  static const _helpKey = 'help';
  static const _modelProviderKey = 'model-provider';
  static const _apiKeyKey = 'api-key';
  static const _vertexAiProjectUrlKey = 'vertex-ai-project-url';
  static const _disableSafetyKey = 'disable-safety';
  static const _contextKey = 'context';
  static const _excludeLocalesKey = 'exclude-locales';

  final _parser = ArgParser(
      usageLineLength: stdout.hasTerminal ? stdout.terminalColumns : null)
    ..addFlag(
      _helpKey,
      abbr: 'h',
      help: 'Print this usage information.',
      negatable: false,
    )
    ..addOption(
      _modelProviderKey,
      help: 'The model provider to use for translation.',
      allowed: ModelProvider.values.map((provider) => provider.key),
      defaultsTo: ModelProvider.gemini.key,
      allowedHelp: {
        ModelProvider.gemini.key: 'Gemini',
        ModelProvider.vertexAi.key:
            'Vertex AI (useful for users in regions where Gemini is unavailable'
                ' such as EU)',
      },
    )
    ..addOption(
      _apiKeyKey,
      help: 'API key used to make translation requests.',
    )
    ..addOption(
      _vertexAiProjectUrlKey,
      help: 'The URL of the Vertex AI project to use for translation.',
    )
    ..addFlag(
      _disableSafetyKey,
      help:
          'Whether or not to disable content safety settings for translation.',
    )
    ..addOption(
      _contextKey,
      help: 'The context to use for translation.',
    )
    ..addMultiOption(
      _excludeLocalesKey,
      help: 'Comma separated list of locales to be excluded from translation.',
    )
    ..addSeparator('ARB options:')
    ..addOption(
      TranslateOptions.arbDirKey,
      help: 'The directory where the template and translated arb files are '
          'located.',
    )
    ..addOption(
      TranslateOptions.templateArbFileKey,
      help: 'The template arb file that will be used as the basis for '
          'translation.',
    )
    ..addFlag(
      TranslateOptions.useEscapingKey,
      help: 'Whether or not to use escaping for messages.\n'
          '\n'
          'By default, this value is set to false for backwards compatibility. '
          'Turning this flag on will cause the parser to treat any special '
          'characters contained within pairs of single quotes as normal '
          'strings and treat all consecutive pairs of single quotes as a '
          'single quote character.',
    )
    ..addFlag(
      TranslateOptions.relaxSyntaxKey,
      help: 'When specified, the syntax will be relaxed so that the special '
          'character "{" is treated as a string if it is not followed by a '
          'valid placeholder and "}" is treated as a string if it does not '
          'close any previous "{" that is treated as a special character.',
    );

  String get usage => _parser.usage;

  /// Parses the given [args] and returns the parsed results as a [TranslateArgResults] object.
  ///
  /// Throws a [FormatException] if there is an unexpected positional argument.
  /// Returns a [TranslateArgResults] object containing the parsed results.
  TranslateArgResults parse(List<String> args) {
    final rawResults = _parser.parse(args);

    if (rawResults.rest.isNotEmpty) {
      throw FormatException(
        'Unexpected positional argument "${rawResults.rest.first}".',
      );
    }

    final modelProvider = rawResults.wasParsed(_modelProviderKey)
        ? ModelProvider.values.firstWhereOrNull(
            (provider) => provider.key == rawResults[_modelProviderKey],
          )
        : null;
    final excludeLocales = rawResults.wasParsed(_excludeLocalesKey)
        ? rawResults[_excludeLocalesKey] as List<String>
        : null;

    return TranslateArgResults(
      help: _getBoolIfParsed(rawResults, _helpKey),
      modelProvider: modelProvider,
      apiKey: rawResults[_apiKeyKey] as String?,
      vertexAiProjectUrl: rawResults[_vertexAiProjectUrlKey] as String?,
      disableSafety: _getBoolIfParsed(rawResults, _disableSafetyKey),
      context: rawResults[_contextKey] as String?,
      excludeLocales: excludeLocales,
      arbDir: rawResults[TranslateOptions.arbDirKey] as String?,
      templateArbFile:
          rawResults[TranslateOptions.templateArbFileKey] as String?,
      useEscaping:
          _getBoolIfParsed(rawResults, TranslateOptions.useEscapingKey),
      relaxSyntax:
          _getBoolIfParsed(rawResults, TranslateOptions.relaxSyntaxKey),
    );
  }

  bool? _getBoolIfParsed(ArgResults results, String key) {
    return results.wasParsed(key) ? results[key] as bool : null;
  }
}
