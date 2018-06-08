%clear;
addpath('./offline_demod/')

%%
path2outputs='run3_1GHz_20180602/';
fileID2=fopen([path2outputs, 'noise_run3.txt'],'w');


etaScan3SavedResults='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180607/run3/1528308007/1528308007_etaOut.mat';
etaScan3 = load(etaScan3SavedResults);

etaScan2SavedResults='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180607/run3/1528307364/1528307364_etaOut.mat';
etaScan2 = load(etaScan2SavedResults);

%filelist = {'1527863622.dat','1527863622.dat'};
%disp(filelist)
%filelist={'1527866899_Ch0.dat';'1527866635_Ch0.dat'}
%filelist={'1527905947_Ch0.dat'};
runtxt=fileread('/home/common/data/cpu-b000-hp01/cryo_data/data2/20180607/run3/run3.txt');
filelist=strsplit(runtxt);
    
filelist_odd={filelist{2:2:end}};
filelist_even={filelist{1:2:end}};
Nfiles=min([length(filelist_even),length(filelist_odd)]);
for fidx=1:Nfiles
    fname=filelist_odd{fidx};
    fFdF=filelist_even{fidx};
    disp(sprintf('fname=%s',fname));
    disp(sprintf('fFdF=%s',fFdF));
    disp('---');

    close all;
    try
        if iscell(fname)
            fname=fname{1};
        end
        [cfg,phase,amp,t,f,pArtHz]=plotIQNoise(fname);
    catch e
        disp(['Caught error:'])
        continue
    end
    disp(['fname=' fname]);
    Foff=cfg.CryoChannels.centerFrequencyArray(cfg.readoutChannelSelect+1);
    bandCenterMHz=cfg.bandCenterMHz;
    
    %
    % grab F,dF snapshot
    
    % need to find the file; that way we don't have to put the path above,
    % which is annoying.
    path2data='/home/common/data/cpu-b000-hp01/cryo_data/data2/';
    dfn_cands=glob(fullfile(path2data,'/*/',fFdF));
    % don't take the one that's in the soft-linked current_data directory
    dfnIdxC=strfind(dfn_cands,'/current_data/');
    dfnIdx=find(cellfun('isempty',dfnIdxC));
    dfn=dfn_cands(dfnIdx);
    dfn=dfn{1,1}; % not sure why this is necessary
    disp(['-> found ' dfn]);
    [fr, dfr, frs] = decodeSingleChannel(dfn);
    
    % plot and compute peak-to-peak
    %figure;
    
    % done with F,dF snapshot
    %
    
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
    
    fsubset_min2=0.1;
    fsubset_max2=1;
    freqs_subset_idxs2 = find((f>fsubset_min2)&(f<fsubset_max2));
    freqs_subset2 = f(freqs_subset_idxs2);
    psd_subset2 = pArtHz(freqs_subset_idxs2);
    psd_mean_in_subset2 = nanmean(psd_subset2);
    psd_median_in_subset2 = median(psd_subset2);
    
    %%
    % plot noise PSD side by side with F,dF

    figure('pos',[75 75 1200 600]);
    subplot(1,2,1);
    loglog(f,filter(ones(1,10)/10,1,pArtHz)); hold on;
    xlabel('Frequency (Hz)','Interpreter','latex','FontSize',16);
    ylabel('Eq. TES Current Noise (pA/$\sqrt{\mathrm{Hz}}$)','Interpreter','latex','FontSize',16);
    ylim([1,psd_median_in_subset*10]);
    xmin=0.01;
    xmax=10000;
    xlim([xmin,xmax]);
    
    semilogx([xmin,xmax],[psd_median_in_subset,psd_median_in_subset],'--','color','red','LineWidth',2);
    xspan=xmax-xmin;
    text(10,10,sprintf('%0.1f pA/rtHz',psd_median_in_subset),'color','red','FontSize',16);
    
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fname,F,band,subband,cfg.readoutChannelSelect),'Interpreter','none','FontSize',8);
    
    subplot(1,2,2);
    plot(fr(1:1000)-mean(fr(1:1000))); hold on;
    plot(dfr(1:1000));
    legend('tracked frequency','tracked frequency error');
    ylabel('$\Delta$F (MHz)','Interpreter','latex','FontSize',16);
    xlabel('Sample number','Interpreter','latex','FontSize',16);
    ylim([-0.10,0.10]);
    
    maxfr=max((fr(1:1000)-mean(fr(1:1000))));
    minfr=min((fr(1:1000)-mean(fr(1:1000))));
    dFr=abs(maxfr-minfr);
    plot([0,1000-1],[maxfr,maxfr],'--','color','green','LineWidth',2);
    plot([0,1000-1],[minfr,minfr],'--','color','green','LineWidth',2);
    text(250,-0.075,sprintf('dFr=%0.1f kHz',dFr*1000.),'color','green','FontSize',16);

    disp(sprintf('-> Median in noise subset : %0.1f pA/rtHz',psd_median_in_subset));
    disp(sprintf('-> Mean in noise subset : %0.1f pA/rtHz',psd_mean_in_subset));
    
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fFdF,F,band,subband,cfg.readoutChannelSelect),'Interpreter','none','FontSize',8);
    
    % done
    %
    
    [fp,fn,fext]=fileparts(fname);
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_psd.png',fn,band,subband,cfg.readoutChannelSelect)));
    
    freqs_subset_idxs = find((f<2*xmax));
    noiseoutfn=fullfile(path2outputs,sprintf('%s_b%dsb%dch%d.psd',fn,band,subband,cfg.readoutChannelSelect));
    fileID=fopen(noiseoutfn,'w');
    fprintf(fileID,'%f\t%f\n',[f(freqs_subset_idxs)';pArtHz(freqs_subset_idxs)']);
    fclose(fileID);
    
    figure;
    plot(t,phase);
    ylabel('Demodulated phase (rad)');
    xlabel('Time (sec)');
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fname,F,band,subband,cfg.readoutChannelSelect),'Interpreter','none','FontSize',8);
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_phase.png',fn,band,subband,cfg.readoutChannelSelect)));
    
    figure;
    plot(t,amp/1e3);
    ylabel('Demodulated amplitude (kHz)');
    xlabel('Time (sec)');
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fname,F,band,subband,cfg.readoutChannelSelect),'Interpreter','none','FontSize',8);
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_amp.png',fn,band,subband,cfg.readoutChannelSelect)));
    
    %plot etaScan
    figure;
    daspect([1 1 1]);
    etaCfg=etaScan.etaCfg;
    resp=etaOut.resp;
    feta=etaOut.f;
    
    a = abs(resp); idx = find(a==min(a),1);
    min_resp=min(a);
    max_resp=max(a);
    F0 = feta(idx) %center frequency in MHz
    left = find(feta>F0-etaCfg.delF,1); feta(left)
    right = find(feta>F0+etaCfg.delF,1); feta(right)

    plot(resp); hold on;
    plot(resp(idx),'r*'); 
    plot(resp(left), 'gx')
    plot(resp(right), 'g+')
    
    x        = 0:0.05:2*pi;
    Ifit     = etaOut.R*cos(x)+etaOut.Icenter;
    Qfit     = etaOut.R*sin(x)+etaOut.Qcenter;
    circ     = Ifit +1i*Qfit;
    plot(circ,'.k')
    
    
    title(sprintf('%s : %0.3f GHz, band %d, subband %d, channel %d',fname,F,band,subband,cfg.readoutChannelSelect),'Interpreter','none','FontSize',8);
    text(etaOut.Icenter-etaOut.R/2,etaOut.Qcenter,sprintf('(Ic,Qc)=(%0.3f,%0.3f)\nR=%0.3f',etaOut.Icenter,etaOut.Qcenter,etaOut.R),'color','black','FontSize',18);
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_IQfit.png',fn,band,subband,cfg.readoutChannelSelect)));

    figure;
    netPhase = unwrap(angle(resp));
    %figure(2); 
    plot(feta, netPhase, '.');grid
    title(['Phase Response for ' num2str(band) '/' num2str(subband)],'FontSize',10)
    xlabel('Frequency (MHz)')
    ylabel('Phase')
    Nf = length(feta);
    latency = (netPhase(Nf)-netPhase(1))/(feta(Nf)-feta(1))/2/pi
    hold on
    plot(feta(left), netPhase(left), 'gx')
    plot(feta(right), netPhase(right), 'g+')

    p = polyfit([feta(left), feta(right)], [netPhase(left), netPhase(right)], 1);
        plot(feta, polyval(p,feta), 'k--')
    axis([feta(1), feta(end), min(netPhase) - 0.2, max(netPhase) + 0.2])
    
    saveas(gcf,fullfile(path2outputs,sprintf('%s_b%dsb%dch%d_dphasedf.png',fn,band,subband,cfg.readoutChannelSelect)));
    
    fprintf(fileID2,'%d\t%d\t%d\t%0.3f\t%0.3f\t%0.3e\t%0.3e\t%0.2f\t%0.2f\t%0.3e\t%0.3e\t%0.2f\t%0.2f\t%0.3e\t%0.3e\t%0.3e\t%0.3e\t%0.3e\t%0.3e\t%0.3f\t%0.1f\n',cfg.readoutChannelSelect,band,subband,Foff,F,fsubset_min,fsubset_max,psd_mean_in_subset,psd_median_in_subset,fsubset_min2,fsubset_max2,psd_mean_in_subset2,psd_median_in_subset2,etaOut.R,min_resp,max_resp,p(1),p(2),latency, mean(amp)/1e3, dFr*1000.);
    
    hold off;
    break;
end
fclose(fileID2);
