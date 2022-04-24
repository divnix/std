# Include Filter

It is very common that you want to filter your source code in order
to avoid unnecesary rebuilds and increase your cache hits.

This is so common that `std` includes a tool for this:

```nix
{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs) std;
in {
  backend = nixpkgs.mkYarnPackage {
    name = "backend";
    src = std.incl (inputs.self + /src/backend) [
      (inputs.self + /src/backend/app.js)
      (inputs.self + /src/backend/config/config.js)
      /* ... */
    ];
  };
}
```
