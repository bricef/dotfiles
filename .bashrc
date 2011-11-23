# .bashrc

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


alias grep="grep --color=auto"

alias ..="cd .."
alias cd..="cd .."
alias ls="ls --color=auto"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias l="ls"
alias +x="chmod +x"
# When you feel desperate
alias lsa="ls -iablhQ"
alias lsc="ls *.c -1"
alias lsh="ls -1 *.h"
alias psg="ps aux | grep "

export LS_COLORS="di=35"


export CVSROOT=:pserver:bfer@cvshost:/newcvs

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


# special characters: ⚡ ↑↓↕ ☠☢ 
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

case `hostname` in
  "bob")
    PS1="\[\e[1;32m\]\u@\[\e[1;31m\]\h\[\e[1;32m\]:\w$\[\e[0m\] "
    ;;
  "element-sim"|"sparrow"|"lappy"|"engbot"|"BHAC")
    # [16:02][BHAC ~ ]{ master }>
    # $ 
    PS1="$BOLD$F_BLACK[$F_WHITE\A$F_BLACK][$END$BOLD$F_GREEN\h$BOLD$F_BLACK "
    PS1+="$END$F_GREEN\w$BOLD$F_BLACK ]"
    PS1+='`test "$(git branch 2> /dev/null | grep ^*)" && echo "{ "`'
    PS1+="$BOLD$F_RED"
    PS1+='`git branch --color=never 2>/dev/null | grep --color=never ^* | sed "s/^* \(.*\)/\1/"`'
    PS1+="$BOLD$F_BLACK"
    PS1+='`test "$(git branch 2>/dev/null| grep ^*)" && echo " }"`'
    PS1+=">\n$END"
    PS1+="$BOLD$F_BLACK$ $END"
    ;;
  "LOMOND")
    EDITOR=nano
    PS1="\u@$F_GREEN\h$END{$F_RED"
    PS1+='`git branch --color=never 2>/dev/null | grep --color=never ^* | sed "s/^* \(.*\)/\1/"`'
    PS1+="$END}:\w$ "
    ;;
  *)
    PS1="\u@\h:\w$ "
    ;;
esac
export PS1


function ds {
  dir=$(~/scripts/dirstack.py "$@")
  test $dir && echo "cd $dir" && cd $dir
}


export PATH=$PATH:/home/$(whoami)/scripts:/var/lib/gems/1.8/bin:/home/$(whoami)/.cabal/bin:/opt/VirtualBox/:/opt/arduino-0022/:/opt/processing-1.5.1/

alias vsbackup="sudo /usr/local/vectastar/bin/vsbackup.py"
alias vssetup="sudo /usr/local/vectastar/bin/vssetup"
export LC_ALL=en_GB.UTF-8
export LC_CTYPE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8
