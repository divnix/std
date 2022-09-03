> _This is an opinionated pattern._
>
> _It helps structure working together on microservices with `std`._

# The 4 Layers of Packaging

## The Problem

We have written an application and now we want to package and run it.
For its supply chain security benefits, we have been advised to employ reproducible and source-based distribution mechanisms.
We furthermore need an interoperability platform that is generic and versatile: a _configuration "lingua franca"_.
Our peers who write another application in another language should share that same approach.
Thereby, we avoid the negative external effects of DevOps silos on integrators and operators, alike.
Short: we make adoption of our application as easy as possible for our consumers.

## The Actors

_Note, that each actor persona can be exercised by one and the same person or a group of persons.
Although possible, and even frequently so, it doesn't imply that these roles are necessarily taken by distinct individuals._

### Developer

The Developer persona incrementally modifies the source code.
At times, such modification are relevant at the interface to the Operator persona.
One such example is when the app configuration is modified.
Another one, when important runtime characteristics are amended.

### Operator

The Operator persona brings the application to production.
She typically engages in further wrapping code or other artifact creation.
She also supervises and observes the running application across different environments.

### Release Manager

The Release Manager persona cuts releases at discrete points in time.
In doing so, she procures their artifacts for general (public) consumtion.
Any release is tied to a sufficiently high level of assurance of an artifact's desired properties.
For that purpose, she works with the Developer, Operator & QA personas along these 4 layers of packaging.

### QA

The QA persona establishes various levels of assurance of an artifact's desired properties.
Thereby, the observable artifacts can emanate from any layer of these 4 layers of packaging.
She informs the Developer, Operator and Release Manager personas about any found assurance levels.
She can do so through manual or automatic (CI) means.

## The Layers

```mermaid
flowchart TD
    packaging([Packaging])
    entrypoint([Entrypoint])
    image([OCI-Image])
    scheduler([Scheduler Chart])
    packaging --> entrypoint
    entrypoint --> image
    image --> scheduler

    click packaging href "#packaging-layer" "Jump to the packaging layer section"
    click entrypoint href "#entrypoint-layer" "Jump to the entrypoint layer section"
    click image href "#oci-image-layer" "Jump to the OCI image layer section"
    click scheduler href "#scheduler-chart-layer" "Jump to the scheduler chart layer section"
```

---

There is one very important factoring & interoperability rule about these layers:

_A domain concern of a higher layer **must not** bleed into previous layers._

Observing this very simple rule ensures long term interoperability and maintainability of the stack.
For example, not presuming a particular scheduler in the entrypoint gives contributors a chance to easily add another scheduler target without painful refactoring.

> _**Future Work:** depending on how you count, there may be actually a 5th layer: the **operator** layer. But we may cover this in a future version of this article in further detail. If you don't want to wait, you may have a conceptual look at the [Charmed Operator Framework][charmed-operator] and [Charmehub][charmhub]._

_Note, that it would be possible to further fold these interfaces and a Nix veteran might be inclined to do so.
But doing so would defeat the purpose of exposing well defined layered interfaces alongside role-boundaries, subject matter concepts for ease of communication and collaboration; as well as external artifact consumers._

### Packaging Layer

```yaml
Cell Block: (clades.installables "packages")
Location:  **/packages.nix          # or **/packages/
Actors:
 - Build Expert Panel, Nix- & language-specific
 - Release Manager
```

This Cell Block builds, unit-tests & packages the application via the appropriate [Nix primitives][nix-superpowers].
Each programming language has a different best practice approach to packaging.
Therfore, a fair ammount of domain knowledge between Nix and the language's build system is required.

The location of the actual build instructions are secondary.
At minimum, though, for transparency's and uniformity's sake, they are still proxied via this Cell Block.
So in the case that upstream already contains appropriate build instructions, the following indirection is perfectly valid (and necessary):

```nix
{ inputs, cell }: {
  app = inputs.upstream.packages.some-app;
}
```

Build instructions themselves should encompass executing unit tests.
Builds that fail unit tests should already be filtered out at this layer (i.e. "a build that fails unit tests is no build, at all").

A Release Manager may decide to provide these artifacts to the general public on tagged releases.

> **In a hurry?**
>
> Fetching binary artifacts and incorporating them at this layer as a temporary work-around for non-production enviornments is acceptable.

### Entrypoint Layer

```yaml
Cell Block: (clades.runnables "entrypoints")
Location:  **/entrypoints.nix       # or **/entrypoints/
Actors:
 - Developer
 - Operator
```

This Cell Block exclusively defines the runtime environment of the application via the entrypoint script.
The role of this script &mdash; customarily written in `bash` &mdash; serves as a concise and reified communication channel between Developers and Operators.
As such, Operators will find all the primariy configuration options re-encoded at a glance and in a well-known location.
In the other direction, Developers will find all the magic ad-hoc warpping that Operators had to engage in, in order to run the application on the target scheduler.

Through this communication channel, operators take reliably note of configuration drift, while Developers gain a valuable source of backlog to increase the operational robustness of the application.

Standard includes a [specific library function][entrypoint-lib] that establishes an implementation-site interface for entrypoints and their collaterals which significantly eases working on the following layers.

### OCI-Image Layer

```yaml
Cell Block: (clades.containers "oci-images")
Location:  **/oci-images.nix        # or **/oci-images/
Actors:
 - Operator
 - Release Manager
```

This layered packaging pattern promotes source-based distribution in principle.
Despite, in common operating scenarios, we require a security stop-gap separation.
This ensures very fundamentally that nothing is accidentially _built_ on the target (production) worker node, where it would cannibalize critical resources.

We chose OCI-Images as the binary distribution format.
It not only fits that purpose through the [OCI Distribution Specification][distribution-spec], but also collaterally procures interoperability for 3rd parties:
OCI images are the de-facto industry standard for deployment artifacts.

If the entrypoints have been created via the above mentioned [library function][entrypoint-lib], the creation of OCI images trivially reduces to:

```nix
{ inputs, cell }: {
  image-hard = cell.entrypoints.app.mkOCI "docker.io/my-image-hardened";
  image = cell.entrypoints.app.mkDebugOCI "docker.io/my-image";
}
```

Alternatively, any of the avaible Nix-based OCI generation mini-frameworks can be used;
[`nlewo/nix2container`][n2c] being the recommended one.
Hence, this mini-framework is internally used by the entrypoints library function.

A Release Manager may decide to provide these artifacts to the general public on tagged releases.

> **In a hurry?**
>
> Fetching published images and incorporating them at this layer as a temporary work-around for non-production enviornments is acceptable.

### Scheduler Chart Layer

```yaml
Cell Block: (clades.functions "<sched>Charts")
Location:  **/<sched>Charts.nix     # or **/<sched>Charts/
Actors:
 - Operator
 - Release Manager
```

The scheduler chart is not _yet_ mainfest data.
Rather, it is a function interface that commonly renders to such json-serializable manifest data.
These mainfests are then ingested and interpreted by the scheduler.

A fair amount of scheduler domain knowledge and familiarity with its scheduling options is required, especially
during creation.

These charts can then be processed further downstream (e.g. in Nix code) to specialize out the final manifests and environments.

Since these charts are the basis of various environments for development, staging and production, it is _highly_ recommended to keep their function interface extremely mininmal **and** stable.
This avoids the risk of inadvertely modifying production manifests (e.g. via a human error in the base charts) based on a development or staging requirement.
In these cases, it is _highly_ recommended to resort to data-oriented overlay mechanisms for ad-hoc modification.
A purpose-built tool to do so (called [`data-merge`][data-merge]) is already re-exported under `std.dmerge` for convenience.
Those modifications should only propagate into a chart interface after _stabilizing_ and after having successfully percolated through all existing environments first.

A Release Manager may decide to provide these artifacts to the general public on tagged releases.
For example: in the transpiled form of a widely used scheduler-specific config sharing format, such as [helm-charts][helm-charts].

> _**Future Work:** it might be a feasible task to extract a common base interface among different schedulers
> and thereby implement a base chart that we could simply specialize for each target schedulers (including `systemd`).
> But this may be subject of future research.
> Potentially, the above mentioned [Charmed Operator Framework][charmed-operator] even obsoletes that need a priori and in practical terms._

[charmed-operator]: https://juju.is/docs/olm
[charmhub]: https://charmhub.io/
[nix-superpowers]: ../explain/why-nix.md#nix-superpowers
[entrypoint-lib]: ../reference/std/lib/writeShellEntrypoint.md
[n2c]: https://github.com/nlewo/nix2container
[helm-charts]: https://helm.sh/docs/topics/charts/
[distribution-spec]: https://github.com/opencontainers/distribution-spec
[data-merge]: https://github.com/divnix/data-merge
