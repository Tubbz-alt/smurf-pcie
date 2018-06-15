function [f,df,frs]=quickData(band,Npts)

    if nargin<2
        Npts=2^18
    end

    % take a short dumb dataset
    dfn='/tmp/tmp2.dat';
    system( ['rm ', dfn] );

    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];
    takeDebugData(band,dfn,Npts);
    
    %[f, df, frs] = decodeSingleChannel(dfn, 0);
    [f,df,frs]=decodeData(dfn);