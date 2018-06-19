% clear;
close all

Fadc = 614.4e6;

rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];

readFpgaStatus( rootPath )

lcaPut( [rootPath, 'rfEnable'], 0 )
lcaPut( [rootPath, 'waveformSelect'], 0 )
lcaPut( [rootPath, 'waveformStart'], 0 )

lcaPut( [rootPath, 'refPhaseDelay'], 0 )

% up to 16 tones are summed/sub-band
% toneScale selects the scaling after summing 16 channels - global setting
%   0 is scaled by 1/8
%   1 is scaled by 1/4
%   2 is scaled by 1/2
%   3 is scaled by 1    (used for outputting single tone/sub-band)
lcaPut( [rootPath, 'toneScale'], 1 )  % setup for single tone/channelizer band

% global feedback enable
lcaPut( [rootPath, 'feedbackEnable'], 0 )

% global feedback limit
% setFeedbackLimit( rootPath, limit_mhz )
setFeedbackLimit( rootPath, 2 ); % MHz

% global feedback polarity
lcaPut( [rootPath, 'feedbackPolarity'], 0 )


% configCryoChannel( rootPath, channelNum, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
configCryoChannel( rootPath, 0, 2, 15, 0, 0, 0 )



lcaPut( [rootPath, 'rfEnable'], 1 )


% [loopFilterOutput, frequencyError] = readbackCryoChannel( rootPath, channelNum )
[a, b] = readbackCryoChannel( rootPath, 0 )

%%

adcData = readAdcData( rootPath, 0 );
dacData = readDacData( rootPath, 0 );

figure
win = hanning(length(adcData)/8);
pwelch(adcData, win, 0, [], Fadc, 'centered')
title('ADC data PSD')

figure
win = hanning(length(dacData)/8);
pwelch(dacData, win, 0, [], Fadc, 'centered')
title('DAC data PSD')

figure
hold on
plot(real(dacData))
plot(imag(dacData))
