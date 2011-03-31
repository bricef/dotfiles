#!/bin/bash


TIMELOG_FILE="/home/bfer/.timelog"
 
last=$(tail -1 $TIMELOG_FILE | sed 's/.*]: \(.*\)$/\1/' )

#date "+[%Y-%m-%d %H:%M]:"

while (true) do
  echo $(date "+[%Y-%m-%d %H:%M]:") $(zenity --entry --text="What are you doing?" --entry-text="$last") >> $TIMELOG_FILE 
  sleep 15m
done
