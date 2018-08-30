
function setup( band , gen2)
    if( ~exist('band', 'var' ) )
        band = [2,3];
    end

    if nargin < 2
        gen2 = 0;
    else
        gen2 = gen2;
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
    
    remap = 0;  % use AdcChRemap?
    
    setEnv(getSMuRFenv('SMURF_EPICS_ROOT'))
    setDefaults
  
    for i = 1:length(band)
        root=[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))];
        lcaPut([root,'iqSwapIn'], num2str(1));
        lcaPut([root,'iqSwapOut'], num2str(1));
        lcaPut([root,'refPhaseDelay'], num2str(6));
        lcaPut([root,'refPhaseDelayFine'], num2str(0));
        lcaPut([root,'toneScale'], num2str(2));
        lcaPut([root,'analysisScale'], num2str(3));
        lcaPut([root,'feedbackEnable'], num2str(1));
        lcaPut([root,'feedbackGain'], num2str(256));
        lcaPut([root,'lmsGain'], num2str(7));
        lcaPut([root, 'rfEnable'], num2str(1));

        
        setFeedbackLimitkHz(band(i),225);
        
        lcaPut([root,'feedbackPolarity'], num2str(1));
        %     lcaPut([root,'bandCenterMHz'], num2str(4250 + 500*band));
        lcaPut([root,'synthesisScale'], num2str(3));
        
        % disable all DAC
        %     for i = 0:8
        %         pv = sprintf([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[%i]'], i);
        %         lcaPut(pv, 'OutputOnes');
        %     end
        
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
        switch band(i)
            
            case 0
                %%%   Ch1  4-4.5GHz %%%
                if remap
                    lcaPut([root,'ChRemap[0]'] , num2str(2));
                    lcaPut([root,'ChRemap[1]'] , num2str(3));
                end
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]'],'UserData')
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]'],'UserData')
                %             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[0]:REG[4]',hex2dec('30008B84'))
                
            case 1
                %%%   Ch2  4.5-5GHz %%%
                if remap
                    lcaPut([root,'ChRemap[0]'] , num2str(0));
                    lcaPut([root,'ChRemap[1]'] , num2str(1));
                end
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]'],'UserData')
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]'],'UserData')
                %             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[1]:REG[4]',hex2dec('30008B84'))
                % I/Q on ADC input swapped for this band!
                lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'iqSwapIn'], num2str(0));
                
                
            case 2
                %%%   Ch3 5-5.5GHz   %%%
                if remap
                    lcaPut([root,'ChRemap[0]'] , num2str(6));
                    lcaPut([root,'ChRemap[1]'] , num2str(7));
                end
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]'],'UserData')
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]'],'UserData')
                %             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[2]:REG[4]',hex2dec('30008B84'))
                lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))],'iqSwapIn'], num2str(1));
                lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))],'iqSwapOut'], num2str(0));
                
                lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))],'bandCenterMHz'], 5250);
            case 3
                %%%  Ch4 5.5-6GHz %%%
                if remap
                    lcaPut([root,'ChRemap[0]'] , num2str(4));
                    lcaPut([root,'ChRemap[1]'] , num2str(5));
                end
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]'],'UserData')
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]'],'UserData')
                %             lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[3]:REG[4]',hex2dec('30008B84'))
                % I/Q on ADC input swapped for this band!
                lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))],'iqSwapIn'], num2str(0));
                lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))],'iqSwapOut'], num2str(0));
                
                lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))],'bandCenterMHz'], 5750);
            otherwise  % default
                %%%   Ch3 5-5.5GHz   %%%
                if remap
                    lcaPut([root,'ChRemap[0]'] , num2str(6));
                    lcaPut([root,'ChRemap[1]'] , num2str(7));
                end
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]'],'UserData')
                lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]'],'UserData')
                %             lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:PLL[2]:REG[4]'],hex2dec('30008B84'))
                
        end
        lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band(i))],'dspEnable'], num2str(1));
        %     lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'lmsEnable1'], num2str(1));
        %     lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'lmsEnable2'], num2str(1));
        %     lcaPut([[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'],'lmsEnable3'], num2str(1));
    end
        %     lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:LMK:PwrDwnSysRef'], 1);



    lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:resetRtm')], 1);
    lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:DAC[0]:enable')], 1);
    lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:DAC[1]:enable')], 1);

    readFpgaStatus( root )
    if gen2
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:DC[1]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:DC[2]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:DC[3]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:DC[4]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:UC[1]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:UC[2]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:UC[3]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:MicrowaveMuxCore[0]:ATT:UC[4]')], 0);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:LINK_DISABLE'], 1);
        pause(0.5);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:LINK_DISABLE'], 0);
    end

    % check temperatures

    temp = lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AmcCarrierCore:AxiSysMonUltraScale:Temperature']);
    if temp > 70
        sprintf('Temperature = %d! Check fans!', temp)
    end

    vccint = lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AmcCarrierCore:AxiSysMonUltraScale:VccInt']);
    vccaux = lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AmcCarrierCore:AxiSysMonUltraScale:VccAux']);
    vccbram = lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AmcCarrierCore:AxiSysMonUltraScale:VccBram']);

    dac0_temp = lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaToplevel:AppTop:AppCore:MicrowaveMuxCore[0]:Dac[0]:Temperature')])
    dac1_temp = lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaToplevel:AppTop:AppCore:MicrowaveMuxCore[0]:Dac[1]:Temperature')])

    if dac0_temp > 60 || dac1_temp > 60
        sprintf('DAC temperature too high! Check fans! \n DAC0 temp = %d, DAC1 temp = %d', dac0_temp, dac1_temp)
    end


    if ~gen2
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:CryoAdcMux:Remap[0]')], 1);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:LINK_DISABLE'], 1);
        pause(0.5);
        lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:LINK_DISABLE'], 0);
    end
end
