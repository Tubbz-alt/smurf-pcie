function [resp, band] = amplQuery(bands, Nread, dwell)


rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];

if nargin < 1
    bands = 0:31;
end

if nargin <2
    Nread = 4; % default number of reads per frequnecy setting
end; 

if nargin <3
    dwell = 0.001; %dwell time default is 1 ms
end; 

resp = [];
band=[];

lcaPut( [rootPath, 'toneScale'], 3 )  % full amplitude in a single tone

% global feedback enable
lcaPut( [rootPath, 'feedbackEnable'], 0 ) %Disable FB

% choose drive amplitude
% Adrive = 12; % -6 dB
Adrive = 14; %  

if min(bands) < 0  |  max(bands) > 31
    display('bands must be in range 0:31')
    return
end

lcaPut( [rootPath, 'rfEnable'], 1 ) %enable RF
pause(dwell)

%loop over band
for j=1:length(bands)
    subchan = 16*bands(j); % use channel 0 of this band
    lcaPut( [rootPath, 'statusChannelSelect'], subchan);   %set monitor channel to this channel
    
    configCryoChannel( rootPath, subchan, 0, Adrive, 0, 0, 0 );
    pause(dwell);
    for nr = 1:Nread
        resp((j-1)*Nread + nr) = (lcaGet( [rootPath, 'I']) + 1i*lcaGet( [rootPath, 'Q'])) / 2^15; %CHECK SCALING!!!
        band((j-1)*Nread + nr) = bands(j); 
    end
    Adrive = 0; %turn down to very low amplitude
    configCryoChannel( rootPath, subchan, 0, Adrive, 0, 0, 0);
end

figure;plot(band,abs(resp),'.')