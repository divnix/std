# update the subflake lockfile using git+file:// override
# this avoids the self-referencing issue with Nix 2.18+
(cd ./src/local && nix flake lock --override-input std git+file://$(pwd)/../.. && git add -f flake.lock)
(cd ./src/tests && nix flake lock --override-input std git+file://$(pwd)/../.. && git add -f flake.lock)
# continue normally ...
