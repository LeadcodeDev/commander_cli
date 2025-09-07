final class Option {
  final String name;
  final String? help;
  final String? abbr;
  final List<String>? allowed;
  final String? defaultTo;
  final bool required;

  const Option({
    required this.name,
    required this.help,
    this.abbr,
    this.allowed,
    this.defaultTo,
    this.required = false,
  });

  factory Option.of(Map<String, dynamic> map) {
    return Option(
      name: map['name'],
      help: map['help'],
      abbr: map['abbr'],
      allowed:
          map['allowed'] != null ? List<String>.from(map['allowed']) : null,
      defaultTo: map['default'],
      required: map['required'] ?? false,
    );
  }
}
