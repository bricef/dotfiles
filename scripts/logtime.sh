#!/bin/bash

LOGDIR="/home/$(whoami)/.timelogs"

test ! -d $LOGDIR && mkdir -p $LOGDIR

LOGFILE=$LOGDIR/$(date "+%Y%m%d.log")
ACTIVFILE=/home/$(whoami)/.activities

if [ "$1" = "edit" ]; then
  vim $(readlink -f $LOGFILE)
else
  prefix=$(date "+[%Y-%m-%d %H:%M]: ")
  ACTIVITY=$(cat <(echo "@show") $ACTIVFILE | dmenu -b )
  if [ "$ACTIVITY" ]; then
    if [ "$ACTIVITY" = "@show" ]; then
      length=$(wc -l $LOGFILE| awk '{print $1}')
      cat <(echo "(press Esc/Return to exit)") $LOGFILE \
        | dzen2 -e 'onstart=uncollapse,grabkeys,grabmouse;key_Return=exit;key_Escape=exit' -l $length -p -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -tw 500 -x 710 -y 100 -w 500 -bg grey -fg black -h 20
    else
      echo $prefix $ACTIVITY>> $LOGFILE
      cat <(echo $ACTIVITY) $ACTIVFILE | sort | uniq > $ACTIVFILE.tmp
      mv $ACTIVFILE.tmp $ACTIVFILE
    fi
  fi
fi
