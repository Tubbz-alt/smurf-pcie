%script testAmplSweepOverlayBands
%sweeps a full band
%updated SRS 15Dec2017

Nread = 2;
dwell = 0.02;
freqs = -10:0.1:10;   %frequencies in MHz

resp = zeros(32, size(freqs,2)*Nread);
f = zeros(32, size(freqs,2)*Nread);

band_centers1 = circshift((0:1:15)'-8, 8);
band_centers2 = circshift((0.5:1:15.5)'-8, 8);
band_centers = [band_centers1; band_centers2]*38.4;

figure
hold on;
xlabel('Frequency (MHz)')
ylabel('Amplitude (normalized)')
title('32 sub-band response')


for band=0:31
    disp(['band ' num2str(band)])
    [resp(band+1,:), f(band+1,:)] = amplSweep(band, freqs, Nread, dwell);
    f(band+1,:) = f(band+1,:) + band_centers(band+1);
    if band == 10
        xlim([-300 300]);
    end
    plot(f(band+1,:), abs(resp(band+1,:)), '.', 'color', rand(1,3))
    grid on;

end

xlim([-300 300])
xlabel('Frequency (MHz)')
ylabel('Amplitude (normalized)')
title('32 sub-band response')
