#!/bin/bash



while true; do
    desktops="^p() "`echo $(wmctrl -l | awk '{print $2}'; wmctrl -d | grep "\*" | grep -Eo "^[0-9]+") \
                | tr " " "\n" \
                | sort | uniq \
                | xargs -n 1 \
                | ( while read number; do echo $(( number + 1)); done; ) \
                | tr "\n" " " \
                | sed "s/ / ^p() /g"`"^p()"
                
    current=`wmctrl -d | grep "\*" | grep -Eo "^[0-9]+"`
    current=$((current + 1))

    echo $desktops | sed "s/ ${current} /^bg(red) ${current} ^bg(black)/"
    sleep 1
done | dzen2 -p -tw 300 -x 0 -ta l -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -y 1065 -fg "#ffffff" -bg "#000000"
