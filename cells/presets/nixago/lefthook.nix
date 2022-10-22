{
  commit-msg = {
    commands = {
      conform = {
        run = "conform enforce --commit-msg-file {1}";
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
