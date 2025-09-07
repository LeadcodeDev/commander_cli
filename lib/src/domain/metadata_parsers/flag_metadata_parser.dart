import 'package:analyzer/dart/ast/ast.dart';

final class FlagAnnotationParser {
  Map<String, dynamic> parse(Annotation metadata) {
    Map<String, dynamic> flag = {};
    final args = metadata.arguments?.arguments ?? [];

    for (final arg in args) {
      if (arg is NamedExpression) {
        final argName = arg.name.label.name;
        final valueExpr = arg.expression;

        if (argName == 'name' && valueExpr is SimpleStringLiteral) {
          flag['name'] = valueExpr.value;
        }

        if (argName == 'help' && valueExpr is SimpleStringLiteral) {
          flag['help'] = valueExpr.value;
        }

        if (argName == 'abbr' && valueExpr is SimpleStringLiteral) {
          flag['abbr'] = valueExpr.value;
        }

        if (argName == 'allowed' && valueExpr is ListLiteral) {
          flag['allowed'] =
              valueExpr.elements.map((e) => e.toString()).toList();
        }

        if (argName == 'defaultTo' && valueExpr is BooleanLiteral) {
          flag['default'] = valueExpr.value;
        }
      }
    }

    return flag;
  }
}
