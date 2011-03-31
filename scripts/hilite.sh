#!/bin/bash

B_RED="\x1b[41m"
B_GREEN="\x1b[42m"
B_YELLOW="\x1b[43m"
B_BLUE="\x1b[44m"
B_MAGENTA="\x1b[45m"
B_CYAN="\x1b[46m"
B_WHITE="\x1b[47m"

F_RED="\x1b[1;31m"
F_GREEN="\x1b[1;32m"
F_YELLOW="\x1b[1;33m"
F_BLUE="\x1b[1;34m"
F_MAGENTA="\x1b[1;35m"
F_CYAN="\x1b[1;36m"
F_WHITE="\x1b[1;37m"

END="\x1b[0m"

regex=""
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
	echo "hilite.sh [-b color] [-f color] -r <regex>"
	echo ""
	echo "Takes stdin to stdout while adding highlighting for patterns "
	echo "that match the regex."
	echo ""
	echo "-f color		The foreground color"
	echo "-b color		The background color"
	echo ""
	echo "Colors can be any of 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan'"
	echo "'white'. The default is a red foreground on default background."
}

while getopts "f:b:r:h" flag
do
	case "$flag" in 
		f) color_fg $OPTARG;;
		b) color_bg $OPTARG;;
		r) regex=$OPTARG;;
		h) usage; exit 0;;
	esac
done

if [ ! -n "$regex" ]; then
	usage
fi

if [ ! -n "$pre" ]; then
	post=""
else
	post=$END
fi

sed "s/$regex/$pre&$post/g" < /dev/stdin >/dev/stdout
