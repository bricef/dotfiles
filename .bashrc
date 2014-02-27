# .bashrc

# propagate error status along pipes
# useful for the "foo | bar | buzz && hello" construct
set -o pipefail 

EDITOR=vim

shopt -s autocd
shopt -s checkwinsize
shopt -s histappend

export HISTCONTROL=erasedups
export HISTSIZE=3000
export HISTFILESIZE=3000
export HISTIGNORE="ls:ll:l:la:lla:pwd:..:cd..:cd ..:"
export EDITOR="vim"

# Append commands to the history every time a prompt is shown,
# instead of after closing the session.
PROMPT_COMMAND='history -a'

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


#
# Source git helpers if they're there.
#
test -f ~/scripts/git-completion.bash && source ~/scripts/git-completion.bash 
test -f ~/scripts/git-prompt.sh && source ~/scripts/git-prompt.sh 
# Show dirty state of branch
GIT_PS1_SHOWDIRTYSTATE=true


alias sudo="sudo "
alias grep="grep --color=auto"

alias ..="cd .."
alias tmux="tmux -2"
alias cd..="cd .."
alias ls="ls --color=auto -X"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias l="ls"
alias +x="chmod +x"
alias bp="bpython"
# When you feel desperate
alias lsa="ls -iablhQ"
alias lsc="ls *.c -1"
alias lsh="ls -1 *.h"
alias psg="ps aux | grep "

# because my fingers have been trained
alias :e="vim"
alias :q="exit"
export LS_COLORS="di=35"


B_BLACK="\[\e[40m\]"
B_RED="\[\e[41m\]"
B_GREEN="\[\e[42m\]"
B_YELLOW="\[\e[43m\]"
B_BLUE="\[\e[44m\]"
B_MAGENTA="\[\e[45m\]"
B_CYAN="\[\e[46m\]"
B_WHITE="\[\e[47m\]"

F_BLACK="\[\e[30m\]"
F_RED="\[\e[31m\]"
F_GREEN="\[\e[32m\]"
F_YELLOW="\[\e[33m\]"
F_BLUE="\[\e[34m\]"
F_MAGENTA="\[\e[35m\]"
F_CYAN="\[\e[36m\]"
F_WHITE="\[\e[37m\]"

BOLD="\[\e[1m\]"

END="\[\e[0m\]"


# special characters: ⚡ ↑↓↕ ☠☢➤✔✘
# see also http://www.utf8-chartable.de/unicode-utf8-table.pl

# uname@host:/working/dir$ _ 
#export PS1="\[\e[1;32m\]\u@\[\e[1;31m\]\h\[\e[1;32m\]:\w$\[\e[0m\] "

# [uname@host:/working/dir]>_
#export PS1="\[\e[1;32m\][\[\e[0;32m\]\u@\[\e[0;31m\]\h\[\e[0;32m\]:\w\[\e[1;32m\]]>\[\e[0m\]"

# ==[uname@host /working/dir ]==> 
# _
#export PS1="\[\e[1;32m\]==[\[\e[0m\]\u@\h \w \[\e[1;32m\]]==>\[\e[0m\] \n"

# [ uname@host ]( /working/dir )>
# $ _


function pstyle {
case $1 in
  "simple")
    PS1="\[\e[1;32m\]\u@\[\e[1;31m\]\h\[\e[1;32m\]:\w$\[\e[0m\] "
    ;;
  "fancy")
    # [16:02][BHAC ~ ]{ master }
    # ➤ 
    PS1="$BOLD$F_BLACK[$F_WHITE\A$F_BLACK][$END$BOLD$F_GREEN\h$BOLD$F_BLACK "
    PS1+="$END$F_GREEN\w$BOLD$F_BLACK ]"
    PS1+='`test "$(git branch 2> /dev/null | grep ^*)" && echo "{ "`'
    PS1+="$BOLD$F_RED"
    PS1+='$(__git_ps1 "%s" )'
    PS1+="$BOLD$F_BLACK"
    PS1+='`test "$(git branch 2>/dev/null| grep ^*)" && echo " }"`'
    PS1+="\n$END"
    PS1+="$BOLD$F_BLACK➤ $END"
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
  *)
    PS1="\u@\h:\w$ "
    ;;
esac
export PS1
}


case `hostname` in 
  "prometheus"|"barracuda")
    pstyle blue
    ;;
  "vsbldhost")
    pstyle simple
    ;;
  *)
    pstyle fancy
    ;;
esac



function ds {
  dir=$(~/scripts/dirstack.py "$@")
  test $dir && echo "cd $dir" && cd $dir
}


function pgen {
  </dev/urandom tr -dc A-Za-z0-9 | head -c $1 | cat - <(echo "")
}


PATH=/usr/local/texlive/2012/bin/x86_64-linux:$PATH
PATH=$PATH:/home/$(whoami)/scripts:
PATH=$PATH:/home/$(whoami)/.cabal/bin
PATH=$PATH:/opt/VirtualBox/
PATH=$PATH:/opt/arduino-0022/
PATH=$PATH:/opt/processing-1.5.1/
PATH="/usr/local/heroku/bin":$PATH
PATH=$PATH:$(ruby -rubygems -e "puts Gem.user_dir")/bin
export PATH

export LC_ALL=en_GB.UTF-8
export LC_CTYPE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8


function bprint {
  <$1 fold -w 72 | pr -F -o3 -h $1 | tee >( lpr )
}

function pprint {
  a2ps -R -T4 --columns=1 --borders=off --header="" --left-footer="" --right-footer="" --line-numbers=1 -f 10 --pro=color -o out.ps $1
  echo "File in out.ps"
}

