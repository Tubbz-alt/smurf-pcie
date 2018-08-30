import epics
import numpy as np
import math


def setHEMTVg(epics_root, bit, docfg = False):
    """ sets the gate voltage on the HEMT
    Args: 
     epics_root (str): epics root (eg mitch_epics)
     bit (int): bit setting; will need to calibrate this with multimeter to 
     get to real voltages
     docfg (bool): register change
    """

    if bit > 250e3
        print("Bits too high! Setting to 250e3 to prevent overbiasing\n")
        bit = 250e3
    
    if bit == 524287
        bit = 524287 # I think this is some special diagnostic bit?

    rtmSpiMaxRootPath = epics_root + ":AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:RtmSpiMax:"
    
    if docfg
        epics.caput(rtmSpiMaxRootPath + "HemtBiasDacCtrlRegCh[33]", str(2))

    epics.caput(rtmSpiMaxRootPath + "HemtBiasDacCtrlRegCh[33]", str(bit))

    return


def setTESbias(epics_root, DAC_number, value, docfg = False):
    """sets a TES bias on a particular DAC number
    Args:
     epics_root (str): epics root
     DAC_number (int): which DAC you want to command
     value (float): -10V to 10V
     docfg (bool): register change
    """

    rtmSpiMaxRootPath = epic_root + ":AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:RtmSpiMax:"

    if docfg
        epics.caput(rtmSpiMaxRootPath + "TesBiasDacCtrlRegCh[{0}]".format(DAC_number), str(2))

    bits = round(value * 2**19 / 10) # DAC is signed 20-bit number

    if bits > 2**19 - 1
        print("Exceeds max range! Setting to 10V")
        bits = 2**19 - 1
    elif bits < -2**19
        print("Below min range! Setting to -10V")
        bits = -2**19

    epics.caput(rtmSpiMaxRootPath + "TesBiasDacCtrlRegCh[{0}]".format(DAC_number), bits)

    return

def fluxramp_fixedbias(epics_root, frac_full_scale):
    """sets the flux ramp at a DC bias
    Args:
     epics_root(str): epics root path
     frac_full_scale(float): fraction of max RTM output. relationship to Phi0 is empirical
    """

    if frac_full_scale < 0 or frac_full_scale > 1:
        print("Error! frac_full_scale must be between 0 and 1!!")
        raise valueError

    rtm_path = epics_root + ":AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:RtmSpiSr:"

    LTC1668RawData = (2**16 * (1 - frac_full_scale)) // 2

    epics.caput(rtm_path + "ModeControl", 1)
    epics.caput(rtm_path + "LTC1668RawDacData", LTC1668RawData)

    return

def fluxramp_setup():
    """this is pulled from a dictionary of flux ramp setup values
    Usually that dictionary is the fluxrampsetup portion of a cfg file

    Args:
     epics_root: epics root path
     setup_dict: dictionary with the following keys
       frac_full_scale (float): default 0.7, amplitude of flux ramp
       diff_frac_full_scale (float): margin allowed on amplitude before error
       sawtooth_rate (int): sawtooth rate in kHz
       pulse_width (int): width of sawtooth shape; usually shouldn't change
       debounce_width (int): also usually doesn't change
       ramp_slope (int): ask mitch
       mode_control (int): ask mitch

    """
    return




def fluxramp_onoff(epics_root, bit):
    """
    turns on/off the flux ramp. assumes that flux ramp has already been set up

    Args:
     epics_root (str): epics root path
     bit (bool): on/off
    """

    rtm_path = epics_root + ":AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:RtmSpiSr:"

    epics.caput(rtm_path + "CfgRegEnaBit", bit)

    return


def reset_rtm(epics_root):
    """ resets the RTM if it's looking funky
    
    Args:
     epics_root (str): epics root path
    """
    # I am sad that we need this sometimes

    rtm_path = epics_root + ":AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:"

    epics.caput(rtm_path + "resetRtm", 1)

    return
