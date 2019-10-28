#!/bin/bash

## log file location - create this manually
log="/home/pi/wifi.log"

## loop counter
count=0

## router address
#router=`/sbin/ip route | awk '/default/ { print $3 }'`
router=192.168.20.1

## ping router to test for wlan0 state
ping -c4 $router
pingtest=$?

## restart wlan0 if ping fails
while [ $pingtest != 0 ]
do
  ## reboot system after 10 fails 
  if [ $count -eq 9 ]
    then
      echo $(date '+%m-%d-%Y %T') "Network connection unrecoverable, rebooting." >> $log
      sudo /sbin/shutdown -r now
  fi
  
  echo "" >> $log
  if [ $count -lt 1 ]
    then
      echo $(date '+%m-%d-%Y %T') "Network connection is down." >> $log
      echo $(date '+%m-%d-%Y %T') "Running check internet script." >> $log
      
      ## run network test and allow time to run - can remove if unwanted
      bash /home/pi/check_internet.sh
      sleep 15
    else
      echo $(date '+%m-%d-%Y %T') "Network connection is still down!" "[" $count "]" >> $log
  fi
  
  echo "" >> $log
  echo $(date '+%m-%d-%Y %T') "Restarting wlan0." >> $log
  
  ## restart wlan0 interface
  sudo ip link set wlan0 down
  sleep 2
  sudo ip link set wlan0 up
  sleep 5

  ## ping router to test for wlan0 state
  ping -c4 $router
  pingtest=$?

  if [ $pingtest -eq 0 ]
  then
    ## success, connection back up!
    echo $(date '+%m-%d-%Y %T') "Network connection re-established." >> $log
    echo $(date '+%m-%d-%Y %T') "Running check internet script again." >> $log
    
    ## run network test again and allow time to run - can remove if unwanted
    bash /home/pi/check_internet.sh
    sleep 15
    
    ## exit loop
    break
  fi

  ## increment count
  let count++
done

exit 0
