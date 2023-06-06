{
  inputs,
  scope,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
in
  inputs.cells.lib.dev.mkNixago {
    data = {};
    format = "yaml";
    output = ".conform.yaml";
    packages = [nixpkgs.conform];
    apply = d: {
      policies =
        []
        ++ (l.optional (d ? commit) {
          type = "commit";
          spec =
            d.commit
            // l.optionalAttrs (d ? cells) {
              conventional =
                d.commit.conventional
                // {
                  scopes =
                    d.commit.conventional.scopes
                    ++ (l.subtractLists l.systems.doubles.all (l.attrNames d.cells));
                };
            };
        })
        ++ (l.optional (d ? license) {
          type = "license";
          spec = d.license;
        });
    };
  }
