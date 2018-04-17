import os
import sys
import math
import matplotlib.pyplot as plt # not sure we need this?
import numpy as np # pyepics reads stuff as numpy arrays if possible
import subprocess
from tuningstage import SmurfStage
from util.cryochannel import *
from util.smurftune import *

"""scan resonances and get eta parameters for locking onto resonances
"""


SysgenCryo =  "AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:"
CryoChannels = SysgenCryo + "CryoChannels:"

def eta_scan(epics_path, band, freqs, drive):
    


def subband_off():

class etaParams(SmurfStage):
    """class to tune the eta parameters. Inherits from the more generic tuning
       stage class
    """

    def __init__(self, tuning):
        super().__init__()
        self._nickname = "eta_params"

        self.tuningname = tuning.name
        self.outputdir = tuning.output_dir
        self.outputname = tuning.filename(self._nickname)
        self.config = tuning.config

    def prepare(self, resfile=None):
        """prepare system to scan for eta parameters by reading in resonance
            locations
           
           Args:
            resfile (str): optional path resonance locations
            If none supplied, then most recent _resloc file is used
        """
        if resfile is not None:
            reslocs = resfile
        else:
            resfiles = sorted([f for f in os.listdir(self.outputdir) if
            "res_locs" in f]) # move nickname to a variable?
            reslocs = resfiles[-1] # grab the most recent

        resonances = np.loadtxt()


    def run(self):

    def analyze(self):

    def clean(self):
