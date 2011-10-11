#!/bin/bash

DESKTOP=$(wmctrl -d | grep "\*" | awk '{print $1}')

while true; do   
  wmctrl -l \
  | while read id desk host title; do 
      if [ "$desk" = "$DESKTOP" ]; then 
        echo $title; 
      fi; 
    done \
  | while read line; do
      echo -n "| $(echo $line| sed 's|\(.\{10\}\).*|\1|g') "
    done
    echo "|"
  sleep 1
 done #| dzen2 -p -tw 300 -x 0 -ta l -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -y 1065 -fg "#ffffff" -bg "#000000"
  

