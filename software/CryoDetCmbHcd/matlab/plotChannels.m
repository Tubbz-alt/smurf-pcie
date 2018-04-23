%plotChannels
%dfn='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180316/1521234479.dat';
%% 100Hz, 0.13Vpp flux ramp
dfn='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180316/1521235661.dat';
[f,df,frs]=decodeData(dfn);
%% 0VDC flux ramp fixed bias
dfn2='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180316/1521235998.dat';
[f2,df2,frs2]=decodeData(dfn2);

load('/data/cpu-b000-hp01/cryo_data/data2/20180316/1521220641/1521220641_etaOut.mat');

%dfn='/home/common/data/cpu-b000-hp01/cryo_data/data2/20180316/1521235504_Ch18.dat';
%[f,df,frs]=decodeSingleChannel(dfn);

%how many lines shall we plot?
for band=31
    Nchans = 8;
    fig=figure;
    subplot(8,1,1)
    nplot=1;
    title(sprintf('band %d',band));
    for chan = (1+16*band):(Nchans+16*band)
        spanf=(max(f(:,chan))-min(f(:,chan)));
        midf=min(f(:,chan))+spanf/2.;
        subplot(8, 1, nplot)
        plot(1e3*(f(:,chan)-midf));%, grid, title(['Channel ' num2str(chan)])
        hold on;
        plot(1e3*(f2(:,chan)-midf));%, grid, title(['Channel ' num2str(chan)])
        
        if chan==(1+16*band)
            text(0.5,2.0,sprintf('band %d',band),'Units','normalized','FontSize',18,'HorizontalAlignment','center');
        end
        
        if ~(chan==1)
            if ~isempty(etaOut(chan-1).eta)
                title(sprintf('band%d, ch%d - %0.3f GHz',band,chan-1,etaOut(chan-1).res));
            else
                title(sprintf('band%d, ch%d - not programmed',band,chan-1));
            end
        else
            title(sprintf('band%d, ch%d etaScan parameters accidentally not programmed due to indexing error',band,chan-1));
        end
        text(0.6,0.15,sprintf('Foff = %0.3f MHz, dFr = %0.0f kHz',midf,spanf*1000),'Units','normalized','FontSize',8);
        ylabel('F (kHz)');
        nplot = nplot+1;
        if chan<(Nchans+16*band)
            set(gca,'XTick',[]);
        else
            xlabel('Sample number');
        end
        ylim([-150,150]);
        set(gcf,'Units','Normalized','OuterPosition',[0.04,0.04,0.6,0.96]);
    end
    figureFileName=sprintf('1521220641_8chan_band%d.png',band);
    saveas(gcf,figureFileName);
end