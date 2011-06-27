#! /bin/bash

col1="\e[1;37m"
col2="\e[1;34m"

ESSID=$1

MAC_H=00:18:de:39:0a:a0

echo -e "${col2}::${col1} Killing existing processes\e[m"
sudo killall wpa_supplicant &>> /home/brice/wpa.log
sudo killall dhcpcd &>> /home/brice/wpa.log

echo -e "${col2}::${col1} Bringing down wlan0\e[m"
sudo ifconfig wlan0 down

echo -e "${col2}::${col1} Correcting MAC address\e[m"
sudo ifconfig wlan0 hw ether $MAC_H

echo -e "${col2}::${col1} Bringing wlan0 up\e[m"
sudo ifconfig wlan0 up

echo -e "${col2}::${col1} Associating with essid\e[m"
sudo iwconfig wlan0 essid $ESSID

echo -e "${col2}::${col1} Running wpa_supplicant\e[m"
sudo wpa_supplicant -Dwext -iwlan0 -c/home/brice/wpa_supplicant.conf >> /home/brice/wpa.log &

sleep 3

echo -e "${col2}::${col1} Requesting IP via DHCP\e[m"
sudo dhcpcd wlan0 


