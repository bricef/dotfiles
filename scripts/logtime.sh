#!/bin/bash

LOGDIR="/home/$(whoami)/.timelogs"

test ! -d $LOGDIR && mkdir -p $LOGDIR

LOGFILE=$LOGDIR/$(date "+%Y%m%d.log")
ACTIVFILE=/home/$(whoami)/.activities


prefix=$(date "+[%Y-%m-%d %H:%M]: ")

ACTIVITY=$(cat $ACTIVFILE | dmenu -b )

if [ "$ACTIVITY" ]; then
  if [ "$ACTIVITY" = "@show" ]; then
    zenity --warning --text="Operation not currently supported"
  else
    echo $prefix $ACTIVITY>> $LOGFILE
    cat <(echo $ACTIVITY) $ACTIVFILE | sort | uniq > $ACTIVFILE.tmp
    mv $ACTIVFILE.tmp $ACTIVFILE
  fi
fi


