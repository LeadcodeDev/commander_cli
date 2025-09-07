import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:commander_cli/src/domain/annotations/flag.dart';
import 'package:commander_cli/src/domain/annotations/option.dart';

final class InternalCommand extends Command {
  @override
  final String name;

  @override
  final String description;

  List<String> args = [];

  List<Flag> flags = [];

  List<Option> options = [];

  final File file;

  InternalCommand({
    required this.name,
    required this.description,
    required this.file,
    this.args = const [],
    this.flags = const [],
    this.options = const [],
  }) {
    for (final flag in flags) {
      argParser.addFlag(flag.name, abbr: flag.abbr, help: flag.help);
    }

    for (final option in options) {
      argParser.addOption(option.name, abbr: option.abbr, help: option.help);
    }
  }

  Map<String, dynamic> matchParams(
    List<String> derivedOptions,
    List<String> derivedFlags,
  ) {
    final Map<String, dynamic> results = {};

    for (final element in argResults!.arguments) {
      if (derivedOptions.contains(element)) {
        final index = argResults!.arguments.indexOf(element) + 1;
        final value = argResults!.arguments.elementAt(index);

        final derivedElement = element.replaceAll('-', '');

        bool match(Option option) {
          return [option.name, option.abbr].contains(derivedElement);
        }

        final key = options.where(match).first;
        results.putIfAbsent(key.name, () => value);
      }
    }

    for (final (index, element) in argResults!.arguments.indexed) {
      final previous =
          index - 1 < 0
              ? null
              : argResults!.arguments.elementAtOrNull(index - 1);

      final derived = [...derivedOptions, ...derivedFlags];
      if (!derived.contains(previous) && !derived.contains(element)) {
        final key = args.elementAt(index);
        results.putIfAbsent(key, () => element);
      }
    }

    return results;
  }

  Map<String, dynamic> matchFlags(List<String> derivedFlags) {
    final Map<String, dynamic> results = {};

    for (final element in argResults!.arguments) {
      if (derivedFlags.contains(element)) {
        final index = argResults!.arguments.indexOf(element) + 1;
        final value = argResults!.arguments.elementAt(index);

        final derivedElement = element.replaceAll('-', '');

        bool match(Flag flag) {
          return [flag.name, flag.abbr].contains(derivedElement);
        }

        final key = flags.where(match).first;
        results.putIfAbsent(key.name, () => value);
      }
    }

    return results;
  }

  @override
  Future run({Map<String, String> bundle = const {}}) async {
    final List<String> derivedOptions = [];
    final List<String> derivedFlags = [];

    for (final flag in flags) {
      derivedFlags.addAll(['--${flag.name}', '-${flag.abbr}'].nonNulls);
    }

    for (final option in options) {
      derivedOptions.addAll(['--${option.name}', '-${option.abbr}'].nonNulls);
    }

    final process = await Process.start(
      'dart',
      [file.path, ...argResults!.rest],
      environment: {
        ...bundle,
        'metadata': json.encode({
          'command': {
            'name': name,
            'description': description,
            'bin': file.path,
          },
          'args': matchParams(derivedOptions, derivedFlags),
          'flags': matchFlags(derivedFlags),
        }),
      },
    );

    process.stdout.listen((event) => stdout.writeln(utf8.decode(event)));
    process.stderr.listen((event) => stderr.writeln(utf8.decode(event)));

    await process.exitCode;
  }

  factory InternalCommand.of(Map<String, dynamic> element) {
    return InternalCommand(
      name: element['name'],
      description: element['description'],
      file: File(element['entrypoint']),
      args: List<String>.from(element['args'] ?? []),
      flags:
          List<Map<String, dynamic>>.from(
            element['flags'] ?? [],
          ).map(Flag.of).toList(),
      options:
          List<Map<String, dynamic>>.from(
            element['options'] ?? [],
          ).map(Option.of).toList(),
    );
  }
}
