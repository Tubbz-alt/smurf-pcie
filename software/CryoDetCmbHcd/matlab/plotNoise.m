    Foff=cfg.CryoChannels.centerFrequencyArray(cfg.readoutChannelSelect+1);

    fsubset_min=1;
    fsubset_max=10;
    freqs_subset_idxs = find((f>fsubset_min)&(f<fsubset_max));
    freqs_subset = f(freqs_subset_idxs);
    psd_subset = pArtHz(freqs_subset_idxs);
    psd_mean_in_subset = nanmean(psd_subset);
    psd_median_in_subset = median(psd_subset);
    
    figure;
    loglog(f,pArtHz); hold on;
    xlabel('Frequency (Hz)','Interpreter','latex','FontSize',16);
    ylabel('Eq. TES Current Noise (pA/$\sqrt{\mathrm{Hz}}$)','Interpreter','latex','FontSize',16);
    %ylim([1,psd_median_in_subset*10]);
    xmin=0.1;
    xmax=50000;
    xlim([xmin,xmax]);
        
    disp(sprintf('-> Median in noise subset : %0.1f pA/rtHz',psd_median_in_subset));
    disp(sprintf('-> Mean in noise subset : %0.1f pA/rtHz',psd_mean_in_subset));
    
    semilogx([xmin,xmax],[psd_median_in_subset,psd_median_in_subset],'--','color','red','LineWidth',2);
    xspan=xmax-xmin;
    text(xmin+xspan/10,psd_median_in_subset/3,sprintf('%0.1f pA/rtHz',psd_median_in_subset),'color','red');
    
    
    
    %title(sprintf('%s : %0.3f GHz, subband %d, channel %d',fname{1},F,band,cfg.readoutChannelSelect),'Interpreter','latex');