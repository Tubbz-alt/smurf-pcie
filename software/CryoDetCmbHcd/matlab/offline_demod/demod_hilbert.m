function phase = demod_hilbert_CY(data, resetPeriod, firstReset, buffer)

n = length(data);

% define flux ramp intervals
starts = firstReset:resetPeriod:n;
nn = round(starts);

%might use this eventually?
% phase_noAverage = unwrap(angle(hilbert(data)));
% phase_deriv = diff(phase_noAverage);
% phase_cutoff = prctile(abs(phase_deriv), 99.9);
% resets2 = find(phase_deriv > phase_cutoff);
% resetperiod2 = nanmean(diff(resets2)); %average of differences between the nearest neighbors?
% firstreset2 = resets2(1);

% clean/scale/process the data
data = (data - nanmean(data)) / nanstd(data);
data(isnan(data)) = 0;

% take the hilbert transform
hilbertdat = hilbert(data .* ones(n,1));
ang = unwrap(angle(hilbertdat));

p1 = polyfit((1:length(ang))',ang,1);
angfilt = ang - polyval(p1,(1:length(ang))');
%plot(angfilt)

for ii = 1:length(nn)-1
  phase(ii) = mean(angfilt(nn(ii)+buffer:nn(ii)+round(resetPeriod)-buffer-1));
end

%disp('demodulation complete')
% convert to degrees
phase = phase*180/pi;




end
