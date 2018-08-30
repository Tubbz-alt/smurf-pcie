%script plotLines
% find(bandchans~=0)
%bands = find(bandchans~=0)
%bandchans

%how many lines shall we plot?
Nplots = sum(bandchans)
subplot(ceil(Nplots/4),4,1)

bands=find(bandchans>0)
nplot = 1;
for nband=1:length(bands)
    for nchan = 1:bandchans(bands(nband))
        chan = 16*(bands(nband) - 1) + nchan
        subplot(ceil(Nplots/4),4,nplot)
        plot(f(:,chan)),grid, title(['Channel ' num2str(chan)])
        nplot = nplot+1;
    end
end
        
    