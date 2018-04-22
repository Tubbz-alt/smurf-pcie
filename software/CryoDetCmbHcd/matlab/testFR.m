function testFR()
    preTune=false;
    tuneEach=true;
    setupEach=false;
    setupBand=2;
    relock=true;
    checklock=false;
    pauseBeforeEach=false;
    singleChannel=false;
    monitorChannel=2;
    
    root=getSMuRFenv('SMURF_EPICS_ROOT');
    rootPath=strcat(root,':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'); 
    
    % keep data organized by date
    datapath='/data/cpu-b000-hp01/cryo_data/data2/';
    now=datetime('now')
    dirdate=datestr(now,'yyyymmdd');
    datadir=fullfile(datapath,dirdate);

    % if today's date directory doesn't exist yet, make it
    if not(exist(datadir))
        disp(['-> creating ' datadir]);
        mkdir(datadir);
    end

    filename=num2str(round(posixtime(now)));
    
    % save data
    %% this is redundant, need to make a function
    % are we in single channel readout mode, and if so, on what channel?
    singleChannelReadoutOpt2 = lcaGet([rootPath 'singleChannelReadoutOpt2']);
    readoutChannelSelect = lcaGet([rootPath 'readoutChannelSelect']);

    % add channel suffix for single channel data
    if singleChannelReadoutOpt2==1
        filename=[filename '_Ch' num2str(readoutChannelSelect)]
    end
    
    % add .mat suffix
    filename=fullfile(datadir,[filename '_FvPhi.mat']);
    disp(['filename=' filename]);

    % if user wants plots saved, save them with in a directory with this
    % hardcoded timestamp.
    savePlots=true;
    plotsCtime=ctimeForFile;
    if savePlots % create directory for plots
        % create directory for results
        plotDir=dataDirFromCtime(plotsCtime);

        % if plot results directory doesn't exist yet, make it
        if not(exist(plotDir))
            disp(['-> creating ' plotDir]);
            mkdir(plotDir);
        end
    end

    legendInfo={};
    counter=1;
    f=[];
    df=[]
    sync=[];
    v=[];
    tunes=[];
% MD - setup flux ramp before starting
    fluxRampSetup
    
    %% For taking with varying TES voltage
    %varName='VTES';
    %varUnits='V';
    
    %% Full IV (attempt)
    %normalBias=3.; %V
    %normalBiasTime=1; %sec
    %waitBtwIVPoints=0.1; %sec
    %Vstep=0.001;
    %maxV=1.2;
    %minV=0.;
    
    %% Short superconducting segment
    %normalBias=7.0; %V
    %normalBiasTime=1; %sec
    %waitBtwIVPoints=0.1;%sec
    %Vstep=0.005; %sec
    %maxV=1.0;
    %minV=0.;
    
    %varPoints=fliplr(minV:Vstep:maxV);
    %varPoints=[normalBias (normalBias-Vstep) 0];
    
    %% For taking with varying input RF power
    varName='Adrive';
    varUnits='';
    %varPoints=[10 12 11 10 9 8 7 6 5 4];
    varPoints=[13 12 11 10 9 8];
    %% done varying dependent variable
    
    if preTune
        fluxRampOnOff(0); 
        if singleChannel
            chan = setupNotches_umux16_singletone(rootPath,10,[fr]);
            lcaPut([rootPath,'readoutChannelSelect'], chan(1));
            lcaPut([rootPath,'singleChannelReadoutOpt2'], 1);
        else 
            lcaPut([rootPath,'singleChannelReadoutOpt2'], 0);
        end
    end
    
    % clear figures
    figure(101); clf;
    figure(102); clf;
    
    for var=varPoints
        %if pauseBeforeEach
        %    disp(['Press any key on the prompt to take data at ',varName,' = ',num2str(var)]);
        %    pause;
        %end
        
        %% vary dependent variable
        % what action to take depends on what the user is varying
        if strcmp(varName,'VTES')
            
            if var==varPoints(1)
                % bias TES normal
                cmdStr=sprintf('ssh -Y pi@171.64.108.91 "~/dac_cmdr/dac_cmdr -v %0.4f"',normalBias);
                system(cmdStr);
                disp(cmdStr);
                pause(normalBiasTime);
            end
            
            cmdStr=sprintf('ssh -Y pi@171.64.108.91 "~/dac_cmdr/dac_cmdr -v %0.4f"',var);
            system(cmdStr);
            disp(cmdStr);
            pause(waitBtwIVPoints);
        end
         
        if strcmp(varName,'Adrive')
            fluxRampOnOff(0); 
            pause(0.5);
            
            if setupEach
                setup(setupBand);
                pause(5);
            end
            
            if tuneEach
                if singleChannel
                    chan = setupNotches_umux16_singletone(rootPath,var,[fr]);
                else
                    %disp(sprintf('* Press enter to tune at Adrive=%d ...',var));
                    %pause;
                    tune_ctime=setupNotches_umux16(rootPath,var,true);
                    
                    % keep track of tune at this tone power
                    [status,cmdout]=system('readlink /data/cpu-b000-hp01/cryo_data/data2/current_eta');
                    [filepath,name,ext] = fileparts(cmdout) 
                    [dirpath,dirname] = fileparts(filepath) 
                    tunes = [tunes ; dirname];
                    
                    % for some reason this can improve the number of tones
                    % which are tracking
                    if relock
                        Off;
                        pause(1);
                        reLock;
                    end
                    
                    pause(5);
                end
            end
            
            % change Adrive for all channels
            pvRoot = [rootPath, 'CryoChannels:'];
            amplitudeScaleArray=lcaGet( [pvRoot, 'amplitudeScaleArray'] );
            amplitudeScaleArray(find(amplitudeScaleArray~=0))=var;
            lcaPut( [pvRoot, 'amplitudeScaleArray'], amplitudeScaleArray );
            pause(0.5);
            
            fluxRampOnOff(1); 
            pause(0.5);
            
            if checklock
                pause(5);
                checkLock;
            end
            
            %if savePlots
            %    figureFilename=fullfile(plotDir,[num2str(plotsCtime),'_res',num2str(round(fr)),'GHz_IQ.png']);
            %    saveas(gcf,figureFilename);
            %end
        end
        %% done varying dependent variable
        
        count = 0;
        err_count = 0;
        while count == err_count 
            try
                % get frame
                clear frameFreq frameFreqError frameStrobe
                [frameFreq,frameFreqError,frameStrobe] = getFrameByFile( rootPath );
        
                % plot frame
                figure(101);
                plot(frameFreq(:,monitorChannel)); hold on;
                legendInfo{counter} = [varName ' = ' num2str(var)];

                % MD - also show frame frequency error - looks to be on a similar scale to frameFreq?           
                figure(102);
                plot(frameFreqError(:,monitorChannel)); hold on;
                legendInfo{counter} = [varName ' = ' num2str(var)];
                counter=counter+1;
        
                %f=horzcat(f,frameFreq);
                %df=horzcat(df,frameFreqError);
                %sync=horzcat(sync,frameStrobe);
                
                f=[f ; frameFreq];
                df=[df ; frameFreqError];
                sync=[sync ; frameStrobe];
                
                v=[v ; var]
            catch e
                disp( e.identifier )
                disp(['ERROR: ', e.message])
                err_count = err_count + 1;
                %% don't crash out, keep going
                %error(['ERROR! Failed to get good data for : Adrive = ',num2str(Adrive)]);
            end
            count = count + 1;
        end
        %save as we go
        save(filename,'v','f','df','sync','tunes');
        %pause;
    end
    figure(101);
    legend(legendInfo);
    
    if savePlots
        figureFilename=fullfile(plotDir,[num2str(plotsCtime),'_f.png']);
        saveas(gcf,figureFilename);
    end
    
    figure(102);
    legend(legendInfo);
    ylim([-0.1 0.1])
    title('Feedback error')
    
    if savePlots
        figureFilename=fullfile(plotDir,[num2str(plotsCtime),'_ferr.png']);
        saveas(gcf,figureFilename);
    end

    %%
    save(filename,'v','f','df','sync','tunes');
    disp(['-> filename=',filename]);
end

function [frameFreq,frameFreqError,frameStrobe] = getFrame( rootPath )

    global DMBufferSizePV

    C = strsplit(rootPath, ':');
    root = C{1};

    % close all
    flux_ramp_rate=1e3; % Hz
    
    % why is sample rate 1.2e6, not 2.4e6?
    tsamp=1/1.2e6; %current sample rate
    fs=1/tsamp;
    
    % multiply by 8 to make sure we get the full flux ramp
    %data_length=8*ceil(fs/flux_ramp_rate);
    data_length=2^22;
    
    time=tsamp*(0:1:data_length-1);
    
    setupDaqMux( 'mitch_epics', 'debug', [], data_length);
    results       = readStreamData( 'mitch_epics', data_length); 

    %%
    freqWordTemp = results(1,:);

    % make unsigned 16
    idx = find( freqWordTemp < 0 );
    freqWordTemp(idx) = freqWordTemp(idx) + 2^16;
    freqWord = freqWordTemp(1:2:end) + freqWordTemp(2:2:end)*2^16;

    freqErrorWordTemp = results(2,:);

    % make unsigned 16
    idx = find( freqWordTemp < 0 );
    freqErrorWordTemp(idx) = freqErrorWordTemp(idx) + 2^16;
    freqErrorWord = freqErrorWordTemp(1:2:end) + freqErrorWordTemp(2:2:end)*2^16;

    rawData = [freqWord; freqErrorWord];
    rawData = rawData(:, 3:end)';  % throw away header, transpose to match rawData
    
    %%
    % decode
    nF = 1; nDF =2;
    
    %decode strobes
    strobes = floor(rawData/2^30);
    data = rawData - 2^30*strobes;
    ch0Strobe = mod(strobes, 2) ==1;
    fluxRampStrobe = floor(strobes/2);

    %decode frequencies
    ch0idx = find(ch0Strobe(:,1) == 1);
    Ffirst = ch0idx(1);
    Flast = ch0idx(length(ch0idx))-1;
    freqs = data(Ffirst:Flast,1);
    neg = find(freqs >= 2^23);
    F = double(freqs);
    if ~isempty(neg)
        F(neg) = F(neg)-2^24;
    end
    
    if mod(length(F),512)~=0
       Npoints = length(F)/512;  % bug??
        F = [];
    else
        F = reshape(F,512,[]) * 19.2/2^23;
        F = F';
    end
    
    fluxRampStrobeF = fluxRampStrobe(Ffirst:Flast, nF);
    
    %decode frequency errors 
    % UNTESTED until fixed data stream tested
    ch0idx = find(ch0Strobe(:,2) == 1);
    if ~isempty(ch0idx)
        Dfirst = ch0idx(1);
        Dlast = ch0idx(length(ch0idx))-1;
        df = data(Dfirst:Dlast,2);
        neg = find(df >= 2^23);
        dF = double(df);
        if ~isempty(neg)
            dF(neg) = dF(neg)-2^24;
        end

        if mod(length(dF),512)~=0
            Npoints = length(dF)/512;  % bug??
            dF = [];
        else
            dF = reshape(dF,512,[]) * 19.2/2^23;
            dF = dF';
        end

    else
        dF = [];
    end
 
    
    
    fluxRampStrobeDF = fluxRampStrobe(Dfirst:Dlast, nDF);
    
%%%
%%%    freqWord      = results(1,:);
%%%    freqErrorWord = results(2,:);
%%%    
%%%    % data is even, strobe is odd, apparently.  
%%%% % %     freq=freqWord(1:2:end);
%%%% % %     freqStrobe=freqWord(2:2:end);
%%%
%%%% MD - make data look like uint32 from disk
%%%   freq1 = double(typecast(int16(freqWord),'uint16')); 
%%%   freq = freq1(1:2:end) + freq1(2:2:end)*2^16;
%%%   strobes = floor(freq/2^30);
%%%   freq = freq - strobes*2^30;
%%%   fluxRampStrobe = floor(strobes./2);
%%%    
%%%    neg = find(freq >= 2^23);
%%%    freq = double(freq);
%%%    if ~isempty(neg)
%%%         freq(neg) = freq(neg)-2^24;
%%%    end
%%%
%%%     freq = freq * 19.2/2^23;
%%%
%%%% % %     freqError=freqErrorWord(1:2:end);
%%%% % %     freqErrorStrobe=freqErrorWord(2:2:end);
%%%    
%%%
%%%    freqError1= double(typecast(int16(freqErrorWord), 'uint16'));
%%%    freqError = freqError1(1:2:end) + freqError1(2:2:end)*2^16;
%%%    freqErrorStrobe = floor(freqError./2^30);
%%%    freqError = freqError - 2^30*freqErrorStrobe;
%%%    
%%%    neg = find(freqError >= 2^23);
%%%%     freqError = double(freqError);
%%%    if ~isempty(neg)
%%%         freqError(neg) = freqError(neg)-2^24;
%%%    end
%%%
%%%     freqError = freqError * 19.2/2^23;
%%%
%%%    %decode strobes from freq stream
%%%% % %     strobes = floor(freqStrobe/2^30);
%%%% % %     fluxRampStrobe = -floor(strobes/2); % not sure why this has to be negative
%%%
%%%    resets = find(fluxRampStrobe >= 0.5);
%%%
%%%    % if there aren't 2 resets or more, need longer datasets for each ramp.
%%%    if length(resets)<2
%%%        error(['ERROR! Not enough flux ramp resets found in acquisition : length(resets) = ',num2str(length(resets))]);
%%%    end
%%%
%%%    % incorporates strobe at beginning of this flux ramp
%%%    frameStart=resets(1);
%%%    frameEnd=resets(2)-1;
%%%    frameFreq=freq(frameStart:frameEnd);
%%%    frameFreqError=freqError(frameStart:frameEnd);
%%%    frameStrobe=fluxRampStrobe(frameStart:frameEnd);    
end

function [frameFreqs,frameFreqErrors,frameStrobes] = getFrameByFile( rootPath )

    global DMBufferSizePV

    C = strsplit(rootPath, ':');
    root = C{1};

    % close all
    flux_ramp_rate=1e3; % Hz
    
    % why is sample rate 1.2e6, not 2.4e6?
    tsamp=1/1.2e6; %current sample rate
    fs=1/tsamp;
    
    % multiply by 8 to make sure we get the full flux ramp
    %data_length=8*ceil(fs/flux_ramp_rate);
    dataLength=2^21;
    
    dfn='/tmp/tmp2.dat';
    system( ['rm ', dfn] );
    tic
    takeDebugData(rootPath,dfn,dataLength);
    toc

    [f,df,frs]=decodeData(dfn);
    
    sync_f = reshape(frs(:,1),512,[]);
    sync_f = sync_f'; 
    
    %% enforce btw 0->1.  Shouldn't have to do this.
    for col=1:size(sync_f,2)
        if ~(max(sync_f(:,col))==min(sync_f(:,col)))
            sync_f(:,col)=(sync_f(:,col)-min(sync_f(:,col)))/(max(sync_f(:,col))-min(sync_f(:,col)));
        else
            sync_f(:,col)=0;
        end
    end
    
    [r,c]=find(sync_f==1);
    sync_f(r, :) = 1;
    
    resets_f = find(sync_f(:,511) == 1);
    resets_f=resets_f(find(~(diff(resets_f)==1)));
    
    frameStart_f=resets_f(1);
    frameEnd_f=resets_f(2)-1;
    
    frameFreqs=f(frameStart_f:frameEnd_f,:);
    frameFreqErrors=df(frameStart_f:frameEnd_f,:);
    frameStrobes=sync_f(frameStart_f:frameEnd_f,:);
end
