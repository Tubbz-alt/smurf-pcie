% take a short dumb dataset
dfn='/tmp/tmp2.dat';
system( ['rm ', dfn] );

rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
takeDebugData(rootPath,dfn,2^16);

[f, df, frs] = decodeSingleChannel(dfn);
%[f,df,frs]=decodeData(dfn);