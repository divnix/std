# 2. Restrict the calling interface

Date: 2022-03-01

## Status

accepted

## Context

> What is the issue that we're seeing that is motivating this decision or change?

<!-- write an answer to this question below -->

The Nix Ecosystem has optimized for contributor efficiency at the expense of local code readibility and local reasoning.
Over time, the `callPackage` idiom was developed that destructures arbitrary attributes of an 80k _upstream_ attributeset provided by `nixpkgs`.
A complicating side condition is added, where overlays modify that original upstream packages set in arbitrary ways.
This is not a problem for people, who know nixpkgs by heart and it is not a problem for the author either.
It is a problem for the future code reader, Nix expert or less so, who needs to grasp the essence of "what's going on" under a productivity side condition.

Local reasoning is a tried and tested strategy to help mitigate those issues.

In a variant of this problem, we observe only somewhat convergent, but still largely diverging styles of passing arguments in general across the repository context.

## Decision

> What is the change that we're proposing and/or doing?

<!-- write an answer to this question below -->

Encourage local reasoning by always fully qualifing identifiers within the scope of a single file.

In order to do so, the entry level nix files of this framework have exactly one possible interface: `{inputs, cell}`.

`inputs` represent the global inputs, whereas `cell` keeps reference to the local context.
_A Cell is the first ordering priciple for "consistent collection of functionality"._

## Consequences

> What becomes easier or more difficult to do because of this change?

<!-- write an answer to this question below -->

This restricts up to the prescribed 3 layers of organization the notion of "how files can communicate with each other".

That inter-files-interface is the _only_ global context to really grasp, and it is structurally aligned across all Standard projects.

By virtue of this meta model of a global context and inter-file-communications, for a somewhat familiarized code reader the barriers to local reasoning are greatly reduced.

The two context references are well known (flake inputs & cell-local blocks) and easily discoverable.

For authors, this schema takes away any delay that might arise out of the consideration of how to best structure that inter-file-communication schema.

Out of experience, a significant and low value (and ad-hoc) design process can be leap-frogged via this guidance.
