import 'package:commander_cli/src/domain/annotations/command.dart';
import 'package:vine/vine.dart';

const args = ['command'];
final validator = vine.compile(
  vine.object({args.elementAt(0): vine.string().optional()}),
);

@Command(name: 'help', description: 'Help command', arguments: args)
Future<void> main(List<String> arguments) async {
  print('help');
}
