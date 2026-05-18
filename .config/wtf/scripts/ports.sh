#!/usr/bin/env bash
# TCP/UDP listening sockets (process name when visible to the current user).

set -euo pipefail

printf "%-5s %-6s %-22s %s\n" "PROTO" "PORT" "ADDRESS" "PROCESS"

# -t TCP, -u UDP, -l listening, -n numeric, -p show pids/processes.
# Sudo for cross-user process visibility (see /etc/sudoers.d/wtf-dashboard);
# falls through to unprivileged ss if the rule is removed.
{ sudo -n /usr/bin/ss -tulnp 2>/dev/null || ss -tulnp 2>/dev/null; } \
  | tail -n +2 | awk '
{
  proto = $1
  local = $5
  m = split(local, parts, ":")
  port = parts[m]
  addr = local
  sub(":" port "$", "", addr)

  # Process info lives in $7 like: users:(("sshd",pid=123,fd=3))
  proc = "-"
  pid = ""
  if (split($0, a, "\"") > 1) proc = a[2]
  if (match($0, /pid=[0-9]+/)) {
    pid = substr($0, RSTART + 4, RLENGTH - 4)
  }

  # Claude Code daemons install per-version binaries named like the version
  # string (e.g. ~/.local/share/claude/versions/2.1.143); kernel derives
  # /proc/<pid>/comm from that basename, so `ss` shows "2.1.143" as the
  # process name. Relabel when the exe path confirms it is Claude.
  if (proc ~ /^[0-9]+\.[0-9]+\.[0-9]+$/ && pid != "") {
    cmd = "readlink /proc/" pid "/exe 2>/dev/null"
    cmd | getline exe
    close(cmd)
    if (exe ~ /\/claude\/versions\//) proc = "claude " proc
  }

  printf "%-5s %-6s %-22s %s\n", proto, port, addr, proc
}
' | sort -u | head -25
