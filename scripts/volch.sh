
#! /bin/bash

##
# Volume management script using alsa amixer.
# @author: brice.fernandes@gmail.com
##

CURRENT=~/.config/vol_cur
STORE=~/.config/vol_store

test ! -e $CURRENT && echo 50 > $CURRENT
test ! -e $STORE && echo 50 > $STORE


vol=`cat $CURRENT`;

usage(){
    echo "usage: volch.sh [OPTION] [-s VOLUME]"
    echo ""
    echo "  where OPTION is:"
    echo "      -q          [query] Print the current volume"
    echo "      -r          [raise] Increase the volume"
    echo "      -l          [lower] Decrease the volume"
    echo "      -h          [help] Show this message"
    echo "      -m          [mute] mute/unmute the volume"
    echo "      -s VOLUME   [set] set the volume to VOLUME, where VOLUME is a number between 0 and 100"
    echo ""
    echo "  Running the -s option without a volume, will switch the sound off"
    exit
}



#if [ "$#" = 0 ]; then
#    let "vol = 0"
#fi;


mute(){
    stor_vol=`cat $STORE`
    if [ $stor_vol -gt 0 ]; then
        let "vol = $stor_vol";
        echo "0" >$STORE;
    else
        echo "$vol" > $STORE;
        let "vol = 0";
    fi
}

#
# Choose actions
#
case $1 in
    "-s")
        if [[ `echo "$2" | grep -E "^[0-9]{1,3}$"` ]]; then
            let "vol = $2";
        elif [[ ! $2 ]]; then
            let "vol = 0";
        else
            usage;
            exit
        fi;
        ;;
    "-r")
        let "vol += 2";
        ;;
    "-l")
        let "vol -= 2";
        ;;
    "-m")
        mute;
        ;;
    "-q")
        echo $vol;
        exit
        ;;
    *)
        usage;
        ;;
esac


#
# make sure that the volume is within range
#
if [ "$vol" -lt 0 ]; then
        let "vol = 0";
fi;
if [ "$vol" -gt 100 ]; then
        let "vol = 100";
fi;

amixer set Master $vol% unmute >/dev/null;
echo "$vol" > $CURRENT;

echo "Volume now $vol";


