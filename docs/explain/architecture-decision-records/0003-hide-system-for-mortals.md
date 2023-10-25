# 3. Hide system for mortals

Date: 2022-04-01

## Status

accepted

## Context

> What is the issue that we're seeing that is motivating this decision or change?

<!-- write an answer to this question below -->

In the context of DevOps (Standard is a DevOps framework), cross compilation is a significatly lesser concern, than what it is for packagers.

The pervasive use of `system` in the current Nix (and foremost Flakes) Ecosystem is an optimization (and in part education) choice for these packagers.

However, in the context of DevOps, while not being irrelevant, it accounts for a fair share of distraction potential.

This ultimately diminishes code-readibility and reasoning; and consequentially adoption. Especially in those code paths, where `system` is a secondary concern.

## Decision

> What is the change that we're proposing and/or doing?

<!-- write an answer to this question below -->

De-systemize everything to the "current" system and effectively hiding the explict manipulation from plain sight in most cases.

An attribute set, that differentiates for systems on any given level of its tree, is `deSystemized`.

This means that all child attributes of the "current" system are lifted onto the "system"-level as siblings to the system attributes.

That also means, if explicit reference to `system` is necessary, it is still there among the siblings.

The "current" system is brought into scope automatically, however.

What "current" means, is an early selector ("select early and forget"), usually determined by the user's operating system.

## Consequences

> What becomes easier or more difficult to do because of this change?

<!-- write an answer to this question below -->

The explicit handling of `system` in foreign contexts, where `system` is not a primary concern is largely eliminated.

This makes using this framework a little easier for everybody, including packaging experts.

Since `nixpkgs`, itself, exposes `nixpkgs.system` and packaging without `nixpkgs` is hardly imaginably, power-users still enjoy easy access to the "current" system, in case it's needed.
