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
