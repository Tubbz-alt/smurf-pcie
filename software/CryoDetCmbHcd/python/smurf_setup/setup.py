from util.getput import *

def init(smurfCfg):
    """                                                                        
Initialize SMuRF."""
    print('Initializing...')

    # this exists because setup only hands off to init if it does
    smurfInitCfg=smurfCfg.get('init')
    #for band in smurfInitCfg['bands']:
    #    print(band)

    rootEpics = smurfInitCfg['epics_root']
    #rootEpics_SysgenCryo = rootEpics + ""


    ca_put(rootEpics_SysgenCryo + 'iqSwapIn', smurfInitCfg['iqSwapIn'])
    ca_put(rootEpics_SysgenCryo + 'iqSwapOut', smurfInitCfg['iqSwapOut'])
    ca_put(rootEpics_SysgenCryo + 'refPhaseDelay', smurfInitCfg['refPhaseDelay'])
    ca_put(rootEpics_SysgenCryo + 'refPhaseDelayFine', smurfInitCfg['refPhaseDelayFine'])
    ca_put(rootEpics_SysgenCryo + 'toneScale', smurfInitCfg['toneScale'])
    ca_put(rootEpics_SysgenCryo + 'feedbackGain', smurfInitCfg['feedbackGain'])
    ca_put(rootEpics_SysgenCryo + 'feedbackPolarity', smurfInitCfg['feedbackPolarity'])
    
    for band_no in smurfInitCfg['bands']:
        ca_put(rootEpics_SysgenCryo + 'bandCenterMHz', 4250 + 500 * band_no)
        # this is currently rewriting

    #for i in range(9):
        #rootEpics_DAC = rootEpics + ":AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:" + "dataOutMux[]".format(i)
        #ca_put(rootEpics_DAC, 'OutputOnes') # this is still hilarious to me

    rootEpics_ADC = rootEpcs + ":AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:CryoAdcMux[0]:"
    # enable DAC, PLL, map ADC for bands; to do here

    return




def setup(smurfCfg):
    """                                                                        
Run complete SMuRF setup."""
    
    # the parts of the config file specifically addressing initialization
    if smurfCfg.has('init'):
        smurfInitCfg=smurfCfg.get('init')
        if 'do_init' in smurfInitCfg and smurfInitCfg['do_init']:
            # initialize the SMuRF based on input from control file
            init(smurfCfg=smurfCfg)
