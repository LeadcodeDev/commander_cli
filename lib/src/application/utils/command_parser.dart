import 'dart:convert';
import 'dart:io';

import 'package:commander_cli/src/domain/metadata/command_metadata.dart';

final class CommandParser {
  late String identifier;
  late final CommandMetadata command;
  late final ArgumentMetadata args;
  late final FlagMetadata flags;

  CommandParser() {
    if (Platform.environment['metadata'] case String value) {
      final metadata = CommandIntrospection.from(json.decode(value));
      identifier = metadata.identifier;
      command = metadata.command;
      args = metadata.arguments;
      flags = metadata.flags;
      return;
    }

    throw Exception('Command metadata not found');
  }
}
