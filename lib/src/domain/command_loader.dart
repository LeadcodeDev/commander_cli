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

    final content = sanitize(pubspecFile.readAsYamlSync());
    final List<InternalCommand> internalCommands = [
      ...resolveCommandFromidentifier('commander_cli', uri, content),
      ...resolveCommandFromidentifier(_identifier, uri, content),
    ];

    return internalCommands;
  }

  List<InternalCommand> resolveCommandFromidentifier(
    String identifier,
    Uri uri,
    Map<String, dynamic> content,
  ) {
    final List<InternalCommand> internalCommands = [];
    if (content[identifier] case Map package) {
      if (package['commands'] case List commands) {
        for (final element in commands) {
          final command = InternalCommand.of({
            'identifier': _identifier,
            ...sanitize(element),
          }, root: uri);
          internalCommands.add(command);
        }
      }
    }

    return internalCommands;
  }

  List<InternalCommand> resolveDependanciesCommands() {
    final pubspecFile = File(join(Directory.current.path, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      return [];
    }

    final List<InternalCommand> internalCommands = [];
    final content = sanitize(pubspecFile.readAsYamlSync());

    if (content case Map package) {
      if (package['dependencies'] case Map dependencies) {
        for (final element in dependencies.values) {
          if (element case Map dependency) {
            if (dependency['path'] case String value) {
              final uri = Uri.parse(join(Directory.current.path, value));
              internalCommands.addAll(resolveLocalCommands(uri));
            }
          }
        }
      }
    }

    return internalCommands;
  }
}
