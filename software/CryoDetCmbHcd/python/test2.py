#!/usr/bin/python3

import smurf_setup
import epics
import smurf_setup.util.cryochannel as cc
from smurf_setup.util.smurftune import SmurfTune

##

testTune = SmurfTune(cfg_file = "smurf_setup/experiment.cfg")
print("tuning object created!\n")

cc.config_cryo_channel(testTune.config, 0, 1, 10, 0, 0, 0)



SysgenCryo = "AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[2]:"
CryoChannels = SysgenCryo + "CryoChannels:"

channelNo=1
root = 'mitch_epics:'
epicsRoot = root + CryoChannels + 'CryoChannel[%i]:' % channelNo

