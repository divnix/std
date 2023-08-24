_: cmd: script: ''
  # GitHub case

  if [[ -v CI ]] && [[ -v BRANCH ]] && [[ -v OWNER_AND_REPO ]] && command gh > /dev/null ; then

  set +e # diff exits 1 if diff existed

  read -r -d "" DIFFSTREAM <<DIFF
  ## DiffPost

  This PR would generate the following \`${cmd}\` diff:

  <details><summary>Preview</summary>

  \`\`\`diff
  $(${script})
  \`\`\`

  </details>
  DIFF

  set -e # we're past the invocation of diff

  if ! gh pr --repo "$OWNER_AND_REPO" comment "$BRANCH" --edit-last -b "$DIFFSTREAM"; then
    echo "Make a first post ..."
    gh pr --repo "$OWNER_AND_REPO" comment "$BRANCH" -b "$DIFFSTREAM"
  fi

  exit 0

  fi
''
