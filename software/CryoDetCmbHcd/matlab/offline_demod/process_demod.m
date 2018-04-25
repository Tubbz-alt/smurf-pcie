% fluxRampRate is determined from reset strobe
function [phase_all, psd_pow, pwelch_f, time] = process_demod(fileName, cfg, numPhi, phi0Rate, decimation, outputName, fsamp)

%fundamental sample rate; try for single and all channel data
pA_per_uPhi0 = 9e-6; %pA/uPhi0
close all

try
    %[freq, ~, sync] = decodeData(fileName);
    %sync_f = reshape(sync(:,1),512,[]);
    %sync_f = sync_f';
    
    [freq,~,sync]=decodeData(fileName);
    
    sync_f = reshape(sync(:,1),512,[]);
    sync_f = sync_f'; 
    
    %% enforce btw 0->1.  Shouldn't have to do this.
    for col=1:size(sync_f,2)
        if ~(max(sync_f(:,col))==min(sync_f(:,col)))
            sync_f(:,col)=(sync_f(:,col)-min(sync_f(:,col)))/(max(sync_f(:,col))-min(sync_f(:,col)));
        else
            sync_f(:,col)=0;
        end
    end
    
    [r,c]=find(sync_f==1);
    sync_f(r, :) = 1;
    
 
    deletechannel = zeros(size(freq,2),1); %initialize indices of channels to delete
    % delete channel if feedback isn't enabled
    deletechannel(find(~(cfg.CryoChannels.feedbackEnableArray==1)))=1;
    
    %%for now, go through and look for only the nonzero channels
    %comp = zeros(size(freq, 1),1); %comparison vector
    %for i=1:size(freq,2)
    %    if isequal(comp,freq(:,i))
    %        deletechannel(i) = 1;
    %    else
    %        deletechannel(i) = 0;
    %    end
    %end
    freq(:,logical(deletechannel)) = [];
    

    % freq = freq(:,273);
    %freq = freq(:,size(freq,2)); %for now just pick the last one

    %figure;
    %exf=(freq(:,1)-min(freq(:,1)))/(max(freq(:,1))-min(freq(:,1)));
    %exsyncf=sync_f(:,1);
    %plot(exf(1:2000)); hold on;
    %plot(exsyncf(1:2000));
    
catch
    [freq, ~, sync] = decodeSingleChannel(fileName, 1);
    sync_f = sync(:,1);
    freq = freq';
    
    %freq = downsample(freq);
end


%for now take only the first channel
%freq = freq(:,1);

% for plot titles
[filePath,fileSuffix,fileExt] = fileparts(fileName) 
[~,fileDir,~] = fileparts(filePath);
plotTitle=sprintf('%s/%s.%s',fileDir,fileSuffix,fileExt);

%set up time vector
N = size(freq,1);
n = 1:N;
dt = decimation / fsamp;
time = (n-1) * dt;

%does all of the below need to happen per channel?

if numPhi == 'rtm'
    resets = find(sync_f(:,1) == 1);
    
    % helps deal with asynchronous flux ramp resets (relative to channel
    % mux)
    resets=resets(find(~(diff(resets)==1)));
    
    resetperiod = nanmean(diff(resets))
    firstreset = resets(1)
else
    %%%begin the demod process:
    %%1 find reset period via first derivative
    deriv = diff(freq(:,1));
    
    cutoffline = 99.999;
    cutoff = prctile(abs(deriv), cutoffline); %maybe change this to a function of resetperiod later
    resets = find(deriv > cutoff); 
    
    while isempty(resets)
        cutoffline = cutoffline - 0.001;
        cutoff = prctile(abs(deriv),cutoffline);
        resets = find(deriv > cutoff);
        %%to do : logic re calculating number of expected resets and moving the
        %%cutoff
    end

    resetperiod = (fsamp / (decimation * 4)) / fluxRampRate; %number of samples per flux ramp, we think

    firstreset = resets(1);
    if firstreset > resetperiod
        firstreset = firstreset - floor(firstreset / resetperiod) * resetperiod; % change this to the 
    end

    %%%%%this is an alternate way to find the flux ramp reset periods
    phase_noAverage = unwrap(angle(hilbert(freq)));
    phase_deriv = diff(phase_noAverage);
    phase_cutoff = prctile(abs(phase_deriv), 99.999);
    resets2 = find(phase_deriv > phase_cutoff);
    firstreset2 = resets2(1);
    resetperiod2 = nanmean(diff(resets2)); %average of differences between the nearest neighbors?
end

fluxRampRate=fsamp/mean(resetperiod);

figure(2)
nframes = round(length(freq) / resetperiod);
for i=1:nframes
    i0=round(firstreset + resetperiod*(i-1));
    i1=round(firstreset + resetperiod*i);
    if i1 > length(freq)
        break
    end
    samples = [i0:i1]-firstreset-resetperiod*(i-1);
    if mod(i,10)==0
        plot(samples, freq(i0:i1)+0.0*i/10.); hold on;
    end
end
title(plotTitle,'Interpreter','none')
xlabel('Sample number');
ylabel('Frequency offset from subband center (MHz)');

n_channels = size(freq,2);
%phase_all = zeros(n_channels, length(resets));
%phase_pow_filtered = zeros(n_channels, length(resets));
%psd_pow = zeros(n_channels, length(resets));

disp('Demodulating')

for i=1:n_channels
    
    %by hand for now
    %firstreset = 122;
    %resetperiod = 300;
    
    
    channel_data = freq(:,i);
    buffer = 50;
    phase_temp = demod_hilbert(channel_data, resetperiod, firstreset, buffer);
    
     while std(phase_temp) > 10
        buffer = buffer * 2;
        phase_temp = demod_hilbert(channel_data, resetperiod, firstreset, buffer);
        disp('Buffer doubled')
    end
    
    if isnan(phase_temp)
        disp(i)
        phase_temp = zeros(size(phase_temp));
    end
   
    
    phase_all(i,:) = phase_temp;

    num_fluxramps = size(phase_all, 2);

    p3 = polyfit(1:num_fluxramps, phase_all(i,:),2);
    phase_pow_filtered(i,:) = phase_all(i,:) - polyval(p3, 1:num_fluxramps);

    figure(3)
    plot(phase_pow_filtered(i,:)); hold on;
    title(plotTitle,'Interpreter','none')
    xlabel('Phi (rad)');
    ylabel('Flux ramp cycle');
    
    
    nphases = size(phase_all,2);
    windowsize = 1;
    while nphases > 2
        nphases = nphases / 2;
        windowsize = windowsize + 1;
    end

    [psd_pow(i,:),pwelch_f] = pwelch(phase_all(i,:),2^(windowsize-1),[],[],fluxRampRate,'psd','onesided');

    %Shawn's PSD computation
    phase_length = length(phase_temp) - 1;
    phase_dft = fft(phase_temp(1:end - 1));
    phase_dft = phase_dft(1:round(phase_length / 2 + 1)); % onesided fft
    psd_phase = (1 / (fluxRampRate  * phase_length)) * abs(phase_dft).^2;

    psd_phase(2:end - 1) = 2* psd_phase(2:end - 1);
    psd_freq = 0: fluxRampRate / phase_length: fluxRampRate/2;
    psd_phase_shawn(i,:) = psd_phase;

    figure;
    %set(gcf,'DefaultAxesColorOrder',jet(size(psd_pow,1)));
    clf; loglog(pwelch_f(3:end),sqrt(psd_pow(i,3:end))/360*pA_per_uPhi0*1e12, 'color', 'b'); hold on;
    if length(psd_freq) == size(psd_phase_shawn,2)
        loglog(psd_freq(3:end), sqrt(psd_phase_shawn(i,3:end))/360*pA_per_uPhi0*1e12, 'color', 'r')
    else
        loglog(psd_freq(2:end), sqrt(psd_phase_shawn(i,3:end))/360*pA_per_uPhi0*1e12, 'color', 'r')
    end
    xlabel('Frequency [Hz]')
    ylabel('Noise power [pA/rt(Hz)]')
    xlim([pwelch_f(1) pwelch_f(end)])
    
    %legend('pwelch','no windowing','mean noise from this pwelch interval');
end

%fsubset_min=10;
%fsubset_max=50;
%freqs_subset_idxs = find((pwelch_f>fsubset_min)&(pwelch_f<fsubset_max));
%freqs_subset = pwelch_f(freqs_subset_idxs);
%psd_subset = sqrt((psd_pow(:,freqs_subset_idxs)))/360*9e-6*1e12;
%psd_mean_in_subset = nanmean(psd_subset);

%plot(freqs_subset,psd_subset,'LineWidth',2,'Color','green');
%xl=xlim();
%plot([min(pwelch_f(2:end)),max(pwelch_f)],[psd_mean_in_subset,psd_mean_in_subset],'LineWidth',2,'Color','green','LineStyle','--');
%text((min(freqs_subset)+max(freqs_subset))/2.,psd_mean_in_subset/4.,sprintf('%0.0f pA/rt.Hz',psd_mean_in_subset),'FontSize',12,'HorizontalAlignment','center','Color','green');

%psd_1Hz = sqrt(nanmean(psd_pow(:,freqs)))/360*9e-6*1e12;
%psd_subset = sqrt(nanmean(psd_pow(:,freqs_subset)))/360*9e-6*1e12;
%psd_1Hz_shawn = sqrt(nanmean(psd_phase_shawn(:,freqs_shawn)))/360*9e-6*1e12;
%psd_shawn_subset = sqrt(nanmean(psd_phase_shawn(:,freqs_shawn_subset)))/360*9e-6*1e12;
%psd_1Hz = squeeze(psd_1Hz);
%psd_1Hz_shawn = squeeze(psd_1Hz_shawn);
%psd_1Hz(psd_1Hz ==0)=NaN;
%psd_1Hz_shawn(psd_1Hz_shawn == 0) = NaN;
%minnoise = min(psd_1Hz)
%minnoise_subset = min(psd_subset)
%minnoise_shawn = min(psd_1Hz_shawn)
%minnoise_shawn_subset = min(psd_shawn_subset)


%save(outputName, 'minnoise', 'minnoise_shawn', 'phase_all', 'psd_pow', 'pwelch_f', 'numPhi', 'freqs', 'freqs_shawn', 'fluxRampRate', 'fileName')
end