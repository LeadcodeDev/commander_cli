import 'dart:io';

import 'package:args/command_runner.dart';

final class CommandExecutor {
  final CommandRunner _runner;
  CommandExecutor(this._runner);

  void execute(List<String> args) {
    _runner.run(args).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64);
    });
  }
}
