#!/bin/bash

Date=$(date '+%m-%d-%Y')

## log file location
logheader="/home/pi/wifi.log"

## log header
header="### wifi log"

## log backup destinateion
backup="/home/pi/wifi.log."$Date

## make sure backup log hasn't been made today
find /home/pi/ -wholename $backup
logexists=$?

## ask user if today's log already exists
if [ $logexists == 0 ]
  then
    read -n1 -p "do you want to overwrite? y/n" ans
    case $ans in
      y|Y) echo && echo "continuing with log overwrite . . .";;
      n|N) echo && echo "exiting to prevent unwanted overwrite . . ."; exit ;;
      *) echo && echo "unknown answer: exiting to be safe"; exit ;;
    esac
  else
    ## create log backup file
    touch $backup
fi

## backup log
echo "backing up latest log to: " $backup
cp $log $backup

## confirm backup exists
find /home/pi/ -wholename $backup
filefound=$?

## exit if backup not found
if [ $filefound != 0 ]
  then
    echo "backup file not found, something went wrong, exiting . . ."
	exit
fi

## confirm backup copy successful
cmp --silent $log $backup
match=$?

if [ $match != 0 ]
  then
    echo "backup does not match original, exiting to prevent unwanted log deletion"
    exit
fi

# reset log
echo "resetting wifi.log . . ."
echo $logheader > $log

sleep 1
echo ""

## count lines in logs to confirm reset - return 1 expected
lines_reset=$(< $log wc -l)

## alternate count methods
  ## method 2
     #lines_wifi=$(grep "" -c $wifi_log)
  ## method 3
     #lines_wifi=$(wc -l $wifi_log | awk '{ print $1 }')

## print status
if [ $filefound -eq 0 ]
  then
    echo "      create backup         [ SUCCESS ]"
  else
    echo "      create backup         [ FAIL    ]"
fi

if [ $match -eq 0 ]
  then
    echo "      backup matches log    [ SUCCESS ]"
  else
    echo "      backup matches log    [ FAIL    ]"
fi

if [ $lines_reset == 1 ]
  then
    echo "      reset log             [ SUCCESS ]"
  else
    echo "      reset log             [ FAIL    ]"
fi

echo ""
