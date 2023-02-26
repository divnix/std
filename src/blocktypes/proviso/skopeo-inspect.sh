#!/usr/bin/env bash
if ! command skopeo inspect --insecure-policy "docker://$2" &>/dev/null; then
  echo "$2" >>"$1"
fi
