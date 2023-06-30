let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.std.lib) dev;

  renderFile = (import ./action/template.nix) lib args;
in {
  ci = dev.mkNixago {
    output = ".github/workflows/ci-cd.yaml";
    data = renderFile {
      default_branch = "main";
      platform = "aws"; # gc, azure, digitalocean
      # set up with nixbuild.net to speed up builds
      withNixbuild = false;
      # use with persistent discovery; needs to be setup separately
      withPersistentDiscovery = false;
    };
  };
}
