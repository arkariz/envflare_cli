import 'package:envflare_cli/commands/index.dart';
import 'package:envflare_cli/core/index.dart';

class FlavorRemoveCommand implements BaseCommand {
  @override
  String get name => 'flavor:remove';

  @override
  void configure(parser) {
    parser.addFlag('help', abbr: 'h', help: 'Show help');
  }

  @override
  Future<void> execute(args) async {
    if (args.arguments.isEmpty) {
      throw CliException('Usage: envflare flavor remove <NAME>');
    }

    final name = args.arguments.first;
    Config.removeFlavor(name);
    EnvFile.deleteEnvFile(name);
    
    Logger.success('Flavor removed: $name');
  }
}