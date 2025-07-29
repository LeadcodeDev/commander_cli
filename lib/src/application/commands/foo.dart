import 'package:commander_cli/src/domain/annotations/command.dart';
import 'package:commander_cli/src/domain/annotations/flag.dart';
import 'package:commander_cli/src/domain/command_argument_parser.dart';
import 'package:vine/vine.dart';

const args = ['name', 'age'];
final validator = vine.compile(
  vine.object({
    args.elementAt(0): vine.string(),
    args.elementAt(1): vine.number().min(18).optional(),
  }),
);

@Command(name: 'foo', description: 'Foo command', arguments: args)
@Flag(name: 'verbose', help: 'Verbose mode', abbr: 'v')
Future<void> main(List<String> arguments) async {
  final parser = CommandArgumentParser(args: arguments, validator: validator);

  print(['Foo command executed', arguments, parser.getArgument('name')]);
}
