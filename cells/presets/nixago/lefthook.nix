{
  commit-msg = {
    commands = {
      conform = {
        # allow WIP, fixup!/squash! commits locally
        run = ''
          [[ "$(head -n 1 {1})" =~ ^WIP(:.*)?$|^wip(:.*)?$|fixup\!.*|squash\!.* ]] ||
          conform enforce --commit-msg-file {1}'';
        skip = ["merge" "rebase"];
      };
    };
  };
  pre-commit = {
    commands = {
      treefmt = {
        run = "treefmt --fail-on-change {staged_files}";
        skip = ["merge" "rebase"];
      };
    };
  };
}
