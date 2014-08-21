#!/bin/bash
# version 2: use common radio_ functions for best practice
shopt -s expand_aliases  #tells bash to pickup any new aliases defined in this script
# by Michael Hirsch, Dec 2013
# This program polls RSSI over a range of frequencies in FreqListHz, at one position

######### user parameters ###########################
# let's try every 10kHz from 435MHz to 438MHz
StartFreqHz=435000000
StopFreqHz=438000000
IncrFreqHz=10000

########### main program #################

StartTime=$(date "+%FT%T")
LogFile="$HOME/RSSIlog/FreqSweep_$StartTime.RSSIlog"

#setup freq list
FreqListHz=($(seq $StartFreqHz $IncrFreqHz $StopFreqHz))
NumFreq=${#FreqListHz[@]}
if [ -z "$IsCron" ]; then echo "Logging $NumFreq freqs from $StartFreqHz Hz to $StopFreqHz Hz to $LogFile"; fi

### open daemons IF NOT ALREADY OPEN, forking into background #####
if [[ -z $(netstat -lnt | grep 4532) ]]; then
  echo "Starting Rigctl daemon"
  #rigctld $RigOpts &
  start_rigctld #my function
  sleep 2; #give rigctld a chance to startup
  RigDProcID=$(pgrep rigctld)
  echo "Using new instance of rigctld, process ID $RigDProcID"
else
  RigDProcID=$(pgrep rigctld)
  if [ -z "$IsCron" ]; then echo "Using already running rigctld of process ID $RigDProcID"; fi
fi
###################################################################
#echo "Reading rig and rotor parameters, storing in $LogFile"
# turn off TS-2000 attenuator
radio_set_att 0
StartAtt=$(radio_get_att)

# turn on TS-2000 INTERNAL preamp
radio_set_preamp 0
StartPreamp=$(radio_get_preamp)

# set TS-2000 modulation
radio_set_mode FM
StartMode=$(radio_get_mode)

# read az/el from rotor
AzEl=$(rotor_get_position)

## write initial settings to file
echo "FrequencyStartStopIncr(Hz), $StartFreqHz $StopFreqHz $IncrFreqHz">>$LogFile
echo "Mode/Bandwidth(Hz), $StartMode">>$LogFile
echo "Attenuation(dB), $StartAtt">>$LogFile
echo "InternalPreamp(dB), $StartPreamp">>$LogFile
echo "Azimuth/Elevation(deg), $AzEl">>$LogFile
echo " ">>$LogFile
echo "UTC Time            Freq (Hz) RSSI">>$LogFile
echo "------------------- --------- ----">>$LogFile
if [ -z "$IsCron" ]; then echo "press <ctrl> c to end this program"; fi
#################### start Loop ###################
#for iter in {1..5..1}; do
  for freqHz in "${FreqListHz[@]}"
  do
	# set frequency of radio
	radio_set_freq $freqHz
	# read frequency from radio (to confirm setting)
	readFreqHz=$(radio_get_freq)

	# read RSSI from radio
	Rssi=$(radio_rssi)

	# get current time
	Now=$(date "+%FT%T")

	# write to logfile
	LogString="$Now $readFreqHz $Rssi"
	echo "$LogString" >> $LogFile

  done #for freqListHz
#done #for iter 1 to 5
