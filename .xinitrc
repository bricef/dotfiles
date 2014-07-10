
setxkbmap -option terminate:ctrl_alt_bksp &
setxkbmap gb &

xsetroot -solid "#2f2f2f" &

. /home/brice/.screenlayout/raven-side-by-side.sh &

xbindkeys &

. /home/brice/scripts/status.sh --dzen &
. /home/brice/scripts/showdesks.sh --dzen &
#. /home/brice/scripts/winlist.sh &
#. /home/brice/scripts/workingon.sh &
#. /home/brice/scripts/top-left.sh &

#feh --bg-scale --no-xinerama /home/brice/Dropbox/Photos/wallpapers/Untitled_Wallpaper.jpg
sudo ln -s /dev/sr0 /dev/dvd
setxkbmap gb &

# Activity monitoring
/home/brice/scripts/activity-log --loop &>/dev/null &
sudo /home/brice/scripts/klog /dev/input/by-path/platform-i8042-serio-0-event-kbd /logging/$(date +"%F").keys &>/dev/null &

xscreensaver -no-splash &
dropbox start
exec openbox


