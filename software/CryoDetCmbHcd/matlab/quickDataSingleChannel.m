function [f,df,frs]=quickDataSingleChannel(band)
    % take a short dumb dataset
    dfn='/tmp/tmp2.dat';
    system( ['rm ', dfn] );
    
    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)];
    takeDebugData(band,dfn,2^16);
    
    [f, df, frs] = decodeSingleChannel(dfn);
    %[f,df,frs]=decodeData(dfn);