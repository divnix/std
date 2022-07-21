# Devshells

- The `default` devshell implements the development environment for the `std` TUI/CLI.
- Furthermore, it implements a `pre-commit` hook to keep the source code formatted.
- It makes use of `std.lib.mkShell` which is a convenience proxy for `numtide/devshell`.
