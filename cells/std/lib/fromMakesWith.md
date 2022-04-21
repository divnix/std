# `fromMakesWith` provides an interface to `makes` tasks

This is an integration for [`fluidattacks/makes`][makes].

A version that has this [patch][patch] is a prerequisite.

## Usage example

```nix
{
  inputs,
  cell,
}: let
  make = inputs.std.std.lib.fromMakesWith inputs;
in {
  task = make ./path/to/make/task//main.nix {};
}
```

_Some refactoring of the tasks may be necessary. Let the error messages be your friend._

---

[patch]: https://github.com/fluidattacks/makes/commit/cd8c4eda69e2ce8dc6f811973ba0d80070b4628a
[makes]: https://github.com/fluidattacks/makes
