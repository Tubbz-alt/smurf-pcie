% [quadraturePhase, Imax] = findQuadrature( rootPath, frequency )
% rootPath  - path to SysgenCryo/Base
% frequency - baseband frequency offset -250MHz - 250Mhz
%
%
%  Finds quadrature etaPhase also returns max in phase response Imax
%  1. set etaMag = 1
%  2. scan etaPhase -180 to 180 degree
%  3. find min/max response 
%     - max response is saved as Imax
%  4. fine etaPhase scan +/- 10 degree around min response
%  5. return etaPhase at minimum response
%


function [quadraturePhase, Imax] = findQuadrature( rootPath, frequency )

freqCenter     = 5250;
% freqOffset     = -20.25;
freqOffset = frequency;
[band, fOff]   = f2band(freqCenter + freqOffset);
chan           = band*16;
fineScanRange  = 10; % scan +/- 6 degree around min response


amplitude      = 10;
feedbackEnable = 0;
etaMag         = 1;
i = 1;
for etaPhase = -180:180   % matlab index start at 1
    % configCryoChannel( rootPath, channelNum, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
    configCryoChannel( rootPath, chan, fOff, amplitude, feedbackEnable, etaPhase, etaMag );
    pause(0.1)
    [~,  frequencyError(i)] = readbackCryoChannel( rootPath, chan );
    i = i+1;
end

etaPhase = -180:180;
figure;plot(etaPhase, frequencyError)
xlabel('etaPhase (degree)')
ylabel('Frequency error')


Imax = mean(abs([max(frequencyError), min(frequencyError)]));

Qmin = min(abs(frequencyError));
idx  = find( Qmin == abs(frequencyError) );

i = 1;
for etaPhase = idx-fineScanRange:0.05:idx+fineScanRange
     % configCryoChannel( rootPath, channelNum, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
    configCryoChannel( rootPath, chan, fOff, amplitude, feedbackEnable, etaPhase, etaMag );
    pause(0.1)
    [~,  frequencyErrorZoom(i)] = readbackCryoChannel( rootPath, chan );
    i = i + 1;
end
frequencyErrorZoomM = medfilt1(frequencyErrorZoom,10);
etaPhase = idx-fineScanRange:0.05:idx+fineScanRange;
figure;plot(etaPhase,frequencyErrorZoomM)
xlabel('etaPhase (degree)')
ylabel('Frequency error')

Qmin2 = min(abs(frequencyErrorZoomM));
idx2 = find( Qmin2 == abs(frequencyErrorZoomM));

quadraturePhase = mean(etaPhase(idx2));

disp( ['Quadrature phase is: ' num2str(quadraturePhase), ' degrees'] )
disp( ['Inphase magnitude response is: ', num2str(Imax)] )

configCryoChannel( rootPath, chan, fOff, amplitude, feedbackEnable, quadraturePhase, etaMag );

end