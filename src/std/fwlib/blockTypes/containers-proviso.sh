function scopeo_inspect() {
  local image
  image="$1"
  if command skopeo inspect --insecure-policy "docker://$image" &>/dev/null; then
    echo "$image"
  fi
}
export -f scopeo_inspect
command jq --raw-output \
  --from-file "@filter@" \
  --arg available "$(
    parallel -j0 scopeo_inspect ::: "$(
       command jq --raw-output 'map(.meta.image|strings)[]' <<< "$1"
    )"
  )" <<< "$1"
unset -f scopeo_inspect
unset images
