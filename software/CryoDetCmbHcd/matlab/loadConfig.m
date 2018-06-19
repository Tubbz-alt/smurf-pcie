function statusOK = loadConfig(fileName, ampl, FBen, exceptions)
%function statusOK = loadConfig(fileName, ample, FBen)
% loads a .mat file containing arrays
%resonators
%chan
%offset
%etaPhaseDeg
%etaScaled

% if defined, lines are set to amplitude = ampl
% if defined, feedback enable is set to the state of FBen

%if exceptions defined, skip these channel numbers in the reconfiguration

rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];

if nargin < 2
    ampl=12
end

if nargin < 3
    FBen = 1
end

if nargin < 4
    exceptions = [];
end

load(fileName)
for ii=1:length(resonators)
    if isempty(find(ii == exceptions))
        configCryoChannel(rootPath, chan(ii), offset(ii), ampl, FBen, etaPhaseDeg(ii), etaScaled(ii));
    end
end
    
    

