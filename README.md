# raspberrypi

A small repository of scripts (Bash, Python) I've written for the raspberry pi zero W and addons.

Script outlines:

(1) check_internet.sh (Bash)
When run, this script runs a basic overall test of network connection types to verify their respective states. 
Returns state of wlan0 interface and tests connections on port 80, http, DNS, and to a preferred internet domain.
All relevant output is logged to an external file 'wifi.log.'

(2) check_wifi.sh (Bash)
When run, this script pings the local LAN router (gateway) to verify that connection has not been lost to local network. 
If connection has failed, it will call script (1) then reset the wlan0 interface before again retesting connection to local LAN router. 
If connection fails to come up after 10 attempts, the script will initiate reboot. 
All relevant output is logged to an external file 'wifi.log.'

(3) display.py (Python)
Written for use with the pitft 2.2" display. Allows programs and/or commands to be called from the 6 dusplay buttons.

(4) log_reset.sh (Bash)
A simply script to automate resetting of logs.

(5) wifi_reset.log (Bash)
The reset log used in script (4) and the output of scripts (1) and (2).