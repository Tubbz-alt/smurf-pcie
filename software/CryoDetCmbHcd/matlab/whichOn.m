%script whichOn
%turn off all channels
%Note this resets all frequencies and eta values
function whichOn=checkLock(chans)
    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
    pvRoot = [rootPath, 'CryoChannels:'];

    amplitudeScaleArray = lcaGet( [pvRoot, 'amplitudeScaleArray'] );
    feedbackEnableArray = lcaGet( [pvRoot, 'feedbackEnableArray'] );

    whichOn=(find(amplitudeScaleArray)-1);

    %for n=0:511
    %    [band, Freq, ampl] = getChannel(n);
    %    if ampl > 0
    %        display(['found channel ' num2str(n) ' set to amplitude ' num2str( ampl)])
    %    end
    %end