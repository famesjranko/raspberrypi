#!/bin/bash

## current date/time
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
   echo "1"
fi

## backup log name
backup="wifi.log."$date

## make sure backup log hasn't been made today
exists=$(find "$dir" -name "$backup")

## if today's log already exists, add timestamp, otherwise use date only
if [ "$exists" == "$dir$backup" ]
  then
    ## create log backup file
    touch $dir$backup.$time

    ## backup log
    cp $log $backup
  else
    ## create log backup file
    touch $dir$backup

    ## backup log
    cp $log $backup
fi

## confirm backup copy successful
cmp --silent $log $backup
match=$?

if [ $match != 0 ]
  then
    echo "5"
    # if backup doesn't match original, exit to prevent unwanted log deletion
    # could output failure to an error.log file if wanted
    exit 1
fi

## safe to reset log
echo $header > $log

exit 0
