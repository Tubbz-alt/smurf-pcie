%% Parallel amplitude scan...
amplitudeScale = 9;

% which channels to scan
channels       = [ones(1,32), zeros(1, 128-32)];
channels       = repmat(channels,1,4);
%channels = [1, zeros(1, 512 - 1)];

root = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[3]:CryoChannels:';


lcaPut([root, 'etaMagArray'],         ones(1,512));
lcaPut([root, 'feedbackEnableArray'], 0*ones(1,512));
lcaPut([root, 'amplitudeScaleArray'], amplitudeScale*channels);

tic
    freq      = -3:0.1:3;
    freqError = zeros(length(freq), 512);
    realImag  = [1, 1i];
    etaPhase  = [0, 90];
    for j = 1:2
        lcaPut([root, 'etaPhaseArray'], etaPhase(j)*ones(1,512));
        for i = 1:length(freq)
           
            lcaPut( [root, 'centerFrequencyArray'], freq(i)*channels);
            %lcaPut( [root, 'centerFrequencyArray'], round(0.5+freq(i)*channels*2^24/9.6));
            freqError(i,:) = freqError(i,:) + realImag(j)*lcaGet([root, 'frequencyErrorArray']);
        end
    end
toc

Off(3);