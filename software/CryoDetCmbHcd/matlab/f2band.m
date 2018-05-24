function [band, Foff] = f2band(F,baseNumber)
    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
    digitizerFrequencyMHz=lcaGet([baseRootPath,'digitizerFrequencyMHz']);
    numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
    bandCenterMHz=lcaGet([baseRootPath,'bandCenterMHz']);
    subBandWidthMHz=2*digitizerFrequencyMHz/numberSubBands;
    
    [subBands,subBandCenters]=getSubBandCenters(baseNumber);
    
    % find band whose center frequency is closest
    [absdiff subBandIndex] = min(abs(subBandCenters-F));
    band=subBands(subBandIndex);
    Foff=F-subBandCenters(subBandIndex);
    
    % make sure that the offset frequency is in the bandwidth of any of the
    % bands.  If not, throw an error!
    if abs(Foff)>subBandWidthMHz/2
        error(sprintf('ERROR! F=%0.1f MHz is not in any sub-band for baseNumber=%d (bandCenterMHz=%0.0f)',F,baseNumber,bandCenterMHz));
    end
end

%if nargin <2
%    bandCenter=5250;
%end
%
%bandNo = [ 8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17 2 18 3 19 4 20 5 21 6 22 7 23 8];
%
%bb = floor((F-(bandCenter-307.2-9.6))/19.2);
%fresid = F - (bandCenter -307.2) - bb*19.2;
%
%bandsInverted = false;    % Jan 19 2018 WTF
%if bandsInverted
%    fresid = -fresid
%    bandInvert = bandNo(33:-1:1);
%    bandNo = bandInvert;
%end
%
%band = bandNo(bb+1);
%
%end
    
