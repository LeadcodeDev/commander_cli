import 'package:analyzer/dart/ast/ast.dart';

final class OptionAnnotationParser {
  Map<String, dynamic> parse(Annotation metadata) {
    Map<String, dynamic> option = {};
    final args = metadata.arguments?.arguments ?? [];

    for (final arg in args) {
      if (arg is NamedExpression) {
        final argName = arg.name.label.name;
        final valueExpr = arg.expression;

        if (argName == 'name' && valueExpr is SimpleStringLiteral) {
          option['name'] = valueExpr.value;
        }

        if (argName == 'help' && valueExpr is SimpleStringLiteral) {
          option['help'] = valueExpr.value;
        }

        if (argName == 'abbr' && valueExpr is SimpleStringLiteral) {
          option['abbr'] = valueExpr.value;
        }

        if (argName == 'allowed' && valueExpr is ListLiteral) {
          option['allowed'] =
              valueExpr.elements.map((e) => e.toString()).toList();
        }

        if (argName == 'defaultTo' && valueExpr is SimpleStringLiteral) {
          option['default'] = valueExpr.value;
        }

        if (argName == 'required' && valueExpr is BooleanLiteral) {
          option['required'] = valueExpr.value;
        }
      }
    }

    return option;
  }
}
