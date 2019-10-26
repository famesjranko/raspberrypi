#!/bin/bash

## router gateway address
router=192.168.20.1

## preferred upstream dns address
#checkdns=8.8.8.8
#checkdns=1.1.1.1
#checkdns=9.9.9.9
checkdns=156.154.70.5

## preferred domain address
checkdomain=google.com
#checkdomain=facebook.com
#checkdomain=yahoo.com

## log location
log='/home/pi/connection.log'

## Log date/time of execution
echo >> $log
echo "script exectuted:    " $(date '+%m-%d-%Y %T') >> $log

## Test functions
interfacestate()
{
  ## Check wlan0 interface state
  wlan0_state=$(cat /sys/class/net/wlan0/operstate)
  if [ $wlan0_state == "up" ]
    then
      echo "wlan0                           [ UP      ]" >> $log
    else
      echo "wlan0                           [ DOWN    ]" >> $log
  fi
}

portscan()
{
  ## Test connection on port 80
  if nc -zw1 $checkdomain  80; then
    echo "Scan Port 80                    [ SUCCESS ]" >> $log
  else
    echo "Scan port 80                    [ FAIL    ]" >> $log
  fi
}

pingnet()
{
  ## Test connection to internet
  ping $checkdomain -c 4

  if [ $? -eq 0 ]
    then
      echo "Check access to $checkdomain      [ SUCCESS ]" >> $log
    else
      echo "Check access to $checkdomain      [ FAIL    ]" >> $log
#      exit 1
  fi
}

pingdns()
{
  ## Test connection to upstream DNS
  ping $checkdns -c 4
    if [ $? -eq 0 ]
    then
      echo "Check DNS ($checkdns)        [ SUCCESS ]" >> $log
    else
      echo "Check DNS ($checkdns)        [ FAIL    ]" >> $log
#     exit 1
  fi
}

httpreq()
{
  ## Test HTTP connection
  case "$(curl -s --max-time 2 -I $checkdomain | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23])  echo "Check HTTP connection           [ SUCCESS ]" >> $log;;
  5)     echo "Check HTTP connection           [ FAIL    ]" >> $log;exit 1;;
  *)     echo "Check HTTP connection           [ FAIL    ]"; exit 1;;
  esac
#  exit 0
}

## Ping gateway first to confirm LAN connection
ping $router -c 4

if [ $? -eq 0 ]
then
  interfacestate
  echo "Ping Gateway ($router)     [ SUCCESS ]" >> $log
  pingdns
  pingnet
  portscan
  httpreq
  exit 0
else
  interfacestate
  echo "Ping Gateway ($router)     [ FAIL    ]" >> $log
  pingdns
  pingnet
  portscan
  httpreq
#  exit 1
fi
