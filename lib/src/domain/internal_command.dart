import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

final class InternalCommand extends Command {
  @override
  final String name;

  @override
  final String description;

  final File file;

  InternalCommand({
    required this.name,
    required this.description,
    required this.file,
  }) {
    argParser.addFlag('all', abbr: 'a');
  }

  @override
  Future run() async {
    final process = await Process.start('dart', [
      file.path,
      ...argResults!.rest,
    ]);

    process.stdout.listen((event) => print(utf8.decode(event)));
    process.stderr.listen((event) => print(utf8.decode(event)));

    await process.exitCode;
  }
}
