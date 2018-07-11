import os
import sys
import math
import subprocess
import numpy as np

from smurf_setup.stage.tuningstage import SmurfStage
from smurf_setup.util.cryochannel import *
from smurf_setup.util.smurftune import *


"""dummy tuning stage to show general structure
"""

class DummyStage(SmurfStage):
    """tuning stage for doing nothing
    """

    def __init__(self, tuning):
        print("initiating dummy stage...")
        self._nickname = "dummy"
        super().__init__(tuning)
        
        SmurfInitConfig = self.config.get('init')
        self.epics_root = SmurfInitConfig['epics_root']
        try:
            self.stage_config = self.config.get('dummy') # this won't work
        except KeyError:
            self.stage_config = None

    def prepare(self, previous_stage_file=None):
        """prepare for this stage. In a real stage, possibly reads in a file
           from a previous stage and uses that information.
        """
        print("Preparing to execute stage...")

        if previous_stage_file is not None:
            print("Your previous stage path is " + \
                    os.path.dirname(previous_stage_file))
        else:
            print("No previous stage file found! Default to config path: "\
                    + self.output_dir)
        return


    def run(self):
        """run the stage
        """

        print("Running stage!")
        return

    def analyze(self):
        """analyze/plot whatever information comes out, as desired
        """

        print("Generating plots to be saved to: " + self.plot_dir)
        return

    def clean(self):
        """clean up
        """
        pass

