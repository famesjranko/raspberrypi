##   Output structured for 2.2" pi-tft display hat.
##
##   A simple looping script that mimics and colourises
##   the output of 'tail -f /var/log/pihole.log' for the
##   raspberry pi 2.2" pi-tft display hat.
##
##   pi 2.2" pi-tft display hat device layout:
##       ______________________
##      | |      ____________  |
##      | | *23 |            | |*17
##      | | *22 |   screen   | |
##      | | *24 |    18x40   | |
##      | | *5  |____________| |*4
##      |_|____________________|

#!/bin/bash

## colour list
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)

## print header and colour key
echo
echo "executing pihole.log tail . . ."
sleep 1
echo
printf "%-15s%10s%b\n" "colour key:" ""
sleep .4
printf "%-16s%10s%b\n" "  replies:" "${CYAN}${BRIGHT}GREEN${NORMAL}"
sleep .4
printf "%-16s%10s%b\n" "  forwards:" "${GREEN}${BRIGHT}CYAN${NORMAL}"
sleep .4
printf "%-16s%10s%b\n" "  cached:" "${YELLOW}${BRIGHT}YELLOW${NORMAL}"
sleep .4
printf "%-16s%10s%b\n" "  queries:" "${MAGENTA}${BRIGHT}MAGENTA${NORMAL}"
sleep .4
printf "%-16s%10s%b\n" "  blocked:" "${RED}${BRIGHT}RED${NORMAL}"
sleep 2
echo

## set initial lines to anything
line1="empty"
line_query1="empty"

## loop forever
while [ true ]
do

  ## grab last line of log proper, then grab relevant line fields
  line2=$(tail -n 1 /var/log/pihole.log)
  line3=$(echo $line2 | awk '{print $5 , $6 , $8}')
  
  ## grab last line of query only log, then grab relevant line fields
  line_query2=$(cat /var/log/pihole.log | grep "query" | tail -n 1)
  line_query3=$(echo $line_query2 | awk '{print $5 , $6 , $8}')

  ## compare query line latest with previous
  ## - specifically needed as queries appear too quickly in log
  ## - test for 'wpad.LandOfOz' is specific to my network; can remove
  if [[ "$line_query3" !=  "$line_query1" && "$(echo $line_query3 | awk '{print $2}')" != "wpad.LandOfOz" ]]
    then
      ## atomise line fields
      ## field 1: type
      ## field 2: human readable address
      ## field 3: ip address
      q_first=$(echo $line_query3 | awk '{print $1}')
      q_second=$(echo $line_query3 | awk '{print $2}')
      q_third=$(echo $line_query3 | awk '{print $3}')

      ## determine field 2 length
      q_second_len=${#q_second}

      ## colourised print
      if [ $(echo "$q_second_len >= 19" | bc) -eq 1 ]
        then
          q_second=$(echo $q_second | cut -c -16)
          printf "%s%s%b\n" "${MAGENTA}${BRIGHT}query${NORMAL} $q_second..." " $q_third"
        else
          printf "%s%s%b\n" "${MAGENTA}${BRIGHT}query${NORMAL} $q_second" " $q_third"
      fi

      ## update last query line
      line_query1=$line_query3
  fi



  ## compare latest line proper with previous
  ## - has queries incl. but mostly misses them - see above
  ## - test for 'wpad.LandOfOz' is specific to my network; can remove
  if [[ "$line3" !=  "$line1" && "$line3" != "$line_query1" && "$(echo $line3 | awk '{print $2}')" != "wpad.LandOfOz" ]]
    then
      ## atomise line fields
      ## field 1: type
      ## field 2: human readable address
      ## field 3: ip address
      first=$(echo $line3 | awk '{print $1}')
      second=$(echo $line3 | awk '{print $2}')
      third=$(echo $line3 | awk '{print $3}')

      ## determine field 2 length
      second_len=${#second}

      ## colourised print
      if [ "$first" = "reply" ]
        then
          if [ $(echo "$second_len >= 34" | bc) -eq 1 ]
            then
              second=$(echo $second | cut -c -31)
              printf "%b\n%s" "${CYAN}${BRIGHT}$first${NORMAL} $second..."
            else
              printf "%b\n%s" "${CYAN}${BRIGHT}$first${NORMAL} $second"
          fi
      elif [ "$first" = "forwarded" ]
        then
          if [ $(echo "$second_len >= 30" | bc) -eq 1 ]
            then
              second=$(echo $second | cut -c -27)
              printf "%b\n%s" "${GREEN}${BRIGHT}$first${NORMAL} $second..."
            else
              printf "%b\n%s" "${GREEN}${BRIGHT}$first${NORMAL} $second"
          fi
      elif [ "$first" = "cached" ]
        then
          if [ $(echo "$second_len >= 33" | bc) -eq 1 ]
            then
              second=$(echo $second | cut -c -30)
              printf "%b\n%s" "${YELLOW}${BRIGHT}$first${NORMAL} $second..."
            else
              printf "%b\n%s" "${YELLOW}${BRIGHT}$first${NORMAL} $second"
          fi
      elif [[ "$first" = "query[A]" || "$first" = "query[PTR]" || "$first" = "query[AAAA]" ]]
        then
          if [ $(echo "$second_len >= 19" | bc) -eq 1 ]
            then
              second=$(echo $second | cut -c -16)
              printf "%s%s%b\n" "${MAGENTA}${BRIGHT}query${NORMAL} $second..." " $third"
            else
              printf "%s%b\n" "${MAGENTA}${BRIGHT}query${NORMAL} $second $third"
          fi
      elif [[ "$first" = "/etc/pihole/gravity.list" || "$first" = "/etc/pihole/black.list" ]]
        then
          if [ $(echo "$second_len >= 32" | bc) -eq 1 ]
            then
              second=$(echo $second | cut -c -29)
              printf "%b\n%s" "${RED}${BRIGHT}blocked${NORMAL} $second..."
            else
              printf "%b\n%s" "${RED}${BRIGHT}blocked${NORMAL} $second"
          fi
      else
          printf "%b\n%s" "$first $second"
      fi

      ## update last line
      line1=$line3
  fi

  ## can add a wait before looping if wanted
  #sleep .5
done
