function [f,dF] = Fcud(channel, dwell )
%[f, dF] = Fcud(channel, dwell)
% scrolls history of frequency, frequency error for a channel

if nargin < 1
    channel = 0
end

if nargin <2
    dwell = 0.1;
end

rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
chanPVprefix = [rootPath, 'CryoChannels:CryoChannel[', num2str(channel), ']:']

F = [];
df=[];
t = [];

count = 0;
tic

while true
%    configCryoChannel( rootPath, channel, freqs(j), Adrive, 0, 0, 0 )
    fword = lcaGet( [rootPath, 'CryoChannels:CryoChannel[' num2str(channel) ']:', 'loopFilterOutput']);
    if fword >= 2^23 fword = fword - 2^24; end
    f = fword/2^24*38.4; %in MHz
   
    df = lcaGet( [rootPath, 'CryoChannels:CryoChannel[' num2str(channel) ']:', 'frequencyError'])/2^24*38.4 ;   % in MHz

    count = count +1;
    F(count) = f;
    dF(count) = df;
    t(count) = toc;
    
    if mod(count, 20) == 0
        figure(1), plot(t,F, '.'), grid, title('Frequency History')
        xlabel('Time (s)'), ylabel('Freq (MHz)')
        figure(2), plot(t, dF, '.'), grid, title('Freq Error History')
        ylabel('Error Freq (MHz)'), xlabel('Time (s)')
    pause(dwell);
end
end

