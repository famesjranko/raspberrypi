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

from gpiozero import Button     # to access buttons
from time import sleep          # for sleep function
import os                       # for shutdown/kill control
import subprocess               # to run program
import signal                   # to kill program

# might not need these
import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(27, GPIO.OUT)

## define display button Objects
run_halt   = Button(4)
run_reboot = Button(17)
p1_start   = Button(5)
p2_start   = Button(22)
p3_start   = Button(23)
p4_start   = Button(24)

## program/command list
halt   = "shutdown now -h"
reboot = "reboot now"
p1     = "./home/pi/padd_mini.sh"
p2     = "pihole -t"
p3     = "./home/pi/net_test.sh"
p4     = "/usr/bin/htop"

sleep(1)

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
        if run_halt.is_pressed:
            sleep(1)
            if run_halt.is_pressed:
                os.system(halt)
        ## run reboot - must press and and hold
        elif run_reboot.is_pressed:
            sleep(1)
            if run_reboot.is_pressed:
                os.system(reboot)
        ## start p1 - no hold needed
        elif p1_start.is_pressed:
            proc = subprocess.Popen(p1, shell=True, preexec_fn=os.setsid)
            # print 'finished . . .'
        ## start p2 - no hold needed
        elif p2_start.is_pressed:
            proc = subprocess.Popen(p2, shell=True, preexec_fn=os.setsid)
            # print 'finished . . .'
        ## start p3 - no hold needed
        elif p3_start.is_pressed:
            proc = subprocess.Popen(p3, shell=True, preexec_fn=os.setsid)
            # print 'finished . . .'
        ## start p4 - no hold needed
        elif p4_start.is_pressed:
            proc = subprocess.Popen(p4, shell=True, preexec_fn=os.setsid)
            # print 'finished . . .'
    ## if any pressed and program running, kill
    else:
        if run_halt.is_pressed or run_reboot.is_pressed or p1_start.is_pressed or p2_start.is_pressed or p3_start.is_pressed or p4_start.is_pressed:
            # print 'program killed . . .'
            os.killpg(proc.pid, signal.SIGTERM)
            proc = None

    ## wait to loop again
    sleep(1)
