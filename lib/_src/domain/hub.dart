import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:commander_cli/_src/domain/command.dart';
import 'package:commander_cli/_src/domain/command_loader.dart';

final class Hub {
  final String identifier;
  late final CommandLoader _loader;
  final List<InternalCommand> commands = [];

  Hub({required this.identifier}) {
    _loader = CommandLoader(identifier);
  }

  Future<void> handle(List<String> arguments) async {
    commands.addAll(await _loader.resolveLocalCommands(Directory.current.uri));

    final parser = ArgParser();
    for (final command in commands) {
      final args = ArgParser();

      parser.addCommand(command.name, args);
    }

    final targetCommand = commands.firstWhere(
      (command) => command.name == arguments.first,
    );

    final file = File(targetCommand.entrypoint);
    final process = await Process.start('dart', [
      file.path,
      identifier,
      ...arguments.skip(1),
    ]);

    process.stdout.listen((event) => print(utf8.decode(event)));
    process.stderr.listen((event) => print(utf8.decode(event)));

    await process.exitCode;
  }
}
