_: marker: diff_output: summary: ''
  if [[ -v CI ]] && [[ -v BRANCH ]] && [[ -v OWNER_AND_REPO ]] && command -v gh > /dev/null ; then

    OWNER_REPO_NAME=$(gh repo view "$OWNER_AND_REPO" --json nameWithOwner --jq '.nameWithOwner')

    if ! gh pr view "$BRANCH" --repo "$OWNER_REPO_NAME" >/dev/null 2>&1; then
      exit 0
    fi

    # Proceed only if there is output
    if [[ -z "${diff_output}" ]]; then
      exit 0
    fi

    CENTRAL_COMMENT_HEADER="<!-- Unified Diff Comment -->"
    ENTRY_START_MARKER="<!-- Start Diff for ${marker} -->"
    ENTRY_END_MARKER="<!-- End Diff for ${marker} -->"

    # Use the provided summary
    DIFF_ENTRY=$(cat <<EOF

$ENTRY_START_MARKER
<details>
<summary>${summary}</summary>

\`\`\`diff
${diff_output}
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

      echo "Updating existing comment..."
      gh api --method PATCH "repos/$OWNER_REPO_NAME/issues/comments/$EXISTING_COMMENT_ID" -f body="$UPDATED_BODY" --jq '.html_url'

    else
      NEW_COMMENT=$(cat <<EOF
$CENTRAL_COMMENT_HEADER
## DiffPost

This PR includes the following diffs:
$DIFF_ENTRY
EOF
      )
      echo "Creating new comment..."
      gh pr comment "$PR_NUMBER" --repo "$OWNER_REPO_NAME" --body "$NEW_COMMENT"
    fi

    exit 0

  fi
''
