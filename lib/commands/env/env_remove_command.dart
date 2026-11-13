import 'package:envflare_cli/commands/index.dart';
import 'package:envflare_cli/core/index.dart';

class EnvRemoveCommand implements BaseCommand {
  @override
  String get name => 'remove';

  @override
  void configure(parser) {
    parser.addFlag('help', abbr: 'h', help: 'Show help');
  }

  @override
  Future<void> execute(args) async {
    Schema.load();

    if (args.arguments.isEmpty) {
      throw CliException('Usage: envflare remove <KEY>');
    }

    final key = args.arguments.first;
    Schema.removeKey(key);
    EnvFile.removeVariable(key);

    Logger.success('Removed key: $key');
  }
}