band=3;
for subband=0:127
    Off(band);
    disp(subband);
    chans=getChannelsInSubBand(band,subband);
    disp(chans(1));
    
    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];
    chanPVprefix = [rootPath, 'CryoChannels:CryoChannel[', num2str(chans(1)), ']:'];
    lcaPut( [chanPVprefix, 'amplitudeScale'], 12) ;
    pause(1);
end
Off(band);