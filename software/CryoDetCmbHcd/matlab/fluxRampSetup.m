function frCfg=fluxRampSetup(rampStep, doRead)

if nargin<1
    rampStep=1;
end

if nargin <2
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

%% set RtmCryoDet
%RTM clock = 307.2MHz/(HighCycle + 1 + LowCycle + 1)0x2 = 51.2MHz RTM clock
%0x10 = 9.03MHz clock
lcaPut( [rtmRootPath, 'LowCycle'],  num2str(4)); 
lcaPut( [rtmRootPath, 'HighCycle'],  num2str(4)); 
lcaPut( [rtmRootPath, 'KRelay'],  num2str(3)); 
lcaPut( [rtmRootPath, 'RampMaxCnt'], num2str(0.895*round((307200*1.5)/(rampStep))-1)); %0x4b000
lcaPut( [rtmRootPath, 'SelectRamp'], num2str(1));
lcaPut( [rtmRootPath, 'RampStartMode'],  num2str(0)); 
lcaPut( [rtmRootPath, 'PulseWidth'],  num2str(400)); % 0x200f
lcaPut( [rtmRootPath, 'DebounceWidth'],  num2str(255)); % 0xff
    
%% set C_RtmSpiSr
lcaPut( [rtmSpiRootPath, 'RampSlope'],  num2str(0));
lcaPut( [rtmSpiRootPath, 'ModeControl'],  num2str(0));
lcaPut( [rtmSpiRootPath, 'FastSlowStepSize'],  num2str(rampStep));
lcaPut( [rtmSpiRootPath, 'FastSlowRstValue'],  num2str(20479));
%lcaPut( [rtmSpiRootPath, 'Fast/Slow Rst Value'],  num2str(13184));

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
%    rtmRootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:';
%    configvars={'LowCycle','HighCycle','KRelay','RampMaxCnt','SelectRamp','EnableRamp','RampStartMode','PulseWidth','DebounceWidth'};
%    for cfgvar=configvars
%        value=lcaGet([rtmRootPath, cfgvar{1}]);
%        frCfg.(cfgvar{1})=value;
%    end
%    
%    %% C_RtmSpiSr
%    rtmSpiRootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:C_RtmSpiSr:';
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