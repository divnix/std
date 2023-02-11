# [`just`][just]

Just is a general purpose command runner with syntax inspired by `make`.

Tasks are configured via an attribute set where the name is the name of the task
(i.e. `just <task>`) and the value is the task definition (see below for an
example). The generated `Justfile` should be committed to allow non-Nix users to
on-ramp without needing access to Nix.

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
        packages = [ nixpkgs.treefmt ];
        data = {
          tasks = {
            fmt = {
              description = "Formats all changed source files";
              content = ''
                treefmt $(git diff --name-only --cached)
              '';
            };
          };
        };
      })
    ];
  };
}
```

It's also possible to override the interpreter for a task:

```nix
{
# ...
  hello = {
    description = "Prints hello world";
    interpreter = nixpkgs.python3;
    content = ''
      print("Hello, world!")
    '';
  };
}
# ...
```

[just]: https://github.com/casey/just

---

#### Definition:

```nix
{{#include ./../../../../cells/std/nixago/just.nix}}
```
