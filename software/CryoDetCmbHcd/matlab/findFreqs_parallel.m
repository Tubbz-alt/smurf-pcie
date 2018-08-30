function resOutFileName = findFreqs_parallel(subbands, band, Adrive);

    tooCloseCutoffFrequencyMHz = 0.2;

    if nargin < 1
	subbands = [63];
    end

    if nargin < 2
	band = 2;
    else
	band = band;
    end

    Off(band);

    if nargin < 3
	Adrive = 9; % a bit lower for parallel
    end

    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', band)]

    bandCenterMHz = lcaGet([rootPath, 'bandCenterMHz']);
    numberSubBands = lcaGet([rootPath, 'numberSubBands']);
    ctime = ctimeForFile;

    scanChans = zeros(1, 512); % initialize empty array

    for i=1:length(subbands)
	subbandNo = subbands(i);
	subbandChans = getChannelsInSubBand(band, subbandNo);
	firstChannel = subbandChans(1) + 1; % only need to sweep the leftmost channel of each subband to cover the whole thing
	scanChans(firstChannel) = 1;
    end
    
    disp('starting parallel scan')

    [f, chanResp] = parallelScan(band, scanChans, Adrive); % this will automatically do two reads, returns resp as complex (length(f) x 512) array

    % now need to remap channel response to subbands
    subbandResp = zeros(length(f), numberSubBands);
    for i=1:length(subbands)
	subbandNo = subbands(i);
	subbandChans = getChannelsInSubBand(band, subbandNo);
	firstChannel = subbandChans(1) + 1;
	subbandResp(:,subbandNo + 1) = chanResp(:, firstChannel);
    end
    
    disp('making some plots wahoo')
    
    % make plots look the same as before
    figure
    hold on;
    xlim([-300 300])
    xlabel('Frequency (MHz)')
    ylabel('Amplitude (normalized)')
    title(sprintf('%d sub-band response', numberSubBands))

    for subband=0:numberSubBands-1
	disp(['Plotting sub-band ' num2str(subband)])
	plot(f, abs(subbandResp(:,subband+1)), '.', 'color', rand(1,3))
	grid on;
    end

    datadir = dataDirFromCtime(ctime);
    resultsDir = fullfile(datadir, strcat(num2str(ctime), 'freqs'));

    if not(exist(resultsDir))
	disp(['-> creating ' resultsDir]);
	mkdir(resultsDir);
    end

    sweepFigureFilename = fullfile(resultsDir, [num2str(ctime), '_amplSweep.png']);
    saveas(gcf, sweepFigureFilename);
    sweepDataFilename = fullfile(resultsDir, [num2str(ctime), '_amplSweep.mat']);
    resp = subbandResp; % in case names of things matter
    save(sweepDataFilename, 'f', 'resp');

    % analyze as before
    plotsaveprefix = fullfile(resultsDir, num2str(ctime));

    res = findAllPeaks(sweepDataFilename, subbands, plotsaveprefix);
    res = res+ bandCenterMHz;
    res = sort(res);

    % cull any resonators that are too close
    too_close = find(abs(diff(res)) < tooCloseCutoffFrequencyMHz);
        disp(sprintf('-> Found %d pair(s) of resonators within %0.3f MHz of each other; removing one from each pair',length(too_close),tooCloseCutoffFrequencyMHz));
    res(too_close)=[];

    disp(['res(MHz) = ',num2str(res)]);
    disp(sprintf('nres = %d',length(res)));

    % save resonators to file as list, by band and Foff
    tone_subbands=zeros(1,length(res)); tone_Foffs=zeros(1,length(res));
    for r=1:length(res)
        [tone_subbands(r), tone_Foffs(r)] = f2band(res(r),band);
    end

    results = horzcat(tone_subbands', tone_Foffs', res');
    results = sortrows(results, 3);

    resOutFileName = fullfile(resultsDir, [num2str(ctime), '.res']);
    dlmwrite(resOutFileName, double(results), 'delimiter', '\t', 'precision', '%0.3f'); % I prefer csv's so maybe this will change when I migrate this to Python sorry Shawn

    % don't do this until troubleshooted
    %system('rm /data/cpu-b000-hp01/cryo_data/data2/current_res');
    %system(sprintf('ln -s %s /data/cpu-b000-hp01/cryo-data/data2/current_res', resOutFileName));


end


