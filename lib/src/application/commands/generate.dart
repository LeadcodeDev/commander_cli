import 'dart:io';

import 'package:commander_cli/src/application/utils/command_parser.dart';
import 'package:commander_cli/src/domain/annotations/command.dart';
import 'package:commander_cli/src/domain/command_generator.dart';
import 'package:commander_cli/src/domain/internal_command.dart';
import 'package:commander_cli/src/domain/utils/sanitize.dart';
import 'package:commander_ui/commander_ui.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

Future<void> sleep(Duration duration) => Future.delayed(duration);

@Command(name: 'generate', description: 'Generate commands')
Future<void> main(_, payload) async {
  final parser = CommandParser(payload);
  final generator = CommandGenerator();

  final commander = Commander(level: Level.verbose);
  final task = await commander.task();

  final pubspecMap = await task.step(
    'Reading pubspec.yaml',
    callback: () async {
      final pubspec = await File('pubspec.yaml').readAsString();
      final pubspecMap = sanitize(loadYaml(pubspec) as YamlMap);

      if (pubspecMap[parser.identifier] == null) {
        print('Command entry not found');
        return;
      }

      await sleep(Duration(seconds: 1));
      return pubspecMap;
    },
  );

  final paths = pubspecMap[parser.identifier]?['includes'] ?? [];
  final List<File> files = [];

  for (final location in paths is List ? paths : [paths]) {
    await task.step(
      'Reading $location',
      callback: () async {
        final directory = Directory(location);
        final results = directory
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'));

        files.addAll(results);
        await sleep(Duration(milliseconds: 200));
      },
    );
  }

  task.success('Preparing commands');

  final createDeclarations = await commander.task();
  final List<InternalCommand> internalCommands = [];
  for (final file in files) {
    task.step(
      'Generate command for ${file.path}',
      callback: () async {
        try {
          final command = generator.generate(file);
          internalCommands.add(command);
        } on ArgumentError catch (error) {
          createDeclarations.error('${error.message} (skipped)');
        }

        await sleep(Duration(milliseconds: 200));
      },
    );
  }

  final Map<String, dynamic> content = await task.step(
    'Create declarations',
    callback: () {
      final declarations = generator.createDeclaration(internalCommands);
      return {
        ...pubspecMap,
        parser.identifier: {
          ...Map<String, dynamic>.from(pubspecMap[parser.identifier]),
          'commands': declarations,
        },
      };
    },
  );

  await task.step(
    'Saving declarations',
    callback: () async {
      final stringified = json2yaml(content, yamlStyle: YamlStyle.pubspecYaml);
      await File('pubspec.yaml').writeAsString(stringified);
    },
  );

  task.success('Commands are successfully saved');
  exit(0);
}
