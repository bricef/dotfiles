#!/bin/bash

# Locations
DATA_ROOT="${HOME}/.timelog"
LOGDIR="${DATA_ROOT}/logs"
ACTIVFILE="${DATA_ROOT}/activities"
LOGFILE=${LOGDIR}/$(date "+%Y%m%d.log")
ALIASFILE="${DATA_ROOT}/activities_aliases"

# Ensure important locations
test ! -d $LOGDIR && mkdir -p $LOGDIR
test ! -f "$ACTIVFILE" && touch "$ACTIVFILE"
test ! -f "$ALIASFILE" && touch "$ALIASFILE"

# Commands
PYTHON_CMD="/usr/local/bin/python3"
SHOWSCRIPT_CMD="${PYTHON_CMD} ${HOME}/scripts/show_timelog.py --timeline --aliasfile $ALIASFILE"
CHOOSER_CMD="${HOME}/scripts/choose -m"
LAUNCH_TERM_CMD="${HOME}/scripts/iterm-cli-mac"
EDITOR="vim"

read -r -d '' COMMANDS <<'EOF'
@week
@aliases
@show
@edit
@history
@activ
EOF

function real_path {
  OIFS=$IFS
  IFS='/'
  for I in $1
  do
    # Resolve relative path punctuation.
    if [ "$I" = "." ] || [ -z "$I" ]
      then continue
    elif [ "$I" = ".." ]
      then FOO="${FOO%%/${FOO##*/}}"
           continue
      else FOO="${FOO}/${I}"
    fi

    ## Resolve symbolic links
    if [ -h "$FOO" ]
    then
    IFS=$OIFS
    set `ls -l "$FOO"`
    while shift ;
    do
      if [ "$1" = "->" ]
        then FOO=$2
             shift $#
             break
      fi
    done
    IFS='/'
    fi
  done
  IFS=$OIFS
  echo "$FOO"
}

function add_entry_to_log {
  ENTRY=$1
  echo $prefix $ENTRY>> $LOGFILE
}

function add_entry_to_activities {
  ENTRY=$1
  cat <(echo $ENTRY) $ACTIVFILE | sort | uniq > $ACTIVFILE.tmp
  mv $ACTIVFILE.tmp $ACTIVFILE
}


prefix=$(date "+[%Y-%m-%d %H:%M]: ")



if [ $1 ]; then
  
  case "$1" in
    "working-on")
      echo $(tail -1 $LOGFILE | awk '{print substr($0, index($0, $3))}' )
      ;;
  esac

else 
   

  ENTRY=$(cat <(echo "${COMMANDS}") $ACTIVFILE | ${CHOOSER_CMD} )

  case "$ENTRY" in 
    "@show") cat $LOGFILE <(echo $prefix "@end") | $SHOWSCRIPT_CMD;;
    "@edit") $LAUNCH_TERM_CMD "$EDITOR $(real_path $LOGFILE); exit" ;;
    "@activ") $LAUNCH_TERM_CMD "$EDITOR $(real_path $ACTIVFILE); exit" ;;
    "@aliases") $LAUNCH_TERM_CMD "$EDITOR $(real_path $ALIASFILE); exit" ;;
    "@week")
      cd $LOGDIR
      echo "[RUNNING]: ${SHOWSCRIPT_CMD}"
      cat `ls -1 *.log| sort -n | tail -5` <(echo $prefix @end ) | $SHOWSCRIPT_CMD
      ;;
    "@history")
      cd $LOGDIR
      echo "[RUNNING]: ${SHOWSCRIPT_CMD}"
      cat `ls -1 *.log | sort -n` <(echo $prefix @end ) | $SHOWSCRIPT_CMD
      ;;
    "")
      #do nothing
      ;;
    *) 
      add_entry_to_activities "$ENTRY"
      add_entry_to_log "$ENTRY"
      ;;
  esac

fi
