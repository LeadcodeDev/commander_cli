import 'package:commander_cli/_src/domain/annotations/flag.dart';

final class Command {
  final String name;
  final String description;
  final List<String> arguments;

  const Command({
    required this.name,
    required this.description,
    this.arguments = const [],
  });
}

final class InternalCommand {
  final String name;
  final String description;
  final String entrypoint;
  final List<String> arguments;
  final List<Flag> flags;

  const InternalCommand({
    required this.name,
    required this.description,
    required this.entrypoint,
    this.arguments = const [],
    this.flags = const [],
  });
}
