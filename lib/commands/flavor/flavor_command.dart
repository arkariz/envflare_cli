
import 'package:args/args.dart';
import 'package:envflare_cli/commands/index.dart';
import 'package:envflare_cli/core/index.dart';

class FlavorCommand implements BaseCommand {
  @override
  String get name => 'flavor';

  @override
  void configure(ArgParser parser) {
    parser.addFlag('help', abbr: 'h');

    final addParser = parser.addCommand('add');
    FlavorAddCommand().configure(addParser);

    final removeParser = parser.addCommand('remove');
    FlavorRemoveCommand().configure(removeParser);

    final listParser = parser.addCommand('list');
    FlavorListCommand().configure(listParser);
  }

  @override
  Future<void> execute(ArgResults args) async {
    final sub = args.command;

    if (sub == null || args['help']) {
      Logger.plain('Usage: envflare flavor <add|remove|list> [options]');
      Logger.plain('');
      Logger.plain('Subcommands:');
      Logger.plain('  add <NAME>    Add a new flavor');
      Logger.plain('  remove <NAME>  Remove a flavor');
      Logger.plain('  list          List all flavors');
      Logger.plain('');
      Logger.plain('Use "envflare flavor <subcommand> --help" for more information.');
      return;
    }

    if (sub['help'] == true) {
      final helpParser = ArgParser();
      switch (sub.name) {
        case 'add':
          FlavorAddCommand().configure(helpParser);
          Logger.plain('Usage: envflare flavor add <NAME> [options]');
          Logger.plain('');
          Logger.plain(helpParser.usage);
          return;
        case 'remove':
          FlavorRemoveCommand().configure(helpParser);
          Logger.plain('Usage: envflare flavor remove <NAME> [options]');
          Logger.plain('');
          Logger.plain(helpParser.usage);
          return;
        case 'list':
          FlavorListCommand().configure(helpParser);
          Logger.plain('Usage: envflare flavor list [options]');
          Logger.plain('');
          Logger.plain(helpParser.usage);
          return;
      }
    }

    switch (sub.name) {
      case 'add':
        await FlavorAddCommand().execute(sub);
        break;

      case 'remove':
        await FlavorRemoveCommand().execute(sub);
        break;

      case 'list':
        await FlavorListCommand().execute(sub);
        break;

      default:
        throw CliException('Unknown flavor command: ${sub.name}');
    }
  }
}