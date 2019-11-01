#!/bin/bash

## Only choose one:
##    Set local router gateway address,
##    or have it set automagically via /sbin/ip route.
#router=192.168.1.1
router=`/sbin/ip route | awk '/default/ { print $3 }'`

## Only choose one:
##    Choose preferred upstream dns address,
##    or have it set automagically via /etc/resolv.conf
#checkdns=8.8.8.8
#checkdns=1.1.1.1
#checkdns=9.9.9.9
checkdns=`cat /etc/resolv.conf | awk '/nameserver/ { print $2 }'`

## Only choose one:
##    Preferred domain address
checkdomain=google.com
#checkdomain=facebook.com
#checkdomain=yahoo.com

## date/time of execution
printf "%-21s%-19s%b\n" "script exectuted:" "$(date '+%m-%d-%Y %T')"

## Test functions
interfacestate()
{
  ## Check wlan0 interface state
  wlan0_state=$(cat /sys/class/net/wlan0/operstate)
  if [ $wlan0_state == "up" ]
    then
      printf "%-32s%-8s%b\n" "Wlan0" "[ PASS ]"
    else
      printf "%-32s%-8s%b\n" "Wlan0" "[ FAIL ]"
  fi
}

portscan()
{
  ## Test connection on port 80
  if nc -zw1 $checkdomain  80; then
    printf "%-32s%-8s%b\n" "Port 80" "[ PASS ]"
  else
    printf "%-32s%-8s%b\n" "Port 80" "[ FAIL ]"
  fi
}

pingnet()
{
  ## Test connection to internet
  ping $checkdomain -c 4 > /dev/null 2>&1

  if [ $? -eq 0 ]
    then
      printf "%-32s%-8s%b\n" "Access $checkdomain" "[ PASS ]"
    else
      printf "%-32s%-8s%b\n" "Access $checkdomain" "[ FAIL ]"
  fi
}

pingdns()
{
  ## Test connection to DNS server
  ping $checkdns -c 4 > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
      printf "%-32s%-8s%b\n" "Access DNS ($checkdns)" "[ PASS ]"
    else
      printf "%-32s%-8s%b\n" "Access DNS ($checkdns)" "[ FAIL ]"
  fi
}

httpreq()
{
  ## Test HTTP connection
  case "$(curl -s --max-time 2 -I $checkdomain | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23])  printf "%-32s%-8s%b\n" "Access HTTP" "[ PASS ]";;
  5)     printf "%-32s%-8s%b\n" "Access HTTP" "[ FAIL ]";;
  *)     printf "%-32s%-8s%b\n" "Access HTTP" "[ FAIL ]";;
  esac
}

publicip()
{
  pipaddress=$(curl -s checkip.amazonaws.com)
  printf "%-26s%-14s%b\n" "Public IPv4: " "$pipaddress"
}

devicestats()
{
  ## network
  interfacestate
  publicip
  printf "%15s%-10s%15s%b\n" "Recieved (RX): " "$(ifconfig wlan0 | awk '/RX packets/ { print $6, $7 }')" "$(ifconfig wlan0 | awk '/RX errors/ { print $2,$3}')"
 # printf "%40s%b\n" "$(ifconfig wlan0 | awk '/RX errors/ { print $2,$3}')"
  printf "%15s%-10s%15s%b\n"     "Sent (TX): " "$(ifconfig wlan0 | awk '/TX packets/ { print $6, $7 }')" "$(ifconfig wlan0 | awk '/TX errors/ { print $2,$3}')"
 # printf "%40s%b\n" "$(ifconfig wlan0 | awk '/TX errors/ { print $2,$3}')"

  ## cpu
  printf "%-30s%10s%b\n" "CPU min MHz:" "$(lscpu | awk '/CPU min MHz:/ { print $4 }')"
  printf "%-30s%10s%b\n" "CPU max MHz:" "$(lscpu | awk '/CPU max MHz:/ { print $4 }')"
  printf "%-10s%-12s%b\n" "CPU temp:" "$(vcgencmd measure_temp | cut -c 6-9)"
  printf "%6s%-14s%12s%8s%b\n" "idle: " "$(grep "cpu " /proc/stat | awk -F ' ' '{total = $2 + $3 + $4 + $5} END {print $5*100/total "%"}')" "used: " "$(grep "cpu " /proc/stat | awk -F ' ' '{total = $2 + $3 + $4 + $5} END {print $2*100/total "%"}')"

  ## kernel version
  echo "OS:" "$(cat /etc/*-release | grep PRETTY_NAME= | cut -c 14-43)"
  echo "Kernel:" "$(uname -mr)"

}

## Ping gateway first to confirm LAN connection
ping $router -c 4 > /dev/null 2>&1

## Ping successful if returns 0
if [ $? -eq 0 ]
then
  printf "%-32s%-8s%b\n" "Ping ($router)" "[ PASS ]"
  pingdns
  pingnet
  portscan
  httpreq
  devicestats
else
  printf "%-32s%-8s%b\n" "Ping ($router)" "[ FAIL ]"
  pingdns
  pingnet
  portscan
  httpreq
  devicestats
fi

exit 0
