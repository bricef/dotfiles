#!/bin/bash

source /home/$(whoami)/scripts/ems-env.sh
test -e /home/$(whoami)/.bashrc && source /home/$(whoami)/.bashrc
PATH=$PATH:/home/$(whoami)/scripts
CACHEFILE="/home/$(whoami)/.config/brice-menu.cache"

reload (){
  ls $(echo $PATH | tr ':' ' ') | grep -v "^/.*:$" | sort | uniq > $CACHEFILE
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

CMD=`echo @reload | cat $CACHEFILE - | dmenu -i -b -nb black -nf white -sb red -sf white`

if [ "$CMD" == "@reload" ]; then
  reload;
  exit;
fi

$CMD

