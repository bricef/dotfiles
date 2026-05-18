#!/usr/bin/env bash
# Emit a Unicode block sparkline for a series of integer values.
#
# Usage:
#   spark 1 2 3 4 5 6 7 8        # -> ▁▂▃▄▅▆▇█
#   spark $(cat ring-file)
#
# Floats: scale to integers in the caller (e.g. multiply by 10).

spark() {
  local chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
  (( $# == 0 )) && return

  local v min=$1 max=$1
  for v in "$@"; do
    (( v < min )) && min=$v
    (( v > max )) && max=$v
  done

  # Avoid divide-by-zero when all samples are equal.
  local range=$(( max - min ))
  (( range == 0 )) && range=1

  local out=""
  for v in "$@"; do
    local idx=$(( (v - min) * 7 / range ))
    out+="${chars[$idx]}"
  done
  printf '%s' "$out"
}
