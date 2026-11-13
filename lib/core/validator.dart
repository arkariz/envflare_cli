import 'package:envflare_cli/core/index.dart';

/// Validation utilities for environment files.
///
/// Provides methods to validate that all required environment variables
/// are present and non-empty in all flavor files according to the schema.
class Validator {
  /// Validates all environment files against the schema.
  ///
  /// Checks each flavor's environment file to ensure all schema-defined
  /// keys are present and have non-empty values. Logs success for valid
  /// flavors and throws [CliException] with detailed error information
  /// for invalid flavors.
  static void validateAll() {
    final schema = Schema.load();
    final invalidFlavors = <String, List<String>>{};

    for (final flavor in EnvFile.flavors()) {
      final env = EnvFile.getEnvKeyPair(flavor);
      final invalidKeys = <String>[];

      for (final field in schema) {
        final value = env[field.key];

        if (value == null || value.trim().isEmpty) {
          invalidKeys.add(field.key);
        }
      }

      if (invalidKeys.isNotEmpty) {
        invalidFlavors[flavor] = invalidKeys;
        continue;
      }

      Logger.success('$flavor valid');
    }

    if (invalidFlavors.isNotEmpty) {
      final detail = invalidFlavors.entries
          .map((entry) => '❌ Missing or empty keys in ${entry.key}:\n${entry.value.map((key) => '- $key').join('\n')}')
          .join('\n\n');

      throw CliException("ENV files validation failed:\n\n$detail");
    }
  }
}