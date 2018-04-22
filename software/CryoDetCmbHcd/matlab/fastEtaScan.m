function [resp, f] = fastEtaScan(band, freqs, Nread, dwell, Adrive)
% Faster version of etaScan based on PVs Mitch added to pyrogue
% Can't implement until we've worked some bugs out of new pyrogue...
% SWH 21Mar2018

rootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:CryoChannels:';

if nargin <3 
    Nread = 2; % default number of reads per frequnecy setting
end; 

if nargin <4 
    dwell = 0.001; %dwell time default is 1 ms
end; 

f=repelem(freqs,Nread);
%
%if length(repfreqs)>1
%    error(sprintf('!!! Error in etaScan2: asked for %d freqs in scan; must be less than 1000',length(repfreqs)))
%end
%%

subchan = 16*band;
lcaPut([rootPath,'etaScanFreqs'],f);
lcaPut([rootPath,'etaScanAmplitude'],Adrive);
lcaPut([rootPath,'etaScanChannel'],subchan);
lcaPut([rootPath,'etaScanDwell'],0);

% results PVs
resultsRealPV=[rootPath,'etaScanResultsReal'];
resultsImagPV=[rootPath,'etaScanResultsImag'];
pvs{1,1} = resultsRealPV;
pvs{2,1} = resultsImagPV;

% run the etaScan
lcaPutNoWait([rootPath,'runEtaScan'],1);

% set monitors on result PVs
lcaSetMonitor(pvs);

% wait for PVs to fill up
try lcaNewMonitorWait(pvs)
    results = lcaGet(pvs,length(f));
catch errs
    fprintf(1,'The identifier was:\n%s',errs.identifier);
    fprintf(1,'There was an error! The message was:\n%s',errs.message);
end

% Clear the monitors
lcaClear( pvs );
%% ... Done waiting for results

I=results(1,:);
Q=results(2,:);

if I >= 2^23
   I  = I-2^24;   %treat as signed 24 bit
end

if Q >= 2^23
   Q  = Q-2^24;   %treat as signed 24 bit
end

I = I/2^23;
Q = Q/2^23;

resp = I + 1i*Q;    %form complex response

Adrive = 0; % turn channel OFF
rootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:';
configCryoChannel( rootPath, subchan, freqs(ceil(end/2)), Adrive, 0, 0, 0 ) ;

end
% end of function etaScan2