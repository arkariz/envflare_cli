import 'dart:io';

import 'package:envflare_cli/core/index.dart';
import 'package:test/test.dart';

import 'support/sandbox.dart';

void main() {
  group('parseEnv / writeEnv', () {
    test(
        'parses KEY=VALUE and keeps "=" inside the value',
        () => inSandbox((_) async {
              File('a.env')
                  .writeAsStringSync('A=1\nURL=https://x.test/?q=1&r=2\n');

              expect(parseEnv(File('a.env')),
                  {'A': '1', 'URL': 'https://x.test/?q=1&r=2'});
            }));

    test(
        'ignores lines without "=" and returns {} for a missing file',
        () => inSandbox((_) async {
              File('a.env').writeAsStringSync('just text\nA=1\n');

              expect(parseEnv(File('a.env')), {'A': '1'});
              expect(parseEnv(File('missing.env')), isEmpty);
            }));

    test(
        'writeEnv output parses back to the same map',
        () => inSandbox((_) async {
              final data = {'A': '1', 'B': 'x=y', 'EMPTY': ''};
              writeEnv(File('a.env'), data);

              expect(parseEnv(File('a.env')), data);
            }));
  });

  group('Config', () {
    test(
        'init creates an empty flavor list and is idempotent',
        () => inSandbox((_) async {
              Config.init();
              Config.addFlavor('dev');
              Config.init(); // must not wipe existing flavors

              expect(Config.getFlavors(), ['dev']);
            }));

    test(
        'rejects duplicate and unknown flavors',
        () => inSandbox((_) async {
              Config.init();
              Config.addFlavor('dev');

              expect(
                  () => Config.addFlavor('dev'), throwsA(isA<CliException>()));
              expect(() => Config.removeFlavor('prod'),
                  throwsA(isA<CliException>()));
            }));

    test(
        'load throws a CliException when the project is not initialized',
        () => inSandbox((_) async {
              expect(Config.load, throwsA(isA<CliException>()));
            }));
  });

  group('Schema', () {
    test(
        'adds keys, rejects duplicates, removes keys',
        () => inSandbox((_) async {
              Schema.init();
              Schema.addKey('A');
              Schema.addKey('B');

              expect(Schema.load().map((f) => f.key), ['A', 'B']);
              expect(() => Schema.addKey('A'), throwsA(isA<CliException>()));

              Schema.removeKey('A');
              expect(Schema.load().map((f) => f.key), ['B']);
              expect(() => Schema.removeKey('A'), throwsA(isA<CliException>()));
            }));

    // Regression: removeKey used to drop the trailing newline, so the next addKey
    // glued its key onto the last remaining one ("API_URL" + "TOKEN" = "API_URLTOKEN").
    test(
        'adding a key after removing one keeps every key on its own line',
        () => inSandbox((_) async {
              Schema.init();
              Schema.addKey('API_URL');
              Schema.addKey('DEBUG');

              Schema.removeKey('DEBUG');
              Schema.addKey('TOKEN');

              expect(Schema.load().map((f) => f.key), ['API_URL', 'TOKEN']);
            }));

    test(
        'removing the last key leaves an empty schema that can be added to again',
        () => inSandbox((_) async {
              Schema.init();
              Schema.addKey('ONLY');
              Schema.removeKey('ONLY');
              Schema.addKey('NEXT');

              expect(Schema.load().map((f) => f.key), ['NEXT']);
            }));
  });

  group('EnvFile', () {
    test(
        'creates, sets and removes a variable across every flavor',
        () => inSandbox((_) async {
              Config.init();
              Config.addFlavor('dev');
              Config.addFlavor('prod');

              EnvFile.createVariablesForFlavors(key: 'API_URL');
              EnvFile.addVariable(
                  flavor: 'dev', key: 'API_URL', value: 'https://dev.test');

              expect(EnvFile.getEnvKeyPair('dev'),
                  {'API_URL': 'https://dev.test'});
              expect(EnvFile.getEnvKeyPair('prod'), {'API_URL': ''});

              EnvFile.removeVariable('API_URL');
              expect(EnvFile.getEnvKeyPair('dev'), isEmpty);
              expect(EnvFile.getEnvKeyPair('prod'), isEmpty);
            }));
  });

  group('Validator', () {
    test(
        'passes when every flavor has every schema key',
        () => inSandbox((_) async {
              Config.init();
              Schema.init();
              Config.addFlavor('dev');
              Schema.addKey('A');
              EnvFile.addVariable(flavor: 'dev', key: 'A', value: '1');

              expect(Validator.validateAll, returnsNormally);
            }));

    test(
        'reports missing and empty keys per flavor',
        () => inSandbox((_) async {
              Config.init();
              Schema.init();
              Config.addFlavor('dev');
              Config.addFlavor('prod');
              Schema.addKey('A');
              Schema.addKey('B');
              EnvFile.addVariable(flavor: 'dev', key: 'A', value: '1');
              EnvFile.addVariable(flavor: 'dev', key: 'B', value: '2');
              EnvFile.addVariable(
                  flavor: 'prod',
                  key: 'A',
                  value: '   '); // blank counts as empty

              expect(
                Validator.validateAll,
                throwsA(
                  isA<CliException>().having(
                    (e) => e.message,
                    'message',
                    allOf(
                        contains('Missing or empty keys in prod'),
                        contains('- A'),
                        contains('- B'),
                        isNot(contains('in dev'))),
                  ),
                ),
              );
            }));
  });

  group('EnviedGenerator', () {
    test(
        'emits one obfuscated @Envied class per flavor and camelCase fields',
        () => inSandbox((_) async {
              Config.init();
              Schema.init();
              Config.addFlavor('dev');
              Config.addFlavor('prod');
              Schema.addKey('API_BASE_URL');

              EnviedGenerator.generate();
              final code = File('lib/env/env.dart').readAsStringSync();

              expect(
                  code,
                  contains(
                      "@Envied(path: '.envs/dev.env', name: 'EnvDev', obfuscate: true)"));
              expect(
                  code,
                  contains(
                      "@Envied(path: '.envs/prod.env', name: 'EnvProd', obfuscate: true)"));
              expect(code, contains("@EnviedField(varName: 'API_BASE_URL')"));
              expect(code,
                  contains('final String apiBaseUrl = _instance.apiBaseUrl;'));
              // An unknown --dart-define=FLAVOR falls back to the first flavor.
              expect(code, contains('_ => _EnvDev()'));
            }));

    test(
        'refuses to generate without flavors',
        () => inSandbox((_) async {
              Config.init();
              Schema.init();

              expect(EnviedGenerator.generate, throwsA(isA<CliException>()));
            }));
  });
}
