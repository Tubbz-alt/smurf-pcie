import smurf_setup.config as config
from smurf_setup.util.cryochannel import *

class SmurfStage:
    """initializes, runs, analyzes, and cleans up after a SMuRF tuning stage
    """

    def __init__(self):
        # list of required config settings
        _required=[]

        # name associated when writing outputs
        _nickname=[]

    def prepare(self):
        pass

    def run(self):
        pass

    def analyze(self):
        pass

    def cleanup(self, SmurfCfg):
        """turn everything off at the end of each stage

           Args:
            SmurfCfg (config object): configuration object as read in from cfg
            file
        """
        SmurfInitCfg = SmurfCfg.get('init')
        epics_root = SmurfInitCfg['epics_root']

        all_off(epics_root)
