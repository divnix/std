_: path: cmd: script: ''
  # GitHub case

  if [[ -v CI ]] && [[ -v BRANCH ]] && [[ -v OWNER_AND_REPO ]] && command gh > /dev/null ; then

  gh pr view "$BRANCH" >/dev/null || exit 0

  set +e # diff exits 1 if diff existed

  read -r -d "" DIFFSTREAM <<DIFF
  ## DiffPost

  This PR would generate the following \`${cmd}\` diff:

  <details><summary>${path}</summary>

  \`\`\`diff
  $(${script})
  \`\`\`

  </details>
  DIFF

  set -e # we're past the invocation of diff

  gh pr --repo "$OWNER_AND_REPO" comment "$BRANCH" -b "$DIFFSTREAM"
  
  exit 0

  fi
''
