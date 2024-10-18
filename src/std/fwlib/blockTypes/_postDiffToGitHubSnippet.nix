_: path: cmd: script: ''

  if [[ -v CI ]] && [[ -v BRANCH ]] && [[ -v OWNER_AND_REPO ]] && command -v gh > /dev/null ; then

    OWNER_REPO_NAME=$(gh repo view "$OWNER_AND_REPO" --json nameWithOwner --jq '.nameWithOwner')

    if ! gh pr view "$BRANCH" --repo "$OWNER_REPO_NAME" >/dev/null 2>&1; then
      exit 0
    fi

    set +e # diff exits 1 if diff existed
    DIFF_OUTPUT=$(${script})
    set -e

    if [[ -z "$DIFF_OUTPUT" ]]; then
      exit 0
    fi

    CENTRAL_COMMENT_HEADER="<!-- Unified Diff Comment -->"
    ENTRY_START_MARKER="<!-- Start Diff for ${path}:${cmd} -->"
    ENTRY_END_MARKER="<!-- End Diff for ${path}:${cmd} -->"

    DIFF_ENTRY=$(cat <<EOF

$ENTRY_START_MARKER
<details>
<summary>//${path}:${cmd}</summary>

\`\`\`diff
$DIFF_OUTPUT
\`\`\`

</details>
$ENTRY_END_MARKER
EOF
    )

    PR_NUMBER=$(gh pr view "$BRANCH" --repo "$OWNER_REPO_NAME" --json number --jq '.number')

    EXISTING_COMMENT_ID=$(gh api "repos/$OWNER_REPO_NAME/issues/$PR_NUMBER/comments?per_page=100" --jq ".[] | select(.body | contains(\"$CENTRAL_COMMENT_HEADER\")) | .id" | head -n 1)

    if [[ -n "$EXISTING_COMMENT_ID" ]]; then
      EXISTING_BODY=$(gh api "repos/$OWNER_REPO_NAME/issues/comments/$EXISTING_COMMENT_ID" --jq '.body')

      if echo "$EXISTING_BODY" | grep -q "$ENTRY_START_MARKER"; then
        UPDATED_BODY=$(echo "$EXISTING_BODY" | sed -e "\#$ENTRY_START_MARKER#,\#$ENTRY_END_MARKER#d")
      else
        UPDATED_BODY="$EXISTING_BODY"
      fi

      UPDATED_BODY="$UPDATED_BODY
$DIFF_ENTRY"

      echo "Make an edit post ..."
      gh api --method PATCH "repos/$OWNER_REPO_NAME/issues/comments/$EXISTING_COMMENT_ID" -f body="$UPDATED_BODY" --jq '.html_url'

    else
      NEW_COMMENT=$(cat <<EOF
$CENTRAL_COMMENT_HEADER
## DiffPost

This PR includes the following diffs:
$DIFF_ENTRY
EOF
      )
      echo "Make a first post ..."
      gh pr comment "$PR_NUMBER" --repo "$OWNER_REPO_NAME" --body "$NEW_COMMENT"
    fi

    exit 0

  fi
''
