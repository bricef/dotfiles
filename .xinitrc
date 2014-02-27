
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &

# :xsetroot -solid "#f2f2f2" &

. /home/brice/.screenlayout/raven-side-by-side.sh &

xbindkeys &

. /home/brice/scripts/status.sh --dzen &
. /home/brice/scripts/showdesks.sh --dzen &
#. /home/brice/scripts/winlist.sh &
#. /home/brice/scripts/workingon.sh &
#. /home/brice/scripts/top-left.sh &

feh --bg-scale --no-xinerama /home/brice/Dropbox/Photos/wallpapers/Untitled_Wallpaper.jpg
sudo ln -s /dev/sr0 /dev/dvd
setxkbmap gb &
xscreensaver &
dropbox start
exec openbox


