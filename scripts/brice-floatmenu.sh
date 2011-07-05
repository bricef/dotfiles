#!/bin/bash

# NOTE WELL:
#   Requires the latest development version of dzen2 for all the features to work.
#

EVENTS="onstart=uncollapse,scrollhome;entertitle=uncollapse,grabkeys;\
enterslave=grabkeys;leaveslave=exit,ungrabkeys;\
button1=menuexec;button2=togglestick;button3=exit:13;\
button4=scrollup;button5=scrolldown;\
key_Down=scrolldown;keyUp=scrollup;key_Page_Down=scrolldown:30;key_Page_Up=scrollup:30;\
key_Escape=ungrabkeys,exit"

LINES=12

DZEN="/home/$(whoami)/Downloads/dzen/dzen2"

XP=$(getcurpos | cut -c1-4 ) # could we use xdotool and wmctrl too?
YP=$(getcurpos | cut -c5-10)


(echo "^fg(red)MENU^fg()"; cat  ~/.config/brice-menu.cache) | $DZEN -ta c -sa c -l $LINES -p -e $EVENTS -x $XP -y $YP -tw 100 -w 100 -m 

