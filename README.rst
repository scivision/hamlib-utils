============
hamlib-utils
============

Note that Bash is required for the scripts due to the redirection that Dash doesn't have

bash/matlab scripts used with `hamlib <https://github.com/N0NB/hamlib>`_ for remote control of amateur radio equipment

pollRSSIfreq2.sh allows using your Kenwood TS-2000 as a poor man's spectrum analyzer / spectrum scope.

Notes
=====
if you get ``RPRT -5`` that means that the radio didn't accept your command. For the Kenwood TS-2000,
you can try to repair this by stopping rigctld, connction with Putty and type several semicolon (withOUT pressing return)
The radio should then start responsing to rigctld after restarting rigctld
