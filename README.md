# raspberrypi

A small repository of scripts (Bash, Python) I've written for the raspberry pi zero W and addons.


Script outlines:

(1) check_internet.sh (Bash)

When run, this script runs a basic overall test of network connection types to verify their respective states. 
Returns state of wlan0 interface and tests connections on port 80, http, DNS, and to a preferred internet domain.
All relevant output is logged to an external file 'wifi.log'.


(2) check_wifi.sh (Bash)

When run, this script pings the local LAN router (gateway) to verify that connection has not been lost to local network. 
If connection has failed, it will call script (1) 'check_internet.sh' then reset the wlan0 interface before again retesting connection 
to local LAN router. If connection fails to come up after 10 attempts, the script will initiate reboot. Can also send an email to a 
specified address on resetablishment if needed.  All relevant output is logged to an external file 'wifi.log'.


(3) display.py (Python)

Written for use with the pitft 2.2" display. Allows programs and/or commands to be called from the 6 display buttons, and includes an 
autostart option for one of the specifed programs/commands if wanted.


(4) logbackup.sh (Bash)

A simple script to backup and reset the wifi log - easy to convert for using with other logs.


(5) auto_logbackup.sh (Bash)

An automated version of script (4) 'logbackup.sh' - also easy to convert for using with other logs.

(6) net_test.sj (Bash)

A console version of script (1) check_internet.sh that doesn't includie logging. It runs test silents and simply outputs results to
the console. 

