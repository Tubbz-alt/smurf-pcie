close all;
clear;

baseNumber=0;
baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)]

pre_singleChannelReadout=lcaGet( [baseRootPath, 'singleChannelReadout'])
pre_singleChannelReadoutOpt2=lcaGet( [baseRootPath, 'singleChannelReadoutOpt2'])
pre_iqStreamEnable=lcaGet( [baseRootPath, 'iqStreamEnable'])
pre_decimation=lcaGet( [baseRootPath, 'decimation'])
pre_filterAlpha=lcaGet( [baseRootPath, 'filterAlpha'])

lcaPut( [baseRootPath, 'singleChannelReadout'], 0)
lcaPut( [baseRootPath, 'singleChannelReadoutOpt2'], 0)
lcaPut( [baseRootPath, 'iqStreamEnable'], 0)
lcaPut( [baseRootPath, 'decimation'], 0)
lcaPut( [baseRootPath, 'filterAlpha'], 16384);

[f,df,frs]=quickData(2^18);

%% return to pre-script readout configuration
lcaPut( [baseRootPath, 'singleChannelReadout'], pre_singleChannelReadout)
lcaPut( [baseRootPath, 'singleChannelReadoutOpt2'], pre_singleChannelReadoutOpt2)
lcaPut( [baseRootPath, 'iqStreamEnable'], pre_iqStreamEnable)
lcaPut( [baseRootPath, 'decimation'],pre_decimation)
lcaPut( [baseRootPath, 'filterAlpha'], pre_filterAlpha);

% keep track of tune at this tone power                     
[status,cmdout]=system('readlink /data/cpu-b000-hp01/cryo_data/data2/current_eta');            
etaFilePath=strtrim(cmdout);
eta=load(etaFilePath);

etaCfgFilePath=strrep(etaFilePath,'_etaOut.mat','.mat');
eta_cfg=load(etaCfgFilePath);

Nchans=(eta_cfg.numberChannels/eta_cfg.numberSubBands);

%% which bands have channels with nonzero data?
% which channels have measured eta parameters?
etaOut=eta.etaOut;
etaChan={etaOut.chan};
chans=etaChan(find(~cellfun(@isempty,etaChan)));
chans=cell2mat(chans);
bands=[];
for chan=chans
    bands=[bands,getChannelSubBand(baseNumber,chan)];
end
bands=sort(unique(bands));

%how many lines shall we plot?
for band=bands
    fig=figure;
    subplot(Nchans,1,1)
    nplot=1;
    title(sprintf('band %d',band));
    
    bandchans=getChannelsInSubBand(baseNumber,band);
    for chan = bandchans
        spanf=(max(f(:,chan+1))-min(f(:,chan+1)));
        midf=min(f(:,chan+1))+spanf/2.;
        subplot(Nchans, 1, nplot)
        plot(1e3*(f(:,chan+1)-midf));%, grid, title(['Channel ' num2str(chan)])
        
        if chan==bandchans(1)
            text(0.5,2.0,sprintf('band %d',band),'Units','normalized','FontSize',18,'HorizontalAlignment','center');
        end
        
        if any(chans(:) == chan);
            %title(sprintf('band%d, ch%d - %0.3f GHz',band,chan,etaOut(chan-1).res));
            title(sprintf('band%d, ch%d',band,chan));
        else
            title(sprintf('band%d, ch%d - not programmed',band,chan));
        end

        text(0.6,0.15,sprintf('Foff = %0.3f MHz, dFr = %0.0f kHz',midf,spanf*1000),'Units','normalized','FontSize',8);
        ylabel('F (kHz)');
        nplot = nplot+1;
        
        if ~(chan==bandchans(end))
            set(gca,'XTick',[]);
        else
            xlabel('Sample number');
        end
        ylim([-150,150]);
        %set(gcf,'Units','Normalized','OuterPosition',[0.04,0.04,0.6,0.96]);
    end
    ctime=ctimeForFile();
    figureFileName=sprintf('%d_band%d.png',ctime,band);
    saveas(gcf,figureFileName);
end
