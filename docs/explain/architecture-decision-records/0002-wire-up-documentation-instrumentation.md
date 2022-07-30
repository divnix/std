# 2. Wire up documentation instrumentation

Date: 2022-04-20

## Status

superseded

Superseded by [4. Add Nixago Instrumentation](0004-add-nixago-instrumentation.md)

## Context

Documentation instrumentation is always necessary. But because there are so many options,
oftentimes it's not the first thing to do when kick-starting a project.

Either because fingers are eager to hack or because the myriad of options stalls efficient
decision making.

## Decision

In this context, we want to provide a default doc instrumentation setup, that, at the very
minimum is capable of rendering and hosting the ADRs.

Batteries included & (this time) not removable.

_You can have any color you like as long as it's black._

## Consequences

As a consequence, entering a devshell, and if no `book.toml` exists, a minimal layout will be
created.

The user is then expected to fill it with life according to the `mdbook` docs.
