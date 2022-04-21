# 1. Increase repo discoverability with a TUI

Date: 2022-04-20

## Status

accepted

## Context

In gerenal, the more a polyglot repository grows, the more folks need very contextual knowledge to
asses the old and still same question: "What's in it for me?" / WIIFM.

And once they find an answer to that question, already ensues the next: "And how do I make use of it?".

Finding an answer to these questions is regularly not trivial and hugely language specific.

The classic solution always has been: "Write a (boilerplate) readme.".

## Decision

Thanks to `nix`, we can largely outperform that classic solution.

So, we implement a TUI that is duely wired with the repository it represents.

It queries the `nix` for the necessary metadata including targets and
the target's actions.

It also detects well-placed readme files and presents them contextually on the CLI
to the user.

The user can then fuzzy search any desired taret, query its contextual help or choose
one of the actions for execution.

## Consequences

Not only in a polglot repository, the different stakeholders can now easily and naturally
interact ("speak") with the repository.

This has the potential of optimizing away a lot of very engrained media-breaks that today sometimes
render massive collaboration across a broad team increasingly friction-laden.
