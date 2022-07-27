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
    imports = [
      (nixpkgs.path + "/nixos/modules/misc/assertions.nix")
      (l.mkRemovedOptionModule ["std" "adr" "enable"] ''
        The std.adr.enable option has been removed from the std shell.
        Please look for something like "adr.enable = false" and drop it.
      '')
      (l.mkRemovedOptionModule ["std" "docs" "enable"] ''
        The std.docs.enable option has been removed from the std shell.
        Please look for something like "docs.enable = false" and drop it.
      '')
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
