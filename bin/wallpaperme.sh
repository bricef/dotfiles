#!/bin/bash


function update {
  files=(/home/brice/Dropbox/Photos/wallpapers/*)
  file="${files[RANDOM % ${#files[@]}]}"
  echo "$file" > ~/.wallpaper
  feh --bg-scale --no-xinerama "$file" 
  echo "$file"
}


if [ "$1$" ]; then
  update;
else
  while true; do
    update;
    sleep 10m;
  done
fi

