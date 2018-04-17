import epics

"""Epics wrapper for configuring a single cryo channel
"""

CryoChannels = "AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:CryoChannels:"



def configCryoChannel(root, channelNo, frequencyMhz, ampl, feedbackEnable, etaPhase, etaMag):
    """written to match configCryoChannel.m

       Args:
        root (str): EPICS root path eg mitch_epics
        channelNo (int): cryo channel number (0 .. 511)
        frequencyMhz (float): frequency within subband (-19.2 .. 19.2)
        amplitude (int): ADC output amplitude (0 .. 15)
        feedbackEnable (0 or 1): boolean for enabling feedback
        etaPhase (float): feedback eta phase, in degrees (-180 .. 180)
        etaMag (float): feedback eta magnitude
    """

    # construct the pvRoot
    epicsRoot = root + CryoChannels + 'CryoChannel[%i]:' % channelNo

    n_subband = 32
    band = 614.4 # MHz
    sub_band = band / (n_subband / 2) # width of each subband

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

