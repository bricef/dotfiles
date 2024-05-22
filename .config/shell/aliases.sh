
# alias ll="ls -lh"
# alias la="ls -A"
# alias lla="ls -lA"
# alias l="ls"
# alias lh="ls -lhA"
# alias lsa="ls -iablh"

eza_params=(
  '--git' '--icons' '--group' '--group-directories-first'
  '--time-style=long-iso' '--color-scale=all'
)

alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'


alias psg="ps aux | grep "
alias sudo="sudo "
alias grep="grep --color=auto"
alias tmux="tmux -2"
alias bp="bpython"
alias rebash="source ~/.bashrc"
alias t="htt"
alias qt="git qt"
alias ls="ls -G --color=auto -X"
alias lsa="ls -iablhQ"
alias lsc="ls *.c -1"
alias lsh="ls -1 *.h"
alias psg="ps aux | grep "
alias _x="chmod +x"
alias :e="vim"
alias :q="exit"
alias cd..="cd .."
alias ..="cd .."
alias icat="kitten icat"

