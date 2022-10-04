# `mkMicrovm` provides an interface to `microvm` tasks

This is an integration for [`astro/microvm.nix`][microvm].

## Usage example

```nix
{
  inputs,
  cell,
}: let
  inherit (inputs.std.lib) ops;
in {
  # microvm <module>
  myhost = ops.mkMicrovm ({ pkgs, lib, ... }: { networking.hostName = "microvms-host";});
}
```

---

[microvm]: https://github.com/astro/microvm.nix
