# Comparing Standard to X

_Where appropriate, we compare with `divnix/paisano`, instead_.

## Comparison with tools in the Nix ecosystem

### flake-utils

`numtide/flake-utils` is a small & lightweight utility with a focus on generating flake file _outputs_ in accordance with the packaging and NixOS use cases built into the Nix CLI tooling.

Paisano, in turn, is an importer with a focus on _code organization_.

Like Flake Utils, it, too, was designed to be used inside the `flake.nix` file.
However, `flake.nix` is a repository's prime estate.
And so Paisano was optimized for keeping that estate as clean as possible and, at the same time, beeing a useful table of content even to a relative nix-layman.

While you _can_ use it to match the schema that Nix CLI expects, it also enables more flexibility as it is not specially optimized for any particular use case.

### flake-parts

`hercules-ci/flake-parts` is a component aggregator with a focus on a flake schema that is built into the Nix CLI tooling that makes use of the NixOS module system for composability and aggregation.

Paisano, in turn, is an importer with a focus on _code organization_; it still plugs well into a `flake.nix` file, but also preserves its index function by keeping it clean.
While you _can_ use it to match the schema that Nix CLI expects, it also enables more flexibility as it is not specially optimized for any particular use case.

To a lesser extent, Paisano is also a component aggregator for your flake outputs.
However, in that role, it gives you back the freedom to use the output schema that best fits your problem domain.

The core tenet of Flake Parts is domain specific interfaces for each use case.
Flake Parts implements and aggregates these interfaces based on the NixOS module system.

Paisano, in turn, focuses on code organization along high level code boundaries connected by generic interfaces.
The core tenet of Paisano remains Nix's original functional style.

Convergence towards the Flakes output schema is provided via the harvester family of utility functions (`winnow`, `harvest` & `pick`).
Depending on the domain schema, it can be a _lossy_ convergence, though, due the lesser expressivity of the flake output schema.

<details>
<summary>Example usage of harvester functions</summary>

```nix
{
  inputs = { /* snip */ };
  outputs = { std, self, ...}:
    growOn {
      /* snip */
    }
    {
      devShells = std.harvest self ["automation" "devshells"];
      packages = std.harvest self [["std" "cli"] ["std" "packages"]];
      templates = std.pick self ["presets" "templates"];
    };
}
```

</details>

### Devshell

Standard wraps `numtide/devshell` to improve the developer experience in the early parts of the SDLC via reproducible development shells.

## Comparison with other tools & frameworks

### My language build tool

Nix wraps language level tooling into a sandbox and cross-language build graph to ensure reproducibility.
Most languages are already covered.

### Bazel

Bazel is similar to Nix in that it creates cross-language build graphs.
However, it does not guarantee reproducibility.
Currently it has more advanced build caching strategies: a gap that the Nix community is very eager to close soon.

### My CI/CD

Any CI can leverage Paisano's Registry to discover work.
Implementations can either be native to the CI or provided via CI-specific wrappers, a strategy chosen, for example, by our reference implementation for GitHub Actions.
