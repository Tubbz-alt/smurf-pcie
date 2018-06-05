clear;
addpath('./offline_demod/')

path2outputs='run2_1GHz_20180602/';
fileID2=fopen('run2_1GHz_20180602/run2_1GHz_20180602_noise.txt','w');

% need to get these into the cfg
%% run2 band2
etaScan2SavedResults='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180601/1527867856/1527867856_etaOut.mat';
etaScan2=load(etaScan2SavedResults);

etaScan3SavedResults='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180601/1527868500/1527868500_etaOut.mat';
etaScan3=load(etaScan3SavedResults);

filelistname='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180602/run2_1GHz_20180602.txt';
filelist=importdata(filelistname);
%disp(filelist)
%filelist={'1527866899_Ch0.dat';'1527866635_Ch0.dat'}
%filelist={'1527905947_Ch0.dat'};
    
for fname=filelist'
    close all;
    try
        if iscell(fname)
            fname=fname{1};
        end
        [cfg,phase,f,pArtHz]=plotIQNoise(fname);
    catch
        continue
    end
    disp(['fname=' fname]);
    Foff=cfg.CryoChannels.centerFrequencyArray(cfg.readoutChannelSelect+1);
    bandCenterMHz=cfg.bandCenterMHz;
    
    % hard coded for now; need to get this into the cfg
    if bandCenterMHz==5250
        band=3;
        etaScan=etaScan3;
    elseif bandCenterMHz==5750
        band=2;
        etaScan=etaScan2;
    else
        error(sprintf('!!! bandCenter mapping has to be hard-coded right, and %f MHz isnt yet',bandCenterMHz));
    end
    etaOut=etaScan.etaOut(cfg.readoutChannelSelect+1);

    if ~(etaOut.band==band)
        error('!!! band no. in etaScan data doesnt match band no. inferred for data.  Give up!');
    end
    
    subband=getChannelSubBand(band,cfg.readoutChannelSelect);   
    [~,subBandCenters]=getSubBandCenters(band);
    F=subBandCenters(subband+1)+Foff;
    
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
    ylim([1,psd_median_in_subset*10]);
    xmin=0.01;
    xmax=2000;
    xlim([xmin,xmax]);
        
    disp(sprintf('-> Median in noise subset : %0.1f pA/rtHz',psd_median_in_subset));
    disp(sprintf('-> Mean in noise subset : %0.1f pA/rtHz',psd_mean_in_subset));
    
    semilogx([xmin,xmax],[psd_median_in_subset,psd_median_in_subset],'--','color','red','LineWidth',2);
    xspan=xmax-xmin;
    text(xmin+xspan/10,psd_median_in_subset/3,sprintf('%0.1f pA/rtHz',psd_median_in_subset),'color','red');
    
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fname,F,band,subband,cfg.readoutChannelSelect),'Interpreter','latex');
    
    [fp,fn,fext]=fileparts(fname);
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_psd.png',fn,band,subband,cfg.readoutChannelSelect)));
    
    freqs_subset_idxs = find((f<2*xmax));
    noiseoutfn=fullfile(path2outputs,sprintf('%s_b%dsb%dch%d.psd',fn,band,subband,cfg.readoutChannelSelect));
    fileID=fopen(noiseoutfn,'w');
    fprintf(fileID,'%f\t%f\n',[f(freqs_subset_idxs)';pArtHz(freqs_subset_idxs)']);
    fclose(fileID);
    
    figure;
    plot((1:length(phase))*(1./600.e3),phase);
    ylabel('Demodulated phase (rad)');
    xlabel('Time (sec)');
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fname,F,band,subband,cfg.readoutChannelSelect),'Interpreter','latex');
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_phase.png',fn,band,subband,cfg.readoutChannelSelect)));
    
    %plot etaScan
    figure;
    daspect([1 1 1]);
    etaCfg=etaScan.etaCfg;
    resp=etaOut.resp;
    
    a = abs(resp); idx = find(a==min(a),1);
    min_resp=min(a);
    max_resp=max(a);
    F0 = f(idx) %center frequency in MHz
    left = find(f>F0-etaCfg.delF,1); f(left)
    right = find(f>F0+etaCfg.delF,1); f(right)

    plot(resp); hold on;
    plot(resp(idx),'r*'); 
    plot(resp(left), 'gx')
    plot(resp(right), 'g+')
    
    x        = 0:0.05:2*pi;
    Ifit     = etaOut.R*cos(x)+etaOut.Icenter;
    Qfit     = etaOut.R*sin(x)+etaOut.Qcenter;
    circ     = Ifit +1i*Qfit;
    plot(circ,'.k')
    
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fname,F,band,subband,cfg.readoutChannelSelect),'Interpreter','latex','FontSize',10);
    text(etaOut.Icenter-etaOut.R/2,etaOut.Qcenter,sprintf('(Ic,Qc)=(%0.3f,%0.3f)\nR=%0.3f',etaOut.Icenter,etaOut.Qcenter,etaOut.R),'color','black','FontSize',18);
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_IQfit.png',fn,band,subband,cfg.readoutChannelSelect)));

    fprintf(fileID2,'%d\t%d\t%0.3f\t%0.3f\t%0.3e\t%0.3e\t%0.2f\t%0.2f\t%0.3e\t%0.3e\t%0.3e\n',band,subband,Foff,F,fsubset_min,fsubset_max,psd_mean_in_subset,psd_median_in_subset,etaOut.R,min_resp,max_resp);
    
    hold off;
end
fclose(fileID2);
