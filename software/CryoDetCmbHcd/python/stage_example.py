#!/usr/bin/python3

import numpy as np

import smurf_setup
from smurf_setup.util.smurftune import SmurfTune
import smurf_setup.stage.dummystage as exstage

# set up a tuning object using the config file
testTune = SmurfTune(cfg_file = "smurf_setup/experiment.cfg")
print("tuning object created!\n")

# make the output directories for the tuning object
testTune.make_dirs()

current_stage = exstage.DummyStage(testTune)

print("filename for stage output: " + current_stage.filename[1] + "\n")

current_stage.prepare()

current_stage.run()

print("create some fake data and save it...\n")
x = np.random.random((10,2))
current_stage.write(x, fileheader="fake dataset")

current_stage.analyze()

current_stage.clean()

