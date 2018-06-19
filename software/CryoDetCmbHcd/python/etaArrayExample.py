import epics
import numpy

rootPath          = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:CryoChannels:'
etaPhaseArray     = epics.PV( rootPath + 'etaPhaseArray' )
etaPhaseCh0       = epics.PV( rootPath + 'CryoChannel[0]:etaPhaseDegree' )

print etaPhaseArray
print etaPhaseCh0

# get all etaPhase
currentEtaValues = etaPhaseArray.get()
print currentEtaValues[0]
print etaPhaseCh0.get()

# set all etaPhase to 10 degree
etaPhaseArray.put( [10.0]*512 )

#look at first 10 channels
print etaPhaseArray.get( 10 )
