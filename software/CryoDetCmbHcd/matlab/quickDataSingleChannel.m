% take a short dumb dataset
dfn='/tmp/tmp2.dat';
system( ['rm ', dfn] );

takeDebugData(rootPath,dfn,2^16);

[f, df, frs] = decodeSingleChannel(dfn, 0);
%[f,df,frs]=decodeData(dfn);