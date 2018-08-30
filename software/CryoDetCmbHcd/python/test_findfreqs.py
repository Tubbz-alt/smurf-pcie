#!/usr/bin/python3

import epics
import smurf_setup.util.cryochannel as cc
import smurf_setup.stage.findfreqs as ff
from smurf_setup.util.smurftune import SmurfTune
import numpy as np
import matplotlib.pyplot as plt

##

testTune = SmurfTune(cfg_file = "smurf_setup/experiment_demo.cfg")

testFindFreqs = ff.findFreqs(testTune)

subband_no = testFindFreqs.prepare()

f, resp = testFindFreqs.run()

absolute = np.absolute(resp)
angle = np.angle(resp)

plt.figure()
plt.plot(f[subband_no[0],:], absolute[subband_no[0],:])
plt.plot(f[subband_no[0],:], angle[subband_no[0],:])
plt.show()
#plt.savefig('test_plot.png')

