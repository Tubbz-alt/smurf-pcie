def init(smurfCfg):
    """                                                                        
Initialize SMuRF."""
    print('Initializing...')

    # this exists because setup only hands off to init if it does
    smurfInitCfg=smurfCfg.get('init')
    #for band in smurfInitCfg['bands']:
    #    print(band)

def setup(smurfCfg):
    """                                                                        
Run complete SMuRF setup."""
    
    # the parts of the config file specifically addressing initialization
    if smurfCfg.has('init'):
        smurfInitCfg=smurfCfg.get('init')
        if 'do_init' in smurfInitCfg and smurfInitCfg['do_init']:
            # initialize the SMuRF based on input from control file
            init(smurfCfg=smurfCfg)
