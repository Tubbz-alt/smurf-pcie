##############################################################################
## This file is part of 'LCLS2 LLRF Development'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'LCLS2 LLRF Development', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################
set format     "mcs"
set inteface   "SPIx1"
set size       "1024"
set BIT_PATH   "$::env(IMPL_DIR)/$::env(PROJECT).bit"

set LCLS_I_BIT  "0x02000000"
set LCLS_II_BIT "0x04000000"
set TEMP_BIT    "0x06000000"

set LCLS_I_GZ  "0x02F43EFC"
set LCLS_II_GZ "0x04F43EFC"
set TEMP_GZ    "0x06F43EFC"

set loadbit    "up ${LCLS_II_BIT} ${BIT_PATH}"