#!/bin/bash
# Runs every apply; silent once run_onchange_after_bitwarden-credentials has installed everything.
printf 'protocol=https\nhost=git.overleaf.com\nusername=git\n\n' |
    GIT_TERMINAL_PROMPT=0 GIT_ASKPASS= SSH_ASKPASS= git credential fill 2>/dev/null |
    grep -q '^password=' &&
    gog auth list --plain 2>/dev/null | grep -q . && exit 0
echo 'Credentials missing (Overleaf/gog). Run: export BW_SESSION=$(bw login --raw || bw unlock --raw) && chezmoi apply' >&2
