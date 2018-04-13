import os
import sys

import smurf_setup as ss

# parse user arguments
from optparse import OptionParser
parser = OptionParser()

# options
parser.add_option("-i", "--init",
                  action="store_true", dest="init", default=False,
                  help="Initialize system prior to tuning.")

# parse
(opts, args) = parser.parse_args()

# run SMuRF setup
ss.smurf_setup(init=opts.init)

# exit successfully
sys.exit(os.EX_OK)
