# 1. Adopt semi-conventional file locations

Date: 2022-03-01

## Status

accepted

## Context

> What is the issue that we're seeing that is motivating this decision or change?

<!-- write an answer to this question below -->

Repository navigation is among the first activities to build a mental model of any given repository.
The Nix Ecosystem has come up with some weak conventions: these are variations that are mainly informed by the `nixpkgs` repository, itself.
Despite that, users find it difficult to quickly "wrap their head" around a new project.
This is often times a result of an organically grown file organization that has trouble keeping up with growing project semantics.
As a result, onboading onto a "new" nix project even within the same organizational context, sometimes can be a very frustrating and time-consuming activity.

## Decision

> What is the change that we're proposing and/or doing?

<!-- write an answer to this question below -->

A semi-conventional folder structure shall be adopted.

That folder structure shall have an abstract organization concept.

At the same time, it shall leave the user maximum freedom of semantics and naming.

Hence, 3 levels of organization are adopted.
These levels correspond to the abstract organizational concepts of:

- consistent collection of functionality ("what makes sense to group together?")
- repository output type ("what types of gitops artifacts are produced?")
- named outputs ("what are the actual outputs?")

## Consequences

> What becomes easier or more difficult to do because of this change?

<!-- write an answer to this question below -->

With this design and despite complete freedom of concrete semantics, a prototypical mental model can be reused across different projects.

That same prototypical mental model also speeds up scaffolding of new content and code.

At the expense of nested folders, it may still be further expanded, if additional organization is required.
All the while that the primary meta-information about a project is properly communicated through these first three levels via the file system api, itself (think `ls` / `rg` / `fd`).

On the other hand, this rigidity is sometimes overkill and users may resort to filler names such as "`default`", because a given semantic only produces singletons.
This is acceptable, however, because this parallellity in addressing even these singleton values trades for very easy expansion or refactoring, as the meta-models of code organization already align.
