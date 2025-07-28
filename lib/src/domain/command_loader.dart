import 'dart:io';

import 'package:commander_cli/_src/domain/utils/file.dart';
import 'package:commander_cli/_src/domain/utils/sanitize.dart';
import 'package:commander_cli/src/domain/internal_command.dart';
import 'package:path/path.dart';

typedef CommandTuple = (String, String, File);

final class CommandLoader {
  final String _identifier;

  CommandLoader(this._identifier);

  List<CommandTuple> resolveLocalCommands(Uri uri) {
    final pubspecFile = File(join(uri.path, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      return [];
    }

    final List<CommandTuple> results = [];
    final content = sanitize(pubspecFile.readAsYamlSync());

    if (content[_identifier] case Map package) {
      if (package['commands'] case List commands) {
        for (final element in commands) {
          try {
            results.add((
              element['name'],
              element['description'],
              File(element['entrypoint']),
            ));
          } catch (error) {
            stdout.writeln(error);
          }
        }
      }
    }

    return results;
  }

  List<InternalCommand> buildCommands(List<CommandTuple> commands) {
    final List<InternalCommand> internalCommands = [];
    for (final (name, description, file) in commands) {
      final command = InternalCommand(
        name: name,
        description: description,
        file: file,
      );

      internalCommands.add(command);
    }

    return internalCommands;
  }
}
