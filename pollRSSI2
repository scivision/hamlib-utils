#!/bin/bash
# by Michael Hirsch, Dec 2013
# version 2: use daemon instead of repeated direct commands


# stop program on error
set -e

StartTime=$(date "+%FT%T")
LogFile=~/RSSIlog/$StartTime.RSSIlog
FreqHz=436750000 #to test at

echo Logging to $LogFile

# netcat-openbsd options (no -c, use -q 0 instead)
ncl="-q 0 -w 1 localhost 4532"

# rigctld options
RigOpts="--model=214 --rig-file=/dev/ttyS0 --serial-speed=57600 -C serial_handshake=Hardware,post_write_delay=50"

#to tell rigctl to connect to the already running rigctld daemon
RigL="--model=2 --rig-file=localhost:4532"
# using rigctl makes a lot of extraneous \dump_state calls that I don't like. Trying nc instead.

# rotctld options
RotOpts="--model=603 --rot-file=/dev/ttyS5 --serial-speed=9600 -C serial_handshake=Hardware,post_write_delay=50,timeout=2000,retry=0"

### open daemons IF NOT ALREADY OPEN, forking into background #####
if [[ -z $(netstat -lnt | grep 4532) ]]
then
echo "Starting Rigctl daemon"
rigctld $RigOpts &
else
RigDProcID=$(pgrep rigctld)
echo "Using already running rigctld of process ID $RigDProcID"
fi
###################################################################
#echo "Reading rig and rotor parameters, storing in $LogFile"
# turn off TS-2000 attenuator
nc $ncl <<< "\set_level ATT 0"
StartAtt=$(nc $ncl <<< "\get_level ATT")

# turn on TS-2000 INTERNAL preamp
nc $ncl <<< "\set_level PREAMP 20"
StartPreamp=$(nc $ncl <<< "\get_level PREAMP")

# set TS-2000 frequency
nc $ncl <<< "\set_freq $FreqHz"
StartFreq=$(nc $ncl <<< "\get_freq")

# set TS-2000 modulation
nc $ncl <<< "\set_mode FM 0"
StartMode=$(nc $ncl <<< "\get_mode")
StartMode=$(tr '\r\n' ' ' <<<$StartMode) #puts space in for newline

# read az/el from rotor
AzEl=$(rotctl $RotOpts get_pos)
AzEl=$(tr '\r\n' ' ' <<<$AzEl) # puts space in for newline

## write initial settings to file
echo "Frequency(Hz), $StartFreq">>$LogFile
echo "Mode/Bandwidth(Hz), $StartMode">>$LogFile
echo "Attenuation(dB), $StartAtt">>$LogFile
echo "InternalPreamp(dB), $StartPreamp">>$LogFile
echo "Azimuth/Elevation(deg), $AzEl">>$LogFile
echo " ">>$LogFile
echo "UTC Time            Freq (Hz) RSSI">>$LogFile
echo "------------------- --------- ----">>$LogFile

echo "press <ctrl> c to end this program"

#################### start infinite Loop ###################
#infinite loop
while :
do

# read RSSI from radio
Rssi=$(nc $ncl <<< "\get_level STRENGTH")
# read frequency from radio
Freq=$(nc $ncl <<< "\get_freq")

# get current time
Now=$(date "+%FT%T")

# write to logfile
LogString="$Now $Freq $Rssi"
echo "$LogString" >> $LogFile

# wait one minute
sleep 60;

done
