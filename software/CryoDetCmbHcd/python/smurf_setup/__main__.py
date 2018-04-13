from optparse import OptionParser
import sys
import os

def do_init():
    """                                                                        
Initialize SMuRF."""
    print('Initializing...')

def setup(init):
    """                                                                        
Run complete SMuRF setup."""

    if init:
        # initialize the SMuRF based on input from control file
        do_init()

if __name__ == "__main__":
    # parse user arguments
    parser = OptionParser()

    # options
    parser.add_option("-i", "--init",
                      action="store_true", dest="init", default=False,
                      help="Initialize system prior to tuning.")
    
    # parse
    (opts, args) = parser.parse_args()

    # run SMuRF setup
    setup(init=opts.init)

    # exit successfully
    sys.exit(os.EX_OK)
