{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
  std-gh-action-discover = "divnix/std-action/discover@main";
  std-gh-action-run = "divnix/std-action/run@main";
in {
  configData = {
    name = "Standard CI";
    on = {};
    permissions.contents = "read";
    jobs = {
      discover = {
        outputs = {
          hits = "\${{ steps.discovery.outputs.hits }}";
          nix_conf = "\${{ steps.discovery.outputs.nix_conf }}";
        };
        runs-on = "ubuntu-latest";
        concurrency.group = "\${{ github.workflow }}";
        steps = [
          {
            name = "Standard CI Target Discovery";
            uses = std-gh-action-discover;
            id = "discovery";
          }
        ];
      };
    };
  };
  format = "yaml";
  output = ".github/workflows/ci.yaml";
  hook.mode = "copy";
  apply = d: let
    mkJob = {
      block,
      action,
    }: {
      "${action}-${block}" = {
        needs = ["discover"];
        strategy.matrix.target = "\${{ fromJSON(needs.discover.outputs.hits).${block}.${action} }}";
        name = "\${{ matrix.target.cell }} - \${{ matrix.target.name }}";
        runs-on = "ubuntu-latest";
        steps = [
          {
            uses = std-gh-action-run;
            "with" = {
              extra_nix_config = "\${{ needs.discover.outputs.nix_conf }}";
              json = "\${{ toJSON(matrix.target) }}";
            };
          }
        ];
      };
    };
  in
    (l.removeAttrs d ["targets"])
    // {
      jobs =
        d.jobs
        // (l.foldl' l.recursiveUpdate {} (map mkJob d.targets));
    };
}
