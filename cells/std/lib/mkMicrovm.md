# `mkMicrovm` provides an interface to `microvm` tasks

This is an integration for [`astro/microvm.nix`][microvm].

## Usage example

```nix
{
  inputs,
  cell,
}: {
  # microvm <module>
  myhost = inputs.std.std.lib.mkMicrovm ({ pkgs, lib, ... }: { networking.hostName = "microvms-host";});
}
```

---

[microvm]: https://github.com/astro/microvm.nix
