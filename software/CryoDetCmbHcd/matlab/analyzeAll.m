addpath('./offline_demod/')

filelistname='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180515/first_all_noise_datasets_swh_20180515.dat';
filelist=importdata(filelistname);

fileID=fopen('noise.txt','w');
for fname=filelist'
    [cfg,phase,f,pArtHz]=plotIQNoise(fname);
    disp(['fname=' fname]);
    Foff=cfg.CryoChannels.centerFrequencyArray(cfg.readoutChannelSelect+1);
    
    % invert Foff to find frequency
    bandCenter=5250;
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
    
    fprintf(fileID,'%d\t%0.3f\t%0.3f\t%0.3e\t%0.3e\t%0.2f\t%0.2f\n',band,Foff,F,fsubset_min,fsubset_max,psd_mean_in_subset,psd_median_in_subset);
    
    disp(sprintf('-> Median in noise subset : %0.1f pA/rtHz',psd_median_in_subset));
    disp(sprintf('-> Mean in noise subset : %0.1f pA/rtHz',psd_mean_in_subset));
end
fclose(fileID);


