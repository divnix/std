declare action="$1"
declare image

eval "$(jq -r '@sh "image=\(.meta.image)"' <<< "$action" )"

if command skopeo inspect --insecure-policy "docker://$image" &>/dev/null; then
  exit 1
fi

exit 0
