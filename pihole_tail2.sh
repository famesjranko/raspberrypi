#!/bin/bash

## streams pihole.log via tail, awk, sed
## output limited due to expected 2.2" screen size - no timestamp, only outbound address and status (colourised)
## can add/remove log fields via awk - currently printing fields 5 and 6.
## can change status indicators via sed - currently single coloured Char used 

tail -f /var/log/pihole.log | awk -W interactive '{print $5 , $6}' | \
     sed -u -E -e "s/\/etc\/pihole\/gravity.list/`tput setaf 1``tput bold`B`tput sgr0`/" \
               -e "s/\/etc\/pihole\/regex.list/`tput setaf 1``tput bold`B`tput sgr0`/" \
               -e "s/\/etc\/pihole\/black.list/`tput setaf 1``tput bold`B`tput sgr0`/" \
               -e "s/\/etc\/hosts/`tput setaf 7``tput bold`H`tput sgr0`/" \
               -e "s/query\[A\]/`tput setaf 5``tput bold`Q`tput sgr0`/" \
               -e "s/query\[AAA\]/`tput setaf 5``tput bold`Q`tput sgr0`/" \
               -e "s/query\[PTR\]/`tput setaf 5``tput bold`Q`tput sgr0`/" \
               -e "s/forwarded/`tput setaf 6``tput bold`F`tput sgr0`/" \
               -e "s/reply/`tput setaf 2``tput bold`R`tput sgr0`/" \
               -e "s/cached/`tput setaf 3``tput bold`C`tput sgr0`/" \
               -e "s/read/`tput setaf f``tput bold`r`tput sgr0`/"

exit
