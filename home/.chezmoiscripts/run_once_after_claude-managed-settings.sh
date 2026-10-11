#!/bin/bash
# Settings shared by every CLAUDE_CONFIG_DIR profile and every launcher (shell, Orca, IDE, desktop app).
# Managed settings are the only scope all of them read; the symlink keeps the file user-editable.
# Managed settings win over each profile's settings.json, so profiles cannot override shared keys.

case "$(uname)" in
Darwin) dir="/Library/Application Support/ClaudeCode/managed-settings.d" ;;
*) dir="/etc/claude-code/managed-settings.d" ;;
esac
src="$HOME/.claude/shared-settings.json"
dst="$dir/shared.json"

[ "$(readlink "$dst")" = "$src" ] && exit 0
echo "Linking $dst -> $src (sudo)"
sudo mkdir -p "$dir" && sudo ln -sfn "$src" "$dst"
