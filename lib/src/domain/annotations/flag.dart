final class Flag {
  final String name;
  final String? help;
  final String? abbr;

  const Flag({required this.name, required this.help, this.abbr});

  factory Flag.of(Map<String, dynamic> map) {
    return Flag(name: map['name'], help: map['help'], abbr: map['abbr']);
  }
}
