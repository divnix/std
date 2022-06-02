# `fromMicrovmWith` provides an interface to `microvm` tasks

This is an integration for [`astro/microvm.nix`][microvm].

## Usage example

```nix
{
  inputs,
  cell,
}: let
  microvm = inputs.std.std.lib.fromMicrovmWith inputs;
in {
  # microvm <module>
  task = microvm ({ pkgs, lib, ... }: { networking.hostName = "microvms-host";});
}
```

_Some refactoring of the tasks may be necessary. Let the error messages be your friend._

---
[microvm]: https://github.com/astro/microvm.nix
