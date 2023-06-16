function getUncachedDrvs {
  local -a uncached
  local drv
  drv=$1

  mapfile -t uncached < <(
    command nix-store --realise --dry-run "$drv" 2>&1 1>/dev/null \
    | command sed -nrf @extractor@
  )

  test ''${#uncached[@]} -eq 0 && return;

  if (
     command nix show-derivation ''${uncached[@]} 2> /dev/null \
     | command jq --exit-status \
     ' with_entries(
         select(.value|.env.preferLocalBuild != "1")
       ) | any
     ' 1> /dev/null
  ); then
    echo "$drv"
  fi
}

export -f getUncachedDrvs

command jq --raw-output \
  --from-file @filter@ \
  --arg uncachedDrvs "$(
    parallel -j0 getUncachedDrvs ::: "$(
       command jq --raw-output 'map(.targetDrv|strings)[]' <<< "$1"
    )"
  )" <<< "$1"

unset -f getUncachedDrvs
