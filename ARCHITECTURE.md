# Standard Design and Architecture

At the time of writing, almost a year of exploratory and freestyle project history has past.
Fortunately, it is not necessary for further understanding, so I'll spare you that.
This document, though, lays out the design, architecture and direction of Standard.

If the topics discussed herein are dear to you, please take it as an invitation to get involved.

This design document can only be altered through an RFC process.

## Overview

Standard is a _kitchen sink_ to bootstrap and sustain an _efficient_ Software Delivery Lifecycle (SDLC) with the power of Nix and Flakes.
_Kitchen sink_, here, is a colloquial word for _Horizontal Integration Framework_ which integrates _vertical_ tooling, that is designed around the linux philosophy of doing one thing and to it well.
The integration target, thereby, is the _efficient_ SDLC end-to-end process for which we offer suitable and well-integrated tools and best practices.
An _efficient_ SDLC is characterized by two things.
Firstly, an adequate _lead time_ which is the amount of time it takes to set up an initial version of the software delivery pipeline.
It needs to be "adequate" rather than "just fast", because it takes place in the context of a team and thus encompasses learning and onboarding activities.
Rather than optimizing for speed, these need optimization for success, above all.k
Secondly, an efficient SDLC is characterized by short _cycle times_ which is the amount of time it takes for a commit to be shipped to a production environment.
Along this journey, we encounter aspects of the development, or in the broader sense, the _contribution_ environment.
We also encounter the packaging pipeline that produces our distributable artifacts.
We encounter Continuous Building & Integration, Continuous Deployment as well as Continuous Observability and Discovery.
The goal of Standard is to optimize the critical path along this process to achieve superior _cycle times_ through the powers of Nix and Flakes when compared to any other similar framework that doesn't recognize the intrinsic value of _reproducability_.

## Scope

The SDLC end-to-end process can be subdivided in roughly three process regions with different overall shapes and characteristics.
That being said, it is important to note, that the shapeshifting nature across these process regions is by no means a valid justification to _break up_ the end-to-end perspective along these not-actual-boundaries.
The process ownership of this process is fundamentally end-to-end and any attempts at optimization needs to honor these natural end-to-end boundaries.

The stipulated process regions are:

- **Contribution Environment** which roughly covers _code-to-commit_.
- **Packaging Pipeline** which roughly covers _commit-to-distribution_. It is typically set up once and then orchestrated by a CI control loop.
- **Continuous 'X' within the Application Lifecycle Management** which roughly covers _distribution-to-next-rollout_.

While Standard is fundamentally concerned with optimizing across the end-to-end process, we also limit the scope inside this project repository to its core value proposition and where we cannot leverage other ecosystem projects.
Therefor, we opt to delegate the **Contribution Environment** to a trusted project with an appropriate scope in the broader Nix Community, while employing community outreach to try to ensure our optimization targets are met or at least not accidentally sabotaged.
On the other hand, we opt to delegate **Continuous 'X' within the Application Lifecycle Management** by dovetailing with more appropriate initiatives of adjacent ecosystems, such as for example [OAM](https://OAM.dev), which has developed an interesting model to reflect role boundaries naturally in their code interfaces.

## Ideals

The project is rooted deeply inside the Nix Ecosystem, but it strives to become a portal to make the powers of a store based reproducible packaging system readily available and palatable to colleagues and friends.

- _Nix where nix due_ &mdash; a Nix maximalist approach may be an innate condition to some of us, but trying to be a portal we deeply recognize and value other more profane perspectives and don't dismiss them as ignorance.
- _Disrupt where disruption is necessary_ &mdash; to our chagrin, the Nix ecosystem is quite a monotheistic silo. Therefore, we don't shy away from deviating from its widely accepted norms and standards when we feel that deviation has a greater chance at furthering the ideas of being a portal.
- _Look left, right, above and beyond_ &mdash; our end-to-end perspective commands us to actively seek and reach out to other projects and ecosystems to compose the best possible value chain.

## Goals

- _Complete_: Standard should make a complete offer for setting up and running the SDLC.
- _Optimized_: Standard should optimize for agent ("make your day-to-day life easier") and principle ("quick time to market"), alike.
- _Integrated_: Standard should provide the best possible integration experience across a well-curated assortment of verticals.

## Architecture

### Code Organization

Standard is build around a balanced model of code organization that promotes transparency, the ability to refactor and productivity.
This code organization is provided by a so-called "Importer Library" housed as an independently useful component under [`divnix/paisano`](https://github.com/divnix/paisano).

It features three principles:

- Three folder levels with predefined semantics
- A single function interface common to all its components
- Typed outputs (which is a novelty compared to Flakes)

The first principle helps you to cut off at a sane level of structure.
Neither too flat, which would make your collection hard to reason about or orderly extend.
Nor too nested, which ends up being an over engineered structure.

The second principle allows for easy organization and refactoring of your global namespace.
From the perspective of one component, all external accessor interfaces are unified, which makes semantic reorganization trivial.
On the flip side, by choosing high level and, above all, stable accessors, productivity may increase.

The third principle allows for keeping code DRY.
There are a finite amount of artifact categories of relevance across the SDLC, such as binary packages or OCI images, among others.
The `paisano` concept of so called Block Types describes these artifact and outputs types in a generic manner and attaches well-known semantics to their handling.

The first two principles combined, also yield collateral benefits when context switching between two standardized benefits, by lowering the amount of relearning effort required for each context switch as the fundamental organizational principles are stable across projects.
The last principle opens up a realm of possibilities from user interfaces to pipeline automations that we pretend to exploit further down.

### Function Library

Alongside the **Packaging Pipeline**, and by dogfooding its code organization principles, Standard provides a curated assortment of library functions and integrations that users are encouraged to adopt in accordance with their concrete use case for productivity and to build on the shoulders of the entire Standard community.
Some library functions and integrations may be assorted outside of these organizational principles as otherwise unspecial top level shorthands.

### Block Type Library

As mentioned in the context of `paisano` above, Standard exploits the Block Type concept with a focus on providing enriched output types for the SDLC & ALM.

For example, it would be redundant in Standard to codify how to build and upload a container image by hand, since the container output type is already fully aware in a highly optimized fashion of these semantics.
As another example, it would be redundant to encode deployment semantics of a terraform deployment declaration, since a (future) terraform type can be made fully aware in a highly optimized fashion (i.e. securely store state) of the required semantics.
