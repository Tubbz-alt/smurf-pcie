% [data] = readDacData( rootPath, dacNumber )
%    rootPath       - sysgen root path
%    adcNumber      - DAC number 0...3
%
% [data] = readDacData( rootPath, dacNumber, dataLength )
%    rootPath       - sysgen root path
%    adcNumber      - DAC number 0...3
%    dataLength     - length of acquisition

function [data] = readDacData( rootPath, dacNumber, varargin )
    global DMBufferSizePV
    
    if ( isempty(varargin) )
        dataLength = 2^19;
    else
        dataLength = varargin{1};     
    end

    setupDaqMux( 0, 'dac', dacNumber, dataLength );   

    results = readStreamData( rootPath, dataLength); 
    
    data = results(2,:) + 1i.*results(1,:);
    
    if nargout == 0
       figure; pwelch(data, [], [], [], 614.4, 'centered'); 
    end


end
