#!/usr/bin/python3

import epics
import smurf_setup.util.cryochannel as cc
cc.all_off('mitch_epics:', [2])

##

SysgenCryo = "AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[2]:"
CryoChannels = SysgenCryo + "CryoChannels:"

channelNo=1
root = 'mitch_epics:'
epicsRoot = root + CryoChannels + 'CryoChannel[%i]:' % channelNo

print('numberSubBands=%s'%str(epics.caget(root + SysgenCryo + 'numberSubBands')))
