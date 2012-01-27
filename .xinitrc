
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &
udiskie &

#xsetroot -solid "#3030cc"

xbindkeys &
. /home/bfer/scripts/status.sh --dzen &
. /home/bfer/scripts/showdesks.sh --dzen &
. /home/bfer/scripts/workingon.sh &
. /home/bfer/scripts/top-left.sh &

setxkbmap gb &
feh --bg-scale Dropbox/Photos/Markarth01_wLegal.jpg
dropbox start &

exec openbox-session


