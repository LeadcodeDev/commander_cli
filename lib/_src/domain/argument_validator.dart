import 'package:args/args.dart';
import 'package:vine/vine.dart';

final class ArgumentValidator {
  final Map<String, dynamic> _results = {};
  final Validator validator;

  Map<String, dynamic> get results => {..._results};

  ArgumentValidator(List<String> arguments, this.validator) {
    final clone = validator.schema as VineObject;
    final Map<String, dynamic> transformed = {};

    for (final element in arguments.skip(1).indexed) {
      final (index, value) = element;
      transformed[clone.properties.keys.elementAt(index)] = value.toString();
    }

    final payload = validator.validate(transformed);
    _results.addAll(Map<String, dynamic>.from(payload));
  }

  T get<T>(String key) {
    return _results[key] as T;
  }
}
