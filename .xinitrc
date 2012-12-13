
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &

. /home/bfer/.screenlayout/new_double.sh 

xsetroot -solid "#aaaaaa"

feh --bg-scale Downloads/milky_way_arch-wallpaper-3360x1050.jpg &

xbindkeys &
. /home/bfer/scripts/status.sh --dzen &
. /home/bfer/scripts/showdesks.sh --dzen &
. /home/bfer/scripts/winlist.sh &
. /home/bfer/scripts/workingon.sh &
. /home/bfer/scripts/top-left.sh &


exec openbox-session


