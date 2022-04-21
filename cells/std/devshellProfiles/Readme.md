# `std`'s `devshellProfiles`

This organelle only exports a single `default` devshellProfile.

Any `std`ized repository should include this into it's [`numtide/devshell`][devshell]
in order to provide any visitor with the fully pre-configured `std` TUI.

It also wires & instantiates a decent ADR tool. Or where you planning to hack away
without some minimal conscious effort of decision making and recording? 😅

# Usage Example

```nix
{
  # a flake
  # with stuff ...

  outputs = inputs:
    inputs.flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] (system: let
      inherit (inputs.std.deSystemize system inputs) devshell std;
      inherit (devshell.legacyPackages) mkShell;
    in {
      devShells.default = mkShell {
        imports = [std.std.devshellProfiles.default];
        cellsFrom = "./nix";
      };
    });
}
```

---

[devshell]: https://github.com/numtide/devshell
