
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ~/.config/shell/init


if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
