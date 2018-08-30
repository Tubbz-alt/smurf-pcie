%% see https://slacsmurf.slack.com/archives/C8ANUFAAU/p1524844499000354
function [frCfg,fractionFullScale] =fluxRampSetup(desiredResetRatekHz, desiredFractionFullScale, acceptableDifferenceFromDesiredFractionFullScale, doRead)

stepSizesToTry=1:10;

if nargin <2
    desiredFractionFullScale=0.7;
end

if nargin <3
    acceptableDifferenceFromDesiredFractionFullScale=0.1;
end

if nargin <4
    % set to inverse
    doRead=false;
end

root=getSMuRFenv('SMURF_EPICS_ROOT');
rootPath=strcat(root,':AMCc:FpgaTopLevel:AppTop:AppCore:'); 
rtmRootPath = strcat(rootPath,'RtmCryoDet:');
rtmSpiRootPath = strcat(rtmRootPath,'RtmSpiSr:');

% before doing anything, disable the flux ramp
lcaPut( [rtmSpiRootPath, 'CfgRegEnaBit'],  num2str(0));

% Need to scale flux ramp reset with carrier freq - NOT YET IMPLEMENTED
% rampStep = 1;
%
% Setup the flux ramp

%% for some reason right now, must set EnableRampTrigger last; JIRA ticket has been submitted to fix.

% as of 4/27/18 digitizerFrequencyMHz=614.4 and dspClockFrequencyMHz=307.2
% should be able to pull from PV, but too much rounding error.
%digitizerFrequencyMHz=lcaGet([rootPath,'SysgenCryo:Base[0]:','digitizerFrequencyMHz']);
disp('!! digitizerFrequencyMHz=614.4 hard-coded due to PyRogue issue');
digitizerFrequencyMHz=614.4;
dspClockFrequencyMHz=digitizerFrequencyMHz/2;

% currently, only supporting reset rates that are exact multiples of 1 kHz,
% in the hopes that this will synchronize the RTM clock with the channel
% MUX.
%RampMaxCnt=307199; % 1kHz, don't change or might get out of sync with other clocks
desiredRampMaxCnt = ((dspClockFrequencyMHz*10^3)/(desiredResetRatekHz)) - 1;

RampMaxCnt=floor(desiredRampMaxCnt);
if ~(floor(desiredRampMaxCnt)==desiredRampMaxCnt)
    error([sprintf('!! Warning; the desired reset rate of %0.3f kHz does not correspond to an integer RampMaxCnt ;\n',desiredResetRatekHz),sprintf('!!          will use floor of computed RampMaxCnt but flux ramp may be out of sync with\n'),sprintf('!!          channels.\n')])
end

resetRate        = (dspClockFrequencyMHz*10^6)/(RampMaxCnt + 1);

HighCycle = 5;
LowCycle = 5;
rtmClock = (dspClockFrequencyMHz*10^6)/(HighCycle + LowCycle + 2);
trialRTMClock = rtmClock;

fullScaleRate         = desiredFractionFullScale*resetRate;
desFastSlowStepSize   = (fullScaleRate*2^20)/rtmClock
trialFastSlowStepSize = round(desFastSlowStepSize)
FastSlowStepSize      = trialFastSlowStepSize;


trialFullScaleRate    = trialFastSlowStepSize*trialRTMClock / (2^20);
trialResetRate        = (dspClockFrequencyMHz*10^6)/(RampMaxCnt + 1);
trialFractionFullScale = trialFullScaleRate/trialResetRate;
fractionFullScale      = trialFractionFullScale;
differenceFromDesiredFractionFullScale=abs(trialFractionFullScale-desiredFractionFullScale);



            disp(sprintf('\tpercentFullScale = %0.1f%%',100.*fractionFullScale));



% set RtmCryoDet.  Reset rate needs to be in sync with other clocks, 
% that's controlled by RampMaxCnt; don't change that.  Adjust Nphi0/ramp
% by changing the RTM clock (via LowCycle and HighCyle) and
% FastSlowStepSize.
%assumes HighCycle=LowCycle

% differenceFromDesiredFractionFullScale=Inf;
% fractionFullScale=Inf;
% for trialFastSlowStepSize=stepSizesToTry
%     desiredRTMClockFastSlowStepSizeProduct=desiredFractionFullScale*resetRate*2^16;
%     trialRTMClock=desiredRTMClockFastSlowStepSizeProduct/trialFastSlowStepSize;
%     trialCycles=floor((((dspClockFrequencyMHz*10^6)/trialRTMClock) - 2)/2);
%     %disp(sprintf('-> FastSlowStepSize=%g\ttrialCycles=%g',trialFastSlowStepSize,trialCycles));
%     
%     trialLowCycle=trialCycles;
%     trialHighCycle=trialCycles;    
%     trialRTMClock         = (dspClockFrequencyMHz*10^6)/(trialHighCycle + trialLowCycle + 2);
%     trialFullScaleRate    = trialFastSlowStepSize*trialRTMClock / (2^16);
%     trialResetRate        = (dspClockFrequencyMHz*10^6)/(RampMaxCnt + 1);
%     trialFractionFullScale = trialFullScaleRate/trialResetRate;
% 
%     if trialLowCycle>1
%         if abs(trialFractionFullScale-desiredFractionFullScale)<differenceFromDesiredFractionFullScale
%             FastSlowStepSize=trialFastSlowStepSize;
%             LowCycle=trialCycles;
%             HighCycle=trialCycles;   
%             rtmClock = (dspClockFrequencyMHz*10^6)/(HighCycle + LowCycle + 2);
%             fullScaleRate    = FastSlowStepSize*rtmClock / (2^16);
%             resetRate        = (dspClockFrequencyMHz*10^6)/(RampMaxCnt + 1);
%             fractionFullScale = fullScaleRate/resetRate;
%             disp(sprintf('\tpercentFullScale = %0.1f%%',100.*fractionFullScale));
%     
%             differenceFromDesiredFractionFullScale=abs(trialFractionFullScale-desiredFractionFullScale);
%         end
%     end
% end

if ~(differenceFromDesiredFractionFullScale<acceptableDifferenceFromDesiredFractionFullScale)
    error(sprintf('!!! Aborting; too far from desired fractional full scale, fractionFullScale=%0.2f%%.',100.*fractionFullScale));
end
            

% John says; "If the RTM system clock is set too low (say less than 2MHz), its likely that things might freeze 
% because the SPI clock runs at 1MHz. You might need to power cycle to the system to bring it back. It would be 
% nice to have an "reset RTM" bit somewhere, but right now the reset is fed by the FPGA MMCM "clock good" signal 
% so it will only be reset during power up initialization.
if rtmClock<2*10^6
    error(sprintf('!!! Aborting; RTM clock rate = %0.2fMHz too low (SPI clock runs at 1MHz).',rtmClock/(10^6)));
end

% no DC offset
FastSlowRstValue = floor((2^20)*(1-fractionFullScale)/2);

disp(sprintf('LowCycle = %d',LowCycle));
disp(sprintf('HighCycle = %d',HighCycle));
disp(sprintf('FastSlowStepSize = %d',FastSlowStepSize));
disp(sprintf('FastSlowRstValue = %d',FastSlowRstValue));
disp(sprintf('RampMaxCnt = %d',RampMaxCnt));

disp(sprintf('rtmClock = %0.3f MHz',rtmClock/1.e6));
disp(sprintf('fullScaleRate = %0.3f Hz',fullScaleRate));
disp(sprintf('resetRate = %0.3f kHz',resetRate/1.e3));
disp(sprintf('percentFullScale = %0.1f%%',100.*fractionFullScale));

%RTM clock = (307.2MHz)/(HighCycle + 1 + LowCycle + 1)
%    HighCycle, LowCycle >= 2
%    Examples:
%        HighCycle = LowCycle = 2 -> 51.2 MHz clock
%        HighCycle = LowCycle = 4 ->  9.03MHz clock

lcaPut( [rtmRootPath, 'LowCycle'],  num2str(LowCycle)); 
lcaPut( [rtmRootPath, 'HighCycle'],  num2str(HighCycle)); 

%?
lcaPut( [rtmRootPath, 'KRelay'],  num2str(3)); 

%lcaPut( [rtmRootPath, 'RampMaxCnt'], num2str(0.895*round((307200*1.5)/(rampStep))-1)); %0x4b000
% so that RTM clock is always in sync with the other clocks, set this to
% 1kHz.
%
%Counter reset rate = (307.2MHz)/(RampMaxCnt + 1)
%    Example:
%        RampMaxCnt = 307199 -> 1kHz reset rate
%
%
lcaPut( [rtmRootPath, 'RampMaxCnt'], num2str(RampMaxCnt));
lcaPut( [rtmRootPath, 'SelectRamp'], num2str(1));
lcaPut( [rtmRootPath, 'RampStartMode'],  num2str(0)); 
lcaPut( [rtmRootPath, 'PulseWidth'],  num2str(400)); % 0x200f
lcaPut( [rtmRootPath, 'DebounceWidth'],  num2str(255)); % 0xff
    
%% set C_RtmSpiSr
lcaPut( [rtmSpiRootPath, 'RampSlope'],  num2str(0));
lcaPut( [rtmSpiRootPath, 'ModeControl'],  num2str(0));
%lcaPut( [rtmSpiRootPath, 'FastSlowStepSize'],  num2str(FastSlowStepSize));
%% new RTM
lcaPut( [rtmSpiRootPath, 'FastSlowStepSize'],  num2str(FastSlowStepSize));

%
%FastSlowRstValue = 2^16 bit unsigned, offset binary
%    Example:
%        0     -> negative full scale
%        32767 -> 0
%        65535 -> postive full scale
%
%lcaPut( [rtmSpiRootPath, 'FastSlowRstValue'],  num2str(FastSlowRstValue));
%% new RTM
lcaPut( [rtmSpiRootPath, 'FastSlowRstValue'],  num2str(FastSlowRstValue));

%% Set EnableRampTrigger last; there's a bug in the firmware right now
lcaPut( [rtmRootPath, 'EnableRampTrigger'],  num2str(1));

% Done setting up the flux ramp
%

%
% read & return
frCfg={};
frCfg.C_RtmSpiSr={};

%% DUE TO LOGIC CONSTRAINTS, CAN'T ACTUALLY READ BACK ALL REGISTERS RIGHT NOW...
%if doRead
%    %% read current state
%    % RtmCryoDet
%    rtmRootPath = [root,':AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:'];
%    configvars={'LowCycle','HighCycle','KRelay','RampMaxCnt','SelectRamp','EnableRamp','RampStartMode','PulseWidth','DebounceWidth'};
%    for cfgvar=configvars
%        value=lcaGet([rtmRootPath, cfgvar{1}]);
%        frCfg.(cfgvar{1})=value;
%    end
%    
%    %% C_RtmSpiSr
%    rtmSpiRootPath = [root,':AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:C_RtmSpiSr:'];
%    configvars={'AD5790_NOP_Reg','AD5790_Data_Reg','AD5790_Ctrl_Reg','AD5790_ClrCode_Reg','Config_Reg', ...
%                'Cfg_Reg_Ena Bit','Ramp Slope','Mode Control'}; %,'Fast Step Size','Fast Rst Value'}; %% not reading right now 
%    for cfgvar=configvars
%        value=lcaGet([rtmSpiRootPath, cfgvar{1}]);
%        disp([rtmSpiRootPath, cfgvar{1}]);
%        frCfg.C_RtmSpiSr.(strrep(cfgvar{1},' ','_'))=value;
%    end
%end
% done with read

end