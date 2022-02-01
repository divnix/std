{ inputs
, system
}:
let
  std = inputs.self.cli.${ system.host.system }.std;
  nixpkgs = inputs.nixpkgs;
in
{
  "" =
    { config
    , ...
    }:
    {
      options.cellsFrom =
        nixpkgs.lib.mkOption
          {
            type = nixpkgs.lib.types.str;
            default = "./cells";
            defaultText = "./cells";
            description = "folder relative to the repo root at which to find the cells (required env variable for std cli)";
          };
      config = {
        env = [
          {
            name = "CELL_ROOT";
            eval = "$PRJ_ROOT/${config.cellsFrom}";
          }
        ];
        commands = [ { package = std; } ];
      };
    };
}
