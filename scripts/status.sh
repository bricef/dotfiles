#! /bin/bash

##
# Simple script to write status information on cli or using dzen (a la wmii)
# depends on:
#       volch.sh
#       dzen2 (when using --dzen switch)
##

netstatus(){
    if [[ `ip link show dev $1 | grep UP` ]]; then
        IP=$(ip addr show dev $1 |grep "\<inet\>" | awk '{print $2}')
        if [[ ! $IP ]]; then
            IP="unassociated";
        fi;
    else 
        IP="down";
    fi;
    echo $IP
}




status() {
    IP_eth0=`netstatus eth0 2>/dev/null`
    IP_wlan0=`netstatus wlp0s10f1u9 2>/dev/null`

    echo '|' $(dropbox status) \
    '| vol:' $(~/scripts/volch.sh -q) \
    '|' $(sensors | grep "CPU Temperature" | awk '{print $3}' | tr -d "\n" | tr "+" " ") \
    '| wlan0:' $IP_wlan0 \
    '| up:' $(uptime | tr -d ','|awk '{print $3" "$4" "$5}') \
    '|' $(date +"%a %d %b, %H:%M") '|' 
}


if [[ $1 == --string ]]; then
    status;
elif [[ $1 == --dzen ]]; then
    while true; do 
        status
        sleep 1
    done | dzen2 -tw 1680 -x 1680 -ta r -y 1035 -fg "#ffffff" -bg "#000000" # "*terminus*medium*-14-*"
else
    echo "invoke with --string or --dzen"
fi;
