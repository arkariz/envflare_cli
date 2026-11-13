import 'dart:io';

import 'package:path/path.dart' as p;

/// The package root. Captured by [inSandbox] before it changes the working directory
/// (a top-level `final` would be initialised lazily, i.e. too late).
late final String _packageRoot;
bool _rootCaptured = false;

/// Runs [body] inside a fresh temporary project directory.
///
/// envflare resolves every path relative to the working directory, so each test
/// gets its own directory and the original one is restored afterwards.
Future<T> inSandbox<T>(Future<T> Function(Directory dir) body) async {
  final original = Directory.current;
  if (!_rootCaptured) {
    _packageRoot = original.path;
    _rootCaptured = true;
  }
  final dir = Directory.systemTemp.createTempSync('envflare_test_');
  Directory.current = dir;
  try {
    return await body(dir);
  } finally {
    Directory.current = original;
    dir.deleteSync(recursive: true);
  }
}

/// The result of running the real CLI as a subprocess.
class CliResult {
  CliResult(this.exitCode, this.stdout);

  final int exitCode;
  final String stdout;
}

/// Runs `envflare <args>` as a separate process in the current (sandbox) directory.
///
/// Used by the end-to-end tests: it exercises argument parsing, output and the
/// process exit code exactly as a user or a CI job sees them.
Future<CliResult> envflare(List<String> args) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    [p.join(_packageRoot, 'bin', 'envflare.dart'), ...args],
    workingDirectory: Directory.current.path,
  );
  return CliResult(result.exitCode, result.stdout as String);
}
