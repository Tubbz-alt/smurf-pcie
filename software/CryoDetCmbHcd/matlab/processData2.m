% Process the data from pyrogue stream interfaces
% data is a multidimensiona matrix with the process data

function [data, header] = processData2(file, type)

    if nargin < 2
        type = 'uint32';
    end

    % Number of stream channels
    numChannels = 2;
    
    % Size of the header (8 bytes in 16-bit words)
    headerSize = 4;

    % Read input file
    fileID = fopen(file,'r');
    data = (fread(fileID,type,'ieee-le'));
    fclose(fileID);
    
    data         = reshape(data,[], numChannels);
    
    if strcmp(type, 'uint32')
        header       = data(1:2, :);
        data(1:2, :) = [];
        data         = uint32(data);
    elseif strcmp(type, 'int32')
        header(:,1)  = typecast(int32(data(1:2, 1)), 'uint32'); 
        header(:,2)  = typecast(int32(data(1:2, 2)), 'uint32');
        data(1:2, :) = [];
        data         = double(data);
    elseif strcmp(type, 'int16')
        header1(:,1) = typecast(int16(data(1:4, 1)), 'uint16');
        header1(:,2) = typecast(int16(data(1:4, 2)), 'uint16');
        header1      = double(header1);
        header       = header1(1:2:end,:) + header1(2:2:end,:)*2^16 ; % convert to uint32
        data(1:4, :) = [];
    else
        error(['Type ', type , ' not yet supported'])    
    end
    

    if header(2,2) == 0
        header = fliplr(header);
        data   = fliplr(data);
    else
        % do nothing 
    end

end
