#!/usr/bin/env bash
# CPU / MEM / NET with rolling Unicode sparklines.
#
# State (rolling-window samples) lives in $XDG_STATE_HOME/wtf-dashboard/.
# wtfutil drives sampling cadence via the module's refreshInterval.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/spark.sh
. "$DIR/lib/spark.sh"

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/wtf-dashboard"
RING_SIZE=30
mkdir -p "$STATE"

# Append a value to a ring file, truncating to last RING_SIZE entries.
push_ring() {
  local file=$1 val=$2
  echo "$val" >> "$file"
  local n
  n=$(wc -l < "$file")
  if (( n > RING_SIZE )); then
    tail -n "$RING_SIZE" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi
}

# Render a sparkline from the values stored in a ring file.
ring_spark() {
  local file=$1
  [ -f "$file" ] || { echo ""; return; }
  # shellcheck disable=SC2046  # word-split is intentional
  spark $(tr '\n' ' ' < "$file")
}

# --- CPU ----------------------------------------------------------------
# /proc/stat first line: cpu user nice system idle iowait irq softirq steal guest guest_nice
read -r _ u n s i io ir sir st _ _ < /proc/stat
idle=$(( i + io ))
busy=$(( u + n + s + ir + sir + st ))
total=$(( idle + busy ))

cpu_pct=0
if [ -f "$STATE/cpu.prev" ]; then
  read -r prev_total prev_idle < "$STATE/cpu.prev"
  dt=$(( total - prev_total ))
  di=$(( idle - prev_idle ))
  if (( dt > 0 )); then
    cpu_pct=$(( (dt - di) * 100 / dt ))
  fi
fi
echo "$total $idle" > "$STATE/cpu.prev"
push_ring "$STATE/cpu.ring" "$cpu_pct"

# --- MEM ----------------------------------------------------------------
mem_total_kb=$(awk '/^MemTotal:/    {print $2}' /proc/meminfo)
mem_avail_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
mem_used_kb=$(( mem_total_kb - mem_avail_kb ))
mem_pct=$(( mem_used_kb * 100 / mem_total_kb ))
mem_used_gb=$(awk  -v k="$mem_used_kb"  'BEGIN { printf "%.1f", k/1024/1024 }')
mem_total_gb=$(awk -v k="$mem_total_kb" 'BEGIN { printf "%.0f", k/1024/1024 }')
push_ring "$STATE/mem.ring" "$mem_pct"

# --- NET ----------------------------------------------------------------
# Sum bytes across real interfaces. /proc/net/dev data lines are indented,
# so we filter on $1 ending in ":" (header lines lack the colon).
# Excluded: loopback, docker/veth/bridge plumbing. tun/tap kept so VPN
# traffic (wireguard, openvpn, tailscale) shows in the chart.
read -r rx tx < <(awk '
  $1 ~ /:$/ && $1 !~ /^(lo:|docker|veth|br-|virbr)/ {
    rx += $2; tx += $10
  }
  END { print rx+0, tx+0 }
' /proc/net/dev)
now=$(date +%s)

rx_rate=0
tx_rate=0
if [ -f "$STATE/net.prev" ]; then
  read -r prev_t prev_rx prev_tx < "$STATE/net.prev"
  dt=$(( now - prev_t ))
  (( dt < 1 )) && dt=1
  rx_rate=$(( (rx - prev_rx) / dt ))
  tx_rate=$(( (tx - prev_tx) / dt ))
fi
echo "$now $rx $tx" > "$STATE/net.prev"
push_ring "$STATE/net-rx.ring" "$rx_rate"
push_ring "$STATE/net-tx.ring" "$tx_rate"

# Human-readable bytes/sec.
human() {
  awk -v b="$1" 'BEGIN {
    if      (b < 1024)    printf "%4d  B/s", b
    else if (b < 1048576) printf "%4.0f KB/s", b/1024
    else                  printf "%4.1f MB/s", b/1048576
  }'
}

# --- render -------------------------------------------------------------
printf "CPU   %3d%%  %s\n"              "$cpu_pct" "$(ring_spark "$STATE/cpu.ring")"
printf "MEM   %3d%%  %s   %s / %s GB\n" "$mem_pct" "$(ring_spark "$STATE/mem.ring")" "$mem_used_gb" "$mem_total_gb"
printf "NET ↓ %s  %s\n"                 "$(human "$rx_rate")" "$(ring_spark "$STATE/net-rx.ring")"
printf "NET ↑ %s  %s\n"                 "$(human "$tx_rate")" "$(ring_spark "$STATE/net-tx.ring")"
