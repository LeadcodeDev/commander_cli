import 'dart:collection';

final class CommandIntrospection {
  final String identifier;
  final CommandMetadata command;
  final ArgumentMetadata arguments;
  final FlagMetadata flags;

  CommandIntrospection(
    this.identifier,
    this.command,
    this.arguments,
    this.flags,
  );

  factory CommandIntrospection.from(Map<String, dynamic> data) {
    return CommandIntrospection(
      data['identifier'] as String,
      CommandMetadata(
        data['command']['name'] as String,
        data['command']['description'] as String,
        data['command']['bin'] as String,
      ),
      ArgumentMetadata(UnmodifiableMapView<String, dynamic>(data['args'])),
      FlagMetadata(UnmodifiableMapView<String, dynamic>(data['flags'])),
    );
  }
}

final class CommandMetadata {
  final String name;
  final String description;
  final String bin;

  CommandMetadata(this.name, this.description, this.bin);
}

final class ArgumentMetadata {
  final UnmodifiableMapView<String, dynamic> _raw;
  Map<String, dynamic> toMap() => Map<String, dynamic>.from(_raw);

  T get<T>(String key, {T? defaultTo}) => (_raw[key] ?? defaultTo) as T;

  ArgumentMetadata(this._raw);
}

final class FlagMetadata {
  final UnmodifiableMapView<String, dynamic> _raw;
  Map<String, dynamic> toMap() => Map<String, dynamic>.from(_raw);

  T get<T>(String key, {T? defaultTo}) => (_raw[key] ?? defaultTo) as T;

  FlagMetadata(this._raw);
}
