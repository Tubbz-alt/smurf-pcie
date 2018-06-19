
singleChannelReadout     = 1;
singleChannelReadoutOpt2 = 0;
filterAlpha              = hex2dec('4000');
decimation               = 1;

onlyOneChannelEachBand   = true;

bases = [2,3];
eta  ={eta2, eta3};
for i = 1:2
    base = bases(i);
    counter=1
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', base)];
    lcaPut([rootPath, 'singleChannelReadout'],     singleChannelReadout);
    lcaPut([rootPath, 'singleChannelReadoutOpt2'], singleChannelReadoutOpt2);
    lcaPut([rootPath, 'decimation'], decimation);
    lcaPut([rootPath, 'filterAlpha'], filterAlpha);
    
     Off([2,3])
     reLock(bases(i), eta{i})
     trackingSetup(bases(i), 0)

    for ch=whichOn(base)

         amplitudeScaleArray = zeros(1,512);
         amplitudeScaleArray(ch+1) = 10;
         feedbackEnableArray = zeros(1,512);
         feedbackEnableArray(ch+1) = 1;
 
         lcaPut( [rootPath, 'CryoChannels:amplitudeScaleArray'], amplitudeScaleArray );
         lcaPut( [rootPath, 'CryoChannels:feedbackEnableArray'], feedbackEnableArray );
         
         trackingSetup(bases(i), ch)
        
        
            disp(ch);
            
%             if (mod(counter,3)==0)
%                 counter=counter+1;
%             else
%                 counter=counter+1;
%                 continue;
%             end
                   
            rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', base)];
            lcaPut( [rootPath, 'readoutChannelSelect'], ch );
            
            lcaPut( [rootPath, 'singleChannelReadoutOpt2'], 1) % setup F,dF readout
            lcaPut( [rootPath, 'iqStreamEnable'],  0  ) 
            takeData(base, 2^16);
            lcaPut( [rootPath, 'singleChannelReadoutOpt2'], 0) % return to multichannel state
            lcaPut( [rootPath, 'iqStreamEnable'],  1  ) % hand off streaming I/Q
            
            takeData(base);
            pause(2);
            close all
            
            if onlyOneChannelEachBand
                % only do one channel
                break;
            end
    end
%    checkLock
end
