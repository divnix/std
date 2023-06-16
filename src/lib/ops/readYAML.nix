{
  inputs,
  cell,
}: let
  inherit (builtins) fromJSON;
  inherit (inputs.nixpkgs) runCommand yq-go;
  inherit (inputs.nixpkgs.lib) readFile;
in
  # Read a YAML file into a Nix datatype using IFD.
  # Similar to:
  # > builtins.fromJSON (builtins.readFile ./somefile)
  # but takes an input file in YAML instead of JSON.
  #
  # Type:
  #   Path -> a :: Nix
  path: let
    jsonOutputDrv =
      runCommand "from-yaml"
      {nativeBuildInputs = [yq-go];}
      "yq -o=json \"${path}\" > \"$out\"";
  in
    fromJSON (readFile jsonOutputDrv)
