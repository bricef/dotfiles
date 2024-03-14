#!/bin/bash
# resizes the window to full height and 50% width and moves into upper right corner

# margins in px 
# Note - should include sum of border pixels.
TOPMARGIN=0
BOTTOMMARGIN=36
LEFTMARGIN=0
RIGHTMARGIN=0

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# new width and height
HALF_W=$(( $SCREEN_WIDTH / 2 - $RIGHTMARGIN ))
FULL_W=$(( $SCREEN_WIDTH - $LEFTMARGIN - $RIGHTMARGIN ))
HALF_H=$(( $SCREEN_HEIGHT / 2 - $TOPMARGIN - $BOTTOMMARGIN ))
FULL_H=$(( $SCREEN_HEIGHT - $TOPMARGIN - $BOTTOMMARGIN ))



case $1 in
    left)
        X=$LEFTMARGIN
        Y=$TOPMARGIN
        W=$HALF_W
        H=$FULL_H
        ;;
    right)
        X=$(( $SCREEN_WIDTH / 2 ))
        Y=$TOPMARGIN
        W=$HALF_W
        H=$FULL_H
        ;;
    top)
        X=$FULL_W   
        Y=$TOPMARGIN
        W=$HALF_W
        H=$FULL_H
        ;;
    bottom)
        Y=$(( $SCREEN_HEIGHT / 2 ))
        ;;
esac

Y=$TOPMARGIN

wmctrl \
    -r :ACTIVE: \
    -b remove,maximized_vert,maximized_horz \
    && wmctrl \
        -r :ACTIVE: \
        -e 0,$X,$Y,$W,$H