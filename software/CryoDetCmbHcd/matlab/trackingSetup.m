lmsDelay   = 5;    % nominally match refPhaseDelay
lmsGain    = 5;    % incrases by power of 2, can also use etaMag to fine tune
lmsEnable1 = 1;    % 1st harmonic tracking
lmsEnable2 = 1;    % 2nd harmonic tracking
lmsEnable3 = 1;    % 3rd harmonic tracking
lmsRstDly  = 31;   % disable error term for 31 2.4MHz ticks after reset
lmsFreqHz  = 3025; % fundamental tracking frequency
lmsDly2    = 50;   % delay DDS counter resets, 307.2MHz ticks

iqStreamEnable = 0; % stream IQ data from tracking loop
                    % ***currently channel not matching f df readout***


root = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:';

lcaPut( [root, 'lmsDelay'],   lmsDelay   )
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
rampStep= 7 % multiplier for flux ramp rate
fluxRampSetup(rampStep)
lcaPut( [root, 'singleChannelReadoutOpt2'], 1)
lcaPut( [root, 'readoutChannelSelect'], 1)
fluxRampOnOff(1)

%for freq = 2900*rampStep:20:3100*rampStep
for freq = (3020*rampStep-50):10:(3020*rampStep+50)
   lcaPut( [root, 'lmsFreqHz'], freq) 
   pause(0.1)
   quickDataSingleChannel
   figure;
   subplot(2,1,1); plot(f); title(['LMS freq: ', num2str(freq)]); xlim([0 10000/rampStep])
   subplot(2,1,2); plot(df); title(['RMS error: ', num2str(std(df))]); xlim([0 10000/rampStep])
end

lcaPut( [root, 'singleChannelReadoutOpt2'], 0) % return to multichannel state
lcaPut( [root, 'lmsFreqHz'], 3020 * rampStep) % default here

% nominally 3025Hz/step size is working