# Standard Design and Architecture

At the time of writing, almost a year of exploratory and freestyle project history has passed.
Fortunately, it is not necessary for further understanding, so I'll spare you that.
This document, though, lays out the design, architecture and direction of Standard.

If the topics discussed herein are dear to you, please take it as an invitation to get involved.

This design document shall be stable and amendments go through a proper process of consideration.

## Overview

Standard is a collection of functionality and best practices (_"framework"_) to bootstrap and sustain the automatable sections of the Software Development Lifecycle (SDLC) _efficiently_ with the power of Nix and Flakes.
In particular, Standard is a _Horizontal\* Integration Framework_ which integrates _vertical\*_ tooling.

> <sub>We occasionally adapt concepts from non-technical contexts. This is one instance.</sub>
>
> _Vertical Tooling_ does one thing and does it well in a narrow scope (i.e "vertical").
>
> _Horizontal Tooling_ stitches vertical tooling together to a polished whole.

What is being integrated are the end-to-end automatable sections of the SDLC.
For these we curate a collection of functionality, tools and best practices.

An SDLCs _efficiency_ is characterized by two things.

Firstly, by adequate _lead time_ which is the amount of time it takes to set up an initial version of the software delivery pipeline.
It needs to be _adequate_ rather than _just fast_, as it takes place in the context of a team.
Rather than for speed, they need optimization for success.
For example, a process needs to be documented & explained and your team needs to be trained on it.
Standard encourages incremental adoption in order to leave enough space for these paramount activities.
If you're in a hurry and your team is onboard, though, you still can jumpstart its adoption.

Secondly, efficient SDLCs are characterized by short _cycle times_ which is the amount of time it takes for a designed feature to be shipped to production.
Along this journey, we encounter our scope (more on it below):

- aspects of the _development_ environment;
- the packaging pipeline that produces artifacts;
- and continuous processes integrating the application lifecycle.

Hence, the goal of Standard is to:

- Enable easy and incremental adoption
- Optimize the critical path that reduces your SDLC's cycle time.

Additionally, unlike similar projects, we harness the power of Nix & Flakes to ensure reproducibility.

## Goals

- _Complete_: Standard should cover the important use cases for setting up and running the automatable sections of the SDLC.
- _Optimized_: Standard should optimize both for the needs of the individual developers and the market success of the product.
- _Integrated_: Standard should provide the user with a satisfying integration experience across a well-curated assortment of tools and functionality.
- _Extensible_: Standard should account for the need to seamlessly modify, swap or extend its functionality when necessary.

Please defer to the [sales pitch](./PITCH.md), if you need more context.

## Ideals

While we aim to improve the SDLC by applying Nix and its ecoysystem's ingenuity to the problem, we also want to build bridges.
In order to bring the powers of store based reproducible packaging to colleagues and friends, we need to maneuver around the ecosystem's pitfalls:

- _Use nix only where it is best suited_ &mdash; a Nix maximalist approach may be an innate condition to some of us, but to build bridges we deeply recognize and value other perspectives and don't dismiss them as ignorance.
- _Disrupt where disruption is necessary_ &mdash; the Nix ecosystem has a fairly rigid set of principles and norms that we don't think always apply in every use case.
- _Look left, right, above and beyond_ &mdash; our end-to-end perspective commands us to actively seek and reach out to other projects and ecosystems to compose our value chain; there's no place for the "not invented here"-syndrome.

## Scope

These are big goals and ideals.
In the interest of practical advancements, we'll narrow down the scope in this section.

We can subdivide (not break up!) our process into roughly three regions with different shapes and characteristics:

- **Development Environment** roughly covers _code-to-commit_.
- **Packaging Pipeline** roughly covers _commit-to-distribution_.
- **Deployment and Beyond** roughly covers _distribution-to-next-rollout_.

We delegate:

- The **Development Environment** to a trusted project in the broader Nix Community employing community outreach to promote our cause and ensure it is at least not accidentally sabotaged.
- The **Deployment and Beyond** by cultivating outreach and dovetailing with initiatives of, among others, the Cloud Native ecosystem.

And we focus on:

- The **Packaging Pipeline**
- _Interfaces_ and _Integration_ with the other two

## Architecture

With clarity about Standard's general scope and direction, let's procede to get an overview over its architecture.

### Locating Standard in the SDLC

Where is Standard located in the big picture?

This graphic locates Standard across the SDLC & Application Lifecycle Management (ALM).

But not only that.
It also explains how automation in itself is implemented as _code_, just as the application itself.
Therefore, we make a distinction between:

- first order application code (L1); and
- above that, higher order supporting code as exemplified by L2 and L3.

> Glossary:
>
> _L2 & L3_ have no clearly defined meaning.
> They represent that we may observe multiple layers of higher order code when automating.
> Examples could be bash scripts, configuration data, platform utility code and more.

<div align="center"><img src="./artwork/sdlc.svg" width="900" /></div>

### Standard's Components and their Value Contribution

What is Standard made of? And how do its components contribute value?

On the left side of the graphic, we show how Standard, like an onion, is build in layers:

Center to Standard is [`divnix/paisano`](https://github.com/paisano-tui/core).
This flake (i.e. "Nix library") implements two main abstractions: Block Types and Cells.

_**Block Types**_ are not unlike Rust's traits or Golang's interfaces.
They are abstract definitions of artifact classes.
Those abstract classes implement _shared functionality_.

A few examples of artifact classes in our scope are: packages, containers, scripts and manifests, among others.
Examples of shared functionality are (a shared implementation of) _push_ on containers and (a shared implementation of) _build_ on packages.

_**Cells**_, in turn, organize your code into related units of functionality.
Hence, Cells are a code _orgnization principle_.

On top of Paisano's abstractions, Standard implements within its scope:

- a collection of Block Types; and
- a collection of library functionality organized in Cells.

On the right side of the graphic, we sketch an idea of how these components are put into service for the SDLC.

<div align="center"><img src="./artwork/components.svg" width="900" /></div>

### Paisano (Code Organization)

We already learned about Paisano's two main abstractions: Cells & Block Types.

Cells enable and encourage the user to cleanly organize their code into related units of functionality.
The concrete semantics of code layout are completely at her choosing.
For example, she could separate application tiers like frontend and backend into their own cells, each.
Or she could reflect the microservices architecture in the Cells.

Paisano has a first class concept of Cells.
By simply placing a folder in the repository, Paisano will pick it up.
In that regard, Paisano is an automated importer, that spares the user the need to setup and maintain boilerplate plumbing code.

Within a Cell, the user groups artifacts within Blocks of an appropriate Block Type.
When configuring Standard, she names her Blocks using Standard's Block Types so that Paisano's importer can pick them up, too.
By doing that, she also declares the repository's artifact type system to humans and machines.

Machines can make great use of that to interact with the artifact type system in multiple ways.
Paisano exports structured json-serializable data about a repository's _typed_ artifacts in its so-called "Paisano Registry".
A CLI or TUI, as is bundled with Standard, or even a web user interface can consume, represent and act upon that data.

And so can CI.

In fact, this is an innovation in the SDLC space:
We can devise an implementation of a CI which, by querying Paisano's Registry, autonomously discovers all work that needs to be done.
In order to demonstrate the value of this proposition, we made a reference implementation for GitHub Actions over at [`divnix/std-action`](https://github.com/divnix/std-action).
To our knowledge, this is the first and only "zero config" CI implementation based on the principles of artifact typing and code organization.
By using these principles rather than a rigid opinionated structure, it also remains highly flexible and adapts well to the user's preferences & needs.

In summary, all these organization and typing principles enable:

- easy refactoring of your repository's devops namespace;
- intuitive grouping of functionality that encourages well-defined internal boundaries,
  - allowing for keeping your automation code clean and maintainable;
- making use of Block Types and the shared library to implement the DRY principle;
- reasoning about the content of your repo through structured data,
  - and, thereby, facilitate interesting user interfaces, such as a CLI, TUI or even a UI,
  - as well as services like a (close to) zero config, self-updating CI;
- similar organizational principles help to lower the cost of context switching between different projects.

### Standard's Block Types (DevOps Type System)

As mentioned above, Standard exploits the Block Type abstraction to provide artifact types for the SDLC.
Within the semantics of each Block Type, we implement shared functionality.
This is designed to offer the user an optimized, audited implementation.
Alleviates the burden of devising "yet another" local implementation of otherwise well-understood generic functionality, such as, the building of a package or the pushing of a container image.

### Standard's Cells (Function Library)

Alongside the **Packaging Pipeline**, Standard provides a curated assortment of library functions and integrations that users can adopt.
While optional, an audited and community maintained function library and its corresponding documentation fulfills the promise of productivity, shared mental models and ease of adoption.

## Modularity & Virality Model

We aim to provide a public registry in which we index and aggregate additional Block Types and Cells from the Standard user community that are not maintained in-tree.
To boost its value, aggregate documentation will be part of that registry.
We need to decide on how to deeply integrate documentation concerns, such as structured docstrings & adjacent readmes, into the framework.
