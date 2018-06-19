import epics
import numpy as np
from math import floor

"""Epics wrappers for working with single cryo channel
"""

SysgenCryo = "AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[2]:"
CryoChannels = SysgenCryo + "CryoChannels:"



def config_cryo_channel(smurfCfg, channelNo, frequencyMhz, ampl, \
        feedbackEnable, etaPhase, etaMag):
    """written to match configCryoChannel.m

       Args:
        smurfCfg (config object): configuration object (really, a dictionary)
        channelNo (int): cryo channel number (0 .. 511)
        frequencyMhz (float): frequency within subband (-19.2 .. 19.2)
        amplitude (int): ADC output amplitude (0 .. 15)
        feedbackEnable (0 or 1): boolean for enabling feedback
        etaPhase (float): feedback eta phase, in degrees (-180 .. 180)
        etaMag (float): feedback eta magnitude
    """

    # construct the pvRoot
    smurfInitCfg = smurfCfg.get('init')
    root = smurfInitCfg['epics_root'] + ":"
    epicsRoot = root + CryoChannels + 'CryoChannel[%i]:' % channelNo

    n_subband = epics.caget(root + SysgenCryo + 'numberSubBands') # should be 32
    band = epics.caget(root + SysgenCryo + 'digitizerFrequencyMHz') # 614.4 MHz
    sub_band = band / (n_subband/2) # width of each subband

    ## some checks to make sure we put in values within the correct ranges

    if frequencyMhz > sub_band/2:
        #print("configCryoChannel: freq too high! setting to top of subband")
        freq = sub_band/2
    elif frequencyMhz < sub_band/2:
        #print("configCryoChannel: freq too low! setting to bottom of subband")
        freq = -sub_band/2
    else:
        freq = frequencyMhz

    if ampl > 15:
        #print("configCryoChannel: amplitude too high! setting to 15")
        amp = 15
    elif ampl < 0:
        #print("configCryoChannel: amplitude too low! setting to 0"
        amp = 0
    else:
        amp = ampl

    # get phase within -180..180
    phase = etaPhase
    while etaPhase > 180:
        phase = phase - 360
    while etaPhase < -180:
        phase = phase + 360

    pv_list = ['centerFrequencyMHz', 'amplitudeScale', 'feedbackEnable', \
            'etaPhaseDegree', 'etaMagScaled']
    pv_values = [freq, amp, feedbackEnable, phase, etaMag]

    for i in range(len(pv_list)):
        epics.caput(epicsRoot + pv_list[i], pv_values[i])


def all_off(root):
    """turn off all the channels quickly (hooray!)

       Args:
        root (str): epics root (eg mitch_epics)
    """
    epicsRoot = root + CryoChannels
    epics.caput(epicsRoot + 'setAmplitudeScales', 0)
    epics.caput(epicsRoot + 'feedbackEnableArray', np.zeros(512).astype(int))

def freq_to_subband(freq, band_center, subband_order):
    """look up subband number of a channel frequency

       Args:
        freq (float): frequency in MHz
        band_center (float): frequency in MHz of the band center
        subband_order (list): order of subbands within the band

       Outputs:
        subband_no (int): subband (0..31) of the frequency within the band
        offset (float): offset from subband center
    """

    # subband_order = [8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17\
    #        2 18 3 19 4 20 5 21 6 22 7 23]
    # default order, but this is a PV now so it can be fed in

    try:
        order = [int(x) for x in subband_order] # convert it to a list
    except ValueError:
        order = [8, 24, 9, 25, 10, 26, 11, 27, 12, 28, 13, 29, 14, 30, 15,\
                31, 0, 16, 1, 17, 2, 18, 3, 19, 4, 20, 5, 21, 6, 22, 7, 23]

    # can we pull these hardcodes out?
    bb = floor((freq - (band_center - 307.2 - 9.6)) / 19.2)
    offset = freq - (band_center - 307.2) - bb * 19.2
    
    subband_no = order[bb]
    
    return subband_no, offset

