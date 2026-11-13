# Contributing to envflare_cli

Thank you for contributing to `envflare_cli`! This guide explains how to set up the project locally, make contributions, and submit improvements.

## Project setup

### Prerequisites

- Dart SDK `>=3.4.0 <4.0.0`
- `melos` installed globally if you want mono-repo tooling

### Install dependencies

From the repository root:

```bash
dart pub get
```

If you use Melos:

```bash
melos bootstrap
```

### Run the CLI locally

```bash
dart run bin/envflare.dart --help
```

### Generate documentation

```bash
dart doc .
```

## Development workflow

### Formatting

Keep code formatted with:

```bash
dart format .
```

### Running the tests

```bash
dart analyze
dart test
```

`test/core_test.dart` covers the core logic in-process. `test/cli_e2e_test.dart` runs the real CLI as a subprocess and checks printed output and exit codes. Both work inside a throwaway project directory, and because the working directory is process-wide, `dart_test.yaml` runs test files one at a time. Add a regression test with every bug fix.

### Adding or changing commands

1. Add a new command under `lib/commands/`.
2. Implement `BaseCommand` in `lib/commands/base_command.dart`.
3. Export the new command from `lib/commands/index.dart`.
4. Register the command in the command registry if needed.
5. Add or update DartDoc comments for public APIs.

### Core logic changes

- Put reusable business logic in `lib/core/`.
- Keep CLI parsing inside `lib/cli/` or command classes.
- Raise user-facing errors with `CliException`.
- Use `Logger` for standard output messages.

## Testing changes

There are currently no dedicated tests in this repo, so manual validation is important.

### Manual validation

Run the CLI directly for the commands you change:

```bash
dart run bin/envflare.dart <command>
```

Example:

```bash
dart run bin/envflare.dart init
```

## Release and changelog

- Update `pubspec.yaml` version when preparing a new release.
- Update `CHANGELOG.md` manually using the preferred minimal style.
- Use commit messages that describe the change clearly.

## Contribution process

1. Fork the repository.
2. Create a branch for your fix or feature.
3. Make your changes and verify locally.
4. Update documentation or changelog if needed.
5. Submit a pull request with a clear description.

## Notes for contributors

- Keep changes focused and small.
- Prefer simple, maintainable solutions.
- Document public APIs and critical logic clearly.
- If you change command behavior, update examples or usage notes.

Thank you for helping improve `envflare_cli`!
