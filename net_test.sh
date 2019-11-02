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

## ping LAN hosts? yes/no
lan_test="no"

## list of LAN host IP addresses - order myst match names list
hosts_address=(
  "addreess1"
  "addreess2"
  "addreess3"
)

## list of LAN host names - order myst match address list
hosts_name=(
  "name1"
  "name2"
  "name3"
)

## possible text colours
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

pinghost() {
  ## Test connection to internet
  ping $2 -c 3 > /dev/null 2>&1

  if [ $? -eq 0 ]
    then
      printf "%-32s%-8s%b\n" "Ping host: $1" "[ ${GREEN}${BRIGHT}PASS${NORMAL} ]"
    else
      printf "%-32s%-8s%b\n" "Ping host: $1" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]"
  fi
}

## Test functions
interfacestate()
{
  ## Check wlan0 interface state
  wlan0_state=$(cat /sys/class/net/wlan0/operstate)
  if [ $wlan0_state == "up" ]
    then
      printf "%-32s%-8s%b\n" "Wlan0" "[ ${GREEN}${BRIGHT}PASS${NORMAL} ]"
    else
      printf "%-32s%-8s%b\n" "Wlan0" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]"
  fi
}

portscan()
{
  ## Test connection on port 80
  if nc -zw1 $checkdomain  80; then
    printf "%-32s%-8s%b\n" "Port 80" "[ ${GREEN}${BRIGHT}PASS${NORMAL} ]"
  else
    printf "%-32s%-8s%b\n" "Port 80" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]"
  fi
}

pingnet()
{
  ## Test connection to internet
  ping $checkdomain -c 4 > /dev/null 2>&1

  if [ $? -eq 0 ]
    then
      printf "%-32s%-8s%b\n" "Access $checkdomain" "[ ${GREEN}${BRIGHT}PASS${NORMAL} ]"
    else
      printf "%-32s%-8s%b\n" "Access $checkdomain" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]"
  fi
}

pingdns()
{
  ## Test connection to DNS server
  ping $checkdns -c 4 > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
      printf "%-32s%-8s%b\n" "Access DNS ($checkdns)" "[ ${GREEN}${BRIGHT}PASS${NORMAL} ]"
    else
      printf "%-32s%-8s%b\n" "Access DNS ($checkdns)" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]"
  fi
}

httpreq()
{
  ## Test HTTP connection
  case "$(curl -s --max-time 2 -I $checkdomain | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23])  printf "%-32s%-8s%b\n" "Access HTTP" "[ ${GREEN}${BRIGHT}PASS${NORMAL} ]";;
  5)     printf "%-32s%-8s%b\n" "Access HTTP" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]";;
  *)     printf "%-32s%-8s%b\n" "Access HTTP" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]";;
  esac
}

publicip()
{
  pipaddress=$(curl -s checkip.amazonaws.com)
  printf "%-26s%-14s%b\n" "Public IPv4: " "${CYAN}${BRIGHT}$pipaddress${NORMAL}"
}

devicestats()
{
  ## network
  interfacestate
  echo
  printf "%-40s%b\n" "Essid: ${CYAN}${BRIGHT}$(iwgetid -r)${NORMAL}"
  printf "%-20s%20s%b\n" "$(iwconfig wlan0  | grep 'Bit Rate=' |  awk '{print $1, $2, $3}')" "$(iwconfig wlan0  | grep 'Bit Rate=' |  awk '{print $4, $5, $6}')"
  printf "%-4s%-24s%12s%b\n" "RX:" "$(ifconfig wlan0 | awk '/RX packets/ { print $2, $3, $6, $7 }')" "$(ifconfig wlan0 | awk '/RX errors/ { print $2,$3}')"
  printf "%-4s%-24s%12s%b\n" "TX:" "$(ifconfig wlan0 | awk '/TX packets/ { print $2, $3, $6, $7 }')" "$(ifconfig wlan0 | awk '/TX errors/ { print $2,$3}')"
  publicip

  ## cpu
  echo
  printf "%-10s%-12s%18s%b\n" "CPU temp:" "$(vcgencmd measure_temp | cut -c 6-9)" "$(NUMCPUS=`grep ^proc /proc/cpuinfo | wc -l`; FIRST=`cat /proc/stat | awk '/^cpu / {print $5}'`; sleep 1; SECOND=`cat /proc/stat | awk '/^cpu / {print $5}'`; USED=`echo 2 k 100 $SECOND $FIRST - $NUMCPUS / - p | dc`; echo ${USED}% CPU Usage)"
  echo
  ## kernel version
  printf "%-40s%b\n" "${MAGENTA}${BRIGHT}$(cat /etc/*-release | grep PRETTY_NAME= | cut -c 14-43)${NORMAL}"
  printf "%-40s" "${MAGENTA}${BRIGHT}$(uname -mr)${NORMAL}"
}

printf "%40s%b\n" "$(date '+%m-%d-%Y %T')"

## Ping gateway first to confirm LAN connection
ping $router -c 4 > /dev/null 2>&1

## Ping successful if returns 0
if [ $? -eq 0 ]
then
  printf "%-32s%-8s%b\n" "Ping ($router)" "[ ${GREEN}${BRIGHT}PASS${NORMAL} ]"
  pingdns
  pingnet
  portscan
  httpreq
  devicestats
  
  if [ $lan_test == "yes" ]
  then
    sleep 5
    echo
    echo
    printf "%-40s%b\n" "Pinging LAN host connections . . ."
    echo
    for index in ${!hosts_name[*]}; do
      pinghost ${hosts_name[$index]} ${hosts_address[$index]}
    done
  fi
  
  echo
  printf "%40s" "${YELLOW}${BRIGHT}Network test completed . . . ${NORMAL}"
else
  printf "%-32s%-8s%b\n" "Ping ($router)" "[ ${RED}${BRIGHT}FAIL${NORMAL} ]"
  pingdns
  pingnet
  portscan
  httpreq
  devicestats
  
  echo
  printf "%40s" "${YELLOW}${BRIGHT}Network test completed . . . ${NORMAL}"
fi

exit 0
