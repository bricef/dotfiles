#!/bin/bash



PATH=$PATH:/home/brice/scripts

CMD=`ls $(echo $PATH | tr ':' ' ')  | grep -v "/:" | sort | uniq | dmenu -i -b -nb black -nf white -sb red -sf white -fn `

$CMD

