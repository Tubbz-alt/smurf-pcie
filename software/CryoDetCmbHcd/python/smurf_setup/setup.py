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

    # read these from a PV list
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


def findFreqs(smurfCfg):
    """find resonance frequencies
    """

    print('Finding frequencies...')

    smurfFreqCfg = smurfCfg.get('findFreqs')

def optimizePowers(smurfCfg):
    "optimize power level for each resonator
    maximize dF for RF power level
    "

    print('Optimizing powers...')
    
    smurfPowerCfg = smurfCfg.get('optimizePowers')

def etaParams(smurfCfg):
    "calculate eta parameters for resonances
    "

    print('Calculating eta parameters...')
    
    smurfEtaCfg = smurfCfg.get('etaParams')

def tuneFluxRamp(smurfCfg):
    "tune the flux ramp
    "

    print('Setting up the flux ramp...')

    smurfFRCfg = smurfCfg.get('tuneFluxRamp')


def setup(smurfCfg):
    """                                                                        
Run complete SMuRF setup."""
    
    # the parts of the config file specifically addressing initialization
    if smurfCfg.has('init'):
        smurfInitCfg=smurfCfg.get('init')
        if 'do_init' in smurfInitCfg and smurfInitCfg['do_init']:
            # initialize the SMuRF based on input from control file
            init(smurfCfg=smurfCfg)

    #include a list of stages to do?
    stage_list = smurfCfg.get('do_stages')['stageList']
    for stage in stage_list:
        smurfCfg[stage]['do_' + stage] = 1
        #someone else can do this in a cleaner way

        # find the frequencies of resonances
        if smurfCfg.has('findFreqs'):
            smurfFreqCfg = smurfCfg.get('findFreqs')
            if 'do_findFreqs' in smurfFreqCfg and smurfFreqCfg['do_findFreqs']:
                # find the frequencies and output to data file (to do: create these data directories)
                findFreqs(smurfCfg=smurfCfg)

       # optimize the RF power for each resonance
        if smurfCfg.has('optimizePowers'):
            smurfPowerCfg = smurfCfg.get('optimizePowers')
            if 'do_optimizePowers' in smurfPowerCfg and smurfPowerCfg['do_optimizePowers']:
                optimizePowers(smurfCfg=smurfCfg)

       # calculate eta parameters
        if smurfCfg.has('etaParams'):
            smurfEtaCfg = smurfCfg.get('etaParams')
            if 'do_etaParams' in smurfEtaCfg and smurfEtaCfg['do_etaParams']:
                etaParams(smurfCfg=smurfCfg)

       # tune the fluxramp
        if smurfCfg.has('tuneFluxRamp'):
            smurfFRCfg = smurfCfg.get('tuneFluxRamp')
            if 'do_tuneFluxRamp' in smurfFRCfg and smurfFRCfg['do_tuneFluxRamp']:
                tuneFluxRamp(smurfCfg=smurfCfg)

