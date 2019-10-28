#!/bin/bash

# full path to log file location
wifi_log="/home/pi/wifi.log"

# full path to log reset file location - backup logfile with 1 line header only
wifi_log_reset="/home/pi/wifi_reset.log"

# reset log
echo "resetting wifi.log. . ."
cp $wifi_log_reset $wifi_log

sleep 1
echo ""

## count lines in log to confirm reset - return 1 expected
lines_wifi_log=$(< $wifi_log wc -l)

## alternate count line methods
  ## method 2
    #lines_wifi=$(grep "" -c $wifi_log)
  ## method 3
    #lines_wifi=$(wc -l $wifi_log | awk '{ print $1 }')

## print status
if [ $lines_wifi_log == 1 ]
  then
    echo "      wifi log reset      [ SUCCESS ]"
  else
    echo "      wifi log reset      [ FAIL    ]"
fi

echo ""
