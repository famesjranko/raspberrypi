#!/bin/bash

##    Only choose one:
##    Set local router gateway address,
##    or have it set automagically via /sbin/ip route.
#router=192.168.1.1
router=`/sbin/ip route | awk '/default/ { print $3 }'`

##    Only choose one:
##    Preferred upstream dns address,
##    or have it set automagically via /etc/resolv.conf
#checkdns=8.8.8.8
#checkdns=1.1.1.1
#checkdns=9.9.9.9
checkdns=`cat /etc/resolv.conf | awk '/nameserver/ { print $2 }'`

##    Only choose one:
##    Preferred domain address
checkdomain=google.com
#checkdomain=facebook.com
#checkdomain=yahoo.com

## log location - create this manually
## Using same log as wifi_check.sh for simplicity
log='/home/pi/wifi.log'

## Log date/time of execution
echo >> $log
printf "%-32s%-11s%b\n" "script exectuted:" "$(date '+%m-%d-%Y %T')" >> $log

## Test functions
interfacestate()
{
  ## Check wlan0 interface state
  wlan0_state=$(cat /sys/class/net/wlan0/operstate)
  if [ $wlan0_state == "up" ]
    then
      printf "%-32s%-11s%b\n" "Wlan0" "[ UP      ]" >> $log
    else
      printf "%-32s%-11s%b\n" "Wlan0" "[ DOWN    ]" >> $log
  fi
}

portscan()
{
  ## Test connection on port 80
  if nc -zw1 $checkdomain  80; then
    printf "%-32s%-11s%b\n" "Scan Port 80" "[ SUCCESS ]" >> $log
  else
    printf "%-32s%-11s%b\n" "Scan Port 80" "[ FAIL    ]" >> $log
  fi
}

pingnet()
{
  ## Test connection to internet
  ping $checkdomain -c 4

  if [ $? -eq 0 ]
    then
      printf "%-32s%-11s%b\n" "Check access to $checkdomain" "[ SUCCESS ]" >> $log
    else
      printf "%-32s%-11s%b\n" "Check access to $checkdomain" "[ FAIL    ]" >> $log
  fi
}

pingdns()
{
  ## Test connection to DNS server
  ping $checkdns -c 4
  if [ $? -eq 0 ]
    then
      printf "%-32s%-11s%b\n" "Check DNS ($checkdns)" "[ SUCCESS ]" >> $log
    else
      printf "%-32s%-11s%b\n" "Check DNS ($checkdns)" "[ FAIL    ]" >> $log
  fi
}

httpreq()
{
  ## Test HTTP connection
  case "$(curl -s --max-time 2 -I $checkdomain | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23])  echo "Check HTTP connection           [ SUCCESS ]" >> $log;;
  5)     echo "Check HTTP connection           [ FAIL    ]" >> $log;;
  *)     echo "Check HTTP connection           [ FAIL    ]" >> $log;;
  esac
}

## Ping gateway first to confirm LAN connection
ping $router -c 4

## Ping successful if returns 0
if [ $? -eq 0 ]
  then
    interfacestate
    printf "%-32s%-11s%b\n" "Ping Gateway ($router)" "[ SUCCESS ]" >> $log
    pingdns
    pingnet
    portscan
    httpreq
    exit 0
  else
    interfacestate
    printf "%-32s%-11s%b\n" "Ping Gateway ($router)" "[ FAIL    ]" >> $log
    pingdns
    pingnet
    portscan
    httpreq
    #exit 1
fi
