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


# special characters: ⚡ ↑↓↕ ☠☢➤✔✘
# see also http://www.utf8-chartable.de/unicode-utf8-table.pl

# uname@host:/working/dir$ _ 

# [uname@host:/working/dir]>_

# ==[uname@host /working/dir ]==> 
# _

# [ uname@host ]( /working/dir )>
# $ _

function __prompt_command {
  local EXIT="$?"
  
  # Append commands to the history every time a prompt is shown,
  # instead of after closing the session.
  history -a

  case $PSTYLE in
    "demo")
      # /working/dir ➤ 
      PS1="$BOLD$F_GREEN\W ➤ $END"
      ;;
    "simple")
      # [user@host]:/working/dir$ 
      PS1="\[\e[1;32m\]\u@\[\e[1;31m\]\h\[\e[1;32m\]:\w$\[\e[0m\] " 
      ;;
    "fancy")
      # [16:02][BHAC ~ ]{ master }
      # ➤ 
      PS1="$BOLD$F_BLACK[$F_WHITE\A$F_BLACK][$END$BOLD$F_GREEN\h$BOLD$F_BLACK "
      PS1+="$END$F_GREEN\w$BOLD$F_BLACK ]"
      
      # Show the exit status of the previoud command if not 0
      if [ "$EXIT" != 0 ]; then
        PS1+="$BOLD$F_RED($EXIT)$BOLD$F_BLACK"
      fi

      # Show the number of type of background jobs
      local BKGJBS=$(jobs -r | wc -l | tr -d ' ')
      local STPJBS=$(jobs -s | wc -l | tr -d ' ')
      if [ "${BKGJBS}" -gt 0 ] || [ "${STPJBS}" -gt 0 ]; then
        PS1+="${BOLD}${F_WHITE}("
        if [ "${BKGJBS}" -gt 0 ]; then 
          PS1+="bg:${BKGJBS}" 
        fi
        if [ "${BKGJBS}" -gt 0 ] && [ "${STPJBS}" -gt 0 ]; then 
          PS1+=", " 
        fi
        if [ "${STPJBS}" -gt 0 ]; then 
          PS1+="st:${STPJBS}" 
        fi
        PS1+=")${BOLD}${F_BLACK}"
      fi

      # Show the status of the git repo if this is a repo
      if [ -n "$(git branch 2> /dev/null | grep ^*)" ]; then
        PS1+="{${BOLD}${F_RED} $(__git_ps1 '%s' ) $BOLD$F_BLACK}"
      fi

      PS1+="\n$END"
      PS1+="$BOLD${F_BLACK}➤ $END"

      ;;
    "blue")
      # [16:02][BHAC ~ ]==>
      # $ 
      PS1="$F_BLUE[$BOLD\A$END$F_BLUE][$END$BOLD$F_MAGENTA\h$END$F_BLUE "
      PS1+="\w ]"
      PS1+="==>\n$END"
      PS1+="$F_BLUE$ $END"
      ;;
    "git-only")
      EDITOR=nano
      PS1="\u@$F_GREEN\h$END{$F_RED"
      PS1+='`git symbolic-ref HEAD 2>/dev/null | cut -b 12-`'
      PS1+="$END}:\w$ "
      ;;
    "uberclean")
      PS1="➤ "
      ;;
    *)
      # [user@host]:/working/dir$
      PS1="\u@\h:\w$ "
      ;;
  esac
  export PS1
}

function pstyle {
  export PSTYLE=$1
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
