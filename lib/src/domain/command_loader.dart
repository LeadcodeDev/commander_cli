import 'dart:io';

import 'package:commander_cli/src/domain/utils/file.dart';
import 'package:commander_cli/src/domain/utils/sanitize.dart';
import 'package:commander_cli/src/domain/internal_command.dart';
import 'package:path/path.dart';

final class CommandLoader {
  final String _identifier;

  CommandLoader(this._identifier);

  List<InternalCommand> resolveLocalCommands(Uri uri) {
    final pubspecFile = File(join(uri.path, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      return [];
    }

    final List<InternalCommand> internalCommands = [];
    final content = sanitize(pubspecFile.readAsYamlSync());

    if (content[_identifier] case Map package) {
      if (package['commands'] case List commands) {
        for (final element in commands) {
          final command = InternalCommand.of(sanitize(element));
          internalCommands.add(command);
        }
      }
    }

    return internalCommands;
  }
}
