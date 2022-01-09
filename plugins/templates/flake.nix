{
  description = "Standard plugin for creating templates";

  # inputs.std.url = "git+ssh://git@github.com/on-nix/std?ref=main";
  inputs.std.url = "../..";

  outputs = { std, ... } @ inputs:
    std.project {
      inherit inputs;
      outputsFrom = ./src;
    };
}
