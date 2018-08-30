function analyzeNoiseAllChannels(fn,band,f_min,f_max,data_dir)
% data_dir is the directory containing all data but not including the 
%   directory for a particular date
% fn is the filename *without* the date directory
% f_min, f_max set the range of freqs. (Hz) to consider for noise analysis
% band: integer indicating 500-MHz band, e.g., 2

if nargin < 3
    f_min = 0.1;
end

if nargin < 4
    f_max = 10;
end

if nargin < 5
    data_dir = '/home/common/data/cpu-b000-hp01/cryo_data/data2/';
end

bin_noise = 10; % histogram bin width (pArtHz)
max_noise = 200; % max. left bin edge for hist.

[cfg,phase,amp,t,f,pArtHz] = plotIQNoise_AC(fn,data_dir);

[n_f,n_det] = size(pArtHz);
% find indices corresponding to frequency range
f1 = f(:,1);
for i = 1:n_f
    if (f1(i) <= f_min) && (f1(i+1) >= f_min)
        i_min = i;
    end
    
    if (f1(i) <= f_max) && (f1(i+1) >= f_max)
        i_max = i+1;
    end
end

f_min_actual = f1(i_min);
f_max_actual = f1(i_max);

noise_mean = mean(pArtHz(i_min:i_max,:));
noise_median = median(pArtHz(i_min:i_max,:));

% get resonator frequencies
res_freqs = zeros(n_det,1);
offsets = cfg.CryoChannels.centerFrequencyArray;
[subbands,subbandcenters] = getSubBandCenters(band);
for i = 1:n_det
   ch = i - 1;
   subband = getChannelSubBand(band,ch); % actually the same for all bands
   subbandFreq = subbandcenters(subband + 1);
   res_freqs(i) = subbandFreq + offsets(i);
end

res_freqs_nonzeromean = res_freqs(find(noise_mean ~= 0));
chans = find(noise_mean ~= 0)
noise_mean_nonzero = noise_mean(find(noise_mean ~= 0))
noise_median_nonzero = noise_median(find(noise_median ~= 0));

figure; scatter(res_freqs_nonzeromean,noise_mean_nonzero,'.'); title([fn ...
        ': mean noise (' num2str(f_min_actual) '-' num2str(f_max_actual) ' Hz), ' ...
        num2str(length(noise_mean_nonzero)) ' channels']); ...
        xlabel('resonator frequency (MHz)'); ylabel('pArtHz'); ...
        ylim([0 200]);
    
noiselt100pArtHzMEAN=length(find(noise_mean_nonzero<100));
    
figure; histogram(noise_mean_nonzero,0:bin_noise:max_noise); title([fn ': mean noise (' num2str(f_min_actual) ...
	     '-' num2str(f_max_actual) ' Hz), ' num2str(noiselt100pArtHzMEAN) '/' num2str(length(noise_mean_nonzero)) ' < 100 pArtHz']);
xlabel('mean pA/rtHz')
ylabel('N')
    
noiselt100pArtHzMEDIAN=length(find(noise_median_nonzero<100)); 
    
figure; histogram(noise_median_nonzero,0:bin_noise:max_noise); title([fn ': median noise (' num2str(f_min_actual) ...
	     '-' num2str(f_max_actual) ' Hz), ' num2str(noiselt100pArtHzMEDIAN) '/' num2str(length(noise_median_nonzero)) ' < 100 pArtHz']);
xlabel('median pA/rtHz')
ylabel('N')
      
figure; imagesc([1 n_det],[f1(i_min) f1(i_max)],log10(pArtHz)); ...
        colorbar; ylim([f_min_actual f_max_actual]); ylabel('freq (Hz)'); ...
        xlabel('detector number'); caxis([1 2.5]);

figure; loglog(f(:,1),pArtHz(:,1));

return
