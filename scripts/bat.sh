#!/bin/bash
##
#
# A simple battery script giving a short and sweet battery message.
#
# Can probably be improved. The use of grep to get the last word really 
# ought to be sed or similar, but I couldn't be bothered to look up the 
# syntax. Feel free to modify at will. (improvements more than welcome!).
#
# Dependencies:
#	bc
#	acpi in kernel
#
# @author brice.fernandes@gmail.com
#
##

PRESENT=`cat /proc/acpi/battery/BAT0/state | grep -o "present:.*$" |grep -o "yes"`

if [[ "$PRESENT" = "yes" ]]; then
	STATUS=`cat /proc/acpi/battery/BAT0/state | grep -o "charging state:.*$" | grep -E -o "[a-zA-Z]*$"`
	CAPACITY=`cat /proc/acpi/battery/BAT0/info | grep "design capacity:" | grep -E -o "[0-9]{3,5}"`
	CHARGE=`cat /proc/acpi/battery/BAT0/state| grep "remaining capacity:" | grep -E -o "[0-9]{2,5}"`
	PERCENT=`echo "scale=2; ($CHARGE/$CAPACITY)*100" | bc | grep -E -o "[0-9]{1,3}" | grep -v "^00" | tr -d "\n\r"`;
	
	RATE=`cat /proc/acpi/battery/BAT0/state| grep "present rate:" | grep -E -o "[0-9]{1,4}"`
	TIME=`echo "scale=2; ($CHARGE/$RATE)" | bc | tr -d "\n\r"`
	HOURS=`echo "scale=0; ($TIME/1)" |bc`
	MINUTES=`echo "scale=0; (($TIME-($TIME/1))*60/1)" |bc`
	
	#echo -e "stat=$STATUS\ncap=$CAPACITY\ncharge=$CHARGE\n%=$PERCENT\nrate=$RATE\ntime=$TIME\nhours=$HOURS\nmins=$MINUTES"
	
	
	#check if minutes is singular and add leading zero
	if [[ `echo $MINUTES| grep -E "^[0-9]{1}$"` ]]; then
		MINUTES="0$MINUTES";
	fi;
	
	if [[ "$STATUS" == "charging" ]]; then
		sleep 0;
	elif [[ "$STATUS" == "charged" ]]; then
		sleep 0;
	else
		STATUS="($HOURS:$MINUTES)";
	fi;
	echo "$PERCENT% $STATUS";
else
	echo "not present"
fi

