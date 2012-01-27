#!/bin/bash



while true; do
    current=`xprop -root | grep "_NET_CURRENT_DESKTOP(CARDINAL)" | awk '{print $3}'`
    desktops="^p() "`echo $(wmctrl -l | awk '{print $2}'; echo $current) \
                | tr " " "\n" \
                | sort | uniq \
                | xargs -n 1 \
                | ( while read number; do echo $(( number + 1)); done; ) \
                | tr "\n" " " \
                | sed "s/ / ^p() /g"`"^p()"
                
    current=$((current + 1))

    echo $desktops | sed "s/ ${current} /^bg(red) ${current} ^bg(black)/"
    sleep 1
done | dzen2 -p -tw 210 -x 0 -ta l -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -y 752 -fg "#ffffff" -bg "#000000"
