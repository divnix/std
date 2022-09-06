# 6. Avoid fix-point logic, such as overlays

Date: 2022-05-01

## Status

accepted

## Context

> What is the issue that we're seeing that is motivating this decision or change?

<!-- write an answer to this question below -->

Fix point logic is marvelously magic and also very practical.
A lot of people love the concept of `nixpkgs`'s `overlays`.

However, we've all been suckers in the early days, and fix point logic wasn't probably one of the concepts that we grasped intuitivly and right at the beginning of our Nix journey.

The concept of recursivity all in itself is already demanding to reason about, where the concept of recourse-until-not-more-possible is even more mind-boggling.

Fix points are also clear instances of overloading global context.

And global context is a double edged sword between high-productivity for that one who has a good mental model of it and nightmare for that one who has to resort to local reasoning.

## Decision

> What is the change that we're proposing and/or doing?

<!-- write an answer to this question below -->

In the interest of balancing productivity (for the veteran) and ease-of-onboarding (for the novice), we do not implement a prime support for fix-point logic, such as `overlays` at the framework level.

## Consequences

> What becomes easier or more difficult to do because of this change?

<!-- write an answer to this question below -->

Users who depend on it, need to scope its use to a particular Cell Block.
For the Nix package collection, users can do, for example: `nixpkgs.appendOverlays [ /* ... */ ]`.
There is a small penalty in evaluating `nixpkgs` a second time, since every moving of the fix point retriggers a complete evalutation.
But since this decision is made in the interest of _balancing_ enacting trade-offs, this appears to be cost-effective in accordance with the overall optimization goals of Standard.
