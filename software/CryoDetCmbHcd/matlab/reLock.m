function reLock(chans)
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

    % only loop over defined channels
    for ii=chans
        configCryoChannel(rootPath, etaIn.etaOut(ii).('chan'), etaIn.etaOut(ii).('Foff'), etaIn.etaCfg.('Adrive'), 1, etaIn.etaOut(ii).('etaPhaseDeg'), etaIn.etaOut(ii).('etaScaled'));
    end
end