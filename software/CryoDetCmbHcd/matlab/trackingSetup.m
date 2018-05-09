% rough calibration of phi0 to fraction of the flux ramp fullscale
fluxRampFullScale_to_Phi0=4.540/0.7; % measured at 1kHz
resetRatekHz=1.000;
fractionFullScaleDesired=0.7;

lmsDelay   = 5;    % nominally match refPhaseDelay
lmsGain    = 5;    % incrases by power of 2, can also use etaMag to fine tune
lmsEnable1 = 1;    % 1st harmonic tracking
lmsEnable2 = 1;    % 2nd harmonic tracking
lmsEnable3 = 1;    % 3rd harmonic tracking
lmsRstDly  = 31;   % disable error term for 31 2.4MHz ticks after reset
lmsFreqHz  = fluxRampFullScale_to_Phi0*fractionFullScaleDesired*(resetRatekHz*10^3); % fundamental tracking frequency guess
lmsDly2    = 50;   % delay DDS counter resets, 307.2MHz ticks
lmsDlyFine = 0;

iqStreamEnable = 0; % stream IQ data from tracking loop
                    % ***currently channel not matching f df readout***
       
optimize=false;
                    
if optimize
    optFreqRange=(lmsFreqHz-40):5:(lmsFreqHz+40)
else
    optFreqRange=lmsFreqHz
end



root = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:';

lcaPut( [root, 'lmsDelay'],   lmsDelay   )
lcaPut( [root, 'lmsDlyFine'],   lmsDlyFine   )
lcaPut( [root, 'lmsGain'],    lmsGain    )
lcaPut( [root, 'lmsEnable1'], lmsEnable1 )
lcaPut( [root, 'lmsEnable2'], lmsEnable2 )
lcaPut( [root, 'lmsEnable3'], lmsEnable3 )
lcaPut( [root, 'lmsRstDly'],  lmsRstDly  )
lcaPut( [root, 'lmsFreqHz'],  lmsFreqHz  )

lcaPut( [root, 'iqStreamEnable'],  iqStreamEnable  )


%% Example freq tuning
%  sweep tracking fundamental frequency, plot results
%  should have better way to do this - maybe minimize RMS( df )
%
%

fluxRampSetup(resetRatekHz,fractionFullScaleDesired);
lcaPut( [root, 'singleChannelReadoutOpt2'], 1)
lcaPut( [root, 'readoutChannelSelect'], 0)
fluxRampOnOff(1)

%for freq = 2900*rampStep:20:3100*rampStep
for freq = optFreqRange
    lcaPut( [root, 'lmsFreqHz'], freq) 
    pause(0.1)
    quickDataSingleChannel
    figure;
    subplot(2,1,1); plot(f); title(['LMS freq: ', num2str(freq)]); xlim([0 10000/(resetRatekHz)])
    subplot(2,1,2); plot(df); title(['RMS error: ', num2str(std(df))]); xlim([0 10000/(resetRatekHz)])
end

lcaPut( [root, 'singleChannelReadoutOpt2'], 0) % return to multichannel state
%lcaPut( [root, 'lmsFreqHz'], 3020 * rampStep) % default here

% nominally 3025Hz/step size is working