function fluxRampOnOff(frEnable)
%% Simple function for turning the flux ramp on or off.  Default is to switch

root=getSMuRFenv('SMURF_EPICS_ROOT');
rootPath=strcat(root,':AMCc:FpgaTopLevel:AppTop:AppCore:'); 
rtmRootPath = strcat(rootPath,'RtmCryoDet:');
rtmSpiRootPath = strcat(rtmRootPath,'RtmSpiSr:');

% read current state
%currentFRState = lcaGet( [rtmSpiRootPath, 'Cfg_Reg_Ena Bit'] );

%if nargin <1
%    % set to inverse
%    frEnable=~currentFRState;
%end

%if currentFRState == frEnable
%    return
%end

lcaPut( [rtmSpiRootPath, 'CfgRegEnaBit'],  num2str(frEnable)); %switch FR on/off
    
% wait 0.11 secound before handing back 
pause(0.11);

end