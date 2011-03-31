#!/bin/bash


source /home/bfer/scripts/ems-env.sh

PATH=$PATH:/home/bfer/scripts

CMD=`ls $(echo $PATH | tr ':' ' ')  | grep -v "/:" | sort | uniq | dmenu -i -b -nb black -nf white -sb red -sf white -fn `

$CMD

