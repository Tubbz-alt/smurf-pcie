function subBand=getChannelSubband(baseNumber,channel)
    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
    numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
    numberChannels=lcaGet([baseRootPath,'numberChannels']);
    channelsPerSubBand=(numberChannels/numberSubBands);
    
    if (channel+1)>numberChannels || channel<0
        error(sprintf('!!! channel=%d (0-indexed) is either <1 or exceeds numberChannels=%d !!!',(channel),numberChannels));
    end
    
    channelOrder=getChannelOrder();
    chIdx=find(channelOrder==channel);
    
    subBand=floor((chIdx-1)/channelsPerSubBand);
    