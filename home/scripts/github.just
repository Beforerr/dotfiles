auto-merge:
    #!/bin/bash
    set -e
    
    # Get latest PR number
    PR_NUMBER=$(gh pr list --state open --limit 1 --json number --jq '.[0].number')
    [ -z "$PR_NUMBER" ] && { echo "No open PRs found"; exit 0; }
    
    echo "Checking PR #$PR_NUMBER status..."
    # Check if all checks have passed
    CHECK_STATUS=$(gh pr checks $PR_NUMBER --json state --jq '.[] | select(.state != "SUCCESS" and .state != "SKIPPED") | .state' | wc -l)
    
    if [ "$CHECK_STATUS" -gt 0 ]; then
        echo "Checks are still running or failed. Cannot merge."
        gh pr checks $PR_NUMBER
        exit 1
    fi
    
    echo "All checks passed. Merging PR #$PR_NUMBER..."
    gh pr merge $PR_NUMBER --squash --delete-branch
    jj git fetch
    jj rebase -s @ -d main
