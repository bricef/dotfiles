#!/bin/bash

DESKTOP=$(wmctrl -d | grep "\*" | awk '{print $1}')

while true; do   
  wmctrl -l \
  | awk -v desk=$DESKTOP '{if($2 == desk) print substr($0, index($0,$4)) }' \
  | while read line; do
      echo -n "| $(echo $line| sed 's|\(.\{10\}\).*|\1|g') "
    done
    echo "|"
  sleep 1
 done | dzen2 -p -tw 1920 -x 0 -y 0 -ta c -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -fg "#ffffff" -bg "#000000"
  

