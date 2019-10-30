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
fi

## backup log name
backup="wifi.log."$date

## check log has been written to - empty log returns 1                                                                  
line_count=$(< $log wc -l)

## exit on empty log - no need to backup                                                                                
if [ $line_count == 1 ]                                                                                                   
  then
    exit 0
fi

## make sure backup log hasn't been made today
exists=$(find "$dir" -name "$backup")

## if today's log already exists, add timestamp, otherwise use date only
if [ "$exists" == "$dir$backup" ]
  then
    ## backup log with date and timestamp
    cat $log > $dir$backup.$time
  else
    ## backup log with date only
    cat $log > $dir$backup
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
