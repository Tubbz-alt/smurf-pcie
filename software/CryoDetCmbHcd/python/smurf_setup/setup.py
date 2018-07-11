import epics
from smurf_setup.util import *
from smurf_setup.util.pyrogue import *

SysgenCryo = ":AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:"

def read_fpga_status(root):
    C = root.split(":")
    epics_root = C[0]

    axiVersion = epics_root + ":AMCc:FpgaTopLevel:AmcCarrierCore:AxiVersion"
    jesdRx = epics_root + ":AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx"
    jesdTx = epics_root + ":AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx"

    uptime = epics.caget(axiVersion + ":UpTimeCnt")
    fpgaVersion = epics.caget(axiVersion + ":FpgaVersion")
    gitHash = epics.caget(axiVersion + ":GitHash")
    buildStamp = epics.caget(axiVersion + ":BuildStamp")

    print("Build stamp: " + str(buildStamp) + "\n")
    print("FPGA version: Ox" + str(fpgaVersion) + "\n")
    print("FPGA uptime: " + str(uptime) + "\n")
    print("\n")

    jesdTxEnable = epics.caget(jesdTx + ":Enable")
    jesdTxValid = epics.caget(jesdTx + ":DataValid")
    if jesdTxEnable != jesdTxValid:
        print("\n JESD Tx DOWN \n")
    else:
        print("JESD Tx Okay")

    return

def init(smurfCfg):
    """                                                                        
Initialize SMuRF."""
    print('Initializing...')

    # this exists because setup only hands off to init if it does
    smurfInitCfg=smurfCfg.get('init')
    root = smurfInitCfg['epics_root']
    set_env(root)
    set_defaults(True)
    
    for band in smurfInitCfg['bands']:
        print(band)

        cryo_root = root + SysgenCryo + "Base[{0}]:".format(band)
        epics.caput(cryo_root + 'iqSwapIn', str(smurfInitCfg['iqSwapIn']))
        epics.caput(cryo_root + 'iqSwapOut', str(smurfInitCfg['iqSwapOut']))
        epics.caput(cryo_root + 'refPhaseDelay', str(smurfInitCfg['refPhaseDelay']))
        epics.caput(cryo_root + 'refPhaseDelayFine', \
                str(smurfInitCfg['refPhaseDelayFine']))
        epics.caput(cryo_root + 'toneScale', str(smurfInitCfg['toneScale']))
        epics.caput(cryo_root + 'analysisScale', str(smurfInitCfg['analysisScale']))
        epics.caput(cryo_root + 'feedbackEnable', \
                str(smurfInitCfg['feedbackEnable']))
        epics.caput(cryo_root + 'feedbackGain', str(smurfInitCfg['feedbackGain']))
        epics.caput(cryo_root + 'lmsGain', str(smurfInitCfg['lmsGain']))

        # set feedbackLimitKHz(band, smurfInitCfg['feedbackLimitkHz'])

        epics.caput(cryo_root + 'feedbackPolarity', \
                str(smurfInitCfg['feedbackPolarity']))
        epics.caput(cryo_root + 'synthesisScale', \
                str(smurfInitCfg['synthesisScale']))

        adcroot = root + SysgenCryo + "CryoAdcMux[0]"
        
        jesd_root = root + ":AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:"

        if band == 0:
            epics.caput(jesd_root + "dataOutMux[{0}]".format(2), "UserData")
            epics.caput(jesd_root + "dataOutMux[{0}]".format(3), "UserData")
        elif band == 1:
            epics.caput(jesd_root + "dataOutMux[{0}]".format(0), "UserData")
            epics.caput(jesd_root + "dataOutMux[{0}]".format(1), "UserData")
            epics.caput(root + SysgenCryo + "Base[0]:iqSwapIn", str(0))
        elif band == 2:
            epics.caput(jesd_root + "dataOutMux[{0}]".format(6), "UserData")
            epics.caput(jesd_root + "dataOutMux[{0}]".format(7), "UserData")
            epics.caput(cryo_root + "iqSwapIn", str(1)) 
            epics.caput(cryo_root + "iqSwapOut", str(0))
        elif band == 3:
            epics.caput(jesd_root + "dataOutMux[{0}]".format(8), "UserData")
            epics.caput(jesd_root + "dataOutMux[{0}]".format(9), "UserData")
            epics.caput(cryo_root + "iqSwapIn", str(0))
            epics.caput(cryo_root + "iqSwapOut", str(0))
        else:
            epics.caput(jesd_root + "dataOutMux[{0}]".format(6), "UserData")
            epics.caput(jesd_root + "dataOutMux[{0}]".format(7), "UserData")
        
        epics.caput(cryo_root + 'dspEnable', str(smurfInitCfg['dspEnable']))

        jesd_link = root + ":AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:LINK_DISABLE"
    epics.caput(jesd_link, 1)
    epics.caput(jesd_link, 0)
    read_fpga_status(cryo_root)
    return


def setup(tuning):
    """                                                                        
Run complete SMuRF setup.
    Args:
     tuning (smurfTune object): tuning object carrying a smurfCfg
    """
    
    smurfCfg = tuning.config
    

    # the parts of the config file specifically addressing initialization
    if smurfCfg.has('init'):
        smurfInitCfg=smurfCfg.get('init')
        #if 'do_init' in smurfInitCfg and smurfInitCfg['do_init']:
            # initialize the SMuRF based on input from control file
		#init(smurfCfg=smurfCfg)
