#!/bin/bash

# log file location
log="/home/pi/wifi.log"

## log attempt
#echo "script executed: " $(date '+%m-%d-%Y %T') >> $log

## ping router to test for wlan0 up state
ping -c4 192.168.20.1 > /dev/null

## restart wlan0 if ping fails
if [ $? != 0 ]
then
  echo  $(date '+%m-%d-%Y %T') >> $log
  echo "Network connection is down." >> $log
  echo "Running check internet script (see connection log)" >> $log

  # run network test script
  sh /home/pi/check_internet.sh
  sleep 10

  # restart wlan0
  echo "restarting wlan0" >> $log
  /sbin/ifdown 'wlan0'
  sleep 5
  /sbin/ifup --force 'wlan0'
  echo "wlan0 restarted" >> $log

  # run network test script again
  echo "Running check internet script again (see connection log)" >> $log
  sh /home/pi/check_internet.sh

#else
#  echo  $(date '+%m-%d-%Y %T') >> $log
#  echo "network connection is up" >> $log
#  sh /home/pi/check_internet.sh
fi

## reboot pi if ping fails
#if [ $? != 0 ]
#then
#  sudo /sbin/shutdown -r now
#fi
