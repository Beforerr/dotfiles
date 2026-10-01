#!/bin/bash
# Runs every apply; silent once run_onchange_after_gog-credential has imported the accounts.
gog auth list --plain 2>/dev/null | grep -q . && exit 0
echo 'gog Gmail accounts missing. Run: export BW_SESSION=$(bw login --raw || bw unlock --raw) && chezmoi apply' >&2
