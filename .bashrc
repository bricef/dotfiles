# .bashrc

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


export LS_COLORS="di=35"


export CVSROOT=:pserver:bfer@cvshost:/newcvs

# uname@host:/working/dir$ _ 
#export PS1="\[\e[1;32m\]\u@\[\e[1;31m\]\h\[\e[1;32m\]:\w$\[\e[0m\] "

# [uname@host:/working/dir]>_
#export PS1="\[\e[1;32m\][\[\e[0;32m\]\u@\[\e[0;31m\]\h\[\e[0;32m\]:\w\[\e[1;32m\]]>\[\e[0m\]"

# ==[uname@host /working/dir ]==> 
# _
#export PS1="\[\e[1;32m\]==[\[\e[0m\]\u@\h \w \[\e[1;32m\]]==>\[\e[0m\] \n"

# [ uname@host ]( /working/dir )>
# $ _
export PS1="\[\e[1;34m\][\[\e[1;33m\] \u@\[\e[1;31m\]\h\[\e[1;33m\] \[\e[1;34m\]]( \[\e[1;33m\]\w\[\e[1;34m\] )>\[\e[0m\]\n\[\e[1;34m\]$\[\e[0m\] "


export PATH=$PATH:/home/$(whoami)/scripts:/opt/VirtualBox/:/opt/arduino-0022/:/opt/processing-1.5.1/

source ~/scripts/ems-env.sh
alias vsbackup="sudo /usr/local/vectastar/bin/vsbackup.py"
alias vssetup="sudo /usr/local/vectastar/bin/vssetup"
export LC_ALL=en_GB.UTF-8
export LC_CTYPE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8
