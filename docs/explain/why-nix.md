# Why `nix`?

A lot of people write a lot of confusing stuff about nix.

So here, we'll try to break it down, instead.

## `nix` is "`json` on steroids"

In configuration management, you have a choice: data vs. language.

On stackoverflow, you'll be tought the "data" stance, because it's simple.

And all of a sudden you hit reality. Outside of a "lab" environment, you suddenly
need to manage a varying degree of complexity.

So you need configuration combinators, or in other words a full blown language
to efficiently render your configurations.

There are a couple of options, that you'll recognize if you've gotten serious about
the configuration challange, like:

- [`dhall`][dhall]
- [`cue`][cue]
- [`jsonnet`][jsonnet]
- [`nickel`][nickel]

And there is [`nix`][nix], the language. In most aspects, it isn't hugely distinct from the others,
but it has superpowers. Read on!

## `nix`' superpowers

You know the concept of string interpolation.

Every time `nix` interpolates an identifier, there is something that
you don't immediatly see: it keeps a so called "string context" right
at the site of interpolation. That string context holds a directed acyclic
graph of all the dependencies that are required to make that string.

"Well, it's just a string; what on earth should I need to make a string?", you may say.

There is a special category of strings, so called "Nix store paths"
(strings that start with `/nix/store/...`). These store paths represent
build artifacts that are content adressed ahead-of-time through
the inputs of an otherwise pure build function, called [`derivation`][derivations].

When you finally reify (i.e. "build") your string interpolation, then all these Nix store
paths get build as well.

This might be a bit of a mind-boggling angle, but after a while, you may realize:

- Nix is a massive build pipeline that tracks all things to their source.
- In their capacity as _pure_ build functions, [`derviation`s][derivations] build _reproducibly_.
- Reproducible builds are the future of software supply chain security, among other things.
- You'll start asking: "who the heck invented all that insecure nonsense of opaque binary registries?
  Shouldn't have those smart people have known better?"
- And from this realization, there's no coming back.
- And you'll have joined the [European Union][ngi], [banks][mercury] and [blockchain companies][cardano-world] who also realized:
  we need to fix our utterly broken and insecure build systems!
- By that time, you'll have already assimilated the legendary [Ken Thompson's "Reflections on Trusting Trust"][trusting-trust].

[dhall]: https://dhall-lang.org/
[cue]: https://cuelang.org/
[jsonnet]: https://jsonnet.org/
[nickel]: https://nickel-lang.org/
[nix]: https://nixos.org/
[derivations]: https://nixos.org/manual/nix/stable/expressions/derivations.html
[trusting-trust]: http://users.ece.cmu.edu/~ganger/712.fall02/papers/p761-thompson.pdf
[ngi]: https://discourse.nixos.org/t/nixos-foundation-participating-in-eus-next-generation-internet-initiative/2011
[mercury]: https://discourse.nixos.org/t/mercury-bank-nix-engineers/13784
[cardano-world]: https://github.com/input-output-hk/cardano-world
