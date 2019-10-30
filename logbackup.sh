#!/bin/bash

date=$(date '+%m-%d-%Y')
time=$(date '+%T')

## log header
header="### wifi log ###"

## full path to log file
log="/home/pi/wifi.log"

## full path to backup directory
dir="/home/pi/logs/"

## if log directory doesn't exist, make it
if [ ! -d "$dir" ]
  then
    mkdir -p $dir
fi

## backup log name
backup=$dir"wifi.log."$date

## make sure backup log hasn't been made today
exists=$(find $dir -wholename $backup)

## ask user if today's log already exists
if [ "$exists" == "$backup" ]
  then
    read -n1 -p "today's log exists press '1' to overwrite '2' to add timestamp or '3' to exit" ans
    case $ans in
      1) echo && echo "continuing with log overwrite . . ." ;;
      2) echo && echo "adding timestamp to filename . . ."; backup=$backup.$time ;;
      3) echo && echo "exiting . . ."; exit ;;
      *) echo && echo "unknown answer . . . exiting to be safe"; exit ;;
    esac
fi

## backup log
echo "backing up latest log to: " $backup
cat $log >> $backup
sleep 1

## confirm backup copy successful
cmp --silent $log $backup
match=$?

if [ $match != 0 ]
  then
    echo "backup does not match original, exiting to prevent unwanted log deletion"
    exit 1
fi

# reset log
echo "resetting wifi.log . . ."
echo $header > $log

sleep 1
echo

## count lines in logs to confirm reset - return 1 expected
lines_reset=$(< $log wc -l)

## print status
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

echo

exit 0
