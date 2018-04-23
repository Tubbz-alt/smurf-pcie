%% tries to find all of the resonators

% System has 8 500MHz bands, centered on 8 different frequencies.
% All of our testing so far has been on the band centered at 5.25GHz.

bandCenterMHz = lcaGet([rootPath,'bandCenterMHz']);
ctime=ctimeForFile;
Adrive=11;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
% bands=[0 16];
%bands=0:31;
bands=[9 25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17 2 18 3 19 4 20 5 21 6 22 7];
%bands=0;

% sweep all bands
[f,resp]=fullBandAmplSweep(bands,Adrive);

% plot
figure
hold on;
xlabel('Frequency (MHz)')
ylabel('Amplitude (normalized)')
title('32 sub-band response')

for band=0:31
    disp(['Plotting band ' num2str(band)])
    if band == 10
        xlim([-300 300]);
    end
    plot(f(band+1,:), abs(resp(band+1,:)), '.', 'color', rand(1,3))
    grid on;
end

xlim([-300 300])
xlabel('Frequency (MHz)')
ylabel('Amplitude (normalized)')
title('32 sub-band response')
%% done plotting sweep results

% create directory for results
datadir=dataDirFromCtime(ctime);

resultsDir=fullfile(datadir,num2str(ctime));

% if resuls directory doesn't exist yet, make it
if not(exist(resultsDir))
    disp(['-> creating ' resultsDir]);
    mkdir(resultsDir);
end

% save figure and data to directory
sweepFigureFilename=fullfile(resultsDir,[num2str(ctime),'_amplSweep.png']);
saveas(gcf,sweepFigureFilename);
sweepDataFilename=fullfile(resultsDir,[num2str(ctime),'_amplSweep.mat']);
save(sweepDataFilename,'f','resp');

% analyze
plotsaveprefix=fullfile(resultsDir,num2str(ctime));
res=findAllPeaks(sweepDataFilename,bands,plotsaveprefix);
res = res + bandCenterMHz;

disp(['res(MHz) = ',num2str(res)]);

% save resonators to file as list, by band and Foff
[band, Foff] = f2band(res,bandCenterMHz);

% bands are interleaved, so let's sort results by frequency, not band
results=horzcat(band',Foff',res');
results = sortrows(results,3);

resOutFileName = fullfile(resultsDir, [num2str(ctime), '.res']);
dlmwrite(resOutFileName,double(results),'delimiter','\t','precision','%0.3f');
%
system('rm /data/cpu-b000-hp01/cryo_data/data2/current_res');
system(sprintf('ln -s %s /data/cpu-b000-hp01/cryo_data/data2/current_res', resOutFileName));

