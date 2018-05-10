function [band, Freq, ampl, FBen, etaPhase, etaMag] = getChannel(chan)
% get parameters for a channel

%SSmith4 Dec 2017


rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];


chanPVprefix = [rootPath, 'CryoChannels:CryoChannel[', num2str(chan), ']:'];
band = floor(chan/16);

Freq = lcaGet( [chanPVprefix, 'centerFrequency']);
if Freq>=2^23
    Freq = Freq - 2^24;
end
Freq = Freq*19.2/2^23;

FBen = lcaGet( [chanPVprefix, 'feedbackEnable']) ;

ampl = lcaGet( [chanPVprefix, 'amplitudeScale']) ;

etaPhase = lcaGet( [chanPVprefix, 'etaPhase']) ;
if etaPhase >= 2^15
    etaPhase=etaPhase-2^16;
end
etaPhase = etaPhase * 180/2^15;

etaMag = lcaGet( [chanPVprefix, 'etaMag'])/2^10 ;

end