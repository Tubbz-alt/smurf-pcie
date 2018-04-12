function lockedChannels=checkLock(chans)
    rootPath='mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:';
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

    [f,df,frs]=getData(rootPath,2^22);
    % only loop over defined channels
    numChannels=0
    numKilled=0
    numGood=0
    for ii=chans
        numChannels=numChannels+1;
        
        chan=etaIn.etaOut(ii).('chan');
        fchan=f(:,ii);
        % retrieve current channel configuration
        [centerFrequencyMHz, amplitudeScale, feedbackEnable, etaPhaseDegree, etaMagScaled] = getCryoChannelConfig(rootPath,chan);
        
        if amplitudeScale==0 && feedbackEnable==0
            % channel already disabled; do nothing
            continue;
        end
        
        disable=false;
        if amplitudeScale==0 && feedbackEnable==1
            % tone amplitude is zero but feedback loop is enabled for some
            % reason.  Shouldn't happen, but just in case.
            disp(sprintf('-> Disabling channel %d because amplitudeScale=0 but feedback is enabled.',chan));
            disable=true;
        end
        
        fchanspan=max(fchan)-min(fchan)
        %if ~disable && ( std(fchan)<0.01 || std(fchan)>0.2 )
        if ~disable && ( fchanspan<0.05 || fchanspan>0.2 )
            %nothing on this channel.  Disable.
            disp(sprintf('-> Disabling channel %d (%0.2f MHz) because rms of tracked frequency is zero.',chan,centerFrequencyMHz));
            disable=true;
        end
        
        if chan==3 || chan==4
            disp('found it');
        end
        
        if disable
            % disable channel by setting amplitudeScale and feedbackEnable
            % to zero.
            %function configCryoChannel( rootPath, channelNum, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
            configCryoChannel(rootPath,chan,centerFrequencyMHz, 0, 0, etaPhaseDegree, etaMagScaled);
            
            numKilled=numKilled+1;
        else
            numGood=numGood+1;
        end
    end
    
    disp(sprintf('numChannels=%d',numChannels));
    disp(sprintf('numKilled=%d',numKilled));
    disp(sprintf('numGood=%d (%0.1f%%)',numGood,100.*(numGood/numChannels)));
end