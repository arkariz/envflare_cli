# envflare_cli

[![pub package](https://img.shields.io/pub/v/envflare_cli.svg)](https://pub.dev/packages/envflare_cli)
[![CI](https://github.com/arkariz/envflare_cli/actions/workflows/ci.yml/badge.svg)](https://github.com/arkariz/envflare_cli/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> A modern CLI tool for managing flavor-based environment configurations in Flutter projects

![envflare in action: create flavors, add a key, validate fails with exit code 1 until every flavor has a value, then passes](doc/demo.gif)

*The output above is what the CLI really prints, replayed with a typing animation. Note that the first `validate` exits with code 1, so the same command can gate a CI job.*

A CLI tool to generate and manage flavor-based environment variable files for Flutter projects. Simplify environment configuration across different build flavors (development, staging, production) with schema validation and automated code generation.

## ✨ Features

- 🍦 **Flavor Management** — Create, remove, and list environment flavors with ease
- 🔐 **Schema-Based Variables** — Define environment variables in a centralized schema file
- 📝 **Environment Operations** — Add, remove, set, and manage variables per flavor
- ✅ **Sync & Validate** — Keep all flavors consistent and validate configurations; `validate` exits non-zero on failure, so it works as a CI gate
- 🧙‍♂️ **Interactive Wizard** — Step-by-step guided setup for fast onboarding
- 💻 **Developer-Friendly** — Intuitive CLI with helpful error messages
- 📋 **Code Generation** — Generate type-safe Dart code from configuration files using `envied`

## 📋 Table of Contents

- [Features](#-features)
- [Getting Started](#-getting-started)
- [Installation](#-installation)
- [Usage](#-usage)
- [Example Workflows](#-example-workflows)
- [Using it in CI](#-using-it-in-ci)
- [Project Structure](#-project-structure)
- [Security](#-security)
- [Contributing](#-contributing)
- [Issues & Support](#-issues--support)
- [License](#-license)

## 🚀 Getting Started

### Prerequisites

- **Dart SDK** `3.4.0` or higher

### Dependencies

To enable code generation features, add these to your `pubspec.yaml`:

```yaml
dependencies:
  envied: ^1.3.4

dev_dependencies:
  build_runner: ^2.13.1
  envied_generator: ^1.3.4
```

Then install:
```bash
flutter pub get
# or
dart pub get
```

**Note:** The `envied` package provides:
- 📝 **Type-safe access** with compile-time verification
- 🔒 **Configuration management** for different flavors
- 📋 **Keeps `.env` out of source control** if properly gitignored

## 📦 Installation

### From pub.dev (Recommended)

```bash
dart pub global activate envflare_cli
```

Verify installation:
```bash
envflare --help
```

## 📖 Usage

### 🧙‍♂️ Quick Start: Interactive Wizard (Recommended)

For a guided, interactive setup experience:

```bash
envflare wizard
```

This launches an interactive menu where you can:

| Option | Description |
|--------|-------------|
| Initialize project with flavors and keys | Set up your project from scratch with flavors and environment variables |
| Add a new flavor | Add a new flavor (e.g., staging, prod) to your configuration |
| Add a new environment variable key | Add a new environment variable to all flavors |
| Remove an environment variable key | Remove an environment variable from all flavors |

#### Initialize Project
```bash
envflare wizard
→ Select: "Initialize project with flavors and keys"
```
Guides you through creating and configuring your `.env.schema` and `.envflare_cli.json`.

#### Add a Flavor
```bash
envflare wizard
→ Select: "Add a new flavor"
```
Add a new flavor and set values for all existing environment keys.

#### Add an Environment Variable
```bash
envflare wizard
→ Select: "Add a new environment variable key"
```
Add a new variable to the schema and set values for all flavors.

#### Remove an Environment Variable
```bash
envflare wizard
→ Select: "Remove an environment variable key"
```
Remove a variable from all flavors and the schema.

### ⌨️ Manual Commands

For more control, use individual commands:

#### Initialize Project
```bash
envflare init
```
Creates `.env.schema` and `.envflare_cli.json` in your project root.

#### Flavor Management
```bash
# Add a new flavor
envflare flavor add development

# List all flavors
envflare flavor list

# Remove a flavor
envflare flavor remove development
```

#### Variable Management
```bash
# Add a variable to schema and all flavors
envflare add API_URL

# Set a variable for specific flavor
envflare set API_URL https://dev.api.com --flavor development

# Set a variable for all flavors
envflare set DEBUG true

# List variables for a flavor
envflare list --flavor development

# List all variables across flavors
envflare list

# Remove a variable from all flavors
envflare remove API_URL
```

#### Configuration Maintenance
```bash
# Sync variables across flavors (add missing ones)
envflare sync

# Validate all configurations
envflare validate
```

#### Code Generation
```bash
# Generate Dart code from .env files
envflare generate
```
Creates environment classes using the `envied` package for secure variable access. See [Security](#-security) section for details on how `envied` protects your environment variables.

## 📚 Example Workflows

### Option 1: Wizard-Based Setup (Fastest)

```bash
# Start the wizard
envflare wizard

# Follow the prompts to:
# 1. Initialize project
# 2. Add flavors (dev, staging, prod)
# 3. Add environment variables (API_URL, DEBUG_MODE, etc.)
# 4. Set values for each flavor
# 5. Generate code
```

### Option 2: Manual Setup (More Control)

```bash
# 1. Initialize
envflare init

# 2. Add flavors
envflare flavor add dev
envflare flavor add prod

# 3. Add variables
envflare add API_BASE_URL
envflare add DEBUG_MODE

# 4. Set values
envflare set API_BASE_URL https://dev.api.com --flavor dev
envflare set API_BASE_URL https://prod.api.com --flavor prod
envflare set DEBUG_MODE true --flavor dev
envflare set DEBUG_MODE false --flavor prod

# 5. Generate code
envflare generate
```

## 🔁 Using it in CI

Every failed command (`validate`, an unknown command, a missing project, ...) exits with a non-zero code, so a pipeline stops on a half-configured environment instead of building with empty values:

```yaml
# .github/workflows/ci.yml
- run: dart pub global activate envflare_cli
- run: envflare validate   # fails the job if any flavor misses a key or has an empty value
```

## 📁 Project Structure

After initialization, your project will have the following structure:

```
project-root/
├── .env.schema              # Schema defining all environment variables
├── .envflare_cli.json       # Configuration file with flavor list
└── .envs/
    ├── dev.env              # Development environment variables
    ├── staging.env          # Staging environment variables
    └── prod.env             # Production environment variables
```

### File Descriptions

| File | Purpose |
|------|---------|
| `.env.schema` | Defines all available environment variable keys |
| `.envflare_cli.json` | Stores flavor list and project configuration |
| `.envs/*.env` | Contains environment variables for each flavor **(local only, never commit to version control)** |

## 🛡️ Security

### What `envflare_cli` + `envied` Provides

`envflare_cli` integrates with `envied` to improve **configuration management** and provide **basic protection** for environment values during development.

### ✅ What It Helps With

* **Type-safe access** — Compile-time verification of environment variables
* **Keeps `.env` files out of source control** — Prevents accidental commits via `.gitignore`
* **Configuration per flavor** — Manage different values for development, staging, production
* **Code obfuscation** — Makes static extraction of values harder
* **Reduces accidental plaintext secrets** — Keeps configuration out of source files
* **Non-sensitive configuration management** — API base URLs, feature flags, app identifiers

### ⚠️ Important: Security Limitations

**`envied` is NOT a secret vault.**

Understand these limitations:

1. **Values may still be compiled into your binary** — Code obfuscation makes extraction harder, but not impossible
2. **Code generation happens at build time** — Values are read from `.env` during `build_runner` execution and embedded in generated code
3. **Determined attackers can recover values** — With reverse engineering tools and effort, strings may be extractable
4. **Not suitable for high-security secrets** — Use this only for non-sensitive configuration

### Generated Code Details

The generated code from `envflare generate`:
- Reads `.env` files at **build time**
- Generates Dart source code with environment values
- Applies code obfuscation to make extraction harder
- Provides type-safe accessors for your configuration

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Before opening a PR, run the checks CI runs:

```bash
dart pub get
dart analyze
dart test   # the tests change the working directory, so files run one at a time (see dart_test.yaml)
```

## 🐛 Issues & Support

- **Found a bug?** [Report it on GitHub](https://github.com/arkariz/envflare_cli/issues)
- **Have a feature request?** [Create an issue](https://github.com/arkariz/envflare_cli/issues)
- **Questions?** Feel free to open a discussion

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## 👤 Author

Created with ❤️ by **Muhammad Rizky**

---

<div align="center">

Made to simplify Flutter environment management

[⬆ back to top](#envflare_cli)

</div>
