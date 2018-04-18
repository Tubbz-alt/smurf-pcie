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
    """scan a small range and get IQ response
    
       Args:
        epics_path (str): root path for epics commands for eta scanning
        band (int): subband number to scan
        freqs (list): frequencies to scan over
        drive (int): power at which to scan
    """




    return response, freqs


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

        initconfig = self.config.get('init')
        self.epics_root = initconfig['epics_root']
        self.stage_config = tuning.config.get('etaParams')

    def prepare(self, resfile=None):
        """prepare system to scan for eta parameters by reading in resonance
            locations
           
           Args:
            resfile (str): optional path resonance locations
            If none supplied, then most recent _resloc file is used

           Outputs:
            freqs (list): list of frequency locations
        """
        if resfile is not None:
            reslocs = resfile
        else:
            resfiles = sorted([f for f in os.listdir(self.outputdir) if
            "res_locs" in f]) # move nickname to a variable?
            reslocs = resfiles[-1] # grab the most recent

        data = np.loadtext(reslocs, dtype=float, delimiter=',', skiprows=1)
        freqs = data[:,0] # assumes frequencies are in the first column
        self.freqs = freqs
        return freqs

    def run(self):
        n_channels = epics.caget(self.epics_root + SysgenCryo \
                + "numberChannels" # should be 512 for a 500MHz band
        n_subbands = epics.caget(self.epics_root + SysgenCryo \
                + "numberSubBands" # is 32 right now

        n_subchannels = n_channels / n_subbands # 16

        epics_path = self.epics_root + CryoChannels
        
        freqs = self.freqs

        try:
            drive = self.stage_config['drive_power']
        except KeyError:
            drive = 10 # default to -6dB unless specified

        try:
            sweep_width = self.stage_config['sweep_width']
        except KeyError:
            sweep_width = 0.3 # default to 300kHz

        try: 
            sweep_df = self.stage_config['sweep_df']
        except KeyError:
            sweep_df = 0.005 # default to 5 kHz

        band_center = epics.caget(self.epics_root + SysgenCryo \
                + "bandCenterMHz") 
        subband_order = epics.caget(self.epics_root + SysgenCryo \
                + "subBandOrder")

        resp_all = []
        freqs_ordered = []

        for f in freqs: 
            subband, offset = freq_to_subband(f, band_center, subband_order)
            
            scan_fs = np.arange(offset - sweep_width, offset + sweepwidth,\
                    sweep_df)

            resp, f = eta_scan(epics_path, subband, scan_fs, drive)

            resp_all = resp + resp_all
            freqs_ordered = f + freqs_ordered

        return resp_all, freqs_ordered


    def analyze(self):
        """convert from etaScan data into parameters
        """

    def clean(self):
        pass
