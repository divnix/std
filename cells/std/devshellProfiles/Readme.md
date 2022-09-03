# `std`'s `devshellProfiles`

This Cell Block only exports a single `default` devshellProfile.

Any `std`ized repository should include this into its [`numtide/devshell`][devshell]
in order to provide any visitor with the fully pre-configured `std` TUI.

It also wires & instantiates a decent ADR tool. Or were you planning to hack away
without some minimal conscious effort of decision making and recording? 😅

# Usage Example

```nix
# ./nix/automation/devshells.nix
{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std;
in
  l.mapAttrs (_: std.lib.mkShell) {
    # `default` is a special target in newer nix versions
    # see: harvesting below
    default = {
      name = "My Devshell";
      # make `std` available in the numtide/devshell
      imports = [ std.devshellProfiles.default ];
    };
  }
```

```nix
# ./flake.nix
{
  inputs.std.url = "github:divnix/std";

  outputs = inputs:
    inputs.std.growOn {
      inherit inputs;
      cellsFrom = ./nix;
      cellBlocks = [
        /* ... */
        (inputs.std.clades.devshells "devshells")
      ];
    }
    # soil for compatiblity ...
    {
      # ... with `nix develop` - `default` is a special target for `nix develop`
      devShells = inputs.std.harvest inputs.self ["automation" "devshells"];
    };
}
```

---

[devshell]: https://github.com/numtide/devshell
