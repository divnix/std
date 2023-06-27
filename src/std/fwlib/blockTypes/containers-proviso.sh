declare action="$1"
declare image

eval "$(jq -r '@sh "image=\(.meta.image)"' <<< "$action" )"

if command skopeo inspect --insecure-policy "docker://$image" &>/dev/null; then
  echo 1
fi

echo 0
