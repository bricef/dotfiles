


# If not running interactively, don't do anything
[[ $- != *i* ]] && return


SMART_PROFILE="${HOME}/.config/shell/profile-common"
test -r $SMART_PROFILE && source $SMART_PROFILE

