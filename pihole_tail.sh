#!/bin/bash

## colourises and prints the latest addition from 
## /var/log/pihole.log

## colour list
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6))
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)

## print colour key
echo
printf "%-16s%10s%b\n" "colour key:" ""
printf "%-16s%10s%b\n" "    reply:" "${GREEN}${BRIGHT}GREEN${NORMAL}"
printf "%-16s%10s%b\n" "    forward:" "${CYAN}${BRIGHT}CYAN${NORMAL}"
printf "%-16s%10s%b\n" "    cached:" "${YELLOW}${BRIGHT}YELLOW${NORMAL}"
printf "%-16s%10s%b\n" "    queries:" "${MAGENTA}${BRIGHT}MAGENTA${NORMAL}"
printf "%-16s%10s%b\n" "    block list:" "${RED}${BRIGHT}RED${NORMAL}"
echo

## set initial line
line1="empty"

while [ true ]
do
  ## grab wanted fields last line from log
  line2=$(tail -n 1 /var/log/pihole.log | awk '{print $5 , $6 , $8}')
  
  ## compare latest line with previous
  if [ "$line2" !=  "$line1" ]
    then
      ## break line up into seperate fields
      ## field 1: type
      ## field 2: human readable address
      ## field 3: ip address
      first=$(echo $line2 | awk '{print $1}')
      second=$(echo $line2 | awk '{print $2}')
      third=$(echo $line2 | awk '{print $3}')

      ## test for field 1 'type'
      if [ "$first" == "reply" ]
        then
          printf "%b\n%s" "${GREEN}${BRIGHT}$second${NORMAL}"
      elif [ "$first" == "forwarded" ]
        then
          printf "%b\n%s" "${CYAN}${BRIGHT}$second${NORMAL}"
      elif [ "$first" == "cached" ]
        then
          printf "%b\n%s" "${YELLOW}${BRIGHT}$second${NORMAL}"
      elif [ "$first" == "query[A]" ]
        then
          printf "%b\n%s" "${MAGENTA}${BRIGHT}$second${NORMAL} $third"
      elif [ "$first" == "query[PTR]" ]
        then
          printf "%b\n%s" "${MAGENTA}${BRIGHT}$second${NORMAL} $third"
      elif [ "$first" == "/etc/pihole/gravity.list" ]
        then
          printf "%b\n%s" "${RED}${BRIGHT}$second${NORMAL}"
      elif [ "$first" ==  "/etc/pihole/black.list" ]
        then
          printf "%b\n%s" "${RED}${BRIGHT}$second${NORMAL}"
      else
          printf "%b\n%s" "$first $third"
      fi
      
      ## update previous line
      line1=$line2
  fi
  
  ## wait to loop again
  sleep 1
done
