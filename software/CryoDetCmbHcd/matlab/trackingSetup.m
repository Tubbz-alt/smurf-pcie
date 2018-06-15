function freq = trackingSetup(band, channel2check)
    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)]
    numberChannels = lcaGet([baseRootPath,'numberChannels']);
    
    if nargin<2
        channel2check=0;
    end
    
    if (channel2check<0 || ~(channel2check<numberChannels))
        error(sprintf('!!! channel2check=%d is <0 or exceeds numberChannels=%d !!!',channel2check,numberChannels));
    end
    
    m = 1;
    n = 1;

    resetRatekHz=4.0*m;
    fractionFullScaleDesired=0.50*n;
    
    % rough calibration of phi0 to fraction of the flux ramp fullscale
    %% 14dB input atten, directly from RTM monitor port
    fluxRampFullScale_to_Phi0=4.565/0.7; % measured at 1kHz
    %% 9dB input atten, RTM monitor port -> NIST isolation amp -> fridge
    %fluxRampFullScale_to_Phi0=4.410/0.7; % measured at 1kHz
    
    lmsDelay   = 7;    % nominally match refPhaseDelay
    lmsGain    = 8;    % incrases by power of 2, can also use etaMag to fine tune
    lmsEnable1 = 1;    % 1st harmonic tracking
    lmsEnable2 = 1;    % 2nd harmonic tracking
    lmsEnable3 = 1;    % 3rd harmonic tracking
    lmsRstDly  = 31;   % disable error term for 31 2.4MHz ticks after reset
    lmsFreqHz  = fluxRampFullScale_to_Phi0*fractionFullScaleDesired*(resetRatekHz*10^3); % fundamental tracking frequency guess
    lmsDly2    = 255;   % delay DDS counter resets, 307.2MHz ticks
    lmsDlyFine = 0;
    iqStreamEnable = 0; % stream IQ data from tracking loop
                      
    
    optimize=true;
    if band == 2
        if m == 3
            lmsFreqHz = 43000*n;
            lmsEnable3 = 0;    % 3rd harmonic tracking
        elseif m == 2
            lmsFreqHz = 28230*n;
            lmsEnable3 = 0;    % 3rd harmonic tracking
        else
            lmsFreqHz=round(13782*m*n);
            %lmsFreqHz = 12200;
        end
    else
        if m == 3
           lmsFreqHz = 40608.57*n;
           lmsEnable3 = 0;    % 3rd harmonic tracking
        elseif m == 2
            lmsFreqHz = 26655*n;
            lmsEnable3 = 0;    % 3rd harmonic tracking
        else   
           lmsFreqHz=13052.8571*m*n;
           %lmsFreqHz = 12200;
        end
    end
    %lmsFreqHz = 40500;
    %lmsFreqHz=lmsFreqHz+40;
    %lmsFreqHz=4846.0714;
    
    %if resetRatekHz>=5.000
    %    lmsDelay   = 6;
    %    lmsGain    = 4; 
    %end
    %
    %if resetRatekHz==5.000
    %    lmsFreqHz = 22825;
    %end
    %if resetRatekHz==6.000
    %    lmsFreqHz = 27470;
    %end
    %if resetRatekHz==3.000
    %    lmsFreqHz = 13715;
    %end
    
    %lmsFreqHz=10350;
    if optimize
        optFreqRange=(lmsFreqHz-250):25:(lmsFreqHz+250)
    else
        optFreqRange=lmsFreqHz
    end

    root = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];

    lcaPut( [root, 'lmsDelay'],   lmsDelay   )
    lcaPut( [root, 'lmsDlyFine'], lmsDlyFine )
    lcaPut( [root, 'lmsGain'],    lmsGain    )
    lcaPut( [root, 'lmsEnable1'], lmsEnable1 )
    lcaPut( [root, 'lmsEnable2'], lmsEnable2 )
    lcaPut( [root, 'lmsEnable3'], lmsEnable3 )
    lcaPut( [root, 'lmsRstDly'],  lmsRstDly  )
    lcaPut( [root, 'lmsFreqHz'],  lmsFreqHz  )
    lcaPut( [root, 'lmsDelay2'],  lmsDly2    )
    
    lcaPut( [root, 'iqStreamEnable'],  iqStreamEnable  )
    
    
    %% Example freq tuning
    %  sweep tracking fundamental frequency, plot results
    %  should have better way to do this - maybe minimize RMS( df )
    %
    %
    
    [~, fracFullScale] = fluxRampSetup(resetRatekHz,fractionFullScaleDesired);
    
    nn = fracFullScale./0.502;
    if band == 2
        if m == 3
            lmsFreqHz = 43000*nn;
        elseif m == 2
            lmsFreqHz = 28230*nn;
        else
            lmsFreqHz=13852*m*nn;
        end
    else
        if m == 3
           lmsFreqHz = 40608.57*nn;
        elseif m == 2
            lmsFreqHz = 26655*nn;
        else   
           lmsFreqHz=13052.8571*m*nn;
        end
    end
    %optFreqRange = lmsFreqHz;
    
    lcaPut( [root, 'lmsFreqHz'],  lmsFreqHz  )
    disp( num2str(lmsFreqHz) )
    
    lcaPut( [root, 'singleChannelReadoutOpt2'], 1)
    lcaPut( [root, 'readoutChannelSelect'], channel2check)
    fluxRampOnOff(1)
    
    %for freq = 2900*rampStep:20:3100*rampStep
    for freq = optFreqRange
        lcaPut( [root, 'lmsFreqHz'], freq) 
        pause(0.1)
        [f,df,frs]=quickDataSingleChannel(band);
        figure;
        subplot(2,1,1); plot(f); title(['LMS freq: ', num2str(freq)]); xlim([0 10000/(resetRatekHz)])
        subplot(2,1,2); plot(df); title(['RMS error: ', num2str(std(df))]); xlim([0 10000/(resetRatekHz)])
        
        subband=getChannelSubBand(band,channel2check);
        channelsInSubBand=getChannelsInSubBand(band,subband);
        title(sprintf('band %d, sub-band %d, channel %d (%d/%d) stdx1000=%0.3f',band,subband,channel2check,find(channelsInSubBand==channel2check),length(channelsInSubBand),std(df*1000)));
    end
    
    lcaPut( [root, 'singleChannelReadoutOpt2'], 0) % return to multichannel state
    lcaPut( [root, 'iqStreamEnable'],  1  ) % hand off streaming I/Q
    %lcaPut( [root, 'lmsFreqHz'], 3020 * rampStep) % default here
    
    % nominally 3025Hz/step size is working