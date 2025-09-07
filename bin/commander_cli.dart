import 'dart:io';

import 'package:commander_cli/src/domain/command_manager.dart';

void main(List<String> arguments) {
  CommandManager(identifier: 'commander_cli')
    ..load(Directory.current.uri)
    ..run(arguments);
}
