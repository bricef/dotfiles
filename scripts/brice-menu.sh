#!/bin/bash

source /home/$(whoami)/scripts/ems-env.sh
PATH=$PATH:/home/$(whoami)/scripts
CACHEFILE="/home/$(whoami)/.config/brice-menu.cache"

reload (){
  ls $(echo $PATH | tr ':' ' ') | grep -v "/:" | sort | uniq > $CACHEFILE
}

test ! -d /home/$(whoami)/.config/ && mkdir -p /home/$(whoami)/.config/
test ! -f $CACHEFILE  && reload

if [ "$1" == "-r" ]; then
  reload;
fi

if [ "$1" == "--reload-only" ]; then
  reload;
  exit;
fi

CMD=`cat $CACHEFILE | dmenu -i -b -nb black -nf white -sb red -sf white -fn `

$CMD

