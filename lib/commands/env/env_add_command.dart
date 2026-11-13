import 'package:envflare_cli/commands/index.dart';
import 'package:envflare_cli/core/index.dart';

class EnvAddCommand implements BaseCommand {
  @override
  String get name => 'add';

  @override
  void configure(parser) {
    parser.addFlag('help', abbr: 'h', help: 'Show help');
  }

  @override
  Future<void> execute(args) async {
    if (args.arguments.isEmpty) {
      throw CliException('Usage: envflare add <KEY>');
    }
    Schema.load();

    final key = args.arguments.first;
    Schema.addKey(key);
    EnvFile.createVariablesForFlavors(key: key);

    Logger.success('Added key: $key');
  }
}