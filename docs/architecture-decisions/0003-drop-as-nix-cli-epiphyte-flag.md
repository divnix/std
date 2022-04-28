# 3. Drop `as-nix-cli-epiphyte` flag

Date: 2022-04-28

## Status

accepted

## Context

Currently, `std.grow` has a `as-nix-cli-epiphyte` flag to make the output scheme
compatible with the `nix` CLI output scheme.

However, part of the raison-d'etre of `std` are the deficiencies of the `nix` CLI
output scheme.

With the introduction of a TUI and soon a CLI equivalence, the need for matching
the `nix` CLI interface is diminishing.

For part of the target audience of `std`, however, the `nix` CLI interface is a
productivity sink and not really a good day to day companion.

Especially at the intersection of `nix` experts and non-nix experts, that particular
aspect might be neglected by experienced `nix` experts that come with different
priorities, habits and workflows.

## Decision

To cater the purpose of `std` to make this a productive Nix-related framework for
teams, we remove the `as-nix-cli-epiphyte` flag and thereby discourage the wide-spread
and general purpose use of the `nix` CLI.

If such interoperability is still needed, a layer of soil can bring back the necessary
adatper.

## Consequences

Nix experts that are making use of `std` outside of the above described context might
prefer to add back a nix cli adapter as a layer of soil. However, being experts and
knowing their needs, this is probably not a huge show stopper.
