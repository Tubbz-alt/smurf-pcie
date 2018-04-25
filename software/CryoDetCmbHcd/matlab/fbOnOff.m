function [f,dF] = fbOnOff(channel, dwell )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

rootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:';
if nargin <2
    dwell = .1
end

F = [];
df=[];
t = [];
count = 0;

tic;
while count == 0 || t(count)<= 100
%    configCryoChannel( rootPath, channel, freqs(j), Adrive, 0, 0, 0 )
    fword = lcaGet( [rootPath, 'CryoChannels:CryoChannel[' num2str(channel) ']:loopFilterOutput']);
    if fword>2^23 fword = fword - 2^24; end
    f = fword/2^24*38.4; %in MHz
   
    dfword = lcaGet( [rootPath, 'CryoChannels:CryoChannel[' num2str(channel) ']:frequencyError'])/2^24*38.4 ;
    
    if dfword > 2^23 dfword = dfword - 2^24; end
    df = dfword/2^24*38.4;   % in MHz

    count = count +1;
    F(count) = f;
    dF(count) = df;
    t(count) = toc;
    
    fben = double(mod(floor(toc),4) <2);
    lcaPut( [rootPath, 'CryoChannels:CryoChannel[' num2str(channel) ']:feedbackEnable'], fben ) %enable RF
    
    if mod(count, 10) == 0
        figure(1), plot(t, F, '.'), grid, title('Frequency'),xlabel('Time (s)'); ylabel('Frequency (MHz)')
        figure(2), plot(t, dF, '.'), grid,title('Error Frequency'),xlabel('Time (s)'); ylabel('Freq Error (MHz)')
    pause(dwell);
end
end

