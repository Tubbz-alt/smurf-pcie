#!/usr/bin/python3

import smurf_setup
import epics
import smurf_setup.util.cryochannel as cc
from smurf_setup.util.smurftune import SmurfTune
from smurf_setup import setup

##

testTune = SmurfTune(cfg_file = "smurf_setup/experiment_demo.cfg")
print("tuning object created!\n")

tuningConfig = testTune.config
print("tuning config object created!\n")

setup.init(tuningConfig)
