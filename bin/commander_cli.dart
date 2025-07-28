import 'dart:io';

import 'package:commander_cli/src/domain/command_loader.dart';
import 'package:commander_cli/src/domain/command_manager.dart';

void main(List<String> arguments) {
  CommandManager(identifier: 'my_package')
    ..load(Directory.current.uri)
    ..run(arguments);
}
