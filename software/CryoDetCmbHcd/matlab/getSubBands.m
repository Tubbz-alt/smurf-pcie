function [subBands,subBandCenters]=getSubBandCenters(baseNumber,asOffset)
    if nargin<2
        asOffset=false;
    end

    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
    digitizerFrequencyMHz=lcaGet([baseRootPath,'digitizerFrequencyMHz']);
    numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
    bandCenterMHz=lcaGet([baseRootPath,'bandCenterMHz']);
    subBandWidthMHz=2*digitizerFrequencyMHz/numberSubBands;

    % subBands artificially defined to increment with increasing frequency,
    % starting with zero.
    subBands=0:(numberSubBands-1);
    subBandCenters=((1:1:numberSubBands)-numberSubBands/2)*subBandWidthMHz/2;
    
    if ~asOffset
        subBandCenters=subBandCenters+bandCenterMHz;
    end