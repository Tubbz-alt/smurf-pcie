% take phase noise data, look at results
% There are 3 parameters - for this FW
%
% phaseNoiseDecimation - decimation from 307.2MHz, values 4...8192
%                      - phaseNoiseDecimation = 4 is 307.2MHz/4 readout rate
%
% phaseNoiseFreq       - uint32, 307.2MHz/2^32
%                      - phaseNoiseFreq = 0xa6aaaaa is 12.5MHz
%
% phaseNoiseScale      - full scale/2^phaseNoiseScale
%                      - phaseNoiseScale = 7 is +/- 256 counts

rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
Fadc     = 614.4e6;


fName      = 'mitchPhaseNoiseTest.dat';
dataLength = 2^22;


% Setup phase noise measurement parameters
phaseNoiseDecimation = 4;  % decimation values 4...8192 (307.2MHz/decimation)
fullScaleDiv2        = 6;    % valid numbers 0...7, fullScale/2^fullScaleDiv2
freqMHz              = 25;   % single tone frequency MHz


if exist( fName, 'file' )
    error([fName, ' already exists!'])
end

readoutRate    = Fadc/(phaseNoiseDecimation*2);
freqUint       = floor(freqMHz*1e6*2^32/(Fadc/2));

% setup complex conjugate multiply
iqSwapOut      = 1; 
iqSwapIn       = 0;

lcaPut( [rootPath, 'phaseNoiseDecimation'], phaseNoiseDecimation )
lcaPut( [rootPath, 'phaseNoiseFreq'], freqUint )
lcaPut( [rootPath, 'phaseNoiseScale'], fullScaleDiv2 )
lcaPut( [rootPath, 'iqSwapOut'], iqSwapOut )
lcaPut( [rootPath, 'iqSwapIn'], iqSwapIn )

takeDebugData( rootPath, fName, dataLength )
[data, header] = processData2( fName, 'int32' );

I = data(:,1);
Q = data(:,2);

phase = atan2(Q, I);
phase = phase - mean(phase);

t     = (1:length(phase))/readoutRate;


w        = blackman(length(phase)/8);
[pxx, f] = pwelch(phase, w, 0, [], readoutRate);
pxxSSB   = pxx./2;

figure; hold on;
plot(t, I)
plot(t, Q)
title('IQ plot')
ylabel('Amplitude')
xlabel('Time (sec)')


figure;
plot(t, phase)
xlabel('Time (sec)')
ylabel('Phase (rad)')

figure;
semilogx(f, 10*log10(pxxSSB))
xlabel('Frequency')
ylabel(' Power dBc/Hz')
title('Phase noise')

% integrated noise
pxxInt   = cumtrapz(pxx)*(f(2)-f(1));
noiseRms = sqrt(pxxInt);


figure;
semilogx(f, noiseRms)
xlabel('Frequency')
ylabel('Integrated noise (rad RMS)')
title('Integrated phase noise')


% these should match
disp( [ 'Total integrated noise: ' num2str( noiseRms(end) ) ] )
disp( [ 'std(phase): ', num2str( std(phase) ) ] )



