function testFR( fr )
    if nargin < 1
        % TES?
        %fr=5426.637;
        
        % TES?
        %fr=5325.069;
        
        % Superconducting short?
        fr=5264.368;
        
        %fr=5116.384;
    end
    %disp(fr);
    %disp('Check that fr is right and then press return at prompt to continue ...');
    %pause;
    
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

    root=getSMuRFenv('SMURF_EPICS_ROOT');
    rootPath=strcat(root,':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'); 

    legendInfo={};
    counter=1;
    f=[];
    df=[]
    sync=[];
    v=[]
% MD - setup flux ramp before starting
    fluxRampSetup
    
    %% For taking with varying TES voltage
    varName='VTES';
    varUnits='V';
    
    %% Full IV (attempt)
    %normalBias=3.; %V
    %normalBiasTime=1; %sec
    %waitBtwIVPoints=0.1; %sec
    %Vstep=0.001;
    %maxV=1.2;
    %minV=0.;
    
    %% Short superconducting segment
    normalBias=7.0; %V
    normalBiasTime=1; %sec
    waitBtwIVPoints=0.1;%sec
    Vstep=0.005; %sec
    maxV=1.0;
    minV=0.;
    
    varPoints=fliplr(minV:Vstep:maxV);
    %varPoints=[normalBias (normalBias-Vstep) 0];
    preTune=true;
    pauseBeforeEach=false;
    
    %% For taking with varying input RF power
%     varName='Adrive';
%     varUnits='';
%     varPoints=[10 10 10 10 10 10 10];
%     preTune=false;
%     pauseBeforeEach=false;
    %% done varying dependent variable
    
    if preTune
        fluxRampOnOff(0); 
        chan = setupNotches_umux16_singletone(rootPath,10,[fr]);
        lcaPut([rootPath,'readoutChannelSelect'], chan(1));
        lcaPut([rootPath,'singleChannelReadoutOpt2'], 1);
        fluxRampOnOff(1);
        pause(1)
    end
    
    % clear figures
    figure(101); clf;
    figure(102); clf;
    
    for var=varPoints
        if pauseBeforeEach
            disp(['Press any key on the prompt to take data at ',varName,' = ',num2str(var)]);
            if var>8
                pause;
            end
        end
        
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
            chan = setupNotches_umux16_singletone(rootPath,var,[fr]);
            lcaPut([rootPath,'readoutChannelSelect'], chan(1));
            lcaPut([rootPath,'singleChannelReadoutOpt2'], 1);
            fluxRampOnOff(1); 
            pause(0.5);
            
            if savePlots
                figureFilename=fullfile(plotDir,[num2str(plotsCtime),'_res',num2str(round(fr)),'GHz_IQ.png']);
                saveas(gcf,figureFilename);
            end
        end
        %% done varying dependent variable
        
        count = 0;
        err_count = 0;
        while count == err_count 
            try
                % get frame
                [frameFreq,frameFreqError,frameStrobe] = getFrame( rootPath );
        
                % plot frame
                figure(101);
                plot(frameFreq); hold on;
                legendInfo{counter} = [varName ' = ' num2str(var)];

                % MD - also show frame frequency error - looks to be on a similar scale to frameFreq?           
                figure(102);
                plot(frameFreqError); hold on;
                legendInfo{counter} = [varName ' = ' num2str(var)];
                counter=counter+1;
        
                f=horzcat(f,frameFreq);
                df=horzcat(df,frameFreqError);
                sync=horzcat(sync,frameStrobe);
                v=horzcat(v,var);
                %pause;
            catch e
                disp( e.identifier )
                disp(['ERROR: ', e.message])
                err_count = err_count + 1;
                %% don't crash out, keep going
                %error(['ERROR! Failed to get good data for : Adrive = ',num2str(Adrive)]);
            end
            count = count + 1;
        end
        %pause;
    end
    figure(101);
    legend(legendInfo);
    
    if savePlots
        figureFilename=fullfile(plotDir,[num2str(plotsCtime),'_res',num2str(round(fr)),'GHz_f.png']);
        saveas(gcf,figureFilename);
    end
    
    figure(102);
    legend(legendInfo);
    ylim([-0.1 0.1])
    title('Feedback error')
    
    if savePlots
        figureFilename=fullfile(plotDir,[num2str(plotsCtime),'_res',num2str(round(fr)),'GHz_ferr.png']);
        saveas(gcf,figureFilename);
    end
    
    % save data
    %% this is redundant, need to make a function
    % are we in single channel readout mode, and if so, on what channel?
    singleChannelReadoutOpt2 = lcaGet([rootPath 'singleChannelReadoutOpt2']);
    readoutChannelSelect = lcaGet([rootPath 'readoutChannelSelect']);

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
    disp(filename);

    % add channel suffix for single channel data
    if singleChannelReadoutOpt2==1
        filename=[filename '_Ch' num2str(readoutChannelSelect)]
    end

    % add .mat suffix
    filename=fullfile(datadir,[filename '_FvPhi.mat']);
    disp(['filename=' filename]);

    %%
    save(filename,'v','f','df','sync');
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
    data_length=8*ceil(fs/flux_ramp_rate);

    time=tsamp*(0:1:data_length-1);

    setupDaqMux( 'mitch_epics', 'debug', [], data_length);
    results       = readStreamData( 'mitch_epics', data_length); 

    freqWord      = results(1,:);
    freqErrorWord = results(2,:);
    
    % data is even, strobe is odd, apparently.  
% % %     freq=freqWord(1:2:end);
% % %     freqStrobe=freqWord(2:2:end);

% MD - make data look like uint32 from disk
   freq1 = double(typecast(int16(freqWord),'uint16')); 
   freq = freq1(1:2:end) + freq1(2:2:end)*2^16;
   strobes = floor(freq/2^30);
   freq = freq - strobes*2^30;
   fluxRampStrobe = floor(strobes./2);
    

    neg = find(freq >= 2^23);
    freq = double(freq);
    if ~isempty(neg)
         freq(neg) = freq(neg)-2^24;
    end

     freq = freq * 19.2/2^23;

% % %     freqError=freqErrorWord(1:2:end);
% % %     freqErrorStrobe=freqErrorWord(2:2:end);
    

    freqError1= double(typecast(int16(freqErrorWord), 'uint16'));
    freqError = freqError1(1:2:end) + freqError1(2:2:end)*2^16;
    freqErrorStrobe = floor(freqError./2^30);
    freqError = freqError - 2^30*freqErrorStrobe;
    
    neg = find(freqError >= 2^23);
%     freqError = double(freqError);
    if ~isempty(neg)
         freqError(neg) = freqError(neg)-2^24;
    end

     freqError = freqError * 19.2/2^23;

    %decode strobes from freq stream
% % %     strobes = floor(freqStrobe/2^30);
% % %     fluxRampStrobe = -floor(strobes/2); % not sure why this has to be negative

    resets = find(fluxRampStrobe >= 0.5);

    % if there aren't 2 resets or more, need longer datasets for each ramp.
    if length(resets)<2
        error(['ERROR! Not enough flux ramp resets found in acquisition : length(resets) = ',num2str(length(resets))]);
    end

    % incorporates strobe at beginning of this flux ramp
    frameStart=resets(1);
    frameEnd=resets(2)-1;
    frameFreq=freq(frameStart:frameEnd);
    frameFreqError=freqError(frameStart:frameEnd);
    frameStrobe=fluxRampStrobe(frameStart:frameEnd);
    
end
