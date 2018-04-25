% readFpgaStatus( rootPath )
%    rootPath       - sysgen root path
%  
%    reports:
%       FPGA build string
%       uptime counter
%       version
%       JESD Rx Status
%       JESD Tx Status

function readFpgaStatus( rootPath )

    C = strsplit(rootPath, ':');
    root = C{1};
    
  
    axiVersionPath = [root, ':AMCc:FpgaTopLevel:AmcCarrierCore:AxiVersion'];
    jesdRxPath = [root, ':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx' ];
    jesdTxPath = [root, ':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx' ];
    
    
    upTime     = lcaGet([axiVersionPath, ':UpTimeCnt']);
    fpgaVersion = lcaGet([axiVersionPath, ':FpgaVersion']);
    gitHash = lcaGet([axiVersionPath, ':GitHash']);
    buildStamp = lcaGet([axiVersionPath, ':BuildStamp']);
    
    disp(' ')
    disp(' ')
    
    disp(['Build stamp: ', buildStamp])
    disp(['FPGA version: 0x', dec2hex(fpgaVersion)])
    disp(['FPGA uptime: ', num2str(upTime)])
%     disp(['GIT hash: ', (gitHash)])

    disp(' ')
    disp(' ')
    
    
    jesdRxEnable = lcaGet([jesdRxPath, ':Enable']);
    jesdRxValid  = lcaGet([jesdRxPath, ':DataValid']);
    
    if ( jesdRxEnable ~= jesdRxValid )
        disp(' ');
        disp(' ');
        disp('JESD Rx DOWN'); 
        disp(' ');
        disp(' ');
    else
        disp('JESD Rx Okay');
    end
    
        
    jesdTxEnable = lcaGet([jesdTxPath, ':Enable']);
    jesdTxValid  = lcaGet([jesdTxPath, ':DataValid']);
    
    if ( jesdTxEnable ~= jesdTxValid )
        disp(' ');
        disp(' ');
        disp('JESD Tx DOWN'); 
        disp(' ');
        disp(' ');
    else
       disp('JESD Tx Okay'); 
    end
    
