#!/bin/bash

# log file location
wifi_log="/home/pi/wifi.log"
network_log="/home/pi/connection.log"

# log reset file location
wifi_log_reset="/home/pi/wifi.log2"
network_log_reset="/home/pi/connection.log2"

# reset both logs
echo "resetting wifi.log. . ."
cp $wifi_log_reset $wifi_log
echo "resetting connection.log. . ."
cp $network_log_reset $network_log

sleep 1
echo ""
## count lines in logs to confirm reset
lines_wifi=$(< $wifi_log wc -l)
lines_connection=$(< $network_log wc -l)

## alternate count methods
## method 2
#lines_wifi=$(grep "" -c $wifi_log)
#lines_connection=$(grep "" -c $network_log)
## method 3
#lines_wifi=$(wc -l $wifi_log | awk '{ print $1 }')
#lines_connection=$(wc -l $network_log | awk '{ print $1 }')

## print status
if [ $lines_wifi == 1 ]
  then
    echo "      wifi log reset      [ SUCCESS ]"
  else
    echo "      wifi log reset      [ FAIL    ]"
fi

if [ $lines_connection == 1 ]
  then
    echo "connection log reset      [ SUCCESS ]"
  else
    echo "connection log reset      [ FAIL    ]"
fi

echo ""
