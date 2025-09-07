final class Flag {
  final String name;
  final String? help;
  final String? abbr;
  final bool? defaultTo;

  const Flag({
    required this.name,
    required this.help,
    this.abbr,
    this.defaultTo,
  });

  factory Flag.of(Map<String, dynamic> map) {
    return Flag(
      name: map['name'],
      help: map['help'],
      abbr: map['abbr'],
      defaultTo: map['default'],
    );
  }
}
