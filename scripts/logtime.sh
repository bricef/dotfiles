#!/bin/bash

LOGDIR="/home/$(whoami)/.timelogs"

test ! -d $LOGDIR && mkdir -p $LOGDIR

LOGFILE=$LOGDIR/$(date "+%Y%m%d.log")
ACTIVFILE=$LOGDIR/activities.txt


prefix=$(date "+[%Y-%m-%d %H:%M]: ")

ACTIVITY=$(cat $ACTIVFILE | dmenu )

if [ "$ACTIVITY" ]; then
  echo $prefix $ACTIVITY>> $LOGFILE
  cat <(echo $ACTIVITY) $ACTIVFILE | sort | uniq > $ACTIVFILE.tmp
  mv $ACTIVFILE.tmp $ACTIVFILE
fi


