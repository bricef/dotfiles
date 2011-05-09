# .bashrc

shopt -s autocd

export HISTCONTROL=erasedups
export HISTSIZE=3000
export HISTFILESIZE=3000
export HISTIGNORE="ls:ll:l:la:lla:pwd:..:cd..:cd ..:"

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


export CVSROOT=:pserver:bfer@cvshost:/newcvs


export PS1="\[\e[1;32m\]\u@\[\e[1;31m\]\h\[\e[1;32m\]:\w$\[\e[0m\] "
#PS1="PS1="\[\e[1;32m\][\[\e[0;32m\]\u@\[\e[0;31m\]\h\[\e[0;32m\]:\w\[\e[1;32m\]]>\[\e[0m\]"

export PATH=$PATH:/home/bfer/scripts

source ~/scripts/ems-env.sh
