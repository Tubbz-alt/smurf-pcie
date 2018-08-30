% [data] = setTESBias( DACn, val, doCfg )
%   DACn  - DAC number 1...32
%   val   - -10...+10 volts
%   doCfg - DAC configuration enable

function setTESBias(DACn,val,doCfg)

if nargin < 3
    % set to inverse
    doCfg=false;
end

rtmSpiMaxRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:RtmSpiMax:'];

if doCfg
    lcaPut([rtmSpiMaxRootPath, sprintf('TesBiasDacCtrlRegCh[%d]',DACn)],num2str(2));
end

% DAC is signed 20 bit number 2^19-1...-2^19
bits = round(val*2^19/10);

% saturate
if bits > 2^19-1
    bits = 2^19-1;
elseif val < -2^19
    bits = -2^19;
end

lcaPut([rtmSpiMaxRootPath, sprintf('TesBiasDacDataRegCh[%d]', DACn)], bits);


end
