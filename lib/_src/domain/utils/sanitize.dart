import 'package:yaml/yaml.dart';

T sanitize<T extends dynamic>(dynamic payload) {
  if (payload is YamlMap) {
    final Map<String, dynamic> sanitizedMap = {};

    for (final element in payload.entries) {
      sanitizedMap[element.key] = sanitize(element.value);
    }

    return sanitizedMap as T;
  }

  if (payload is YamlList) {
    final List<dynamic> sanitizedList = [];

    for (final element in payload) {
      sanitizedList.add(sanitize(element));
    }

    return sanitizedList as T;
  }

  return payload as T;
}
