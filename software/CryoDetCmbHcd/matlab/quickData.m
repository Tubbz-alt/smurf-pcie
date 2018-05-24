function [f,df,frs]=quickData(Npts)

    if nargin<1
        Npts=2^20
    end

    % take a short dumb dataset
    dfn='/tmp/tmp2.dat';
    system( ['rm ', dfn] );

    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
    takeDebugData(rootPath,dfn,Npts);
    
    %[f, df, frs] = decodeSingleChannel(dfn, 0);
    [f,df,frs]=decodeData(dfn);