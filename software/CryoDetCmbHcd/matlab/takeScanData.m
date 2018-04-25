%test concept of frequency sacn in debug data stream
%% SS 14Dec2017

% takeDebugData( rootPath, fileName )
%    rootPath       - sysgen root path
%    dataLength     - data length
%
%
% takeDebugData( rootPath, fileName, dataLength )
%    rootPath       - sysgen root path
%    dataLength     - data length
%    fileName       - file name to save data


function takeScanData( rootPath, fileName, varargin )
    global DMBufferSizePV
     
    if ( isempty(varargin) )
        dataLength = 2^19;
    else
        dataLength = varargin{1};     
    end


    C = strsplit(rootPath, ':');
    root = C{1};
    
    C1 = strsplit(fileName, '/');
    if length(C1) == 1
        currentFolder = pwd;
        fullPath = [currentFolder, '/', fileName];
    else
        fullPath = fileName;
    end
    
    %get present center freq
    channelNum = lcaGet([rootPath,  'statusChannelSelect'])
    pvRoot = [rootPath, 'CryoChannels:CryoChannel[', num2str(channelNum), ']:'];
    Fc = lcaGet([pvRoot 'centerFrequency']);
    if Fc >= 2^23
        Fc = Fc -2^24;
    end
    Fc = Fc * 19.2/2^24
    
    
    daqMuxChannel0 = 22; % +22 to set debug stream
    daqMuxChannel1 = 23;
    setBufferSize(dataLength)
    
    lcaPut([root,':AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]'],daqMuxChannel0)
    lcaPut([root,':AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]'],daqMuxChannel1)
    
    disp('Data acquisiton in progress...')
    
    % open file relative current directory?    
    
%     delete '/tmp/test.dat'
    
    disp('Setting file name...')
%     lcaPut([root, ':AMCc:streamDataWriter:dataFile'], double('/tmp/test.dat'))
    lcaPut([root, ':AMCc:streamDataWriter:dataFile'], double(fullPath))

    disp(['Opening file...',fullPath])
    lcaPut([root, ':AMCc:streamDataWriter:open'], 'True')

    %triggerDM
    disp(['Taking data...'])
    lcaPut([root, ':AMCc:FpgaTopLevel:AppTop:AppCore:CmdDacSigTrigArm'],1);
    

    % how long to pause?
    
%   Here we do a brief pause then monitor waveform engine done status
    done = 0;
    pause(0)
    while done == 0
        done = 1;
        for j = 0:3
            empty = lcaGet([root,':AMCc:FpgaTopLevel:AmcCarrierCore:AmcCarrierBsa:BsaWaveformEngine[0]:WaveformEngineBuffers:Empty[', num2str(j), ']']);
            if empty == 0
                done = 0;
            end   
        end
       for df=-0.3:0.01:0.3
           ff = Fc + df;
           fword = ff/19.2;
           if fword < 0
               fword = fword + 1;
           end
           lcaPut([pvRoot 'centerFrequency'], floor(fword*2^24));
           pause(0.001)
       end
       % TODO add percent complete for large datasets..
       fprintf('%s','%');
    end
    disp(' ') % newline


    disp('Closing file...')
    lcaPut([root, ':AMCc:streamDataWriter:open'], 'False')
    
%     movefile '/tmp/test.dat' fullPath

    disp('Done taking data')