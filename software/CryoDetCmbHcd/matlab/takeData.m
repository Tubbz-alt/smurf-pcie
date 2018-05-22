function filename=takeData(Npts,rootPath)
    if nargin < 1
        Npts=2^25;
    end

    if nargin < 2
        rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
    end
    
    % check if we're in single channel mode; if we are get the channel
    %single = lcaGet([chanPVprefix, 'frequencyError']);
    %fileName='Ch64_250HzFR_swh_20171222.dat',takeDebugData(rootPath, fileName, 2^25);

    % are we in single channel readout mode, and if so, on what channel?
    singleChannelReadoutOpt2 = lcaGet([rootPath 'singleChannelReadoutOpt2']);
    singleChannelReadout = lcaGet([rootPath 'singleChannelReadout']);
    readoutChannelSelect = lcaGet([rootPath 'readoutChannelSelect']);

    ctime=ctimeForFile();
    filename=num2str(ctime);
    
    % add channel suffix for single channel data
    if singleChannelReadoutOpt2==1 || singleChannelReadout==1
        filename=[filename '_Ch' num2str(readoutChannelSelect)]
    end
    
    % add .dat suffix
    datadir=dataDirFromCtime(ctime);
    configfile=fullfile(datadir,[filename '.mat']);
    filename=fullfile(datadir,[filename '.dat']);
    disp(['filename=' filename]);
    disp(['configfile=' configfile]);
    
    writeRunFile(rootPath,configfile);
    
    % take data!
    disp('-> Jesd statusValidCnts before taking data');
    dumpJesdStatusValidCnts();
    takeDebugData(rootPath,filename,Npts);
    disp('-> Jesd statusValidCnts after taking data');
    dumpJesdStatusValidCnts();
