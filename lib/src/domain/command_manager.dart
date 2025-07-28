import 'package:args/command_runner.dart';
import 'package:commander_cli/src/domain/command_executor.dart';
import 'package:commander_cli/src/domain/command_loader.dart';

final class CommandManager {
  final commandRunner = CommandRunner('', '');
  late final CommandExecutor commandExecutor;
  late final CommandLoader commandLoader;

  final String identifier;

  CommandManager({required this.identifier}) {
    commandExecutor = CommandExecutor(commandRunner);
    commandLoader = CommandLoader(identifier);
  }

  void load(Uri uri) {
    final commands = commandLoader.resolveLocalCommands(uri);
    final internalCommands = commandLoader.buildCommands(commands);

    for (final command in internalCommands) {
      commandRunner.addCommand(command);
    }
  }

  void run(List<String> args) => commandExecutor.execute(args);
}
