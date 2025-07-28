import 'dart:io';

import 'package:commander_cli/_src/domain/command.dart';
import 'package:commander_cli/_src/domain/utils/file.dart';
import 'package:commander_cli/_src/domain/validators.dart';
import 'package:path/path.dart';
import 'package:vine/vine.dart';
import 'package:yaml/yaml.dart';

final class CommandLoader {
  final String _identifier;

  CommandLoader(this._identifier);

  Future<List<InternalCommand>> resolveLocalCommands(Uri uri) async {
    final pubspecFile = File(join(uri.path, 'pubspec.yaml'));

    if (!await pubspecFile.exists()) {
      return [];
    }

    final List<InternalCommand> results = [];
    final content = await pubspecFile.readAsYaml();
    if (content[_identifier] case YamlMap package) {
      if (package['commands'] case YamlList commands) {
        for (final element in commands) {
          try {
            results.add(extractCommand(element));
          } catch (error) {
            stdout.writeln(error);
          }
        }
      }
    }

    return results;
  }

  InternalCommand extractCommand(YamlMap command) {
    try {
      final payload = commandValidator.validate(command);
      return InternalCommand(
        name: payload['name'],
        description: payload['description'],
        entrypoint: payload['entrypoint'],
        arguments: payload['arguments'] ?? const [],
        flags: payload['flags'] ?? const [],
      );
    } on ValidationException catch (error) {
      throw Exception(
        'Named command ${command['name']} is invalid: ${error.message}',
      );
    }
  }
}
