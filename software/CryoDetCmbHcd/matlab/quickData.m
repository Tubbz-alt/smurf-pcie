% take a short dumb dataset
dfn='/tmp/tmp2.dat';
system( ['rm ', dfn] );
tic
takeDebugData(rootPath,dfn,2^22);
toc

[f,df,frs]=decodeData(dfn);