#!/usr/bin/env bash
# Put the Telegram api_id/api_hash into the macOS Keychain (service "telegram-api"),
# using Bitwarden item "Telegram API" as the synced copy.
# First machine: prompts for the values and creates the Bitwarden item.
# Other machines: pulls them from Bitwarden. Run in a real terminal (prompts).
set -euo pipefail
ITEM="Telegram API"
SVC="telegram-api"

case "$(bw status | jq -r .status)" in
  unauthenticated) BW_SESSION=$(bw login --raw) ;;
  locked) BW_SESSION=$(bw unlock --raw) ;;
esac
export BW_SESSION
bw sync >/dev/null

item=$(bw list items --search "$ITEM" | jq -c --arg n "$ITEM" 'map(select(.name == $n)) | .[0] // empty')
if [[ -n "$item" ]]; then
  field() { jq -r --arg k "$1" '.fields[] | select(.name == $k) | .value' <<<"$item"; }
  api_id=$(field api_id)
  api_hash=$(field api_hash)
  echo "Pulled from Bitwarden item '$ITEM'."
else
  read -rp "api_id: " api_id
  read -rsp "api_hash (hidden): " api_hash; echo
fi

[[ "$api_id" =~ ^[0-9]+$ ]] || { echo "api_id must be digits" >&2; exit 1; }
[[ "$api_hash" =~ ^[0-9a-f]{32}$ ]] || { echo "api_hash must be 32 hex chars" >&2; exit 1; }

if [[ -z "$item" ]]; then
  bw get template item | jq --arg n "$ITEM" --arg id "$api_id" --arg h "$api_hash" '
    .type = 2 | .secureNote = {type: 0} | .login = null | .name = $n
    | .notes = "https://my.telegram.org/apps — app credentials, not a login; safe to reuse on every machine."
    | .fields = [{name: "api_id", value: $id, type: 0}, {name: "api_hash", value: $h, type: 1}]' \
    | bw encode | bw create item >/dev/null
  echo "Created Bitwarden item '$ITEM'."
fi

# `security -i` reads commands from stdin, keeping the secrets out of argv / ps.
printf 'add-generic-password -U -s %s -a api_id -w %s\nadd-generic-password -U -s %s -a api_hash -w %s\n' \
  "$SVC" "$api_id" "$SVC" "$api_hash" | security -i
echo "Stored in Keychain service '$SVC'."
