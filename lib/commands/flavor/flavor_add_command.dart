
import 'package:envflare_cli/commands/index.dart';
import 'package:envflare_cli/core/index.dart';

class FlavorAddCommand implements BaseCommand {
  @override
  String get name => 'flavor:add';

  @override
  void configure(parser) {
    parser.addFlag('help', abbr: 'h', help: 'Show help');
  }

  @override
  Future<void> execute(args) async {
    if (args.arguments.isEmpty) {
      throw CliException('Usage: envflare flavor add <NAME>');
    }

    final name = args.arguments.first;
    Config.addFlavor(name);
    
    for (final field in Schema.load()) {
      EnvFile.addVariable(flavor: name, key: field.key);
    }

    Logger.success('Flavor added: $name');
  }
}