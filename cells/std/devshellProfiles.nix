{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  nixpkgs = inputs.nixpkgs;

  inherit (import "${inputs.self}/deprecation.nix" inputs.nixpkgs) warnRemovedDevshellOptionAdr warnRemovedDevshellOptionDocs;
in {
  default = {config, ...}: let
    cfg = config.std;
  in {
    imports = [
      (nixpkgs.path + "/nixos/modules/misc/assertions.nix")
      (l.mkRemovedOptionModule ["std" "adr" "enable"] (warnRemovedDevshellOptionAdr "Hurry up!"))
      (l.mkRemovedOptionModule ["std" "docs" "enable"] (warnRemovedDevshellOptionDocs "Hurry up!"))
    ];
    config = {
      motd = ''

        {202}{bold}🔨 Welcome to ${config.name} 🔨{reset}

        {italic}To autocomplete 'std' in bash, zsh, oil: {202}source <(std _carapace){reset}
        {italic}More shells: https://rsteube.github.io/carapace/carapace/gen/hiddenSubcommand.html{reset}

        $(type -p menu &>/dev/null && menu)
      '';
      commands = [{package = cell.cli.default;}];
    };
  };
}
