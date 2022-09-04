{
  fmt = {
    description = "Formats all changed source files";
    steps = [
      "treefmt $(git diff --name-only --cached)"
    ];
  };
}
