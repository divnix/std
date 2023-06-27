declare action="$1"
declare targetDrv

eval "$(jq -r '@sh "targetDrv=\(.targetDrv)"' <<< "$action" )"

mapfile -t uncached < <(
  command nix-store --realise --dry-run "$targetDrv" 2>&1 1>/dev/null \
  | command sed -nr '
    # If the line "will be built" is matched ...
    /will be built/ {
        # Create a label to iterate over dervivations
        :b
    
        # Get next line from input into pattern buffer
        # (Overwrite the pattern buffer)
        n
    
        # If the line matches a nix store path ...
        /\/nix/ {
    
            # ... strip leading whitespaces and print it
            s/\s*(.*)/\1/p
    
            # and go on with the next line (step back to b)     
            bb
        }
    }
  '
)

if [[ ${#uncached[@]} -eq 0 ]];
then
  exit 1
fi

if ! (
  command nix show-derivation ''${uncached[@]} 2> /dev/null \
  | command jq --exit-status \
  ' with_entries(
      select(.value|.env.preferLocalBuild != "1")
    ) | any
  ' 1> /dev/null
); then
  exit 1
fi

exit 0
