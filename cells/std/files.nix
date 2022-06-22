{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  example = nixpkgs.writeText "explore" "example";
}
