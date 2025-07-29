import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

extension YamlFile on File {
  Future<T> readAsYaml<T extends dynamic>({
    T Function(Map<String, dynamic> payload)? constructor,
  }) async {
    final stringifyContent = await readAsString();
    final YamlMap yamlContent = loadYaml(stringifyContent);
    final Map<String, dynamic> map = {};

    for (final entry in yamlContent.entries) {
      map[entry.key.toString()] = entry.value;
    }

    return constructor != null ? constructor(map) : map;
  }

  T readAsYamlSync<T extends dynamic>({
    T Function(Map<String, dynamic> payload)? constructor,
  }) {
    final stringifyContent = readAsStringSync();
    final YamlMap yamlContent = loadYaml(stringifyContent);
    final Map<String, dynamic> map = {};

    for (final entry in yamlContent.entries) {
      map[entry.key.toString()] = entry.value;
    }

    return constructor != null ? constructor(map) : map;
  }
}

extension JsonFile on File {
  Future<T> readAsJson<T extends dynamic>({
    T Function(Map<String, dynamic> payload)? constructor,
  }) async {
    final content = await readAsString();
    final Map<String, dynamic> map = jsonDecode(content);

    return constructor != null ? constructor(map) : map;
  }

  T readAsJsonSync<T extends dynamic>({
    T Function(Map<String, dynamic> payload)? constructor,
  }) {
    final content = readAsStringSync();
    final Map<String, dynamic> map = jsonDecode(content);

    return constructor != null ? constructor(map) : map;
  }
}

extension YamlWriter<K, V> on Map<K, V> {
  void writeAsYaml({
    required StringBuffer buffer,
    required dynamic payload,
    int spacing = 0,
  }) {
    final spaces = ' ' * spacing;
    if (payload case Map payload) {
      for (final entry in payload.entries) {
        if (entry.value is int ||
            entry.value is double ||
            entry.value is String ||
            entry.value is bool) {
          buffer.writeln('$spaces${entry.key}: ${entry.value}');
        }

        if (entry.value case Map payload) {
          buffer.writeln('$spaces${entry.key}:');
          writeAsYaml(
            buffer: buffer,
            payload: {...payload},
            spacing: spacing + 2,
          );

          buffer.writeln();
        }

        if (entry.value case List payload) {
          buffer.writeln('$spaces${entry.key}:');
          writeAsYaml(buffer: buffer, payload: [...payload], spacing: spacing);

          buffer.writeln();
        }
      }
    }

    if (payload is List) {
      for (final item in payload) {
        if (item is int || item is double || item is String || item is bool) {
          buffer.writeln('${' ' * (spacing + 2)}- $item');
        } else {
          if (item case Map payload) {
            final firstElement = payload.entries.first;
            payload.remove(firstElement.key);
            buffer.writeln(
              '${' ' * (spacing + 2)}- ${firstElement.key}: ${firstElement.value}',
            );

            writeAsYaml(
              buffer: buffer,
              payload: {
                ...payload.entries.fold({}, (acc, e) {
                  return {...acc, '${' ' * spacing}${e.key}': e.value};
                }),
              },
              spacing: spacing + 2,
            );
          }
        }
      }
    }
  }
}
