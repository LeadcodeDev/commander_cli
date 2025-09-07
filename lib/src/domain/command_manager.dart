import 'package:commander_cli/src/domain/command_executor.dart';
import 'package:commander_cli/src/domain/command_loader.dart';
import 'package:commander_cli/src/domain/command_line_runner.dart';

final class CommandManager {
  late final CommandLineRunner _commandRunner;
  late final CommandExecutor _commandExecutor;
  late final CommandLoader _commandLoader;

  final String identifier;

  CommandManager({
    required this.identifier,
    String executableName = 'dart run',
    String executableDescription = '',
  }) {
    _commandRunner = CommandLineRunner(executableName, executableDescription);
    _commandExecutor = CommandExecutor(_commandRunner);
    _commandLoader = CommandLoader(identifier);
  }

  void load(Uri uri) {
    final commands = _commandLoader.resolveLocalCommands(uri);
    for (final command in commands) {
      _commandRunner.addCommand(command);
    }
  }

  void followDependencies() {
    print('Following dependencies...');
    final dependencies = _commandLoader.resolveDependanciesCommands();
    for (final dependency in dependencies) {
      _commandRunner.addCommand(dependency);
    }
  }

  void run(List<String> args) {
    _commandRunner.init();
    _commandExecutor.execute(args);
  }
}
