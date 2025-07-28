import 'package:vine/vine.dart';

final commandValidator = vine.compile(
  vine.object({
    'name': vine.string(),
    'description': vine.string(),
    'entrypoint': vine.string(),
  }),
);
