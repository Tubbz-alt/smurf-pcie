import os
import numpy as np
import smurf_setup.config as config
from smurf_setup.util.cryochannel import *
from smurf_setup.util.smurftune import SmurfTune

class SmurfStage:
    """initializes, runs, analyzes, and cleans up after a SMuRF tuning stage
    """

    def __init__(self, tuning):
        # list of required config settings
        _required = []

        # name associated when writing outputs
        _nickname = [] 

        self.output_dir = tuning.output_dir
        self.plot_dir = tuning.plot_dir
        self.filename = tuning.filename(suffix=".txt", nickname=self._nickname)
        self.config = tuning.config

    def prepare(self):
        pass

    def run(self):
        pass

    def analyze(self):
        pass

    def write(self, data, fileheader):
        """ dump the data from a stage into a csv

           Args:
            data (np array-like) : np array-like object to write
            header (str) : desired header
        """

        try:
            filepath = os.path.join(self.output_dir, self.filename[1])
        except AttributeError:
            filepath = os.path.join(self.output_dir, "generic_stage.txt")

        np.savetxt(filepath, data, delimiter=',', header=fileheader)

    def cleanup(self):
        """turn everything off at the end of each stage
        """

        SmurfCfg = self.config
        SmurfInitCfg = SmurfCfg.get('init')
        epics_root = SmurfInitCfg['epics_root']

        all_off(epics_root)
