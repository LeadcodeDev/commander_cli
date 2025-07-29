import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:commander_cli/src/domain/command_line_runner.dart';

final class CommandExecutor {
  final CommandLineRunner _runner;
  CommandExecutor(this._runner);

  void execute(List<String> arguments) {
    _runner.run(arguments).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64);
    });
  }
}
