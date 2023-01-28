# Comparing Standard to X

_Where appropriate, we compare with `divnix/paisano`, instead_.

## Comparison with tools in the Nix ecosystem

### flake-utils

`numtide/flake-utils` is a small & lightweight utility with a focus on generating flake file _outputs_ in accordance with the packaging use case built-in into the Nix CLI tooling.

Paisano, in turn, is an importer with a focus on _code organization_; it still plugs well into a `flake.nix` file, but also preserves its index function by keeping it clean.
While you _can_ use it to match the schema that Nix CLI expects, it also enables more flexibility as it is not specially optimized for the Nix _package manager use case_.

### flake-parts

`hercules-ci/flake-parts` is a component aggregator with a focus on a flake schema that is built-in into the Nix CLI tooling that makes use of the NixOS module system for composability and aggregation.

Paisano, in turn, is an importer with a focus on _code organization_; it still plugs well into a `flake.nix` file, but also preserves its index function by keeping it clean.
While you _can_ use it to match the schema that Nix CLI expects, it also enables more flexibility as it is not specially optimized for the Nix _package manager use case_.

To a lesser extent, Paisano is also a component aggregator for your flake outputs.
However, in that role, it gives you back the freedom to use the output schema that best fits your problem domain.

Convergence towards the Flakes output schema is provided via the harvester family of functions (`winnow`, `harvest` & `pick`).
Depending on the domain schema, it can be a _lossy_ convergence due the lesser expressivity of the flake output schema.

Flake Parts aggregates bespoke use-case specific interfaces implemented in the module system DSL.
Paisano, in turn, focuses on code organization along high level code boundaries connected by generic interfaces.

The core tenet of Flake Parts is bespoke module system DSL interfaces for each use case.

The core tenet of Paisano remains Nix' original functional style.

### Devshell

Standard wraps `numtide/devshell` to improve the developer experience in the early parts of the SDLC via reproducible development shells.

## Comparison with other tools & frameworks

### My language build tool

Nix wraps language level tooling into a sandbox and cross-language build graph to ensure reproducibility.
Most languages are already covered.

### Bazel

Bazel is similar to Nix in that it creates cross-language build graphs.
However, it doesn't not guarantee reproducibility.
Currently it has more advanced build caching strategies: a gap that the Nix community is very eager to close soon.

### My CI/CD

Any CI can leverage Paisano's Registry to discover work.
Implementations can either be native to the CI or provided via CI-specific wrappers, a strategy chosen for example by our reference implementation for GitHub Actions.
