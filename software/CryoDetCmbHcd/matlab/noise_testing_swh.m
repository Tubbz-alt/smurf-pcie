function noise_testing_swh(band,dirname,var2add,text2add,Adrive)

    if nargin<5
        Adrive=10;
    end

    singleChannelReadout     = 1;
    singleChannelReadoutOpt2 = 0;
    filterAlpha              = hex2dec('4000');
    decimation               = 0;
    %filterAlpha              = hex2dec('0666');
    %decimation               = 5;
    
    onlyOneChannelEachBand   = true;
    
    resf=findFreqs(band);
    etaf=setupNotches_umux16(band,Adrive,true,false,resf);
    bases = [band];
    eta  ={etaf};
    for i = 1:1
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
        %chans=whichOn(base);
        %ch=chans(1);
        
             amplitudeScaleArray = zeros(1,512);
             amplitudeScaleArray(ch+1) = Adrive;
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
                
                fFdF=fileNameFromPath(takeData(base, 2^16));
                lcaPut( [rootPath, 'singleChannelReadoutOpt2'], 0) % return to multichannel state
                lcaPut( [rootPath, 'iqStreamEnable'],  1  ) % hand off streaming I/Q
    
                tic;
                %fIQ=fileNameFromPath(takeData(base,2^22));
                fIQ=fileNameFromPath(takeData(base,2^25));
                toc;
                pause(2);
                close all
                
                computeNoiseSpectra(dirname,{fFdF,fIQ},var2add,text2add);
    
                %if onlyOneChannelEachBand
                %    % only do one channel
                %    break;
                %end
        end
    %    checkLock
    end
    