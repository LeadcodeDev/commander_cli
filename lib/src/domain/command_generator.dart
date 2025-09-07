import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:commander_cli/src/domain/internal_command.dart';
import 'package:commander_cli/src/domain/metadata_parsers/command_metadata_parser.dart';
import 'package:commander_cli/src/domain/metadata_parsers/flag_metadata_parser.dart';
import 'package:commander_cli/src/domain/metadata_parsers/option_metadata_parser.dart';

final class CommandGenerator {
  InternalCommand generate(File file) {
    final content = File(file.path).readAsStringSync();
    final parsed = parseString(content: content, path: file.path);
    final unit = parsed.unit;

    String? commandName;
    String? commandDescription;
    List<String> commandArguments = [];
    List<Map<String, dynamic>> commandFlags = [];
    List<Map<String, dynamic>> commandOptions = [];

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
        constantsMap[variable.name.lexeme] =
            initializer.elements
                .whereType<SimpleStringLiteral>()
                .map((e) => e.value)
                .toList();
      }
    }

    final commandParser = CommandAnnotationParser(constantsMap);
    final flagParser = FlagAnnotationParser();
    final optionParser = OptionAnnotationParser();

    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == 'main') {
        final commandAnnotation =
            declaration.metadata
                .where((meta) => meta.name.name == 'Command')
                .firstOrNull;

        if (commandAnnotation == null) {
          throw ArgumentError(
            'Missing "Command" annotation in ${file.path.split('/').last}',
          );
        }

        for (final meta in declaration.metadata) {
          final name = meta.name.name;
          final args = meta.arguments?.arguments ?? [];

          if (name == 'Command') {
            final command = commandParser.parse(meta);

            commandName = command['name'];
            commandDescription = command['description'];
            commandArguments = command['arguments'] ?? [];
          }

          if (name == 'Flag' && args.isNotEmpty) {
            final flag = flagParser.parse(meta);
            commandFlags.add(flag);
          }

          if (name == 'Option') {
            final option = optionParser.parse(meta);
            commandOptions.add(option);
          }
        }
      }
    }

    return InternalCommand.of({
      'name': commandName,
      'description': commandDescription,
      'entrypoint': file.path,
      'args': commandArguments,
      'flags': commandFlags,
      'options': commandOptions,
    }, root: null);
  }

  List<Map<String, dynamic>> createDeclaration(List<InternalCommand> commands) {
    final List<Map<String, dynamic>> results = [];
    for (final command in commands) {
      results.add({
        'name': command.name,
        'description': command.description,
        'entrypoint': command.file.path,
        if (command.args.isNotEmpty) 'args': command.args,
        if (command.flags.isNotEmpty)
          'flags':
              command.flags.map((flag) {
                return {
                  'name': flag.name,
                  if (flag.abbr != null) 'abbr': flag.abbr,
                  if (flag.help != null) 'help': flag.help,
                  if (flag.defaultTo != null) 'default': flag.defaultTo,
                };
              }).toList(),
        if (command.options.isNotEmpty)
          'options':
              command.options.map((option) {
                if (command.args.contains(option.name)) {
                  throw ArgumentError(
                    'Option "${option.name}" cannot be used because it is already used as an argument',
                  );
                }

                return {
                  'name': option.name,
                  if (option.abbr != null) 'abbr': option.abbr,
                  if (option.help != null) 'help': option.help,
                  if (option.allowed != null) 'allowed': option.allowed,
                  if (option.defaultTo != null) 'default': option.defaultTo,
                  if (option.required) 'required': true,
                };
              }).toList(),
      });
    }

    return results;
  }
}
