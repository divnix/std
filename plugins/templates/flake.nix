{
  description = "Standard plugin for creating templates";
  # inputs.std.url = "github.com:divnix/std?ref=main";
  inputs.std.url = "../..";
  outputs = { std, ... } @ inputs: std.grow { inherit inputs; cellsFrom = ./src; };
}
