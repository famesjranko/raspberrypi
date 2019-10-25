#!/bin/bash

# collect local network gateway and DNS addresses
GW=`/sbin/ip route | awk '/default/ { print $3 }'`
checkdns=`cat /etc/resolv.conf | awk '/nameserver/ {print $2}' | awk 'NR == 1 {print; exit}'`

#set domain lookup address
checkdomain=google.com

# log file location
log='/home/pi/connection.log'

# print date/time of script execution
echo >> $log
echo "script exectuted:    " $(date '+%m-%d-%Y %T') >> $log

# some functions
function portscan
{
  if nc -zw1 $checkdomain  80; then
    tput setaf 2; echo "Scan Port 80                    [SUCCESS]" >> $log; tput sgr0;
  else
    echo               "Scan port 80                    [FAIL]" >> $log
  fi
}

function pingnet
{
  # Google has the most reliable host name. Feel free to change it.
  ping $checkdomain -c 4

  if [ $? -eq 0 ]
    then
      echo             "Check access to $checkdomain      [SUCCESS]" >> $log
    else
      echo             "Check access to $checkdomain      [FAIL]" >> $log
#      exit 1
  fi
}

function pingdns
{
  # Grab first DNS server from /etc/resolv.conf
  ping $checkdns -c 4
    if [ $? -eq 0 ]
    then
      echo             "Check DNS ($checkdns)           [SUCCESS]" >> $log
    else
      echo             "Check DNS ($checkdns)           [FAIL]" >> $log
#     exit 1
  fi
}

function httpreq
{
  case "$(curl -s --max-time 2 -I $checkdomain | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) tput setaf 2; echo "Check HTTP connection           [SUCCESS]" >> $log; tput sgr0;;
  5) echo              "Check HTTP connection           [FAIL]" >> $log;exit 1;;
  *)echo               "Check HTTP connection           [FAIL]"; exit 1;;
  esac
#  exit 0
}

# Ping gateway first to verify connectivity with LAN
if [ "$GW" = "" ]; then
    echo "LAN gateway not found            [FAIL]" >> $log
#    exit 1
fi

ping $GW -c 4

if [ $? -eq 0 ]
then
  echo "Ping Gateway ($GW)     [SUCCESS]" >> $log
  pingdns
  pingnet
  portscan
  httpreq
  exit 0
else
  echo "Ping Gateway ($GW)     [FAIL]" >> $log
  pingdns
  pingnet
  portscan
  httpreq
#  exit 1
fi
