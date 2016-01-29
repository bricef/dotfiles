#!/bin/bash

# (c) 2011 by Brice fernandes <brice.fernandes@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Source available at https://github.com/bricef/dotfiles/blob/master/scripts/hilite.sh

B_BLACK="\x1b[40m"
B_RED="\x1b[41m"
B_GREEN="\x1b[42m"
B_YELLOW="\x1b[43m"
B_BLUE="\x1b[44m"
B_MAGENTA="\x1b[45m"
B_CYAN="\x1b[46m"
B_WHITE="\x1b[47m"

F_BLACK="\x1b[30m"
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

show(){
echo -e "black:  $F_BLACK normal $BOLD bold $END $B_BLACK background $END"
echo -e "red:    $F_RED normal $BOLD bold $END $B_RED background $END"
echo -e "green:  $F_GREEN normal $BOLD bold $END $B_GREEN background $END"
echo -e "yellow: $F_YELLOW normal $BOLD bold $END $B_YELLOW background $END"
echo -e "blue:   $F_BLUE normal $BOLD bold $END $B_BLUE background $END"
echo -e "magenta:$F_MAGENTA normal $BOLD bold $END $B_MAGENTA background $END"
echo -e "cyan:   $F_CYAN normal $BOLD bold $END $B_CYAN background $END"
echo -e "white:  $F_WHITE normal $BOLD bold $END $B_WHITE background $END"
}

color_fg(){
	case $1 in
		black)pre=$pre$F_BLACK;;
		red)pre=$pre$F_RED;;
		green)pre=$pre$F_GREEN;;
		yellow)pre=$pre$F_YELLOW;;
		blue)pre=$pre$F_BLUE;;
		magenta)pre=$pre$F_MAGENTA;;
		cyan)pre=$pre$F_CYAN;;
		white)pre=$pre$F_WHITE;;
		*) echo "'$1' is not a color!" 1>&2 ; exit 1;
	esac
}

color_bg(){
	case $1 in
		black)pre=$pre$B_BLACK;;
		red)pre=$pre$B_RED;;
		green)pre=$pre$B_GREEN;;
		yellow)pre=$pre$B_YELLOW;;
		blue)pre=$pre$B_BLUE;;
		magenta)pre=$pre$B_MAGENTA;;
		cyan)pre=$pre$B_CYAN;;
		white)pre=$pre$B_WHITE;;
		*) echo "'$1' is not a color!" 1>&2 ; exit 1;
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
  echo "-s          Show the colors"
  echo ""
	echo "Colors can be any of 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan'"
	echo "'white' and 'black'. The default is a bold red foreground on default"
  echo "background which is equivalent to:"
  echo "    hilite.sh -B -f red "
}

while getopts "f:b:r:Bhs" flag
do
	case "$flag" in 
		f) color_fg $OPTARG;;
		b) color_bg $OPTARG;;
    B) bold=$BOLD;;
		r) regex=$OPTARG;;
    s) show; exit 0;;
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

cat - | sed -u "s/$regex/$pre$bold&$post/g"
