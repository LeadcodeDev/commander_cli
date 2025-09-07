final class Option {
  final String name;
  final String? help;
  final String? abbr;

  const Option({required this.name, required this.help, this.abbr});

  factory Option.of(Map<String, dynamic> map) {
    return Option(name: map['name'], help: map['help'], abbr: map['abbr']);
  }
}
