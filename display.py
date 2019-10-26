##   For Raspberry Pi ZERO W - 2.2" pi-tft display hat.
##
##   This is a simple python script template that can 
##   be set to start program on boot and loops forever, 
##   testing for display GPIO button presses. 
##
##   Currently implements reboot, shutdown, and program 
##   start/stop when the respective button is pressed.
##
##   programs p1, p2, and p3 not set - must add these.
## 

from gpiozero import Button 	# to access buttons
from time import sleep          # for sleep function
import os                       # for shutdown/kill control
import subprocess               # to run program
import signal                   # to kill program

## define display button Objects
run_halt    = Button(4)
run_reboot  = Button(17)
p1_start    = Button(5)
p2_start    = Button(22)
p3_start    = Button(23)
p4_start    = Button(24)

## program/command list
halt    = "shutdown now -h"
reboot  = "reboot now"
p1      = "/full/path/to/program1.file"
p2      = "/full/path/to/program2.file"
p3      = "/full/path/to/program3.file"
p4      = "/full/path/to/program4.file"

## wait for system to fully boot
sleep(20)	                 

## if set to True, p1 will start at boot
start_on_boot = True

if start_on_boot:
    proc = subprocess.Popen(p1, shell=True, preexec_fn=os.setsid)
else:
    proc = None

while True:
    ## if pressed and nothing running, run
    if proc is None:
        ## run halt - must press and and hold
        if halt.is_pressed:		 	            
            sleep(1)
            if halt.is_pressed: 			    
                os.system(halt)
        ## run reboot - must press and and hold
        elif reboot.is_pressed:
            sleep(1)
            if reboot.is_pressed:
                os.system(reboot)
        ## start p1 - no hold needed
        elif p1_start.is_pressed:
        proc = subprocess.Popen(p1, shell=True, preexec_fn=os.setsid)
        ## start p2 - no hold needed
        elif p2_start.is_pressed:
        proc = subprocess.Popen(p2, shell=True, preexec_fn=os.setsid)
        ## start p3 - no hold needed
        elif p3_start.is_pressed:
        proc = subprocess.Popen(p3, shell=True, preexec_fn=os.setsid)
        ## start p4 - no hold needed
        elif p4_start.is_pressed:
        proc = subprocess.Popen(p3, shell=True, preexec_fn=os.setsid)
    ## if any pressed and program running, kill
    else:                           
        if p_stop.is_pressed or halt.is_pressed or reboot.is_pressed or p1_start.is_pressed or p2_start.is_pressed or p3_start.is_pressed or p4_start.is_pressed:
            os.killpg(proc.pid, signal.SIGTERM)
            proc = None
    
    ## wait to loop again
    sleep(1)
