
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &

xsetroot -solid "#3030cc"

xbindkeys &
. /home/bfer/scripts/status.sh --dzen &
. /home/bfer/scripts/showdesks.sh --dzen &
. /home/bfer/scripts/winlist.sh &
. /home/bfer/scripts/workingon.sh &
. /home/bfer/scripts/top-left.sh &


exec openbox-session


