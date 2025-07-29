import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:commander_cli/src/domain/annotations/flag.dart';

final class InternalCommand extends Command {
  @override
  final String name;

  @override
  final String description;

  List<String> args = [];

  List<Flag> flags = [];

  final File file;

  InternalCommand({
    required this.name,
    required this.description,
    required this.file,
    this.args = const [],
    this.flags = const [],
  }) {
    for (final flag in flags) {
      argParser.addFlag(flag.name, abbr: flag.abbr, help: flag.help);
    }
  }

  @override
  Future run() async {
    final process = await Process.start('dart', [
      file.path,
      ...argResults!.rest,
    ]);

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
    );
  }
}
