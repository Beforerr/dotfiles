auto-merge:
    #!/bin/bash
    set -e
    
    # Get latest PR number
    PR_NUMBER=$(gh pr list --state open --limit 1 --json number --jq '.[0].number')
    [ -z "$PR_NUMBER" ] && { echo "No open PRs found"; exit 0; }
    
    echo "Checking PR #$PR_NUMBER status..."
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
    
    echo "All checks passed. Merging PR #$PR_NUMBER..."
    gh pr merge $PR_NUMBER --squash
    # Delete remote branch after merge
    BRANCH_NAME=$(gh pr view $PR_NUMBER --json headRefName --jq '.headRefName')
    git push origin --delete "$BRANCH_NAME"
    jj git fetch
    jj rebase -s @ -d main

push:
    #!/bin/bash
    set -e
    
    # Push current commit to GitHub
    echo "Pushing current commit to GitHub..."
    jj git push -c @

create-pr:
    #!/bin/bash
    set -e
    
    # Get current branch name
    BRANCH_NAME=$(jj log -r @ --no-graph -T 'bookmarks')
    
    # Check if we're on main branch
    if [[ "$BRANCH_NAME" == *"main"* ]]; then
        echo "Cannot create PR from main branch"
        exit 1
    fi
    
    # Get commit message for PR title
    COMMIT_MSG=$(jj log -r @ --no-graph -T 'description' | head -n1)
    
    # Create PR
    echo "Creating PR from branch: $BRANCH_NAME"
    echo "PR title: $COMMIT_MSG"
    gh pr create --title "$COMMIT_MSG" --body "🤖 Generated with [Claude Code](https://claude.ai/code)"

push-and-pr: push create-pr
