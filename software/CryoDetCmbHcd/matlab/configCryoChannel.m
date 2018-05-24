% configCryoChannel( rootPath, channelNum, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
%    rootPath       - sysgen root path
%    channelNum     - cryo channel number (0...511)
%    frequency      - frequency within sub-band (MHz) (-digitizerFrequencyMHz/numberSubBands (MHz)...+digitizerFrequencyMHz/numberSubBands (MHz))
%    amplitude      - amplitdue 0...15  (15 full scale)
%    feedbackEnable - enable feedback
%    etaPhase       - feedback ETA phase (deg) (-180 180)
%    etaMag         - feedback ETA mag 
%


function configCryoChannel( baseNumber, channelNum, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
    cryoChannelsRootPath = [baseRootPath, 'CryoChannels:CryoChannel[', num2str(channelNum), ']:'];
    
    numberSubBands = lcaGet([baseRootPath,'numberSubBands']);
    band = lcaGet([baseRootPath,'digitizerFrequencyMHz']);
    sub_band = band./(numberSubBands/2); % oversample by 2
    
    % limit frequency to +/- sub-band/2
    if frequency_mhz > sub_band/2
        freq = sub_band/2;    
    elseif frequency_mhz < -sub_band/2
        freq = -sub_band/2;
    else
        freq = frequency_mhz;
    end
    
    lcaPut( [cryoChannelsRootPath, 'centerFrequencyMHz'], freq );
    
    % amp 0 - 15
    if amplitude > 15
        amp = 15;
    elseif amplitude < 0
        amp = 0;
    else
        amp = amplitude;
    end
    lcaPut( [cryoChannelsRootPath, 'amplitudeScale'], amp );
    
    
    lcaPut( [cryoChannelsRootPath, 'feedbackEnable'], feedbackEnable );
    
    % phase, wrap to +/- 180
    phase = etaPhase;
    while( phase > 180 )
        phase = phase - 360;
    end
    while( phase < -180 )
        phase = phase + 360;
    end
    
    lcaPut( [cryoChannelsRootPath, 'etaPhaseDegree'], phase );
    
    lcaPut( [cryoChannelsRootPath, 'etaMagScaled'], etaMag );
