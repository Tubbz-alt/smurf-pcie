%% TO DO: NEED TO SAVE CFG SO WE CAN RELOAD FOR OFFLINE DATA
function resOutFileName=findFreqs(bandOrOfflineDataCtime,subbands,Adrive);

    tooCloseCutoffFrequencyMHz=0.2;

    isOffline=false;
    if nargin<1
        band=2;
    elseif isstring(bandOrOfflineDataCtime) || ischar(bandOrOfflineDataCtime)
        isOffline=true;
        offlineDataCtime=bandOrOfflineDataCtime;
        %% hard-coded for now, but need to save configuration data and load it instead for offline data 
        band=0;
    else
        band=bandOrOfflineDataCtime;
    end
    Off(band);
    
    if nargin < 2
        %subBands=[0+10,127-10];
        subbands=[12:114];
        %subbands=[63];
    end
    
    if nargin<3
        Adrive=10;
    end
    
    %% tries to find all of the resonators
    
    % System has 8 500MHz bands, centered on 8 different frequencies.
    % All of our testing so far has been on the band centered at 5.25GHz.
    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)]
    smurfRoot = getSMuRFenv('SMURF_EPICS_ROOT');    
    bandCenterMHz = lcaGet([rootPath,'bandCenterMHz']);
    numberSubBands=lcaGet([rootPath,'numberSubBands']);
    ctime=ctimeForFile;
    
    if ~isOffline
        % sweep all bands
        Nread=2;
        [f,resp]=fullBandAmplSweep(band,subbands,Adrive,Nread);
    else
        % load data from saved data by ctime
        path2data='/home/common/data/cpu-b000-hp01/cryo_data/data2/';
        dfn_cands=glob(fullfile(path2data,sprintf('/*/%s/%s_amplSweep.mat',offlineDataCtime,offlineDataCtime)));
        % don't take the one that's in the soft-linked current_data directory
        dfnIdxC=strfind(dfn_cands,'/current_data/');
        dfnIdx=find(cellfun('isempty',dfnIdxC));
        dfn=dfn_cands(dfnIdx);
        dfn=dfn{1,1}; % not sure why this is necessary
        disp(['-> found ' dfn]);
        offlineData=load(dfn);
        
        % used later
        f=offlineData.f;
        resp=offlineData.resp;
        sweepDataFilename=dfn;
        
        % overwrite bands to include all bands with a nonzero response
        subbands={};
        for subband=0:numberSubBands-1
            if any(abs(resp(subband+1,:)))
                subbands=[subbands, subband];
            end
        end
        %subbands=horzcat(bands{:});
        subbands=[0:127];
        %subbands=[117,118];
    end
        
    % plot
    figure
    hold on;
    xlabel('Frequency (MHz)')
    ylabel('Amplitude (normalized)')
    title(sprintf('%d sub-band response',numberSubBands))
    
    for subband=0:numberSubBands-1
        disp(['Plotting sub-band ' num2str(subband)])
        %plot(f(subband+1,:), abs(resp(subband+1,:)), '.', 'color', rand(1,3))
        plot(f(subband+1,:), abs(resp(subband+1,:)), 'color', rand(1,3))
        grid on;
    end
    
    xlim([-300 300])
    xlabel('Frequency (MHz)')
    ylabel('Amplitude (normalized)')
    title(sprintf('%d sub-band response',numberSubBands))
    %% done plotting sweep results
    
    if ~isOffline
        % create directory for results
        datadir=dataDirFromCtime(ctime);
        resultsDir=fullfile(datadir,num2str(ctime));
    
        % if resuls directory doesn't exist yet, make it
        if not(exist(resultsDir))
            disp(['-> creating ' resultsDir]);
            mkdir(resultsDir);
        end
    
        % save figure and data to directory
        sweepFigureFilename=fullfile(resultsDir,[num2str(ctime),smurfRoot, '_amplSweep.png']);
        saveas(gcf,sweepFigureFilename);
        sweepDataFilename=fullfile(resultsDir,[num2str(ctime),smurfRoot, '_amplSweep.mat']);
        save(sweepDataFilename,'f','resp');
    end
    
    % analyze
    if ~isOffline
        plotsaveprefix=fullfile(resultsDir,[num2str(ctime), smurfRoot]);
    else
        plotsaveprefix='';
    end
    res=findAllPeaks(sweepDataFilename,subbands,plotsaveprefix);
    res = res + bandCenterMHz;
    res = sort(res);
    
    %% cull any resonators that are too close; sometimes a resonator is between bands such that it appears in both, for instance
    too_close=find(abs(diff(res))<tooCloseCutoffFrequencyMHz); 
    disp(sprintf('-> Found %d pair(s) of resonators within %0.3f MHz of each other; removing one from each pair',length(too_close),tooCloseCutoffFrequencyMHz));
    res(too_close)=[];
    
    disp(['res(MHz) = ',num2str(res)]);
    disp(sprintf('nres = %d',length(res)));
    
    % save resonators to file as list, by band and Foff
    tone_subbands=zeros(1,length(res)); tone_Foffs=zeros(1,length(res));
    for r=1:length(res)
        [tone_subbands(r), tone_Foffs(r)] = f2band(res(r),band);
    end
    
    if ~isOffline
        % bands are interleaved, so let's sort results by frequency, not band
        results=horzcat(tone_subbands',tone_Foffs',res');
        results = sortrows(results,3);
        
        resOutFileName = fullfile(resultsDir, [num2str(ctime),smurfRoot,'.res']);
        %% works, but looks dumb
        dlmwrite(resOutFileName,double(results),'delimiter','\t','precision','%0.3f');
        
        %
        system(sprintf('rm /data/cpu-b000-hp01/cryo_data/data2/current_res_%s', smurfRoot));
        system(sprintf('ln -s %s /data/cpu-b000-hp01/cryo_data/data2/current_res_%s', resOutFileName, smurfRoot));
    end
    
    
