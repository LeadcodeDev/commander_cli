import 'dart:io';

import 'package:commander_cli/src/domain/annotations/command.dart';
import 'package:commander_cli/src/domain/command_generator.dart';
import 'package:commander_cli/src/domain/internal_command.dart';
import 'package:commander_cli/src/domain/utils/sanitize.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

@Command(name: 'generate', description: 'Generate commands')
Future<void> main(List<String> arguments) async {
  final generator = CommandGenerator();
  final identifier = 'my_package';

  final pubspec = await File('pubspec.yaml').readAsString();
  final pubspecMap = sanitize(loadYaml(pubspec) as YamlMap);

  final paths = pubspecMap[identifier]?['includes'] ?? [];
  final List<File> files = [];

  for (final location in paths) {
    final directory = Directory(location);
    final results = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    files.addAll(results);
  }

  final List<InternalCommand> internalCommands = [];
  for (final file in files) {
    try {
      final command = generator.generate(file);
      internalCommands.add(command);
    } on ArgumentError catch (error) {
      stdout.writeln('${error.message} (skipped)');
    }
  }

  final declarations = generator.createDeclaration(internalCommands);
  final Map<String, dynamic> content = {
    ...pubspecMap,
    identifier: {
      ...Map<String, dynamic>.from(pubspecMap[identifier]),
      'commands': declarations,
    },
  };

  final stringified = json2yaml(content, yamlStyle: YamlStyle.pubspecYaml);
  await File('pubspec.yaml').writeAsString(stringified);

  print('Generate commands');
}
