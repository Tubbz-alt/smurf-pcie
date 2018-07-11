import smurf_setup.util.smurftune as sm
import smurf_setup.util.cryochannel as cc
import numpy as np
import matplotlib.pyplot as plt
import epics

t = sm.SmurfTune(cfg_file='smurf_setup/experiment.cfg')
smurfInitCfg = t.config.get('init') 
#bandNo = smurfInitCfg['bands']   
bandNo = [0]
SysgenCryo = "AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:"
CryoChannels = "CryoChannels:"
base = 'Base[%i]:' % bandNo[0]
#root = smurfInitCfg['epics_root'] + ':'
root = 'demo_epics:'
rootGen = root + SysgenCryo + base + CryoChannels

cc.all_off(root,bandNo)

epics.caput(rootGen + 'etaScanChannel',63)

epics.caput(rootGen + 'runEtaScan',1)
re = epics.caget(rootGen + 'etaScanResultsReal')
im = epics.caget(rootGen + 'etaScanResultsImag')
mag = np.sqrt(re**2 + im**2)

plt.figure()
plt.plot(mag)
plt.savefig('ari_test.png')

plt.figure()
plt.plot(re,im)
plt.savefig('ari_test_2.png')

