import epics
import time

def set_defaults(x = False):
    """ function to set default config
    """

    global setDefaultsPV

    if x == True:
        epics.caput(setDefaultsPV, 1)
        time.sleep(5)
        print("Done setting defaults\n")
    return

def read_all(x = False):
    """read all registers of the pyrogue server
    """

    global ReadAllPV

    print("Sending command to read all registers...")
    epics.caput(ReadAllPV, 1)
    time.sleep(5)
    print("Done reading all\n")

def set_env(epics_root):
    """set the environment for the EPICS server
    Args:
        epics_root (str): the PV name prefix used to launch, eg "demo_epics"
    """

    # do I need to set labCA path? isn't that a Matlab thing?

    global PVNamePrefix
    global DMIndex
    global ReadAllPV
    global setDefaultsPV
    global buildStampPV
    global gitHashPV
    global fpgaVersionPV
    global upTimeCntPV
    global DMTriggerPV
    global DMBufferSizePV
    global DMInputDataValidPV
    global DMInputMuxSelPV
    global WEBStartAddrPV
    global WebEndAddrPV
    global streamPV
    global cmdJesdRst

    PVNamePrefix = epics_root
    print("Using the EPICS PV name prefix: %s", PVNamePrefix)

    DMIndex = 0 # should this be hardcoded?

    ReadAllPV = epics_root + ":AMCc:ReadAll"
    setDefaultsPV = epics_root + ":AMCc:setDefaults"
    buildStampPV = epics_root + ":AMCc:FpgaTopLevel:AmcCarrierCore:AxiVersion:BuildStamp"
    gitHashPV = epics_root + ":AMCc:FpgaTopLevel:AmcCarrierCore:AxiVersion:GitHash"
    fpgaVersionPV = epics_root + ":AMCc:FpgaTopLevel:AmcCarrierCore:AxiVersion:FpgaVersion"
    upTimeCntPV = epics_root + ":AMCc:FpgaTopLevel:AmcCarrierCore:AxiVersion:UpTimeCnt"
    DMTriggerPV = epics_root + ":AMCc:FpgaTopLevel:AppTop:DaqMuxV2[%s]:TriggerDaq" % str(DMIndex)
    DMBufferSizePV = epics_root + ":AMCc:FpgaTopLevel:AppTop:DaqMuxV2[%s]:DataBufferSize" % str(DMIndex)
    cmdJesdRst  = epics_root + ":AMCc:FpgaTopLevel:AppTop:JesdReset"

    DMInputMuxSelPV = [None] * 4
    DMInputDataValidPV = [None] * 4
    WEBStartAddrPV = [None] * 4
    WEBEndAddrPV = [None] * 4

    for i in range(4):
        DMInputMuxSelPV[i] = epics_root + ":AMCc:FpgaTopLevel:AppTop:DaqMuxV2[%s]:InputMuxSel[%s]" % (str(DMIndex), str(i))
        DMInputDataValidPV[i] = epics_root + ":AMCc:FpgaTopLevel:AppTop:DaqMuxV2[%s]:InputDataValid[%s]" % (str(DMIndex), str(i))
        WEBStartAddrPV[i] = epics_root + ":AMCc:FpgaTopLevel:AmcCarrierCore:AmcCarrierBsa:BsaWaveformEngine[%s]:WaveformEngineBuffers:StartAddr[%s]" % (str(DMIndex), str(i))
        WEBEndAddrPV[i] = epics_root + ":AMCc:FpgaTopLevel:AmcCarrierCore:AmcCarrierBsa:BsaWaveformEngine[%s]:WaveformEngineBuffers:EndAddr[%s]" % (str(DMIndex), str(i))

    streamPV = [None] * 8
    for j in range(8):
        streamPV[j] = epics_root + ":AMCc:Stream%s" % str(j)


    print("Done setting environment\n")

    read_all(True)

    print("Firmware image information:")
    print("=====================================================")
    buildstamp = epics.caget(buildStampPV)
    print("Build Stamp = %s" % str(buildstamp)) # might need to convert to ascii
    print("Fpga Version = %s" % str(epics.caget(fpgaVersionPV)))
    print("Git Hash = %s" % str(epics.caget(gitHashPV))) # convert to ascii??
    print("Up Time Counter = %s" % str(epics.caget(upTimeCntPV)))
