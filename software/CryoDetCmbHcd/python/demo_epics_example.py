import epics

rootPath = 'demo_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'
path2PV = rootPath + 'digitizerFrequencyMHz'

exPV = epics.PV( path2PV )
value = exPV.get()

print(path2PV)
print(value)
