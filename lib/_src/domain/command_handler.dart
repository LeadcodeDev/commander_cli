import 'dart:async';
import 'dart:convert';
import 'dart:io';

sealed class CommandHandler {}

final class EntrypointHandler extends CommandHandler {
  String entrypoint;
  EntrypointHandler(this.entrypoint);

  Future<void> handle(List<String> arguments) async {
    final file = File('$entrypoint.dart');
    final process = await Process.start('dart', [file.path, ...arguments]);

    process.stdout.listen((event) => print(utf8.decode(event)));
    process.stderr.listen((event) => print(utf8.decode(event)));

    await process.exitCode;
  }
}

final class ScriptHandler extends CommandHandler {
  final FutureOr<void> Function(List<String>) handle;
  ScriptHandler(this.handle);
}
