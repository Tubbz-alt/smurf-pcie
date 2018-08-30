function [channels, phase_avg, ampl_avg, I, Q, sync] = decodeAvg(filename, singleChannel)


if nargin < 2
	singleChannel = 1;
end

if singleChannel:
	[I, Q, sync] = decodeSingleChannel(filename);
	channels = []; % eventually want to parse the config file to grab this
	Fs = 2.4e6;
else
	[I, Q, sync] = decodeData(filename)
	%sync = reshape(sync(:,1), [], 512); % this totally does not work
	channels = [0:511];
	Fs = 6e3; 
	I = I(:, any(I, 1)); % drop channels with zeros
	Q = Q(:, any(I, 1)); % drop the same ones each time
	channels = channels(:, any(I, 1)); % to be able to match channels
end

amp = sqrt(I.^2 + Q.^2);
phase = atan2(Q, I);
t = [1:size(phase,1)]/Fs;

resets = find(sync(:,1) == 1); % this totally doesn't work in multichannel mode
resetperiod = nanmean(diff(resets));
firstreset = resets(1);

amp_avg = mean(reshape(amp, resetperiod, []));
phase_avg = mean(reshape(phase, resetperiod, []));



end
