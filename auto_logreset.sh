#!/bin/bash

## current date/time
date=$(date '+%m-%d-%Y')
time=$(date '%T')

## log file location
log="/home/pi/wifi.log"

## log header
header="### wifi log"

## log backup destinateion
backup="/home/pi/logs/wifi.log."$date

## log directory
dir="/home/pi/logs"

if [ ! -d "$dir" ] 
  then
    mkdir -p $dir
fi

## make sure backup log hasn't been made today
find /home/pi/logs -wholename $backup
logexists=$?

## if today's log already exists, add timestamp, otherwise use date only
if [ $logexists == 0 ]
  then
    backup=$backup.$time
	touch $backup
  else
    ## create log backup file
    touch $backup
fi

## backup log
cp $log $backup

## confirm backup exists
find /home/pi/ -wholename $backup
filefound=$?

## exit if backup not found
if [ $filefound != 0 ]
  then
    # if backup file not found, exit to prevent unwanted log deletion
	# could output failure to an error.log file if wanted
	exit 1
fi

## confirm backup copy successful
cmp --silent $log $backup
match=$?

if [ $match != 0 ]
  then
    # if backup doesn't match original, exit to prevent unwanted log deletion
	# could output failure to an error.log file if wanted
    exit 1
fi

## reset log
echo $header > $log
exit 0
