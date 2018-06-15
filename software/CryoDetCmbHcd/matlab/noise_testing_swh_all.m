function noise_testing_swh(base,ch,dirname)

    singleChannelReadout     = 1;
    singleChannelReadoutOpt2 = 0;
    %filterAlpha              = hex2dec('4000');
    %decimation               = 1;
    filterAlpha              = hex2dec('0666');
    decimation               = 5;
    
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', base)];
    lcaPut([rootPath, 'singleChannelReadout'],     singleChannelReadout);
    lcaPut([rootPath, 'singleChannelReadoutOpt2'], singleChannelReadoutOpt2);
    lcaPut([rootPath, 'decimation'], decimation);
    lcaPut([rootPath, 'filterAlpha'], filterAlpha);
    
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', base)];
                lcaPut( [rootPath, 'readoutChannelSelect'], ch );
    
                lcaPut( [rootPath, 'singleChannelReadoutOpt2'], 1) % setup F,dF readout
                lcaPut( [rootPath, 'iqStreamEnable'],  0  ) 
                
                fFdF=fileNameFromPath(takeData(base, 2^16));
                lcaPut( [rootPath, 'singleChannelReadoutOpt2'], 0) % return to multichannel state
                lcaPut( [rootPath, 'iqStreamEnable'],  1  ) % hand off streaming I/Q
    
                tic;
                %fIQ=fileNameFromPath(takeData(base,2^22));
                fIQ=fileNameFromPath(takeData(base,2^26));
                toc;
                pause(2);
                close all
                
                computeNoiseSpectra(dirname,{fFdF,fIQ},'','');
    
                %if onlyOneChannelEachBand
                %    % only do one channel
                %    break;
                %end
    %    checkLock    