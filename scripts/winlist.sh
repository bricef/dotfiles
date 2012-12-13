#!/bin/bash


while true; do   
  DESKTOP=$(wmctrl -d | grep "\*" | awk '{print $1}')
  ACTIVE="0x0$(echo "obase=16;`xdotool getactivewindow`" | bc | tr '[:upper:]' '[:lower:]')"
  
  wmctrl -l \
  | awk -v desk=$DESKTOP '{if($2 == desk) print $0}'\
  | while read line; do
    WINID=$(echo $line | awk '{print $1}' )
    TITLE=$(echo $line | awk '{print substr($0, index($0,$4))}' | sed 's|\(.\{10\}\).*|\1|g'  )
    if [ "$ACTIVE" = "$WINID" ]; then
      echo -n "|^bg(red) $TITLE ^bg(black)"
    else 
      echo -n "| $TITLE "
    fi
    done
    echo "|"
  sleep 1
 done | dzen2 -p -tw 1570 -x 350 -y 0 -ta r -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -fg "#ffffff" -bg "#000000"
 


