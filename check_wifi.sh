#!/bin/bash

## log date
#echo "script executed: " $(date '+%m-%d-%Y %T') >> $wifi_log

# log file location
wifi_log="/home/pi/wifi.log"
network_log="/home/pi/connection.log"

## ping router to test for wlan0 up state
ping -c4 192.168.20.1 > /dev/null

## restart wlan0 if ping fails
if [ $? != 0 ]
then
  echo $(date '+%m-%d-%Y %T') "Network connection is down." >> $wifi_log
  echo $(date '+%m-%d-%Y %T') "Running check internet script (see connection.log)" >> $wifi_log

  # run network test
  echo "START====================================" >> $network_log
  echo $(date '+%m-%d-%Y %T') "Network connection is down" >> $network_log
  sh /home/pi/check_internet.sh
  sleep 10

  # restart wlan0
  echo $(date '+%m-%d-%Y %T') "restarting wlan0" >> $wifi_log
  sudo /etc/init.d/networking restart
  sleep 5

  ## ping router to test for wlan0 up state
  ping -c4 192.168.20.1 > /dev/null

  if [ $? -eq 0 ]
  then
    echo $(date '+%m-%d-%Y %T') "network connection re-established" >> $wifi_log
    echo >> $network_log
    echo $(date '+%m-%d-%Y %T') "network connection re-established" >> $network_log
  else
	echo $(date '+%m-%d-%Y %T') "network is still down" >> $wifi_log
        echo >> $network_log
        echo $(date '+%m-%d-%Y %T') "network is still down" >> $network_log
  fi

  # run network test again
  echo $(date '+%m-%d-%Y %T') "Running check internet script again (see connection.log)" >> $wifi_log
  sh /home/pi/check_internet.sh
  echo "======================================END" >> $network_log

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
