# 4. Add Nixago Instrumentation

Date: 2022-07-29

## Status

accepted

Supersedes [2. Wire up documentation instrumentation](0002-wire-up-documentation-instrumentation.md)

## Context

The current implementation of mdbook instrumentation and adrgen instrumentation is brittle and ad-hoc.
Furthermore, the making these two "special" is a contentious decision.

Adjacently, oftentimes, there are other "repo dotfiles" that we want to somehow centrally manage (and
auto-update), instead of copy pasting them for the n-th time.

Recently, the Nixago project has seen the face of the earth which deals precisely with repo dotfile
templating and linking/copying.

## Decision

Implement a first class integreation with Nixago and add the appropriate glue-code to work seamlessly
together with Devshells.

Ship some generic Nixago Pebbles as part of the `std` Celle.

## Consequences

- mdbook / adgen dotfile templating is no more "special"
- user can make use of this instrumentation to template _any_ repo dotfile
- user can reuse the shipped Nixago Pebbles and take inspiration from our dogfooding
