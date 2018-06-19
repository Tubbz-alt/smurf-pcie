% [loopFilterOutput, frequencyError] = readbackCryoChannel( rootPath, channelNum )
%    rootPath       - sysgen root path
%    channelNum     - cryo channel number (0...511)

function [loopFilterOutput, frequencyError] = readbackCryoChannel( rootPath, channelNum )
    pvRoot = [rootPath, 'CryoChannels:CryoChannel[', num2str(channelNum), ']:'];
    
    freq             = lcaGet( [pvRoot, 'loopFilterOutput'] );
    frequencyError   = lcaGet( [pvRoot, 'frequencyError'] );
    
    loopFilterOutput = freq*38.4*2^-24;  % MHz
%     lcaPut([pvRoot, 'frequencyError'],1000);
