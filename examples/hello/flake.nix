{
  # inputs.std.url = "git+ssh://git@github.com/on-nix/std?ref=main";
  inputs.std.url = "../..";

  outputs = { std, ... } @ inputs:
    std.project {
      inherit inputs;
      outputsFrom = ./src;
      systems = [
        {
          build = "x86_64-unknown-linux-gnu";
          host = "x86_64-unknown-linux-gnu";
        }
        {
          build = "x86_64-unknown-linux-gnu";
          host = "i686-w64-mingw32";
        }
      ];
    };
}
