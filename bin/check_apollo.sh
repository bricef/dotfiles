#!/bin/bash


snmpwalk -v2c -c public apollo16 1.3.6.1.4.1.5419.3.3500.25.1.1.2 | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ " | while read line; do 

  snmpget -v2c -c public apollo16 1.3.6.1.4.1.5419.3.3500.25.2.1.2.$line.2 | awk '{print $4}' | while read stat; do if [[ "$stat" = "1" ]]; then echo "$line port type   [OK] "; else echo "$line port type   [FAIL]";fi ;done; 
  snmpget -v2c -c public apollo16 1.3.6.1.4.1.5419.3.3500.25.2.1.3.$line.2 | awk '{print $4}' | while read stat; do if [[ "$stat" = "1" ]]; then echo "$line port status [OK] "; else echo "$line port status [FAIL]";fi ;done; 
  snmpget -v2c -c public apollo16 1.3.6.1.4.1.5419.3.3500.25.2.1.4.$line.2 | awk '{print $4}' | while read stat; do if [[ "$stat" = "" ]];  then echo "$line port alarms [OK] "; else echo "$line port alarms [FAIL]";fi ;done; 



done

