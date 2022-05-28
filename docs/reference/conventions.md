# Conventions in `std`

In principle, we all want to be able to read code with local reasoning.

However, these few conventions are pure quality of live and
help us to keep our nix code organized.

## Nix File Locations

Nix files are imported from either of these two locations, if present, in this order of precedence:

```
${cellsFrom}/${cell}/${organelle}.nix
${cellsFrom}/${cell}/${organelle}/default.nix
```

## Readme File Locations

Readme files are picked up by the TUI in the following places:

```
${cellsFrom}/${cell}/Readme.md
${cellsFrom}/${cell}/${organelle}/Readme.md
${cellsFrom}/${cell}/${organelle}/${target}.md
```

## Organelle File Arguments

Each organelle is a function and expects the following standardized interface for interoperability:

```nix
{ inputs, cell }: {}
```

## The `inputs` argument

The `inputs` argument holds all the de-systemized flake inputs plus a few special inputs:

```nix
{
  inputs = {
    self = {}; # sourceInfo of the current repository
    nixpkgs = {}; # an _instantiated_ nixpkgs
    cells = {}; # the other cells in this repo
  };
}
```

## The `cell` argument

The `cell` argument holds all the different organelle targets of the current cell.
This is the main mechanism to by which code organization and separation of concern is enabled.

## The `deSytemize`d inputs

All inputs are scoped for the _current_ system, that is derived from the `sytems` input list to `std.grow`.
That means contrary to the usual nix-UX, in most cases, you don't need to worry about `system`.

The current system will be "lifted up" one level, while still providing full access to all `sytems` for
cross-compliation scenarios.

```nix
# inputs.a.packages.${system}
{
  inputs.a.packages.pkg1 = {};
  inputs.a.packages.pkg2 = {};
  /* ... */
  inputs.a.packages.${system}.pkgs1 = {};
  inputs.a.packages.${system}.pkgs2 = {};
  /* ... */
}
```

#### `deSystemize`'s implementation

```nix
{{#include ../../src/de-systemize.nix}}
```

## Top-level `system`-scoping of outputs

Contrary to the upstream flake schema, all outputs are `system` spaced at the top-level.
This allows us to uniformly select on the _current_ system and forget about it for most
of the time.

Sometimes `nix` evaluations don't strictly depend on a particular `system`, and scoping
them seems counter-intuitive. But due to the fact that function calls are memoized, there
is never a pentalty in actually scpoing them. So for the sake of uniformity, we scope them
anyways.

The outputs therefore abide by the following "schema":

```nix
{
  ${system}.${cell}.${organelle}.${target} = {};
}
```
