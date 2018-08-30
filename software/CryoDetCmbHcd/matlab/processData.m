% Process the data from pyrogue strema interfaces
% data is a multidimensiona matrix with the process data

function data = processData(file, type)

    if nargin < 2
        type = 'uint32';
    end

    % Number of stream channels
    numChannels = 2
    
    % Size of the header (8 bytes in 32-bit words)
    headerSize = 4;

    % Read input file
    fileID = fopen(file,'r');
    data = (fread(fileID,type,'ieee-le'));
    if strcmp(type, 'uint32')
        data = uint32(data);
    end
    fclose(fileID);
    
    data(1:headerSize) = [];
    l = length(data);
    data = reshape(data,[l/numChannels numChannels]);

end
