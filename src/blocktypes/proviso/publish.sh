SKOPEO_INSPECT=${SKOPEO_INSPECT:-$(dirname "${BASH_SOURCE[0]}")/skopeo-inspect.sh}

function proviso() {
  local -n input=$1
  local -n output=$2

  local missing image
  local -a images filtered

  missing=$(mktemp)
  trap 'rm -f $missing' RETURN

  mapfile -t images < <(jq -r '.meta.images[0]|select(.!=null)' <<<"${input[@]}")

  echo "${images[@]}" |
    command xargs -n 1 -P 0 "$SKOPEO_INSPECT" "$missing"

  for in in "${input[@]}"; do
    image=$(jq -r '.meta.images[0]' <<<"$in")

    [[ $image == null ]] && continue

    if command grep "$image" "$missing" &>/dev/null; then
      filtered+=("$in")
    fi
  done

  output=$(command jq -cs '. += $p' --argjson p "$output" <<<"${filtered[@]}")
}
