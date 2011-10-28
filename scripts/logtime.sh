#!/bin/bash

LOGDIR="/home/$(whoami)/.timelogs"

test ! -d $LOGDIR && mkdir -p $LOGDIR

LOGFILE=$LOGDIR/$(date "+%Y%m%d.log")
ACTIVFILE=/home/$(whoami)/.activities
SHOWSCRIPT=/home/$(whoami)/scripts/show_timelog.py

prefix=$(date "+[%Y-%m-%d %H:%M]: ")

if [ $1 ]; then
  
  case "$1" in
    "working-on")
      echo $(tail -1 $LOGFILE | awk '{print substr($0, index($0, $3))}' )
      ;;
  esac

else 
  
  ACTIVITY=$(cat <(echo -e "@show\n@edit") $ACTIVFILE | dmenu -b )

  case "$ACTIVITY" in 
    "@show")
      length=$(wc -l $LOGFILE| awk '{print $1}')
      cat $LOGFILE <(echo $prefix NOW ) | $SHOWSCRIPT 
#        | dzen2 -e 'onstart=uncollapse,grabkeys,grabmouse;key_Return=exit;key_Escape=exit' -l $length -p -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' -tw 500 -x 710 -y 100 -w 500 -bg grey -fg black -h 20
      ;;
    "@edit")
      gnome-terminal --working-directory=/home/$(whoami)/ -e "$EDITOR $(readlink -f $LOGFILE)"
      ;;
    "")
      #do nothing
      ;;
    *)
      echo $prefix $ACTIVITY>> $LOGFILE
      cat <(echo $ACTIVITY) $ACTIVFILE | sort | uniq > $ACTIVFILE.tmp
      mv $ACTIVFILE.tmp $ACTIVFILE
      ;;
  esac

fi
