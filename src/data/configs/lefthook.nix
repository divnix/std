let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) lib;
in {
  data = {
    commit-msg = {
      commands = {
        conform = {
          # allow WIP, fixup!/squash! commits locally
          run = ''
            [[ "$(head -n 1 {1})" =~ ^WIP(:.*)?$|^wip(:.*)?$|fixup\!.*|squash\!.* ]] ||
            ${lib.getExe nixpkgs.conform} enforce --commit-msg-file {1}'';
          skip = ["merge" "rebase"];
        };
      };
    };
    pre-commit = {
      commands = {
        treefmt = {
          run = "${lib.getExe nixpkgs.treefmt} --fail-on-change {staged_files}";
          skip = ["merge" "rebase"];
        };
      };
    };
  };
}
