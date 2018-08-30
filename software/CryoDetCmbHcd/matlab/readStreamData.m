% [data] = readStreamData( rootPath, dacNumber )
%    rootPath       - sysgen root path
%    dataLength     - length of acquisition
%

function [results] = readStreamData( rootPath, dataLength )
    
    C = strsplit(rootPath, ':');
    root = C{1};
    
    stream0 = [root, ':AMCc:Stream0'];
    stream1 = [root, ':AMCc:Stream1'];
    pvs{1,1}  = stream0;
    pvs{2,1}  = stream1;

    lcaSetMonitor(pvs)
    pause(0.1);
    results = lcaGet(pvs);
    
    
    triggerDM
    %lcaPut([root, ':AMCc:FpgaTopLevel:AppTop:AppCore:DaqMuxV2[0]:TriggerDaq'],1);

    try lcaNewMonitorWait(pvs)
        results = lcaGet(pvs, dataLength);
    catch errs
        fprintf(1,'The identifier was:\n%s',errs.identifier);
        fprintf(1,'There was an error! The message was:\n%s',errs.message);
    end
    
    lcaClear( pvs );
