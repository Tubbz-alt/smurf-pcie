import os
import sys
import math
import matplotlib.pyplot as plt # not sure we need this?
import numpy as np # pyepics reads stuff as numpy arrays if possible
import subprocess
import epics
from smurf_setup.stage.tuningstage import SmurfStage
from smurf_setup.util.cryochannel import *
from smurf_setup.util.smurftune import *

"""scan resonances and get eta parameters for locking onto resonances
"""


SysgenCryo =  "AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:"
CryoChannels = SysgenCryo + "CryoChannels:"

def eta_scan(epics_path, subchan, freqs, drive):
    """scan a small range and get IQ response
    
       Args:
        epics_path (str): root path for epics commands for eta scanning
        subchan (int): subchannel to scan; should be n_subchan * subband_no
        freqs (list): frequencies to scan over
        drive (int): power at which to scan
    """



    pv_list = ["etaScanFreqs", "etaScanAmplitude", "etaScanChannel", \
            "etaScanDwell"]
    pv_vals = [freqs, drive, subchan, 0] # make 0 a variable?

    for i in range(len(pv_list)):
        epics.caput(epics_path + pv_list[i], pv_vals[i])


    #while False:
        # set a monitor
    #epics.camonitor(epics_path + "etaScanResultsReal", writer=None, on_change)
    epics.caput(epics_path + "runEtaScan", 1)

    I = epics.caget(epics_path + "etaScanResultsReal", count = len(freqs))
    Q = epics.caget(epics_path + "etaScanResultsImag", count = len(freqs))

    epics.camonitor_clear(epics_path + "etaScanResultsReal")

    

    if I > 2**23:
        I = I - 2**24
    if Q > 2**23:
        Q = Q - 2**24

    I = I / (2**23)
    Q = Q / (2**23)

    response = I + 1j * Q
    return response, freqs


def full_band_ampl_sweep(epics_root, band, subbands, drive, N_read):
    """sweep a full band in amplitude, for finding frequencies

    args:
     epics_root (str) = epics root path
     band (int) = bandNo (500MHz band)
     subbands (list of ints) = which subbands to sweep
     drive (int) = drive power (defaults to 10)
     n_read (int) = numbers of times to sweep, defaults to 2

    returns:
     freqs (list, n_freqs x 1) = frequencies swept
     resp (array, n_freqs x 2) = complex response
    """

    baseroot = epics_root + ":AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[{0}]:".format(band)
    digitizer_freq_MHz = epics.caget(baseroot + "digitizerFrequencyMHz")
    n_subbands = epics.caget(baseroot + "numberSubBands")
    band_center_MHz = epics.caget(baseroot + "bandCenterMHz")
    subband_width_MHz = 2 * digitizer_freq_MHz / n_subbands

    scan_freqs = np.arange(-3, 3.1, 0.1) # take out this hardcode

    resp = np.zeros((n_subbands, np.shape(scan_freqs)[0]), dtype=complex)
    freqs = np.zeros((n_subbands, np.shape(scan_freqs)[0]))

    subband_nos, subband_centers = get_subband_centers(epics_root,band)

    print('Working on band {:d}'.format(band))
    for subband in subbands:
        print('sweeping subband no: ', subband)
        r, f = fast_eta_scan(epics_root, band, subband, scan_freqs, N_read, drive)
        resp[subband,:] = r
        freqs[subband,:] = f
        freqs[subband,:] = scan_freqs + \
            subband_centers[subband_nos.index(subband)]
    return freqs, resp

def peak_finder(x, y, threshhold):
    """finds peaks in x,y data with some threshhold
    """
    in_peak = 0

    peakstruct_max = []
    peakstruct_nabove = []
    peakstruct_freq = []

    for idx in range(len(y)):
        freq = x[idx]
        amp = y[idx]

        if in_peak == 0:
            pk_max = 0
            pk_freq = 0
            pk_nabove = 0

        if amp > threshhold:
            if in_peak == 0: # start a new peak
                n_peaks = n_peaks + 1

            in_peak = 1
            pk_nabove = pk_nabove + 1

            if amp > pk_max: # keep moving until find the top
                pk_max = amp
                pk_freq = freq

            if idx == len(y) or y[idx + 1] < threshhold:
                peakstruct_max.append(pk_max)
                peakstruct_nabove.append(pk_nabove)
                peakstruct_freq.append(pk_freq)
                in_peak = 0
    return peakstruct_max, peakstruct_nabove, peakstruct_freq

def linear_fit(x,y):
    """returns a slope and y-intercept from x and y data. written to avoid
    loading more packages.
    """

    n_points = len(y)
    slopes = np.zeros((1, int(n_points * (n_points - 1) / 2)))
    slp_idx = 0

    for idx in range(n_points):
        for idx2 in range(idx+1, n_points):
            slopes[idx] = (y[idx2] - y[idx]) / (x[idx2] - x[idx])
            if x[idx2] < x[idx]:
                slopes[idx] = -1 * slopes[idx]

            slp_idx += 1

    m = np.median(slopes)
    b = np.median(y - m * x)
    return m, b

def find_peaks(freqs, response, subband, params):
    """find the peaks within a given subband

    Args:
     freqs (vector): should be a single row of the broader freqs array
     response (complex vector): complex response for just this subband
     subband (int): which subband we are looking in
     params (list): normalize, nsampdrop, threshhold, margin factor, phaseMinCut,
      phaseMaxCut

    Outputs:
     resonances (list of floats) found in this subband
    """

    normalize = params[0]
    nsampdrop = params[1]
    threshhold = params[2]
    fmarginfactor = params[3]
    phaseMinCut = params[4]
    phaseMaxCut = params[5]

    # reduce_fresp??

    df = freqs[1] - freqs[0]
    Idat = np.real(response)
    Qdat = np.imag(response)
    phase = np.unwrap(np.arctan2(Qdat, Idat))

    diff_phase = np.diff(phase)
    diff_freqs = np.add(freqs[:-1], df / 2) # lose an index from differencing

    if normalize==True:
        norm_min = min(diff_phase[nsampdrop:-nsampdrop])
        norm_max = max(diff_phase[nsampdrop:-nsampdrop])

        diff_phase = (diff_phase - norm_min) / (norm_max - norm_min)

    peakstruct_max, peakstruct_nabove, peakstruct_freq = peak_finder(diff_freqs, diff_phase, threshhold)

    diff_peakfreqs = np.diff(peakstruct_freq)

    fmargin = df * fmarginfactor
    
    #peakfinder

    #remove gradient

    #some other random stuff that looks to be just diagnostics


def find_all_peaks(freqs, response, subbands, params):
    """find the peaks within each subband requested from a fullbandamplsweep
    Args:
     freqs (array):  (n_subbands x n_freqs_swept) array of frequencies swept
     response (complex array): n_subbands x n_freqs_swept array of complex response
     subbands (list of ints): subbands that we care to search in
     params (list): normalize, nsampdrop, threshhold, marginc factor, phaseMinCut,
      phaseMaxCut
    """
    res = np.zeros((0,2))

    for subband in subbands:
        peak = find_peaks(freqs[subband,:], response[subband,:], params)
        
        peak_sub = np.vstack((peak, subband))
        res = np.vstack((res, peak_sub))

    return res



def subband_off(smurfCfg, subchan, freqs):
    """turn off a single subband

       Args:
        smurfCfg (config object)
        subchan (int): channel number
        freqs (list): freqs to disable
    """
    initConfig = smurfCfg.get('init')
    epics_root = initConfig["epics_root"]

    config_cryo_channel(epics_root, subchan, freqs, 0, 0, 0, 0)
    return


class findFreqs(SmurfStage):
    """class to locate the resonances. Inherits from the more generic tuning
       stage class
    """

    def __init__(self, tuning):
        self._nickname = "find_freqs"

        super().__init__(tuning)

        initconfig = self.config.get('init')
        self.epics_root = initconfig['epics_root']
        self.stage_config = tuning.config.get('findFreqs')

    def prepare(self):
        """prepare system to scan for eta parameters by figuring out which band to use
           
           Args:
            none; subbands should come off of the config file

           Outputs:
            subbands: which subbands will be scanned
        """
        try:
            subbands = self.stage_config['subbands']
        except KeyError:
            subbands = [63] # default to the center

        self.subbands = subbands
        return self.subbands

    def run(self):
        initconfig = self.config.get('init')
        band = initconfig["bands"][0]
        SysgenCryo = ":AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:" + \
            "Base[%s]:" % str(band)
        n_channels = epics.caget(self.epics_root + SysgenCryo \
                + "numberChannels") # should be 512 for a 500MHz band
        n_subbands = epics.caget(self.epics_root + SysgenCryo \
                + "numberSubBands") # is 128 right now

        n_subchannels = n_channels / n_subbands # 16
        
        epics_path = self.epics_root + SysgenCryo + "CryoChannels:" 
        
        subbands = self.subbands

        try:
            drive = self.stage_config['drive_power']
        except KeyError:
            drive = 10 # default to -6dB unless specified

        try:
            n_read = self.stage_config['n_read']
        except KeyError:
            n_read = 2 # default to two sweeps per subband

        band_center = epics.caget(self.epics_root + SysgenCryo \
                + "bandCenterMHz") 
        self.band_center = band_center # probably should have done this even earlier


        f, resp = full_band_ampl_sweep(self.epics_root, band, subbands, \
            drive, n_read)
        print("band center: ", band_center)

        self.f = f
        self.resp = resp

        plt.figure()
        for subband in subbands:
            plt.plot(f[subband, :], np.absolute(resp[subband, :]), marker = ".")
        
        plot_name = os.path.join(self.plot_dir, self._nickname + ".png")
        plt.title("findfreqs response")
        plt.xlabel("Frequency offset from Subband Center (MHz)")
        plt.ylabel("Normalized Amplitude")
        plt.savefig(plot_name)

        # should probably write this somewhere; analogous to *amplSweep.mat
        
        return f, resp
    

    def analyze(self):
        """make & save some plots and stuff
        """
        res_freqs = find_all_peaks(self.f, self.resp, self.subbands)


        try:
            cutoff_freq = self.stage_config['cutoff_freq']
        except KeyError:
            cutoff_freq = 0.2 # drop within 0.2MHz of each other

        header = "frequency,band,offset"
        self.write(results, header) # this should've been defined in the superclass        
        

    def clean(self):
        pass
