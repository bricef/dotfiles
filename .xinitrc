
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &
udiskie &

xsetroot -solid "#3030cc"

feh --bg-scale Dropbox/Photos/Markarth01_wLegal.jpg

xbindkeys &
. /home/brice/scripts/volch.sh -s 50 &
. /home/brice/scripts/status.sh --dzen &
. /home/brice/scripts/showdesks.sh --dzen &


exec openbox-session


