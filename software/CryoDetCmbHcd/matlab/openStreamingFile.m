% openStreamingFile( fileName, open )
%    fileName       - file name to save data
%    open           - 1 = open, 0 = close
function openStreamingFile( fileName, open )
    global DMBufferSizePV

    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT')]
    

    C = strsplit(rootPath, ':');
    root = C{1};
    
    C1 = strsplit(fileName, '/');
    if length(C1) == 1
        currentFolder = pwd;
        fullPath = [currentFolder, '/', fileName];
    else
        fullPath = fileName;
    end

    if open 
        disp('Setting file name...')
    
        % must write full array here
        charArray = double(fullPath);
        writeData = zeros(1,300);
        writeData(1:length(charArray)) = charArray;
        lcaPut([root, ':AMCc:streamingInterface:dataFile'], writeData)
    
        disp(['Opening file...',fullPath])
        lcaPut([root, ':AMCc:streamingInterface:open'], 'True')
    else
        disp(['Closing file...',fullPath])
        lcaPut([root, ':AMCc:streamingInterface:open'], 'False')
    end
