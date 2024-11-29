#!/bin/bash

while true; do 
  echo $(wmctrl -l \
    | grep $(printf "%x\n" `xdotool getactivewindow`) \
    | awk '{print "["strftime("%Y-%m-%d %H:%M:%S")"]: " substr($0, index($0, $4))}'
   )
  sleep 1; 
done

