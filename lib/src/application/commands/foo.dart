import 'package:commander_cli/src/application/utils/command_parser.dart';
import 'package:commander_cli/src/domain/annotations/command.dart';
import 'package:commander_cli/src/domain/annotations/flag.dart';
import 'package:commander_cli/src/domain/annotations/option.dart';
import 'package:vine/vine.dart';

final validator = vine.compile(
  vine.object({'name': vine.string(), 'age': vine.number().min(18).optional()}),
);

@Command(name: 'foo', description: 'Foo command', arguments: ['test', 'age'])
@Flag(name: 'verbose', help: 'Verbose mode', abbr: 'v')
@Option(name: 'color', help: 'Color mode', abbr: 'c')
@Option(name: 'name', help: 'Name mode', abbr: 'n')
Future<void> main() async {
  final parser = CommandParser();
  print(parser.flags.get('verbose'));

  // final data = validator.validate(parser.args.payload);
  // print(['Foo command executed', data]);
}
