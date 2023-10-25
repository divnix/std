# 4. Early select system for conceptual untangling

Date: 2022-04-01

## Status

accepted

## Context

> What is the issue that we're seeing that is motivating this decision or change?

<!-- write an answer to this question below -->

Building on the previous ADR, we saw why we hide `system` from plain sight.

In that ADR, we mention "select early and forget" as a strategy to scope the current system consistently across the project.

The current best practices for flakes postulate `system` as the second level selector of an output attribute.

For current flakes, type primes over system.

However, this design choice makes the lema "select early and forget" across multiple code-paths a pain to work with.

This handling is exacerbated by the distinction between "systemized" and "non-systemized" (e.g. `lib`) output attributes.

In the overall set of optimization goals of this framework, this distinction is of extraordinarily poor value, more so, that function
calls are memoized during a single evaluation, which renders the system selector computationally irrelevant where not used.

## Decision

> What is the change that we're proposing and/or doing?

<!-- write an answer to this question below -->

- Move the `system` selector from the second level to the first level.
- Apply the `system` selector regardless and without exception.

## Consequences

> What becomes easier or more difficult to do because of this change?

<!-- write an answer to this question below -->

The motto "select early and forget" makes various code-paths easier to reason about and maintain.

The Nix CLI completion won't respond gracefully to these changes.
However, the Nix CLI is explicitly _not_ a primary target of this framework.
The reason for this is that the use cases for the Nix CLI are somewhat skewed towards the packager use case, but in any case are (currently) not purpose built for the DevOps use case.

A simple patch to the Nix binary, can mitigate this for people whose muscle memory prefers the Nix CLI regardless.
If you've already got that level of muscle memory, its meandering scope is probably anyways not an issue for you anymore.
