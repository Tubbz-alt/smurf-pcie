%script allOff
%turn off all channels
%Note this resets all frequencies and eta values

rootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:';


for n=0:511
    [band, Freq, ampl] = getChannel(n);
    if ampl > 0
        display(['found channel ' num2str(n) ' set to amplitude ' num2str( ampl)])
        chanPVprefix = [rootPath, 'CryoChannels:CryoChannel[', num2str(n), ']:'];
        lcaPut( [chanPVprefix, 'amplitudeScale'], 0) ;
        
    end
end