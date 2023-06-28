# create the store path of
nix store add-path --name source .

# update the subflake lockfile to the (now existing) store path
# set lastModified to 1 because unknown issues in the GH action environment
(cd ./src/local && nix flake lock --update-input std && (
  jq '.nodes.std.locked.lastModified = 1' flake.lock > flake.lock.new && rm flake.lock && mv flake.lock.new flake.lock
) && git add -f flake.lock)
(cd ./src/tests && nix flake lock --update-input std && (
  jq '.nodes.std.locked.lastModified = 1' flake.lock > flake.lock.new && rm flake.lock && mv flake.lock.new flake.lock
) &&git add -f flake.lock)
# continue normally ...
