addpath('./glob/');
path2datedirs='/data/cpu-b000-hp01/cryo_data/data2/';

numberSamples = 33554432;
Fs            = 2.4e6;    % processing rate
Nphi0         = 4;        % no. of phi0 swept per flux ramp 
Fr            = 250;      % flux ramp reset rate
Fc            = Fr*Nphi0;      % flux ramp carrier rate
frameSize     = Fs/Fr;  

% include frequency  noise?
%11: 1515617497_Ch272.dat
%12: 1515617685_Ch272.dat
%13: 1515617784_Ch272.dat
%14: 1515617924_Ch272.dat
%15: 1515618002_Ch272.dat
noiseDataFile    = '1515618002_Ch272.dat';
reloadNoiseData  = true;
hasNoise         = true;
noiseScaleFactor = 1.00; % multiply noise model by this # (in phase)

%%
%% Flux ramp models
% input is in phase (rad)

% pure sine
frSineModDepth = 140.e3/2.; % Hz
frSinePhiOffset = pi/6; % rad
sineFR = @(x) frSineModDepth*cos(x+frSinePhiOffset);

% SQUID
frSQUIDf0=5.311e9; % Hz
frSQUID4McsqoverZ1Ls=3.33e-15; % units?
frSQUIDlambda=0.49; % unitless
frSQUIDPhiOffset=0.;
SQUIDFR = @(x) frSQUIDf0^2*frSQUID4McsqoverZ1Ls*rdivide(frSQUIDlambda*cos(x+frSQUIDPhiOffset),(1+frSQUIDlambda*cos(x+frSQUIDPhiOffset)));

%s = lambda.*cos(2*pi*i*Fc/Fs + frameTheta + theta0);
%s = s./(1+s);
%s = s*modDepth./0.65;

%%
%%

%%
%% Signal models
% input is in time (sec)

% no signal
noSignal = @(x) x*0.;

% sine signal
sigSineAmplitude   = pi/10.;
sigSinePhaseOffset = pi/9.;
sigSineFrequency   = Fc/100.;
%thetasig = Ampl*cos(2*pi*double(jj)*Fc/(Fs*1000.) + thetasig0);
sineSignal = @(x) sigSineAmplitude*cos(2*pi*x*sigSineFrequency + sigSinePhaseOffset);

%%
%%

%%
%% Pick a flux ramp model to use

%% Options = sineFR, SQUIDFR
frModel=SQUIDFR;

%% 
%% Pick a signal to inject (if any)
% inject a flux signal?
injectSignal  = true;

%% Options = noSignal, sineSignal
signalModel = noSignal;

numberFrames  = numberSamples/frameSize;
% if the number of requested samples isn't an integer number of frames,
% truncate to the nearest number of frames
if ~(rem(numberFrames,1)==0)
    xtraSamples=rem(numberFrames,1)*frameSize;
    fprintf('-> Dropping the last %d samples so that data is an integer number of frames.\n',xtraSamples);
    numberSamples = numberSamples - xtraSamples;
    numberFrames  = numberSamples/frameSize;
    % case as integers
    numberSamples = uint64(numberSamples); 
    numberFrames  = uint64(numberFrames);
end

fprintf('* numberSamples=%d\n',numberSamples);
fprintf('* frameSize=%d\n',frameSize);
fprintf('* numberFrames=%d\n',numberFrames);

%%
%% Build noise

if hasNoise
    
    if reloadNoiseData || ~exist(fmeas)
        % load real noise
        dfn=noiseDataFile;
        dfn_cands=glob(fullfile(path2datedirs,'/*/',dfn));
        % don't take the one that's in the soft-linked current_data directory
        dfnIdxC=strfind(dfn_cands,'/current_data/');
        dfnIdx=find(cellfun('isempty',dfnIdxC));
        dfn=dfn_cands(dfnIdx);
        dfn=dfn{1,1}; % not sure why this is necessary
        disp(['-> found ' dfn]);
        [fmeas,dfmeas,frsmeas]=decodeSingleChannel(dfn,1);
    end
    
    % build noise from measured noise
    noise=(fmeas-mean(fmeas))*1.e6;
    
    % make sure there's enough data in the noise data
    % for the requested # of frames
    if length(noise)<numberSamples
        error('Error, number of noise data points=%d not enough for requested numberSamples=%d.\n.',length(noise),numberSamples)
    else
        % truncate noise to number of requested frames & transpose
        noise=noise(1:numberSamples);
        noise=noise';
    end
else
    noise=zeros(numberSamples, 1);
end

% print noise std
fprintf('* std(noise)=%0.3f Hz\n',std(noise));
fprintf('* std(noiseScaleFactor*noise)=%0.3f Hz\n',std(noiseScaleFactor*noise));

%% Done building noise
%%

%%
%% Build flux ramp signal

y=zeros(numberSamples,1);
signal=zeros(numberSamples,1);
if ~injectSignal
    %% this works if there's no flux signal
    % generate signal for 1 frame
    i = 0:(frameSize-1);
    i = i(:);
    s = frModel(2*pi*i*Fc/Fs);
    
    % extend to numberFrames
    y = repmat(s, numberFrames, 1);
else
    %% flux signal being modulated by the flux ramp in this frame
    jj = 0:(numberSamples-1);
    jj = jj(:);
    signal=signalModel(double(jj)/Fs);
    
    %% build flux ramp, with a signal encoded, one frame at a time
    y=zeros(numberSamples,1);
    i = 0:(frameSize-1);
    i = i(:); 
    for ii=1:numberFrames
        % build this frame  
        frameTheta=signal(frameSize*(ii-1)+1:frameSize*ii);
        s = frModel(2*pi*i*Fc/Fs + frameTheta);
        y(frameSize*(ii-1)+1:frameSize*ii)=s;
    end
end

%% Done building flux ramp signal
%%

%%
%% Add noise to signal
y = y + noiseScaleFactor*noise;
%% Done adding noise to signal
%%


%%
%% Demod
% frame processing

%% measurement model (from Mitch)
H = [sin(2*pi*i*Fc./Fs), cos(2*pi*i*Fc./Fs)];

theta = zeros(numberFrames, 1);
for k = 0:numberFrames-1
    alpha = H\y( (k*frameSize+1):((k+1)*frameSize) );
    theta(k+1) = atan2(alpha(2), alpha(1));
end

%% done demoding
%%

%% 
%% Plot results

% Plot measured frequency noise w/ and w/o flux ramp
figure;
[pxx, f] = pwelch(y, [], [], [], Fs);
loglog(f,sqrt(pxx)); hold on;
[pxx, f] = pwelch(noise, [], [], [], Fs);
loglog(f,sqrt(pxx));
legend('simulated flux ramp + measured noise','measured noise','Location','southwest');
ylabel('Frequency noise ASD (Hz/rt.Hz)')
title('Modeling frequency noise through flux ramp')
xlabel('Frequency (Hz)')

% Plot a couple of frames of flux ramp + noise
figure;
for kk=[1 round(numberFrames/3) round(2.*numberFrames/3) numberFrames]
    plot(y(frameSize*(kk-1)+1:kk*frameSize)); hold on;
end
ylabel('Frequency (Hz)')
title('A couple of flux ramp cycles')
xlabel('Sample number (mod the frameSize)')

% Plot reconstructed signal
figure;
sample_times=linspace(1,length(signal),length(signal))/Fs;
demod_times=linspace(1,length(theta),length(theta))/Fr;

plot(demod_times,theta-mean(theta)); hold on;
plot(sample_times,signal-mean(signal));
legend('reconstructed','input')
ylabel('Phase (rad)')
title('Input vs reconstructed phase (mean-subtracted)')
xlabel('Time (sec)')

% Plot power spectrum of reconstructed signal
figure;
[pxx, f] = pwelch(theta-mean(theta), [], [], [], Fr);
loglog(f,sqrt(pxx)); hold on;
fprintf('noiseScaleFactor = %0.3f\tPhase noise = %0.3e rad/rt.Hz\n',noiseScaleFactor,mean(sqrt(pxx)))
fprintf('eq. TES current noise = %0.3f pA/rt.Hz\n',mean(sqrt(pxx))*1.56e-6*1.e12)
%legend('simulated flux ramp + measured noise','measured noise','Location','southwest');
ylabel('Phase noise ASD (rad/rt.Hz)')
title('Modeling frequency noise through flux ramp')
xlabel('Frequency (Hz)')

%% Done plotting results
%%

%average noise at 1kHz
[pxx, f] = pwelch(noise, [], [], [], Fs);
ii=3447
i0=ii; i1=i0+100; clf; loglog(f,sqrt(pxx)); hold on; loglog(f(i0:i1),sqrt(pxx(i0:i1))); disp(mean(f(i0:i1)));
mean(sqrt(pxx(i0:i1)))
fprintf('Frequency noise @ %0.3e Hz = %0.3e Hz/rt.Hz\n',mean(f(i0:i1)),mean(sqrt(pxx(i0:i1))));

return
