#!/bin/bash

PREFIX=/home/bfer/files/branches/vectastar-3-3-20-red-e1-opt-branch


export LD_LIBRARY_PATH=$PREFIX/Linux_Desktop_x86_64/INSTALLROOT/usr/local/vectastar/lib
export PATH=$PREFIX/nms-manager-apps/scripts:$PREFIX/Linux_Desktop_x86_64/INSTALLROOT/usr/local/vectastar/bin:$PATH
export EMS_BINARY_ROOT=$PREFIX/nms-manager-apps/scripts
export EMS_SYSTEM_ROOT=$PREFIX/INSTALLROOT/

export EMS_ROOT=/home/bfer/files/vnms_data
export EMS_CONFIG_ROOT=$EMS_ROOT/conf
export EMS_ALARM_ROOT=$EMS_ROOT/alarms
export EMS_DATA_ROOT=$EMS_ROOT/data

export rackA=192.168.110.3
export rackA_id=18041686

alias racka="ssh -Y root@$rackA"

