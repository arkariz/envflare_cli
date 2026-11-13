import 'dart:io';

import 'package:args/args.dart';
import 'package:envflare_cli/cli/index.dart';
import 'package:envflare_cli/core/index.dart';

/// The main CLI runner for envflare_cli.
///
/// This class handles command parsing, execution, and error handling
/// for the envflare CLI tool.
class CliRunner {
  /// The command registry containing all available commands.
  final CommandRegistry registry;

  /// Creates a new CLI runner with the given command registry.
  CliRunner(this.registry);

  /// Runs the CLI with the provided command line arguments.
  ///
  /// Parses arguments, executes the appropriate command, and handles errors.
  /// Shows help information when requested or when no command is provided.
  Future<void> run(List<String> args) async {
    final parser = ArgParser();
    parser.addFlag('help', abbr: 'h', help: 'Show help');

    for (final cmd in registry.all) {
      cmd.configure(parser.addCommand(cmd.name));
    }

    try {
      final result = parser.parse(args);
      final cmdName = result.command?.name;

      // ArgParser doesn't treat an unregistered word as a command: it lands in `rest`.
      if (cmdName == null && result.rest.isNotEmpty) {
        throw CliException('Unknown command: ${result.rest.first}');
      }

      if (result['help'] || cmdName == null) {
        if (cmdName != null) {
          // Show help for specific command
          final command = registry.get(cmdName);
          if (command != null) {
            final subParser = ArgParser();
            command.configure(subParser);
            Logger.plain('Usage: envflare $cmdName [options]');
            Logger.plain('');
            Logger.plain(subParser.usage);
          }
        } else {
          // Show global help
          Logger.plain('envflare_cli - A CLI tool for managing Flutter environment variables');
          Logger.plain('');
          Logger.plain('Usage: envflare <command> [options]');
          Logger.plain('');
          Logger.plain('Commands:');
          for (final cmd in registry.all) {
            Logger.plain('  ${cmd.name}');
          }
          Logger.plain('');
          Logger.plain('Use "envflare <command> --help" for more information about a command.');
        }
        return;
      }

      final command = registry.get(cmdName);

      if (command == null) {
        throw CliException('Unknown command: $cmdName');
      }

      if (result.command!['help'] == true) {
        final subParser = ArgParser();
        command.configure(subParser);
        Logger.plain('Usage: envflare $cmdName [options]');
        Logger.plain('');
        Logger.plain(subParser.usage);
        return;
      }

      await command.execute(result.command!);
    } on CliException catch (e) {
      Logger.error(e.message);
      // A failed command must fail the process, so `envflare validate` can gate CI.
      exitCode = 1;
    } catch (e) {
      Logger.error('Unexpected error: $e');
      exitCode = 1;
    }
  }
}