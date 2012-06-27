#! /bin/bash

##
# Simple script to write status information on cli or using dzen (a la wmii)
# depends on:
#       volch.sh
#       pm-sensors
#       dzen2 (when using --dzen switch)
##

netstatus(){
    if [[ `ifconfig | grep $1` ]]; then
        IP=`ifconfig | grep "$1.*$" -A1 | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | head -1`;
        if [[ ! $IP ]]; then
            IP="unassociated";
        fi;
    else 
        IP="down";
    fi;
    echo $IP
}




status() {
    IP_eth1=`netstatus eth1 2>/dev/null`
    IP_wlan0=`netstatus wlan0 2>/dev/null`

    SONG=$(mpc 2>/dev/null | head -1)
    
    if [[ ! -z "${SONG:35}" ]]; then
      SONG="${SONG::35}..."
    fi

    echo '|' $(dropbox status) \
    '|' $(echo "vol:"; echo `sudo ~/scripts/volch.sh -q`) \
    '|' $(sensors | grep temp1 | awk '{print $2}'| tr -d "\n" | tr "+" " ") \
    '|' $(acpi | awk '{print $3 $4}' | tr ',' ' ') \
    '| eth0:' $IP_eth0 \
    '| wlan0:' $IP_wlan0 '('$(mac.py)')'\
    '| up:' $(uptime | tr -d ','|awk '{print $3" "$4" "$5}') \
    '|' $(date +"%a %d %b, %H:%M") '|' 
}


if [[ $1 == --string ]]; then
    status;
elif [[ $1 == --dzen ]]; then
    while true; do 
        status
        sleep 1
    done | dzen2 -tw 1156 -x 210 -ta r -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -y 752 -fg "#ffffff" -bg "#000000" # "*terminus*medium*-14-*"
else
    echo "invoke with --string or --dzen"
fi;
