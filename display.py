##   For Raspberry Pi ZERO W - 2.2" pi-tft display hat.
##
##   This is a simple python script template that can
##   be set to start program on boot and loops forever.
##
##   Currently implements reboot, shutdown, and program
##   start/stop when the respective button is pressed.
##
##   device layout:
##       ______________________
##      | |      ____________  |
##      | | *23 |            | |*17
##      | | *22 |   screen   | |
##      | | *24 |    18x40   | |
##      | | *5  |____________| |*4
##      |_|____________________|

from gpiozero import Button     # to access buttons
from time import sleep          # for sleep function
import os                       # for shutdown/kill control
import subprocess               # to run program
import signal                   # to kill program

# might not need these - display backlight
import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(27, GPIO.OUT)

## define display button Objects                       
p4_start   = Button(23)
p3_start   = Button(22)
p2_start   = Button(24)
p1_start   = Button(5)
run_reboot = Button(17)
run_halt   = Button(4)

## program/command list - set these.
halt   = "shutdown now -h
reboot = "reboot now"
p4     = "./home/pi/net_test.sh"
p3     = "pihole -t | awk '{print $5,$7,$8}'  | cut -c -40"
p2     = "/usr/bin/htop"
p1     = "./home/pi/padd_mini.sh"

## if set to True, p1 will start on run
start_on_boot = True

## clear display
def d_refresh():
  for x in range(18):
    print()

## wait for system to fully boot
sleep(2)

## start p1 
if start_on_boot:
  proc = subprocess.Popen(p1, shell=True, preexec_fn=os.setsid)
else:
  proc = None
    
## button input loop
while True:
  if proc is None:
    ## run halt
    if run_halt.is_pressed:
      os.system(halt)
    ## run reboot
    elif run_reboot.is_pressed:
      os.system(reboot)
    ## start p1
    elif p1_start.is_pressed:
	  d_refresh()
      proc = subprocess.Popen(p1, shell=True, preexec_fn=os.setsid)
    ## start p2
    elif p2_start.is_pressed:
	  d_refresh()
      proc = subprocess.Popen(p2, shell=True, preexec_fn=os.setsid)
    ## start p3
    elif p3_start.is_pressed:
	  d_refresh()
      proc = subprocess.Popen(p3, shell=True, preexec_fn=os.setsid)
    ## start p4
    elif p4_start.is_pressed:
	  d_refresh()
      proc = subprocess.Popen(p4, shell=True, preexec_fn=os.setsid)
  ## if any button pressed while program running, kill program
  else:
    if run_halt.is_pressed or run_reboot.is_pressed or p1_start.is_pressed or p2_start.is_pressed or p3_start.is_pressed or p4_start.is_pressed:
      os.killpg(proc.pid, signal.SIGTERM)
      proc = None

  sleep(1)
