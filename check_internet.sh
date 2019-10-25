#!/bin/bash

GW=`/sbin/ip route | awk '/default/ { print $3 }'`
checkdns=`cat /etc/resolv.conf | awk '/nameserver/ {print $2}' | awk 'NR == 1 {print; exit}'`
checkdomain=google.com
log='connection.log'

# print date/time of script execution
echo >> $log
echo "script exectuted:    " $(date '+%m-%d-%Y %T') >> $log

#some functions

portscan()
{
  #tput setaf 6; echo "Starting port scan of $checkdomain port 80"; tput sgr0;
  if nc -zw1 $checkdomain  80; then
    tput setaf 2; echo "Scan Port 80                    [SUCCESS]" >> $log; tput sgr0;
  else
    echo               "Scan port 80                    [FAIL]" >> $log
  fi
}

pingnet()
{
  #Google has the most reliable host name. Feel free to change it.
  #tput setaf 6; echo "Pinging $checkdomain to check for internet connection." && echo; tput sgr0;
  ping $checkdomain -c 4

  if [ $? -eq 0 ]
    then
      #tput setaf 2; echo && echo "$checkdomain pingable. Internet connection is most probably available." && echo ; tput sgr0;
      echo             "Check access to $checkdomain      [SUCCESS]" >> $log
      #Insert any command you like here
    else
      #echo && echo "Could not establish internet connection. Something may be wrong here." >&2
      echo             "Check access to $checkdomain      [FAIL]" >> $log
      #Insert any command you like here
#      exit 1
  fi
}

pingdns()
{
  #Grab first DNS server from /etc/resolv.conf
  #tput setaf 6; echo "Pinging first DNS server in resolv.conf ($checkdns) to check name resolution" && echo; tput sgr0;
  ping $checkdns -c 4
    if [ $? -eq 0 ]
    then
      #tput setaf 6; echo && echo "$checkdns pingable. Proceeding with domain check."; tput sgr0;
      echo             "Check DNS ($checkdns)           [SUCCESS]" >> $log
      #Insert any command you like here
    else
      #echo && echo "Could not establish internet connection to DNS. Something may be wrong here." >&2
      echo             "Check DNS ($checkdns)           [FAIL]" >> $log
      #Insert any command you like here
#     exit 1
  fi
}

httpreq()
{
  #tput setaf 6; echo && echo "Checking for HTTP Connectivity"; tput sgr0;
  case "$(curl -s --max-time 2 -I $checkdomain | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) tput setaf 2; echo "Check HTTP connection           [SUCCESS]" >> $log; tput sgr0;;
  5) echo              "Check HTTP connection           [FAIL]" >> $log;exit 1;;
  *)echo               "Check HTTP connection           [FAIL]"; exit 1;;
  esac
#  exit 0
}


#Ping gateway first to verify connectivity with LAN
#tput setaf 6; echo "Pinging gateway ($GW) to check for LAN connectivity" && echo; tput sgr0;
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

  #Insert any command you like here
#  exit 1
fi
