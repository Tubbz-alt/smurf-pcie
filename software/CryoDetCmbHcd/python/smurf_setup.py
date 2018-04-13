import os
import sys

import smurf_setup as ss

# parse user arguments
from optparse import OptionParser
parser = OptionParser()
(options, args) = parser.parse_args()

# run SMuRF setup
ss.smurf_setup()

# exit successfully
sys.exit(os.EX_OK)
