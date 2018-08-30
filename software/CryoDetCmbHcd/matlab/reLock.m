function reLock(band,etaScanDir,chans)
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];
    
    if nargin < 2
        
        smurfRoot = getSMuRFenv('SMURF_EPICS_ROOT')
        [status,cmdout]=system(sprintf('readlink /data/cpu-b000-hp01/cryo_data/data2/current_eta_%s',smurfRoot));
        etaIn=load(deblank(cmdout));
    else
        etaIn=load(fullfile(etaScanDir,[fileNameFromPath(etaScanDir), getSMuRFenv('SMURF_EPICS_ROOT'), '_etaOut.mat']));
    end
    
    if nargin < 3
        % index of channel in etaOut array is +1 the channel
        chans=find(~cellfun(@isempty,{etaIn.etaOut.chan}));
    else
        % the index of a channel in the etaOut struct is +1 the channel
        % number because matlab doesn't zero index
        chans=chans+1;
    end
    
    fitErrorThreshold = 1e-4;
    
    digitizerFrequencyMHz = lcaGet([rootPath,'digitizerFrequencyMHz']);
    numberSubBands = lcaGet([rootPath,'numberSubBands']);
    numberChannels = lcaGet([rootPath,'numberChannels']);
    sub_band = digitizerFrequencyMHz./(numberSubBands/2); % oversample by 2
    
    disp(['digitizerFrequencyMHz=',num2str(digitizerFrequencyMHz)]);
    disp(['numberSubBands=',num2str(numberSubBands)]);
    
    % faster, uses array writes
    pvRoot = [rootPath, 'CryoChannels:'];
    % at least for now, defaults are all zeros
    amplitudeScaleArray = zeros(1,numberChannels);
    centerFrequencyArray = zeros(1,numberChannels);
    feedbackEnableArray = zeros(1,numberChannels);
    etaPhaseArray = zeros(1,numberChannels);
    etaMagArray = zeros(1,numberChannels);
    
    % populate arrays
    for ii=chans
        frequency_mhz=etaIn.etaOut(ii).('F0'); % testing this CY
        % limit frequency to +/- sub-band/2
        if frequency_mhz > sub_band/2
            freq = sub_band/2;    
        elseif frequency_mhz < -sub_band/2
            freq = -sub_band/2;
        else
            freq = frequency_mhz;
        end
        centerFrequencyArray(ii)=freq;
%% CHECK THIS        
        %if etaIn.etaOut(ii).('error') > fitErrorThreshold
        if 0
            amplitudeScaleArray(ii)=0;
            feedbackEnableArray(ii)=0;
        else
            amplitudeScaleArray(ii)=etaIn.etaCfg.('Adrive');
            feedbackEnableArray(ii)=1;
        end
%%
        % phase, wrap to +/- 180
        phase = etaIn.etaOut(ii).('etaPhaseDeg');
        while( phase > 180 )
            phase = phase - 360;
        end
        while( phase < -180 )
            phase = phase + 360;
        end
        
        etaPhaseArray(ii)=phase;
        etaMagArray(ii)=etaIn.etaOut(ii).('etaScaled');
    end
    lcaPut( [pvRoot, 'centerFrequencyArray'], centerFrequencyArray );
    lcaPut( [pvRoot, 'amplitudeScaleArray'], amplitudeScaleArray );
    lcaPut( [pvRoot, 'feedbackEnableArray'], feedbackEnableArray );
    lcaPut( [pvRoot, 'etaPhaseArray'], etaPhaseArray );
    lcaPut( [pvRoot, 'etaMagArray'], etaMagArray );

    
    % slow, relies on single transation for each channel
    %% only loop over defined channels
    %for ii=chans
    %    configCryoChannel(rootPath, etaIn.etaOut(ii).('chan'), etaIn.etaOut(ii).('Foff'), etaIn.etaCfg.('Adrive'), 1, etaIn.etaOut(ii).('etaPhaseDeg'), etaIn.etaOut(ii).('etaScaled'));
    %end
end