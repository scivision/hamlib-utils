#!/bin/bash
# by Michael Hirsch, Dec 2013

# stop program on error
set -e

StartTime=$(date "+%FT%T")
LogFile=~/RSSIlog/$StartTime.RSSIlog
FreqHz=436750000 #to test at

echo Logging to $LogFile

# repetitive rigctl options
RigOpts="--model=214 --rig-file=/dev/ttyS0 --serial-speed=19200 -C serial_handshake=Hardware,post_write_delay=50"

# repetitive rotctl options
RotOpts="--model=603 --rot-file=/dev/ttyS5 --serial-speed=9600 -C serial_handshake=Hardware,post_write_delay=50,timeout=2000,retry=0"


# turn off TS-2000 attenuator
rigctl $RigOpts set_level ATT 0
StartAtt=$(rigctl $RigOpts get_level ATT)

# turn on TS-2000 INTERNAL preamp
rigctl $RigOpts set_level PREAMP 20
StartPreamp=$(rigctl $RigOpts get_level PREAMP)

# set TS-2000 frequency
rigctl $RigOpts set_freq $FreqHz
StartFreq=$(rigctl $RigOpts get_freq)

# set TS-2000 modulation
rigctl $RigOpts set_mode FM 0
StartMode=$(rigctl $RigOpts get_mode)
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
Rssi=$(rigctl $RigOpts get_level STRENGTH)
# read frequency from radio
Freq=$(rigctl $RigOpts get_freq)

# get current time
Now=$(date "+%FT%T")

# write to logfile
LogString="$Now $Freq $Rssi"
echo "$LogString" >> $LogFile

# wait one minute
sleep 60;

done
