function setFeedbackLimitkHz(band,desiredFeedbackLimitkHz)
    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];
    digitizerFrequencyMHz = lcaGet([baseRootPath,'digitizerFrequencyMHz']);
    bandCenterMHz = lcaGet([baseRootPath,'bandCenterMHz']);
    numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
    
    subBandWidthMHz=2*digitizerFrequencyMHz/numberSubBands;
    
    
    desiredFeedbackLimitMHz=desiredFeedbackLimitkHz/1000.;
    % limit frequency to +/- sub-band/2
    if desiredFeedbackLimitMHz > subBandWidthMHz/2
        desiredFeedbackLimitMHz = subBandWidthMHz/2;
    else
        %% do nothing
    end
    
    desiredFeedbackLimitDec=floor(desiredFeedbackLimitMHz/(subBandWidthMHz/2^16));
    desiredFeedbackLimitHex=dec2hex(desiredFeedbackLimitDec);

    %disp(sprintf('desiredFeedbackLimitDec=%d',desiredFeedbackLimitDec));
    %disp(sprintf('desiredFeedbackLimitHex=0x%s',desiredFeedbackLimitHex));
    
    lcaPut([baseRootPath,'feedbackLimit'],desiredFeedbackLimitDec);