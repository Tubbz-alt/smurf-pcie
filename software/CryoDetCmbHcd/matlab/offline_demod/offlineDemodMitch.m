close all
clear
%
%file = '/afs/slac/g/lcls/epics/R3-14-12-4_1-1/iocTop/users/mdewart/cryo-data/fw_demod/1526483838_Ch0.dat'; % closed loop, banging
file = '/afs/slac/g/lcls/epics/R3-14-12-4_1-1/iocTop/users/mdewart/cryo-data/fw_demod/1526562710_Ch0.dat'; % open loop, banging
%file = '/afs/slac/g/lcls/epics/R3-14-12-4_1-1/iocTop/users/mdewart/cryo-data/fw_demod/1526562813_Ch0.dat'; % open loop, stable


[F, dF, fluxRampStrobe] = decodeSingleChannel(file);

% Readout setup
Fs           = 0.6e6;                       % downsampled rate
lmsFreq      = 13052.8571;                  % tracking (demod) frequency
freqNorm     = lmsFreq/Fs;                  % normalized frequency


% Pre-process to frame align flux ramp
frs          = fluxRampStrobe(:,2);
idx          = find(frs == 2);
idx          = idx + 5;                     % delay reset 4 samples
idx_diff     = idx - circshift(idx,1);
frameSize    = floor(mean(idx_diff(2:end-2)));
fluxRampRate = Fs./frameSize;


obs          = dF(idx(1):idx(end-1)-1);   % noisy observation, frame algined
numberFrames = length(obs)./frameSize;   % number of frames

% reshape into frames for plotting - we've already frame algined
obsFrames    = reshape(obs, frameSize, numberFrames); 

%
figure; 
plot(obsFrames(:, 1:1000))               % plot first 1000 frames
title('Overlay flux ramp frames')
ylabel('Frequency (MHz)')
xlabel('Sample')


% demod feedback gain
gain      = 1/32;

tic
[y_hat, a1, a2, a3, a4, a5, a6, a7] = fluxRampDemodBlockProcessing_mex( obs, frameSize, freqNorm, gain ); 
toc

phase1        = atan2(a2, a1);
mag1          = sqrt(a1.^2 + a2.^2);
phase2        = atan2(a4, a3);
mag2          = sqrt(a3.^2 + a3.^2);
phase3        = atan2(a6, a5);
mag3          = sqrt(a5.^2 + a6.^2);
c             = a7;

trackingError = obs(:) - y_hat(:);

figure;

subplot(2,1,1)
plot(obs(1:5000))
hold on
plot(y_hat(1:5000))
xlim([0 5000])
title('Measurement')
xlabel('sample')
legend('noise corrupted measurement','estimated signal')

subplot(2,1,2)
xlim([0 5000])
plot(trackingError(1:5000))
title('Tracking error')
xlabel('sample')
ylabel('Error (MHz)')
legend('Tracking error')

figure

subplot(2,1,1)
plot(phase1(1:5000))
xlim([0 5000])
title('Phase estimate')
xlabel('sample')
ylabel('Phase estimate (rad)')
legend('Phase estimate')

subplot(2,1,2)
plot(c(1:5000))
xlim([0 5000])
title('DC offset')
xlabel('sample')
ylabel('DC offset (freq)')
legend('DC offset')

figure;

plot(c(10000:end-1000))
title('DC offset')


figure;
hold on
plot(mag3(2000:end))
plot(mag2(2000:end))
plot(mag1(2000:end))
title('Harmonic tracking amplitudes')
legend('3rd harmonic', '2nd harmonic', '1st harmonic')

figure;
hold on
plot(phase3(2000:end) - mean(phase3(2000:end)))
plot(phase2(2000:end) - mean(phase2(2000:end)))
plot(phase1(2000:end) - mean(phase1(2000:end)))
title('Harmonic tracking phase')
legend('3rd harmonic', '2nd harmonic', '1st harmonic')

% Relative harmonic noise, amplitudes
s1 = std(phase1(2000:end));
s2 = std(phase2(2000:end));
s3 = std(phase3(2000:end));

m1 = mean(mag1(2000:end));
m2 = mean(mag2(2000:end));
m3 = mean(mag3(2000:end));

disp('Harmonic phase noise noise:')
disp(['    1st harmonic RMS: ', num2str(s1)])
disp(['    2st harmonic RMS: ', num2str(s2)])
disp(['    3rd harmonic RMS: ', num2str(s3)])
disp(' ')

disp('Relative harmonic amplitudes:')
disp(['    1st harmonic/2nd harmonic: ', num2str(m1/m2)])
disp(['    1st harmonic/3rd harmonic: ', num2str(m1/m3)])
disp(['    2nd harmonic/3rd harmonic: ', num2str(m2/m3)])
disp(' ')

[pxx, f] = pwelch(phase1-mean(phase1),[],[],[],fluxRampRate);
figure;
semilogx(f, 10*log10(pxx))