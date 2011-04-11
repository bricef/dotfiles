#!/bin/bash

B_RED="\x1b[41m"
B_GREEN="\x1b[42m"
B_YELLOW="\x1b[43m"
B_BLUE="\x1b[44m"
B_MAGENTA="\x1b[45m"
B_CYAN="\x1b[46m"
B_WHITE="\x1b[47m"

F_RED="\x1b[31m"
F_GREEN="\x1b[32m"
F_YELLOW="\x1b[33m"
F_BLUE="\x1b[34m"
F_MAGENTA="\x1b[35m"
F_CYAN="\x1b[36m"
F_WHITE="\x1b[37m"

BOLD="\x1b[1m"

END="\x1b[0m"

regex=""
bold=""
pre=""
bgr=""
fgr=""
post=$END

color_fg(){
	case $1 in
		red)pre=$pre$F_RED;;
		green)pre=$pre$F_GREEN;;
		yellow)pre=$pre$F_YELLOW;;
		blue)pre=$pre$F_BLUE;;
		magenta)pre=$pre$F_MAGENTA;;
		cyan)pre=$pre$F_CYAN;;
		white)pre=$pre$F_WHITE;;
		*) echo "'$1' is not a color!">/dev/sdterr; exit 1;
	esac
}

color_bg(){
	case $1 in
		red)pre=$pre$B_RED;;
		green)pre=$pre$B_GREEN;;
		yellow)pre=$pre$B_YELLOW;;
		blue)pre=$pre$B_BLUE;;
		magenta)pre=$pre$B_MAGENTA;;
		cyan)pre=$pre$B_CYAN;;
		white)pre=$pre$B_WHITE;;
		*) echo "'$1' is not a color!">/dev/sdterr; exit 1;
	esac
}

usage(){
	echo "hilite.sh [-b color] [-f color] [-B] -r <regex>"
	echo ""
	echo "Takes stdin to stdout while adding highlighting for patterns "
	echo "that match the regex."
	echo ""
	echo "-f color    Set the foreground color"
	echo "-b color    Set the background color"
	echo "-B          Make text bold"
  echo ""
	echo "Colors can be any of 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan'"
	echo "'white'. The default is a bold red foreground on default background"
  echo "which is equivalent to:"
  echo "    hilite.sh -B -f red "
}

while getopts "f:b:r:Bh" flag
do
	case "$flag" in 
		f) color_fg $OPTARG;;
		b) color_bg $OPTARG;;
    B) bold=$BOLD;;
		r) regex=$OPTARG;;
		h) usage; exit 0;;
    *) usage; exit 0;;
	esac
done

if [ ! -n "$regex" ]; then
	usage
fi

if [ ! -n "$pre" ]; then
	bold=${BOLD}
  pre=${F_RED}
fi

sed "s/$regex/$pre$bold&$post/g" < /dev/stdin >/dev/stdout
