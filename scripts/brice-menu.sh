#!/bin/bash

source /home/$(whoami)/scripts/ems-env.sh
PATH=$PATH:/home/$(whoami)/scripts

CMD=`ls $(echo $PATH | tr ':' ' ')  | grep -v "/:" | sort | uniq | dmenu -i -b -nb black -nf white -sb red -sf white -fn `

$CMD

