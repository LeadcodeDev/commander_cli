import 'package:args/args.dart';
import 'package:args/command_runner.dart';

final class CommandLineRunner extends CommandRunner {
  final Map<String, Command> _commands = {};

  @override
  ArgParser argParser = ArgParser();

  CommandLineRunner(super.executableName, super.description) {
    argParser =
        ArgParser()..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Print this usage information.',
        );
  }

  @override
  void addCommand(Command command) {
    final names = [command.name, ...command.aliases];
    for (final name in names) {
      _commands[name] = command;
    }
  }

  init() {
    if (!_commands.containsKey('help')) {
      super.addCommand(_commands['help']!);
      argParser.addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Print this usage information.',
      );
    }

    for (final element in _commands.entries) {
      super.addCommand(element.value);
    }
  }
}
