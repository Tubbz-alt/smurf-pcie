%script allOff
%turn off all channels
%Note this resets all frequencies and eta values
for n=0:511
    configCryoChannel( rootPath, n, 0, 0, 0, 0, 1 );
end