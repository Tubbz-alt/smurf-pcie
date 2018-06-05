
singleChannelReadout     = 1;
singleChannelReadoutOpt2 = 0;
filterAlpha              = hex2dec('4000');
decimation               = 1;

for base = 2:3
    counter=1
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', base)];
    lcaPut([rootPath, 'singleChannelReadout'],     singleChannelReadout);
    lcaPut([rootPath, 'singleChannelReadoutOpt2'], singleChannelReadoutOpt2);
    lcaPut([rootPath, 'decimation'], decimation);
    lcaPut([rootPath, 'filterAlpha'], filterAlpha);
    for ch=whichOn(base)
            disp(ch);
            
%             if (mod(counter,3)==0)
%                 counter=counter+1;
%             else
%                 counter=counter+1;
%                 continue;
%             end
                   
            rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', base)];
            lcaPut( [rootPath, 'readoutChannelSelect'], ch );
            takeData(base);
            pause(2);
    end
%    checkLock
end
