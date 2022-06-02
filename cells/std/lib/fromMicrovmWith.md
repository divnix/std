# `fromMicrovmWith` provides an interface to `microvm` tasks

This is an integration for [`astro/microvm.nix`][microvm].

A version that has this [patch][patch] is a prerequisite.

## Usage example

```nix
{
  inputs,
  cell,
}: let
  microvm = inputs.std.std.lib.fromMicrovmWith inputs;
in {
  # microvm <channel> <module>
  task = microvm nixpkgs ({ pkgs, lib, ... }: { networking.hostName = "microvms-host";});
}
```

_Some refactoring of the tasks may be necessary. Let the error messages be your friend._

---

[patch]: https://github.com/fluidattacks/makes/commit/cd8c4eda69e2ce8dc6f811973ba0d80070b4628a
[makes]: https://github.com/fluidattacks/makes
