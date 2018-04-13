from optparse import OptionParser
import sys
import os

from .setup import *
from .config.get_config import *

if __name__ == "__main__":
    # parse user arguments
    parser = OptionParser()

    # options
    #parser.add_option("-i", "--init",
    #                  action="store_true", dest="init", default=False,
    #                  help="Initialize system prior to tuning.")
    
    # parse
    (opts, args) = parser.parse_args()

    # load config file
    smurfCfg=SmurfConfig('/home/cryo/ssmith/cryo-det/software/CryoDetCmbHcd/python/smurf_setup/experiment.cfg')

    # run SMuRF setup
    setup(smurfCfg=smurfCfg)

    # exit successfully
    sys.exit(os.EX_OK)
