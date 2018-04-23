allOff

bandCenter=4250;
[band,Foff]=f2band(4162.2,bandCenter)
chan = 16*band;

etaPhaseDeg = 0;
etaScaled = 0;

configCryoChannel(rootPath, chan, Foff, 12, 1, etaPhaseDeg, etaScaled);