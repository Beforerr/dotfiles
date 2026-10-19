merge-dependabot:
    #!/bin/bash
    gh pr list --state open --author "app/dependabot" --json number --jq '.[].number' \
    | xargs -I {} gh pr merge {} --squash --delete-branch 

auto-merge:
    #!/bin/bash
    set -e

    # Get latest PR number
    PR_NUMBER=$(gh pr list --state open --limit 1 --json number --jq '.[0].number')
    [ -z "$PR_NUMBER" ] && { echo "No open PRs found"; exit 0; }

    echo "Checking PR #$PR_NUMBER status..."
    sleep 8
    # Check if all checks have passed (retry up to 3 times if still running)
    for attempt in 1 2 3; do
        echo "Attempt $attempt/3..."
        CHECK_STATUS=$(gh pr checks $PR_NUMBER --json state --jq '.[] | select(.state != "SUCCESS" and .state != "SKIPPED") | .state' | wc -l)

        [ "$CHECK_STATUS" -eq 0 ] && break

        if [ "$attempt" -eq 3 ]; then
            echo "Checks are still running or failed after 3 attempts. Cannot merge."
            gh pr checks $PR_NUMBER
            exit 1
        fi

        sleep_time=$((60 * (2 ** attempt)))
        echo "Checks still running. Waiting $sleep_time seconds before retry..."
        sleep $sleep_time
    done

    echo "All checks passed."
    just --justfile {{ justfile() }} merge $PR_NUMBER

# method: squash|rebase|merge. Default rebase when the PR has several distinct
# commits and none look like review churn (fixup!/wip/typo/GitHub web edits), else squash.
[no-cd]
merge pr_number="" method="":
    #!/bin/bash
    set -e
    PR_NUMBER='{{ pr_number }}'
    METHOD='{{ method }}'
    if [ -z "$PR_NUMBER" ]; then
        PR_NUMBER=$(gh pr list --state open --limit 1 --json number --jq '.[0].number')
        [ -z "$PR_NUMBER" ] && { echo "No open PRs found"; exit 0; }
    fi
    if [ -z "$METHOD" ]; then
        METHOD=$(gh pr view $PR_NUMBER --json commits --jq '
            [.commits[].messageHeadline] as $s
            | if ($s | length) > 1 and ($s | unique | length) == ($s | length)
                 and all($s[]; test("^(fixup|squash|amend)!|^(wip|fixup|address|apply suggestions|merge branch|fmt|format|fix (typo|lint|ci|tests?))\\b|^update \\S+$"; "i") | not)
              then "rebase" else "squash" end')
    fi
    echo "Merging #$PR_NUMBER with --$METHOD"
    gh pr merge $PR_NUMBER --$METHOD
    # Not gh --delete-branch: it also switches the local git HEAD, which fights jj
    BRANCH_NAME=$(gh pr view $PR_NUMBER --json headRefName --jq '.headRefName')
    git push origin --delete "$BRANCH_NAME"
    jj git fetch
    # squash/rebase merges rewrite the PR commits; the local originals become empty on rebase
    jj rebase -d 'trunk()' --skip-emptied

[no-cd]
track-branch branch="":
    #!/bin/bash
    set -e

    if [ -n "$branch" ]; then
        BRANCH="$branch"
    else
        BRANCH=$(gh pr list --state open --limit 1 --json headRefName --jq '.[0].headRefName')
        [ -z "$BRANCH" ] && { echo "No open GitHub PR branch found. Provide one: just track-branch <branch>"; exit 1; }
    fi

    if ! git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
        echo "Branch '$BRANCH' not found on origin (GitHub)."
        exit 1
    fi

    echo "Tracking GitHub branch with jujutsu: $BRANCH@origin"
    jj bookmark track "$BRANCH@origin"

push-and-pr revision="@":
    #!/bin/bash
    set -e
    jj git push -c {{ revision }}
    BRANCH_NAME=$(jj log -r {{ revision }} --no-graph -T 'bookmarks')

    if [[ "$BRANCH_NAME" == *"main"* ]]; then
        echo "Cannot create PR from main branch"
        exit 1
    fi
    # Create PR using the remote branch
    echo "Creating PR from branch: $BRANCH_NAME"
    gh pr create --head "$BRANCH_NAME" --fill
    jj new

qrcode:
    #!/usr/bin/env sh
    # Get the repository URL
    REPO_URL=$(git config --get remote.origin.url)
    # Extract the username and repository name
    USERNAME=$(echo $REPO_URL | awk -F'[/:]' '{print $(NF-1)}')
    REPO_NAME=$(basename $REPO_URL .git)
    # Format the GitHub Pages URL
    GH_PAGES_URL="https://$USERNAME.github.io/$REPO_NAME"
    # Generate the QR code
    segno $GH_PAGES_URL -o=files/qrcode.png --light transparent --scale 10
