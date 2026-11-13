import 'package:envflare_cli/cli/index.dart';
import 'package:envflare_cli/commands/index.dart';

Future<void> runCLI(List<String> args) {
  final registry = CommandRegistry()
    ..register(InitCommand())
    ..register(WizardCommand())
    ..register(EnvAddCommand())
    ..register(EnvRemoveCommand())
    ..register(EnvSetCommand())
    ..register(EnvListCommand())
    ..register(EnvSyncCommand())
    ..register(EnvValidateCommand())
    ..register(EnvGenerateCommand())
    ..register(FlavorCommand());

  return CliRunner(registry).run(args);
}