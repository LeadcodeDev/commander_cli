import 'package:vine/vine.dart';

final class CommandArgumentParser {
  final Validator? _validator;
  final Map<String, dynamic> _argResults = {};

  CommandArgumentParser({required List<String> args, Validator? validator})
    : _validator = validator {
    if (_validator != null) {
      final schema = _validator.schema.clone() as VineObject;
      final Map<String, dynamic> transformed = {};

      for (final element in args.indexed) {
        final (index, value) = element;
        transformed[schema.properties.keys.elementAt(index)] = value.toString();
      }

      final results = _validator.validate(transformed);
      _argResults.addAll(Map<String, dynamic>.from(results));
    }
  }

  T getArgument<T>(String key) {
    if (_validator == null) {
      throw Exception('Validator is required');
    }

    return _argResults[key] as T;
  }
}
