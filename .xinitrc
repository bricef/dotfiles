
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &
udiskie &

xsetroot -solid "#3030cc"

feh --bg-scale Dropbox/Photos/Markarth01_wLegal.jpg

xbindkeys &
. /home/brice/scripts/volch.sh -s 50 &
. /home/brice/scripts/status.sh --dzen &
. /home/brice/scripts/showdesks.sh --dzen &
. /home/bfer/scripts/winlist.sh &
. /home/bfer/scripts/workingon.sh &
. /home/bfer/scripts/top-left.sh &


exec openbox-session


