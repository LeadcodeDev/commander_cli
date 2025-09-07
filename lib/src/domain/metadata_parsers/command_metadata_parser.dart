import 'package:analyzer/dart/ast/ast.dart';

final class CommandAnnotationParser {
  final Map<String, List<String>> _constantsMap;
  CommandAnnotationParser(this._constantsMap);

  Map<String, dynamic> parse(Annotation metadata) {
    final Map<String, dynamic> command = {};
    final args = metadata.arguments?.arguments ?? [];

    for (final arg in args) {
      if (arg is NamedExpression) {
        final argName = arg.name.label.name;
        final valueExpr = arg.expression;

        extractName(argName, valueExpr, command);
        extractDescription(argName, valueExpr, command);
        extractArguments(argName, valueExpr, command);
      }
    }

    return command;
  }

  void extractName(
    String argName,
    Expression valueExpr,
    Map<String, dynamic> command,
  ) {
    if (argName == 'name' && valueExpr is SimpleStringLiteral) {
      command['name'] = valueExpr.value;
    }
  }

  void extractDescription(
    String argName,
    Expression valueExpr,
    Map<String, dynamic> command,
  ) {
    if (argName == 'description' && valueExpr is SimpleStringLiteral) {
      command['description'] = valueExpr.value;
    }
  }

  void extractArguments(
    String argName,
    Expression valueExpr,
    Map<String, dynamic> command,
  ) {
    if (argName == 'arguments') {
      command['arguments'] = <String>[];

      if (valueExpr case SimpleIdentifier identifier) {
        final constName = identifier.name;
        final constValue = _constantsMap[constName];
        if (constValue != null) {
          command['arguments'].addAll(constValue);
        }
      }

      if (valueExpr case ListLiteral(:final elements)) {
        for (final element in elements) {
          if (element is StringLiteral) {
            final value = element.stringValue;
            if (value != null) {
              command['arguments'].add(value);
            }
          }
        }
      }
    }
  }
}
