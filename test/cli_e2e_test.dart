import 'dart:io';

import 'package:test/test.dart';

import 'support/sandbox.dart';

/// End-to-end: the real `bin/envflare.dart` as a subprocess, so argument parsing,
/// printed output and the process exit code are exactly what a user or CI job sees.
void main() {
  test(
      '--help lists the commands and exits 0',
      () => inSandbox((_) async {
            final r = await envflare(['--help']);

            expect(r.exitCode, 0);
            expect(
                r.stdout,
                allOf(contains('init'), contains('flavor'),
                    contains('validate'), contains('generate')));
          }));

  test(
      'a complete workflow validates with exit code 0',
      () => inSandbox((_) async {
            expect((await envflare(['init'])).exitCode, 0);
            await envflare(['flavor', 'add', 'dev']);
            await envflare(['flavor', 'add', 'prod']);
            await envflare(['add', 'API_URL']);
            await envflare(
                ['set', 'API_URL', 'https://dev.test', '--flavor', 'dev']);
            await envflare(
                ['set', 'API_URL', 'https://prod.test', '--flavor', 'prod']);

            final r = await envflare(['validate']);

            expect(r.exitCode, 0);
            expect(
                r.stdout, allOf(contains('dev valid'), contains('prod valid')));
            expect(File('.envs/dev.env').readAsStringSync(),
                'API_URL=https://dev.test\n');
          }));

  // Regression: validate used to print the failure but exit 0, so it could not gate CI.
  test(
      'validate exits non-zero and names the missing key',
      () => inSandbox((_) async {
            await envflare(['init']);
            await envflare(['flavor', 'add', 'dev']);
            await envflare(['add', 'API_URL']); // added, never given a value

            final r = await envflare(['validate']);

            expect(r.exitCode, isNot(0));
            expect(
                r.stdout,
                allOf(contains('Missing or empty keys in dev'),
                    contains('- API_URL')));
          }));

  test(
      'an unknown command and a missing project both exit non-zero',
      () => inSandbox((_) async {
            expect((await envflare(['frobnicate'])).exitCode, isNot(0));
            expect((await envflare(['validate'])).exitCode,
                isNot(0)); // not initialized
          }));

  test(
      'sync fills keys that a flavor is missing',
      () => inSandbox((_) async {
            await envflare(['init']);
            await envflare(['flavor', 'add', 'dev']);
            await envflare(['add', 'A']);
            File('.envs/dev.env')
                .writeAsStringSync(''); // drop the value the add created

            expect((await envflare(['sync'])).exitCode, 0);

            expect(File('.envs/dev.env').readAsStringSync(), 'A=\n');
          }));

  test(
      'removing a key and then adding one no longer corrupts the schema',
      () => inSandbox((_) async {
            await envflare(['init']);
            await envflare(['flavor', 'add', 'dev']);
            await envflare(['add', 'API_URL']);
            await envflare(['add', 'DEBUG']);
            await envflare(['remove', 'DEBUG']);
            await envflare(['add', 'TOKEN']);

            expect(File('.env.schema').readAsStringSync(), 'API_URL\nTOKEN\n');
          }));
}
