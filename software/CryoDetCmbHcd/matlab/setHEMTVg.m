function hemtVg(bit,doCfg)

if nargin <2
    % set to inverse
    doCfg=false;
end

if bit<0
end
if bit>524287
    bit=524287
end

rtmSpiMaxRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:RtmSpiMax:'];

%% set RtmCryoDet
%lcaPut( [rtmRootPath, 'LowCycle'],  num2str(2)); 

if doCfg
    lcaPut([rtmSpiMaxRootPath, 'HemtBiasDacCtrlRegCh[33]'],num2str(2));
end

lcaPut([rtmSpiMaxRootPath, 'HemtBiasDacDataRegCh[33]'],num2str(bit));

% from fit to Vg versus bits on 4/19/2018 by SWH
a=1.92751e-06;
b=-0.000165972;
Vg=a*bit+b;
disp(sprintf('-> Set Vg=%0.3f V',Vg));

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
