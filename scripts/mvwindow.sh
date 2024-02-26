#!/bin/bash

MARGIN_TOP=0
MARGIN_RIGHT=0
MARGIN_BOTTOM=64
MARGIN_LEFT=0



# get width and height of desktop
WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# new width and height
HALF_WIDTH=$(( $WIDTH / 2))
HALF_HEIGHT=$(( $HEIGHT / 2 ))
QUARTER_WIDTH=$(( $WIDTH / 4))

function move {
	local x="$1"
	local y="$2"
	local w="$3"
	local h="$4"

	echo "Moving active window to x=$x y=$y w=$w h=$h"
	wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz \
		&& wmctrl -r :ACTIVE: -e 0,$x,$y,$w,$h
}


case "$1" in
	"left") 
		x=$MARGIN_LEFT
		y=$MARGIN_TOP
		w=$(( $HALF_WIDTH - $MARGIN_LEFT))  
		h=$(( $HEIGHT - $MARGIN_TOP - $MARGIN_BOTTOM ))
		;;
	"right") 
		x=$HALF_WIDTH
		y=$MARGIN_TOP
		w=$(( $HALF_WIDTH - $MARGIN_LEFT))  
		h=$(( $HEIGHT - $MARGIN_TOP - $MARGIN_BOTTOM ))
		;;
	"bottom") 
		x=$MARGIN_LEFT
		y=$HALF_HEIGHT
		w=$(( $WIDTH - $MARGIN_LEFT - $MARGIN_RIGHT))  
		h=$(( $HALF_HEIGHT - $MARGIN_BOTTOM ))
		;;
	"top")
		x=$MARGIN_LEFT
		y=$MARGIN_TOP
		w=$(( $WIDTH - $MARGIN_LEFT - $MARGIN_RIGHT))  
		h=$(( $HALF_HEIGHT - $MARGIN_TOP ))
		;;
	"p1")
		x=$MARGIN_LEFT
		y=$MARGIN_TOP
		w=$(( $QUARTER_WIDTH - $MARGIN_LEFT ))
		h=$(( $HEIGHT - $MARGIN_TOP - $MARGIN_BOTTOM ))
		;;
	"p2")
		x=$QUARTER_WIDTH
		y=$MARGIN_TOP
		w=$(( $QUARTER_WIDTH ))
		h=$(( $HEIGHT - $MARGIN_TOP - $MARGIN_BOTTOM ))
		;;
	"p3")
		x=$HALF_WIDTH
		y=$MARGIN_TOP
		w=$(( $QUARTER_WIDTH ))
		h=$(( $HEIGHT - $MARGIN_TOP - $MARGIN_BOTTOM ))
		;;
	"p4")
		x=$(( $HALF_WIDTH + $QUARTER_WIDTH ))
		y=$MARGIN_TOP
		w=$(( $QUARTER_WIDTH - $MARGIN_RIGHT ))
		h=$(( $HEIGHT - $MARGIN_TOP - $MARGIN_BOTTOM ))
		;;
	*)
		echo "did not understand window location '$1'"
		exit 1
		;;
esac


move $x $y $w $h


