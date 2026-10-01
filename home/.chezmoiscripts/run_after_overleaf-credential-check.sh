#!/bin/bash
# Runs every apply; silent once run_onchange_after_overleaf-credential has stored the token.
printf 'protocol=https\nhost=git.overleaf.com\nusername=git\n\n' |
    GIT_TERMINAL_PROMPT=0 GIT_ASKPASS= SSH_ASKPASS= git credential fill 2>/dev/null |
    grep -q '^password=' && exit 0
echo 'Overleaf git token missing. Run: export BW_SESSION=$(bw login --raw || bw unlock --raw) && chezmoi apply' >&2
