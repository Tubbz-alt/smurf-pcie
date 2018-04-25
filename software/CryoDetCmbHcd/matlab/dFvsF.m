function [dF, f] = dFvsF(band, freqs, Nread, dwell)
%sweep frequencies in a band with feedback off
%plot dF vs F

%SSmith 28 Nov 2017

rootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:';


if nargin <3 
    Nread = 4; % default number of reads per frequnecy setting
end; 

if nargin <4 
    dwell = 0.002; %dwell time default is 1 ms
end; 

df = zeros(1, Nread*length(freqs)); %allocate response vector
f = df;

lcaPut( [rootPath, 'toneScale'], 3 )  % full amplitude in a single tone

% global feedback enable
lcaPut( [rootPath, 'feedbackEnable'], 0 ) %Disable FB

% choose drive amplitude
Adrive = 12; % -6 dB

%Qualify inputs
if band <0 | band > 31 
    display('band out of range ( 0 <= band <= 31')
    return
end

if min(freqs) < -19.2  |  max(freqs) > 19.2
    display('frequencies must be in range +-19.2 MHz')
    return
end

subchan = 16*band; % use channel 0 of this band

lcaPut( [rootPath, 'rfEnable'], 1 ) %enable RF
lcaPut( [rootPath, 'statusChannelSelect'], subchan)   %set monitor channel to this channel
chanPVprefix = [rootPath, 'CryoChannels:CryoChannel[', num2str(subchan), ']:']

etaPhase = 180 * lcaGet([chanPVprefix, 'etaPhase']) / 2^15
etaMag = lcaGet([chanPVprefix, 'etaMag'])/1024

for j=1:length(freqs)
    
    configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, etaPhase, etaMag )
    pause(dwell);
    for nr = 1:Nread
        pause(dwell)
        dFword = lcaGet([chanPVprefix, 'frequencyError']); %get real part
        if dFword >= 2^23
            dFword = dFword - 2^24;   %treat as signed 24 bit
        end
        dF((j-1)*Nread + nr) = dFword * 38.4/2^24; %get real part

        f((j-1)*Nread + nr) = freqs(j); 
    end
end

figure(1); plot(f, dF, '.');grid
title(['Freq Error vs Freq ' num2str(band)])
xlabel('Frequency (MHz)')
ylabel('Freq Error (MHz)')

Adrive = 1; %turn down to low amplitude
configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, etaPhase, etaMag ) ;
end
