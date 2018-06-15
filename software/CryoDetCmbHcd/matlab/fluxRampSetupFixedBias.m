%% see https://slacsmurf.slack.com/archives/C8ANUFAAU/p1524844499000354
function fluxRampSetupFixedBias(fractionFullScale)

if (fractionFullScale<0)||(fractionFullScale>1)
    error(sprintf('!!! fractionFullScale=%d must be >0 and <1 !!!',fractionFullScale));
end

root=getSMuRFenv('SMURF_EPICS_ROOT');
rootPath=strcat(root,':AMCc:FpgaTopLevel:AppTop:AppCore:'); 
rtmRootPath = strcat(rootPath,'RtmCryoDet:');
rtmSpiRootPath = strcat(rtmRootPath,'RtmSpiSr:');


LTC1668RawDacData = floor((2^16)*(1-fractionFullScale)/2);

lcaPut( [rtmSpiRootPath, 'ModeControl'],  num2str(1));
lcaPut( [rtmSpiRootPath, 'LTC1668RawDacData'],  num2str(LTC1668RawDacData));


end