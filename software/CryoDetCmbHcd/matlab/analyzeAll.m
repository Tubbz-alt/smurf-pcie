addpath('./offline_demod/')

%filedir='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180810/prelim_single/';
filedir = '/home/common/data/cpu-b000-hp01/cryo_data/data2/20180815/analysis_dir2/'
files= dir ([filedir, '*.dat'])

%filelist = files.name;

fileID = fopen('noise_fprun27_singlechannel.txt','w');
for i=1:length(files)
    fname=files(i).name
    %try
        [cfg,phase,amp, t, f,pArtHz]=plotIQNoise(fname, '/home/common/data/cpu-b000-hp01/cryo_data/data2/20180815/analysis_dir2/');
        disp(['fname=' fname]);
        Foff=cfg.CryoChannels.centerFrequencyArray(cfg.readoutChannelSelect+1);

        % invert Foff to find frequency
        bandCenter=cfg.bandCenterMHz;
        chan=cfg.readoutChannelSelect;
        band=floor(chan/16);
        bandNo = [ 8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17 2 18 3 19 4 20 5 21 6 22 7 23 8];
        bb=find(bandNo == band,1,'first') - 1;
        F=Foff + (bandCenter - 307.2) + bb*19.2;

        %if ~(band==16)
        %    continue;
        %end

        fsubset_min=0.1;
        fsubset_max=1;
        freqs_subset_idxs = find((f>fsubset_min)&(f<fsubset_max));
        freqs_subset = f(freqs_subset_idxs);
        psd_subset = pArtHz(freqs_subset_idxs);
        psd_mean_in_subset = nanmean(psd_subset);
        psd_median_in_subset = median(psd_subset);
        
        fsubset_min2=1;
        fsubset_max2=10;
        freqs_subset_idxs2 = find((f>fsubset_min2)&(f<fsubset_max2));
        freqs_subset2 = f(freqs_subset_idxs2);
        psd_subset2 = pArtHz(freqs_subset_idxs2);
        psd_mean_in_subset2 = nanmean(psd_subset2);
        psd_median_in_subset2 = median(psd_subset2);

        fprintf(fileID,'%d\t%0.3f\t%0.3f\t%0.3e\t%0.3e\t%0.2f\t%0.2f\t%0.2f\t%0.2f\n',band,Foff,F,fsubset_min,fsubset_max,psd_mean_in_subset,psd_median_in_subset, psd_mean_in_subset2, psd_median_in_subset2);

        disp(sprintf('-> Median in .1-1Hz subset : %0.1f pA/rtHz',psd_median_in_subset));
        disp(sprintf('-> Mean in .1-1Hz subset : %0.1f pA/rtHz',psd_mean_in_subset));
    %catch
    %    continue
    %end
end
fclose(fileID);


