{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  nixpkgs = inputs.nixpkgs;
in {
  default = {config, ...}: let
    cfg = config.std;
  in {
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
