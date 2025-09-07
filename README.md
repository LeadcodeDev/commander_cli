# Commander CLI

A lightweight and powerful Dart library for creating command-line applications with a declarative API.

## Installation

Add commander_cli to your `pubspec.yaml` file:

```yaml
dependencies:
  commander_cli: ^1.0.0
```

## Usage

```dart
void main(List<String> arguments) {
  CommandManager(identifier: 'mineral')
    ..load(Directory.current.uri)
    // Used to track commands included in dependencies
    ..followDependencies()
    ..run(arguments);
}
```

### Create your first command

```dart
@Command(name: 'foo', description: 'Foo command')
@Option(name: 'name', help: 'Name of the user', abbr: 'n')
@Option(name: 'age', help: 'Current age', abbr: 'a')
Future<void> main(_, input) async {
  final parser = CommandParser(input);

  print(parser.args.toMap());
  print(parser.flags.toMap());

  exit(0);
}
```

You can validate your input data with [`Vine`](https://pub.dev/packages/vine) or another package like this:

```dart
final validator = vine.compile(
  vine.object({
    vine.string('name'),
    vine.number('age').min(18),
  })
);

@Command(name: 'foo', description: 'Foo command')
@Option(name: 'name', help: 'Name of the user', abbr: 'n')
@Option(name: 'age', help: 'Current age', abbr: 'a')
Future<void> main(_, input) async {
  final parser = CommandParser(input);

  final data = await validator.validate(parser.args.toMap());
  print(data);

  exit(0);
}
```

### Generate declaration

You should run the following command to generate the declaration:

```bash
dart run bin/main.dart generate
```

```yaml
name: your_project
mineral:
  includes: lib/commands
  commands:
    - name: foo
      description: Foo command
      entrypoint: lib/commands/foo.dart
      options:
        - name: name
          abbr: n
          help: Name of the user
        - name: age
          abbr: a
          help: Current age
```

Now you can run your command:

```
dart run bin/main.dart foo --name "John Doe" --age 30
```
