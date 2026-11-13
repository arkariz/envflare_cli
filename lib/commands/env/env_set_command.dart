import 'package:envflare_cli/commands/index.dart';
import 'package:envflare_cli/core/index.dart';

class EnvSetCommand implements BaseCommand {
  @override
  String get name => 'set';

  @override
  void configure(parser) {
    parser.addFlag('help', abbr: 'h', help: 'Show help');
    parser.addOption('flavor', abbr: 'f', help: 'Select flavor to update');
  }

  @override
  Future<void> execute(args) async {
    if (args.arguments.length < 2) {
      throw CliException('Usage: envflare set <KEY> <VALUE>');
    }

    final key = args.arguments[0];
    final value = args.arguments[1];
    final flavor = args['flavor'];

    final schema = Schema.load();
    if (!schema.map((field) => field.key).contains(key)) {
      throw CliException('Key "$key" not found in schema');
    }

    final flavors = EnvFile.flavors();
    if (flavor != null) {
      if (!flavors.contains(flavor)) throw CliException('Flavor "$flavor" not found');

      EnvFile.addVariable(flavor: flavor, key: key, value: value);
    } else {
      if (flavors.isEmpty) throw CliException('No flavors configured');
      EnvFile.createVariablesForFlavors(key: key, value: value);
    }

    Logger.success('Updated $key');
  }
}