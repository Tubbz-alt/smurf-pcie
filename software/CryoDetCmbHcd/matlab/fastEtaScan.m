function [resp, f] = fastEtaScan(band, freqs, Nread, dwell, Adrive, baseNumber)
% Faster version of etaScan based on PVs Mitch added to pyrogue
% Can't implement until we've worked some bugs out of new pyrogue...
% SWH 21Mar2018
  
if nargin <3 
    Nread = 2; % default number of reads per frequnecy setting
end; 

if nargin <4 
    dwell = 0.001; %dwell time default is 1 ms
end; 

if nargin <5 
    Adrive = 10;
end; 

if nargin <6 
    baseNumber = 0;
end; 

f=repelem(freqs,Nread);
%
%if length(repfreqs)>1
%    error(sprintf('!!! Error in etaScan2: asked for %d freqs in scan; must be less than 1000',length(repfreqs)))
%end
%%

baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
numberChannels=lcaGet([baseRootPath,'numberChannels']);

%subchan = (numberChannels/numberSubBands)*band;
channelOrder=getChannelOrder;
channelsPerSubBand=(numberChannels/numberSubBands);
firstChannelInEachSubBand=channelOrder(1:channelsPerSubBand:end);
subchan=firstChannelInEachSubBand(band+1);

cryoChannelsRootPath = [baseRootPath,'CryoChannels:'];
lcaPut([cryoChannelsRootPath,'etaScanFreqs'],f);
lcaPut([cryoChannelsRootPath,'etaScanAmplitude'],Adrive);
lcaPut([cryoChannelsRootPath,'etaScanChannel'],subchan);
lcaPut([cryoChannelsRootPath,'etaScanDwell'],0);

% results PVs
resultsRealPV=[cryoChannelsRootPath,'etaScanResultsReal'];
resultsImagPV=[cryoChannelsRootPath,'etaScanResultsImag'];
pvs{1,1} = resultsRealPV;
pvs{2,1} = resultsImagPV;

% run the etaScan
lcaPutNoWait([cryoChannelsRootPath,'runEtaScan'],1);

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
configCryoChannel( baseNumber, subchan, freqs(ceil(end/2)), Adrive, 0, 0, 0 ) ;

end
% end of function etaScan2
