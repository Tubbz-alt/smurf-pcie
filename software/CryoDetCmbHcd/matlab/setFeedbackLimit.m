% setFeedbackLimit( rootPath, limit_mhz )

function setFeedbackLimit( rootPath, limit_mhz )
    
    n_channels = 32;
    band = 614.4;
    sub_band = band./(n_channels/2); % oversample by 2
    
    % limit frequency to +/- sub-band/2
    if limit_mhz > sub_band/2
        limit = sub_band/2;
    else
        limit = limit_mhz;
    end
    
    limit_scale = floor((limit./(sub_band/2))*2^16);
    lcaPut( [rootPath, 'feedbackLimit'], limit_scale );
    
    