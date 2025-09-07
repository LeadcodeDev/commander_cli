import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:commander_cli/src/domain/annotations/flag.dart';
import 'package:commander_cli/src/domain/annotations/option.dart';
import 'package:path/path.dart';

final class InternalCommand extends Command {
  @override
  final String name;

  @override
  final String description;

  List<String> args = [];

  List<Flag> flags = [];

  List<Option> options = [];

  final File file;

  final String? identifier;

  InternalCommand({
    required this.name,
    required this.description,
    required this.file,
    required this.identifier,
    this.args = const [],
    this.flags = const [],
    this.options = const [],
  }) {
    for (final flag in flags) {
      argParser.addFlag(
        flag.name,
        abbr: flag.abbr,
        help: flag.help,
        defaultsTo: flag.defaultTo,
      );
    }

    for (final option in options) {
      argParser.addOption(
        option.name,
        abbr: option.abbr,
        help: option.help,
        allowed: option.allowed,
        defaultsTo: option.defaultTo,
        mandatory: option.required,
      );
    }
  }

  Map<String, dynamic> matchParams(
    List<String> derivedOptions,
    List<String> derivedFlags,
  ) {
    final Map<String, dynamic> results = {};

    for (final element in options) {
      final value = argResults!.option(element.name);
      if (value != null) {
        results.putIfAbsent(element.name, () => value);
      }
    }

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

    for (final element in flags) {
      final flag = argParser.options[element.name];
      results.putIfAbsent(
        element.name,
        () => flag?.valueOrDefault(argResults?.flag(element.name)),
      );
    }

    return results;
  }

  @override
  Future run() async {
    final List<String> derivedOptions = [];
    final List<String> derivedFlags = [];

    for (final flag in flags) {
      derivedFlags.addAll(['--${flag.name}', '-${flag.abbr}'].nonNulls);
    }

    for (final option in options) {
      derivedOptions.addAll(['--${option.name}', '-${option.abbr}'].nonNulls);
    }

    final receivePort = ReceivePort();

    final metadata = {
      'identifier': identifier,
      'command': {'name': name, 'description': description, 'bin': file.path},
      'args': matchParams(derivedOptions, derivedFlags),
      'flags': matchFlags(derivedFlags),
    };

    await Isolate.spawnUri(Uri.file(file.path), [], {
      'sendPort': receivePort.sendPort,
      'metadata': metadata,
    });

    receivePort.listen((message) {
      if (message is String) {
        stdout.writeln(message);
      } else if (message is Map) {
        stderr.writeln(jsonEncode(message));
      }
    });
  }

  factory InternalCommand.of(Map<String, dynamic> element, {Uri? root}) {
    return InternalCommand(
      identifier: element['identifier'],
      name: element['name'],
      description: element['description'],
      file: File(join(root?.path ?? '', element['entrypoint'])),
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
