import 'package:commander_cli/_src/domain/annotations/arguments.dart';
import 'package:commander_cli/_src/domain/annotations/flag.dart';
import 'package:commander_cli/_src/domain/argument_validator.dart';
import 'package:commander_cli/_src/domain/command.dart';
import 'package:vine/vine.dart';

const args = ['name', 'age'];
final validator = vine.compile(
  vine.object({
    args.elementAt(0): vine.string(),
    args.elementAt(1): vine.number().min(18).optional(),
  }),
);

@Command(name: 'foo', description: 'Foo command', arguments: args)
@Flag(name: 'verbose', abbr: 'v', description: 'Verbose mode')
@Flag(name: 'quiet', abbr: 'q', description: 'Quiet mode')
Future<void> main(List<String> arguments) async {
  print(['Foo command executed', arguments]);
}
