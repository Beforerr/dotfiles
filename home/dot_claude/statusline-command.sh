#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Shorten home directory
if [ -n "$cwd" ]; then
  home="$HOME"
  cwd="${cwd/#$home/~}"
fi

time=$(date +%H:%M:%S)
parts=""

parts="$time"
[ -n "$cwd" ] && parts="$parts | $cwd"
[ -n "$model" ] && parts="$parts | $model"
[ -n "$used_pct" ] && parts="$parts | ctx: $(printf '%.0f' "$used_pct")% used"

rate=""
[ -n "$five_hour" ] && rate="5h:$(printf '%.0f' "$five_hour")%"
[ -n "$seven_day" ] && rate="$rate 7d:$(printf '%.0f' "$seven_day")%"
[ -n "$rate" ] && parts="$parts | $rate"

printf "%s" "$parts"
