function pn_generate_tone(phaseNoiseDecimation, fullScaleDiv2, freqMHz)
%% stupid function to generate tones in this new FW image
%% mostly used for setting up tones before taking actual data


rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
Fadc     = 614.4e6;

%% Setup phase noise measurement parameters
%phaseNoiseDecimation = 4;  % decimation values 4...8192 (307.2MHz/decimation)
%fullScaleDiv2        = 6;    % valid numbers 0...7, fullScale/2^fullScaleDiv2
%freqMHz              = 25;   % single tone frequency MHz

readoutRate    = Fadc/(phaseNoiseDecimation*2);
freqUint       = floor(freqMHz*1e6*2^32/(Fadc/2));

lcaPut( [rootPath, 'phaseNoiseDecimation'], phaseNoiseDecimation )
lcaPut( [rootPath, 'phaseNoiseFreq'], freqUint )
lcaPut( [rootPath, 'phaseNoiseScale'], fullScaleDiv2 )


end