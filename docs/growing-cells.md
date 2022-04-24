# Growing Cells

Growing cells can be done via two variants:

- `std.grow { cellsFrom = "..."; /* ... */ }`
- `std.growOn { cellsFrom = "..."; /* ... */ } # soil`

## `std.growOn {} # soil`

This eases talking and reasoning about a `std`ized repository, that also needs
some sort of adapters to work together better with external frameworks.

Typically, you'd arrange those adapters in numbered layers of soil, just
so that it's easier to conceptually reference them when talking / chatting.

It's a variadic function and takes an unlimited number of "soil layers".

```nix
{
  inputs.std.url = "github:divnix/std";

  outputs = {std, ...} @ inputs:
    std.growOn {
      inherit inputs;
      cellsFrom = ./cells;
    }
    # soil
    () # first layer
    () # second layer
    () # ... nth layer
    ;
}
```

These layers get recursively merged onto the output of `std.grow`.
