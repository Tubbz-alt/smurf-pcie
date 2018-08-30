function fbOff(band)
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];

    numberChannels = lcaGet([rootPath,'numberChannels']);
    
    feedbackEnableArray = zeros(1,numberChannels);
    
    pvRoot = [rootPath, 'CryoChannels:'];

    lcaPut( [pvRoot, 'feedbackEnableArray'], feedbackEnableArray );
end