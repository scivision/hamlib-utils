============
hamlib-utils
============

Bash/Matlab/Octave scripts used with `hamlib <https://github.com/N0NB/hamlib>`_ for remote control of amateur radio equipment

pollRSSIfreq2.sh allows using your Kenwood TS-2000 as a poor man's spectrum analyzer / spectrum scope.

Prereqs
=======
Linux -- should work on Cygwin, I haven't tried it.

Bash  -- These days, it's the default Terminal shell on most Linux distros and Cygwin

Netcat  ``sudo apt-get install netcat``

hamlib ``sudo apt-get install libhamlib-utils``

How to use hamlib for simple remote radio control
==============================================================
I wanted the simplest possible command-line interface to my Kenwood TS-2000 (or other hamlib controllable rig, with minor modifications). 
I startup the ``rigctld`` daemon and then issue commands using netcat to the open port.
OBVIOUSLY this port should not be open to the Internet! You must be using a firewall such as ufw ``sudo ufw enable``.

First you start the rigctld, using the parameters specific to your rig (here a Kenwood TS-2000)::
  
  start_rigctld
  
Now you simply issue command/parameter pairs. To set frequency to 146.520MHz, type in Terminal::

  radio_set_freq 146520000
  
Tab completion is your friend.

  
How to use hamlib for simple remote ROTOR control
=================================================
This code is at your own risk, I use it for az/el pointing with a Yaseu G5500 rotor.::

  start_rotctld

  rotor_get_position



Stopping rigctld / rotctld
==========================
If you want to stop the rigctld daemon when you're done for the day (don't have to, but if you want to), type in Terminal::
  
  stopRigRot

Notes
=====
if you get ``RPRT -5`` that means that the radio didn't accept your command. For the Kenwood TS-2000,
you can try to repair this by stopping rigctld, connction with Putty and type several semicolon (withOUT pressing return)
The radio should then start responsing to rigctld after restarting rigctld
