#! /bin/bash

col1="\e[1;37m"
col2="\e[1;34m"

ESSID=$1

LOGFILE=~/.wpa.log

MAC_H=00:17:de:43:f5:a9

tell (){
  echo -e "${col2}::${col1} $@\e[m"
}

sudo killall wpa_supplicant &> $LOGFILE
sudo killall dhcpcd &>> $LOGFILE

tell Bringing down wlan
sudo ifconfig wlan0 down

tell Correcting MAC address
#sudo ifconfig wlan0 hw ether $MAC_H

tell Bringing wlan0 up
sudo ifconfig wlan0 up

tell Associating with essid
sudo iwconfig wlan0 essid $ESSID

tell Running wpa_supplicant
sudo wpa_supplicant -Dwext -iwlan0 -c/etc/wpa_supplicant.conf >> $LOGFILE &

sleep 3

tell Requesting IP via DHCP
sudo dhcpcd wlan0 


