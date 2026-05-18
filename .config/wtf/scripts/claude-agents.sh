#!/usr/bin/env bash
# Live Claude Code background sessions and their state.
#
# Sources:
#   ~/.claude/daemon/roster.json       - live worker pids/sessions
#   ~/.claude/jobs/<short>/state.json  - per-session state (blocked/active/...)

set -euo pipefail

ROSTER="$HOME/.claude/daemon/roster.json"
JOBS="$HOME/.claude/jobs"

if [ ! -f "$ROSTER" ]; then
  echo "No daemon roster (Claude daemon not running)"
  exit 0
fi

printf "%-9s %-22s %-9s %5s  %s\n" "SHORT" "NAME" "STATE" "T/Q" "CWD"

jq -r '.workers | keys[]' "$ROSTER" | while read -r short; do
  state_file="$JOBS/$short/state.json"
  if [ -f "$state_file" ]; then
    jq -r --arg s "$short" '
      [
        $s,
        (.name // "-"),
        (.state // "-"),
        ((.inFlight.tasks // 0) | tostring) + "/" + ((.inFlight.queued // 0) | tostring),
        (.cwd // "-")
      ] | @tsv
    ' "$state_file"
  else
    printf "%s\t-\t-\t-/-\t-\n" "$short"
  fi
done | awk -F'\t' -v home="$HOME" '
{
  cwd = $5
  if (index(cwd, home) == 1) cwd = "~" substr(cwd, length(home) + 1)
  if (length(cwd)  > 30) cwd  = "…" substr(cwd,  length(cwd)  - 29)
  name = $2
  if (length(name) > 22) name = substr(name, 1, 21) "…"
  printf "%-9s %-22s %-9s %5s  %s\n", $1, name, $3, $4, cwd
}
'
