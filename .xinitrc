
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &

xsetroot -solid "#3030cc" &

. /home/brice/.screenlayout/raven-side-by-side.sh &

xbindkeys &

. /home/brice/scripts/status.sh --dzen &
. /home/brice/scripts/showdesks.sh --dzen &
#. /home/brice/scripts/winlist.sh &
#. /home/brice/scripts/workingon.sh &
#. /home/brice/scripts/top-left.sh &

feh --bg-scale --no-xinerama /home/brice/Dropbox/Photos/wallpapers/Untitled_Wallpaper.jpg

exec openbox


