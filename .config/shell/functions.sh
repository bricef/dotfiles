#!/bin/sh

function bprint {
  <$1 fold -w 72 | pr -F -o3 -h $1 | tee >( lpr )
}

function pprint {
  a2ps -R -T4 --columns=1 --borders=off --header="" --left-footer="" --right-footer="" --line-numbers=1 -f 10 --pro=color -o out.ps $1
  echo "File in out.ps"
}

function pgen {
  </dev/urandom tr -dc A-Za-z0-9 | head -c $1 | cat - <(echo "")
}

function transfer {
  if [ $# -eq 0 ]; then 
    echo "No arguments specified."
    echo "Usage:"
    echo "echo transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; 
    return 1; 
  fi 
  local tmpfile=$( mktemp -t transferXXX ); 
  
  if tty -s; then 
    local basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); 
    curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; 
  else 
    curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; 
  fi; 
  cat $tmpfile; 
  rm -f $tmpfile; 
}

function colors {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
