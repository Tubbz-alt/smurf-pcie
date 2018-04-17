import epics

# maybe we'll read these from a file; that would be sweet
SysgenCryoBase = ":AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:"
dataOutMux = ":AMCc:FpgaToplevel:AppTop:AppTopJesd[0]:JesdTx:"
CryoADCMux = ":AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:CryoAdcMux[0]:"

def enable_dac_adc_map(epics_root, band_no):
    """stupid function to do the DAC/PLL enable, ADC remapping for a single band
       hopefully we can ditch this function soon

       Args:
        epics_root (str): address of epics root
        band_no (int): band to set up
    """
    if band_no == 0:
        epics.caput(epics_root + CryoADCMux + 'ChRemap[0]', 2)
        epics.caput(epics_root + CryoADCMux + 'ChRemap[1]', 3)
        epics.caput(epics_root + dataOutMux + 'dataOutMux[2]', 'UserData')
        epics.caput(epics_root + dataOutMux + 'dataOutMux[3]', 'UserData')
    elif band_no == 1:
        epics.caput(epics_root + CryoADCMux + 'ChRemap[0]', 0)
        epics.caput(epics_root + CryoADCMux + 'ChRemap[1]', 1)
        epics.caput(epics_root + dataOutMux + 'dataOutMux[0]', 'UserData')
        epics.caput(epics_root + dataOutMux + 'dataOutMux[1]', 'UserData')
        epics.caput(epics_root + SysgenCryoBase + 'iqSwapIn', 0)
    elif band_no == 2:
        epics.caput(epics_root + CryoADCMux + 'ChRemap[0]', 6)
        epics.caput(epics_root + CryoADCMux + 'ChRemap[1]', 7)
        epics.caput(epics_root + dataOutMux + 'dataOutMux[6]', 'UserData')
        epics.caput(epics_root + dataOutMux + 'dataOutMux[7]', 'UserData')
    elif band_no == 3:
        epics.caput(epics_root + CryoADCMux + 'ChRemap[0]', 4)
        epics.caput(epics_root + CryoADCMux + 'ChRemap[1]', 5)
        epics.caput(epics_root + dataOutMux + 'dataOutMux[8]', 'UserData')
        epics.caput(epics_root + dataOutMux + 'dataOutMux[9]', 'UserData')
        epics.caput(epics_root + SysgenCryoBase + 'iqSwapIn', 0)
    else: # default to band_no = 2 for now
        epics.caput(epics_root + CryoADCMux + 'ChRemap[0]', 6)
        epics.caput(epics_root + CryoADCMux + 'ChRemap[1]', 7)
        epics.caput(epics_root + dataOutMux + 'dataOutMux[6]', 'UserData')
        epics.caput(epics_root + dataOutMux + 'dataOutMux[7]', 'UserData')
    return

def init(smurfCfg):
    """                                                                        
Initialize SMuRF."""
    print('Initializing...')

    # this exists because setup only hands off to init if it does
    smurfInitCfg=smurfCfg.get('init')
    #for band in smurfInitCfg['bands']:
    #    print(band)

    rootEpics = smurfInitCfg['epics_root']
    root_SysgenCryo = rootEpics + SysgenCryoBase

    # read these from a PV list
    SysgenCryoPVs = ['iqSwapIn', 'iqSwapOut', 'refPhaseDelay', 'toneScale', \
            'feedbackGain', 'feedbackPolarity']
    for pv in SysgenCryoPVs:
        epics.caput(root_SysgenCryo + pv, smurfInitCfg[pv])

    #epics.caput(rootEpics_SysgenCryo + 'iqSwapIn', smurfInitCfg['iqSwapIn'])
    # etc (you get the idea, if you want to switch it back) 

    for band_no in smurfInitCfg['bands']:
        epics.caput(root_SysgenCryo + 'bandCenterMHz', 4250 + 500 * band_no)
        # this is currently rewriting

    for dacno in range(9):
        epics.caput(rootEpics + dataOutMux + 'dataOutMux[%i]' % dacno, 'OutputOnes')

    # enable DAC, PLL, ADC mapping for single band
    rootADC = rootEpics + CryoADCMux
    for band_no in smurfInitCfg['bands']:
        enable_dac_adc_map(band_no)

    #readFpgaStatus(epics_root)



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
    smurfStageCfg = smurfCfg.get('do_stages')
    stage_list = smurfStageCfg['stageList']
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

