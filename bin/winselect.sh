#!/bin/bash

DESKTOP=$(wmctrl -d | grep "\*" | awk '{print $1}')

wmctrl -l \
   | sort -k 2 \
   | awk '{$2++; print $1" "$2" "substr($0, index($0,$4))}' \
   | dmenu -i -l 10 -nb black -nf white -sb red -sf white \
   | wmctrl -i -a $(awk '{print $1}')

