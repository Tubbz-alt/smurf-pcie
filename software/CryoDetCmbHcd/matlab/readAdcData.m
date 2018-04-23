% [data] = readAdcData( rootPath, adcNumber )
%    rootPath       - sysgen root path
%    adcNumber      - ADC number 0...3
%
% [data] = readAdcData( rootPath, adcNumber, dataLength )
%    rootPath       - sysgen root path
%    adcNumber      - ADC number 0...3
%    dataLength     - length of acquisition

function [data] = readAdcData( rootPath, adcNumber, varargin )
    global DMBufferSizePV
    
    if ( isempty(varargin) )
        dataLength = 2^19;
    else
        dataLength = varargin{1};     
    end

    setupDaqMux( rootPath, 'adc', adcNumber, dataLength );   

    results = readStreamData( rootPath, dataLength); 
    
    data = results(2,:) + 1i.*results(1,:);

end
