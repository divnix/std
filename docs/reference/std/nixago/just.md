# [`just`][just]

Just is a general purpose command runner with syntax inspired by `make`.

Tasks are configured via an attribute set where the name is the name of the
task (i.e. `just <task>`) and the value is a list of commands to run. The
generated `Justfile` should be committed to allow non-Nix users to on-ramp
without needing access to Nix.

Task dependencies (i.e. `treefmt` below) should be included in `packages` and
will automatically be picked up in the devshell.

```nix
{ inputs, cell }:
let
  inherit (inputs.std) nixpkgs std;
in
{

  default = std.lib.mkShell {
    /* ... */
    nixago = [
      (std.nixago.just {
        packages = [nixpkgs.treefmt];
        configData = {
          tasks = {
            fmt = [
              ''
                treefmt $(git diff --name-only --cached)
              ''
            ];
          };
        };
      })
    ];
  };
}
```

[just]: https://github.com/casey/just
