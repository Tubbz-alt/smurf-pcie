function [resp, f] = amplSweep(band, freqs, Nread, dwell)
% Sweep frequency, plot amplitude and phase
% band selects one of 32 sub bands (only 0:7 presently allowed)
% freqs is a vector of frequencies in the range -19.2 (MHz) to + 19.2 (MHz)

% resp is complex response demodulated response
% Nread (optional) number of reads of response per frequency setting
% dwell (optional) dwell time between setting and read and between reads
% Example:
%   Response  = ampleSweep(7, (-9.6:.1:9.6)*1e6) sweeps from -9.6 MHz to
%   +9.6 MHz in steps of 100kHz
% SS 20Nov2017

rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];

if nargin <3 
    Nread = 4; % default number of reads per frequnecy setting
end; 

if nargin <4 
    dwell = 0.001; %dwell time default is 1 ms
end; 

resp = zeros(1, Nread*length(freqs)); %allocate response vector

% up to 16 tones are summed/sub-band
% toneScale selects the scaling after summing 16 channels - global setting
%   0 is scaled by 1/8
%   1 is scaled by 1/4
%   2 is scaled by 1/2
%   3 is scaled by 1    (used for outputting single tone/sub-band)
lcaPut( [rootPath, 'toneScale'], 2 )  % half of full scale amplitude in a single tone

% global feedback enable
lcaPut( [rootPath, 'feedbackEnable'], 0 ) %Disable FB

% choose drive amplitude
Adrive = 5; % -15 dB
%Adrive = 13; % -6 dB
%Adrive = 15; %  full scale

%Qualify inputs
if band <0 | band > 31 
    display('band out of range (for now  0 <= band <= 7')
    return
end

if min(freqs) < -19.2  |  max(freqs) > 19.2
    display('frequencies must be in range +-19.2 MHz')
    return
end

subchan = 16*band; % use channel 0 of this band

lcaPut( [rootPath, 'rfEnable'], 1 ) %enable RF
lcaPut( [rootPath, 'statusChannelSelect'], subchan)   %set monitor channel to this channel

%loop over frequencies
for j=1:length(freqs)
    % configCryoChannel( rootPath, subchan, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
    configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, 0, 0 )
    pause(dwell);
    for nr = 1:Nread
        %read I & Q, save response as complex vector
%         configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, 0, 0 ); %write again to trigger status register update
%         pause(dwell);
        resp((j-1)*Nread + nr) = (lcaGet( [rootPath, 'I']) + 1i*lcaGet( [rootPath, 'Q'])) / 2^15; %CHECK SCALING!!!
        % are I&Q synchronous?        
        f((j-1)*Nread + nr) = freqs(j); 
    end
end
Adrive = 0; %turn down to very low amplitude
configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, 0, 0 )

% if we should want to check dF:
% [loopFilterOutput, frequencyError] = readbackCryoChannel( rootPath, channelNum )
%[a, b] = readbackCryoChannel( rootPath, 0 )
