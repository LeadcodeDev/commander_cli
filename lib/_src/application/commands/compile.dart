import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:commander_cli/_src/domain/annotations/flag.dart';
import 'package:commander_cli/_src/domain/command.dart';
import 'package:commander_cli/_src/domain/utils/sanitize.dart';
import 'package:yaml/yaml.dart';
import 'package:commander_cli/_src/domain/utils/file.dart';
import 'package:json2yaml/json2yaml.dart';

@Command(name: 'compile', description: 'Compile commands')
Future<void> main(List<String> args) async {
  final pubspec = await File('pubspec.yaml').readAsString();
  final pubspecMap = loadYaml(pubspec) as YamlMap;

  final paths = pubspecMap[args.first]?['includes'] ?? [];
  final List<File> files = [];

  for (final dir in paths) {
    final directory = Directory(dir);
    final results = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    files.addAll(results);
  }

  final commands = <String, Map<String, dynamic>>{};

  for (final file in files) {
    final content = await File(file.path).readAsString();
    final parsed = parseString(content: content, path: file.path);
    final unit = parsed.unit;

    String? commandName;
    String? commandDescription;
    List<String> commandArgs = [];
    List<Flag> commandFlags = [];

    final topLevelVariables =
        unit.declarations
            .whereType<TopLevelVariableDeclaration>()
            .map((e) => e.variables.variables.first)
            .where((v) => v.initializer != null)
            .toList();

    // Map des constantes définies dans le fichier
    final constantsMap = <String, List<String>>{};
    for (final variable in topLevelVariables) {
      final initializer = variable.initializer;
      if (initializer is ListLiteral) {
        final elements =
            initializer.elements
                .whereType<SimpleStringLiteral>()
                .map((e) => e.value)
                .toList();
        constantsMap[variable.name.lexeme] = elements;
      }
    }

    // Rechercher la méthode main avec les annotations
    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == 'main') {
        for (final meta in declaration.metadata) {
          final name = meta.name.name;
          final args = meta.arguments?.arguments ?? [];

          if (name == 'Command') {
            for (final arg in args) {
              if (arg is NamedExpression) {
                final argName = arg.name.label.name;
                final valueExpr = arg.expression;
                if (argName == 'name' && valueExpr is SimpleStringLiteral) {
                  commandName = valueExpr.value;
                } else if (argName == 'description' &&
                    valueExpr is SimpleStringLiteral) {
                  commandDescription = valueExpr.value;
                } else if (argName == 'arguments') {
                  if (valueExpr is SimpleIdentifier) {
                    final constName = valueExpr.name;
                    final constValue = constantsMap[constName];
                    if (constValue != null) {
                      commandArgs = constValue;
                    }
                  }
                }
              }
            }
          }

          if (name == 'Flag' && args.isNotEmpty) {
            String name = '';
            String? abbr = '';
            String? description;

            for (final arg in args) {
              if (arg is NamedExpression) {
                final argName = arg.name.label.name;
                final valueExpr = arg.expression;

                if (argName == 'name' && valueExpr is SimpleStringLiteral) {
                  name = valueExpr.value;
                } else if (argName == 'abbr' &&
                    valueExpr is SimpleStringLiteral) {
                  abbr = valueExpr.value;
                } else if (argName == 'description' &&
                    valueExpr is SimpleStringLiteral) {
                  description = valueExpr.value;
                }
              }
            }

            commandFlags.add(
              Flag(name: name, abbr: abbr, description: description),
            );
          }
        }

        if (commandName != null) {
          commands[commandName] = {
            'entrypoint': file.path,
            if (commandDescription != null) 'description': commandDescription,
            if (commandArgs.isNotEmpty) 'arguments': commandArgs,
            if (commandFlags.isNotEmpty)
              'flags':
                  commandFlags.map((flag) {
                    return {
                      'name': flag.name,
                      'abbr': flag.abbr,
                      'description': flag.description,
                    };
                  }).toList(),
          };
        }
      }
    }
  }

  // Génération du YAML
  final buffer = StringBuffer();
  final List<Map<String, dynamic>> declarations = [];

  for (final entry in commands.entries) {
    declarations.add({
      'name': entry.key,
      'entrypoint': entry.value['entrypoint'],
      if (entry.value['description'] != null)
        'description': entry.value['description'],
      if (entry.value['arguments'] != null)
        'arguments': [...entry.value['arguments']],
      if (entry.value['flags'] != null) 'flags': [...entry.value['flags']],
    });
  }

  final Map<String, dynamic> content = sanitize({
    ...pubspecMap,
    args.first: {...pubspecMap[args.first] ?? {}, 'commands': declarations},
  });

  print(content);

  final a = json2yaml(content, yamlStyle: YamlStyle.pubspecYaml);
  content.writeAsYaml(buffer: buffer, payload: content);
  await File('pubspec.yaml').writeAsString(a);
}
