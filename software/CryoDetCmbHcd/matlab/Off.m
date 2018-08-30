function Off(band)
    %function allOff
    %turn off all channels
    if nargin <1 
        band = 2; % default number of reads per frequnecy setting
    end; 

    for i = 1:length(band)
        rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))];
        
        % Old way, by channel
        %for n=0:511
        %    [band, Freq, ampl] = getChannel(n);
        %    if ampl > 0
        %        display(['found channel ' num2str(n) ' set to amplitude ' num2str( ampl)])
        %        chanPVprefix = [rootPath, 'CryoChannels:CryoChannel[', num2str(n), ']:'];
        %        lcaPut( [chanPVprefix, 'amplitudeScale'], 0) ;
        %
        %    end
        %end
        
        % New way, turns everyone off efficiently
        pvRoot = [rootPath, 'CryoChannels:'];
        lcaPut( [pvRoot, 'setAmplitudeScales'], 0);
        lcaPut( [pvRoot, 'feedbackEnableArray'], zeros(1,512) );
    end

    fluxRampOnOff(0)