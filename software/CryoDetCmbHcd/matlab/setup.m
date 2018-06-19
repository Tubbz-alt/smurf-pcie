
function setup( band )
    baseNumber=0;
    if( ~exist('band', 'var' ) )
        band = 2;
    end

    if 0
        addpath('/afs/slac/g/lcls/package/pyrogue/control-server/pyrogue-control-server.git/utils/matlab/epics');
    else
        addpath('/afs/slac/g/lcls/package/pyrogue/control-server/dev2/utils/matlab/epics');
    end 

    try
        lcaClear
    catch e
    end
    
    setEnv(getSMuRFenv('SMURF_EPICS_ROOT'))
    setDefaults
  
    root=[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
    lcaPut([root,'iqSwapIn'], num2str(1));
    lcaPut([root,'iqSwapOut'], num2str(1));
    lcaPut([root,'refPhaseDelay'], num2str(6));
    lcaPut([root,'refPhaseDelayFine'], num2str(0));
    lcaPut([root,'toneScale'], num2str(2));
    lcaPut([root,'analysisScale'], num2str(3));
    lcaPut([root,'feedbackEnable'], num2str(1));
    lcaPut([root,'feedbackGain'], num2str(256));
    
    setFeedbackLimitkHz(0,225);
    
    lcaPut([root,'feedbackPolarity'], num2str(1));
    lcaPut([root,'bandCenterMHz'], num2str(4250 + 500*band));
    lcaPut([root,'synthesisScale'], num2str(3));

% disable all DAC
    for i = 0:8
        pv = sprintf([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[%i]'], i);
        lcaPut(pv, 'OutputOnes');
    end

% % disable all LO
%     for i = 0:3
%         if i == band
%             % leave this one on
%        else
%             pv = sprintf('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[%i]:REG[4]', i);
%            lcaPut(pv, hex2dec('30008BC4'));
%         end
%     end

% enable DAC, PLL, map ADC for a particular band
    root=[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:CryoAdcMux[0]:'];
    switch band
        
        case 0
            %%%   Ch1  4-4.5GHz %%%
            lcaPut([root,'ChRemap[0]'] , num2str(2));
            lcaPut([root,'ChRemap[1]'] , num2str(3));
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]'],'UserData')
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]'],'UserData')
%             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[0]:REG[4]',hex2dec('30008B84'))

        case 1
            %%%   Ch2  4.5-5GHz %%%
            lcaPut([root,'ChRemap[0]'] , num2str(0));
            lcaPut([root,'ChRemap[1]'] , num2str(1));
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]'],'UserData')
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]'],'UserData')
%             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[1]:REG[4]',hex2dec('30008B84'))
            % I/Q on ADC input swapped for this band!
            lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'iqSwapIn'], num2str(0));


        case 2
            %%%   Ch3 5-5.5GHz   %%%
            lcaPut([root,'ChRemap[0]'] , num2str(6));
            lcaPut([root,'ChRemap[1]'] , num2str(7));
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]'],'UserData')
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]'],'UserData')
%             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[2]:REG[4]',hex2dec('30008B84'))

        case 3
            %%%  Ch4 5.5-6GHz %%%
            lcaPut([root,'ChRemap[0]'] , num2str(4));
            lcaPut([root,'ChRemap[1]'] , num2str(5));
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]'],'UserData')
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]'],'UserData')
%             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[3]:REG[4]',hex2dec('30008B84'))
            % I/Q on ADC input swapped for this band!
            lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'iqSwapIn'], num2str(0));
            
        otherwise  % default
            %%%   Ch3 5-5.5GHz   %%%
            lcaPut([root,'ChRemap[0]'] , num2str(6));
            lcaPut([root,'ChRemap[1]'] , num2str(7));
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]'],'UserData')
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]'],'UserData')
            lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[2]:REG[4]'],hex2dec('30008B84'))

    end
     lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'dspEnable'], num2str(1));
%     lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'lmsEnable1'], num2str(1));
%     lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'lmsEnable2'], num2str(1));
%     lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'lmsEnable3'], num2str(1));
%     lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:LMK:PwrDwnSysRef'], 1);
    readFpgaStatus( root )
end
