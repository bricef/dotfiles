
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &
udiskie &

xsetroot -solid "#3030cc"

xbindkeys &
. /home/brice/scripts/volch.sh -s 50 &
. /home/brice/scripts/status.sh --dzen &
. /home/brice/scripts/showdesks.sh --dzen &


exec openbox-session


