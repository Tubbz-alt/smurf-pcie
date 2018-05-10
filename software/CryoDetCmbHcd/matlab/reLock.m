function reLock(chans)
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
    [status,cmdout]=system('readlink /data/cpu-b000-hp01/cryo_data/data2/current_eta');
    etaIn=load(deblank(cmdout));
    
    if nargin < 1
        % index of channel in etaOut array is +1 the channel
        chans=find(~cellfun(@isempty,{etaIn.etaOut.chan}));
    else
        % the index of a channel in the etaOut struct is +1 the channel
        % number because matlab doesn't zero index
        chans=chans+1;
    end
    
    digitizerFrequencyMHz = lcaGet([rootPath,'digitizerFrequencyMHz']);
    numberSubBands = lcaGet([rootPath,'numberSubBands']);
    sub_band = digitizerFrequencyMHz./(numberSubBands/2); % oversample by 2
    
    disp(['digitizerFrequencyMHz=',num2str(digitizerFrequencyMHz)]);
    disp(['numberSubBands=',num2str(numberSubBands)]);
    
    % faster, uses array writes
    pvRoot = [rootPath, 'CryoChannels:'];
    % at least for now, defaults are all zeros
    nArray=512;
    amplitudeScaleArray = zeros(1,nArray);
    centerFrequencyArray = zeros(1,nArray);
    feedbackEnableArray = zeros(1,nArray);
    etaPhaseArray = zeros(1,nArray);
    etaMagArray = zeros(1,nArray);
    
    % populate arrays
    for ii=chans
        frequency_mhz=etaIn.etaOut(ii).('Foff');
        % limit frequency to +/- sub-band/2
        if frequency_mhz > sub_band/2
            freq = sub_band/2;    
        elseif frequency_mhz < -sub_band/2
            freq = -sub_band/2;
        else
            freq = frequency_mhz;
        end
        centerFrequencyArray(ii)=freq;
        
        amplitudeScaleArray(ii)=etaIn.etaCfg.('Adrive');
        feedbackEnableArray(ii)=1;
        
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