% returns channel configuration in the units needed as inputs to the configCryoChannel
% function
function [centerFrequencyMHz, amplitudeScale, feedbackEnable, etaPhaseDegree, etaMagScaled]=getCryoChannelConfig(band,chan)

    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];

    pvRoot = [rootPath, 'CryoChannels:CryoChannel[', num2str(chan), ']:'];
        
    centerFrequencyMHz=lcaGet([pvRoot,'centerFrequencyMHz']);
    amplitudeScale=lcaGet([pvRoot,'amplitudeScale']);
    feedbackEnable=lcaGet([pvRoot,'feedbackEnable']);
    etaPhaseDegree=lcaGet([pvRoot,'etaPhaseDegree']);
    etaMagScaled=lcaGet([pvRoot,'etaMagScaled']);
end
