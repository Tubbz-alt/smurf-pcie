function channelsInSubBand=getChannelSubband(baseNumber,subBand)
    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
    numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
    numberChannels=lcaGet([baseRootPath,'numberChannels']);
    channelsPerSubBand=(numberChannels/numberSubBands);
    
    if (subBand+1)>numberSubBands || subBand<0
        error(sprintf('!!! subBand=%d (0-indexed) is either <1 or exceeds numberSubBands=%d !!!',(subBand),numberSubBands));
    end
    
    channelOrder=getChannelOrder();    
    channelsInSubBand=channelOrder(subBand*channelsPerSubBand+1:subBand*channelsPerSubBand+channelsPerSubBand);