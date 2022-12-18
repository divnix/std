{
  inputs,
  cell,
}: {
  configData = {};
  output = ".github/settings.yml";
  format = "yaml";
  hook.mode = "copy"; # let the Github Settings action pick it up outside of devshell
}
