function channelOrder=getChannelOrder()
    freq = [-2 -0.5 0.5  2.1];
    fftLen        = 64;
    fftOversample = 2;
    b             = bitrevorder(0:fftLen/fftOversample - 1);
    subChan       = 4;
    remap128      = reshape([b, b+32, b+64, b+96], fftLen/fftOversample, subChan)';
         

    % 128,384,0,256 -> 5.55664,4.94824, 5.2501, 5.25478
    %remap128=fliplr(remap128);
    channelOrder=zeros(1,512);
    for ii=1:32
        channelOrder((1+8*(ii-1)):(4+8*(ii-1)))=sort(fliplr(remap128((1+4*(ii-1)):(4+4*(ii-1)))) + 128);
        channelOrder((5+8*(ii-1)):(8+8*(ii-1)))=sort(fliplr(remap128((1+4*(ii-1)):(4+4*(ii-1)))) + 384);
        
        channelOrder((257+8*(ii-1)):(260+8*(ii-1)))=sort(remap128((1+4*(ii-1)):(4+4*(ii-1))) + 0);
        channelOrder((261+8*(ii-1)):(264+8*(ii-1)))=sort(remap128((1+4*(ii-1)):(4+4*(ii-1))) + 256);
    end
    channelOrder=circshift(channelOrder,-4,2);

%%for ch=channelOrder(257:257+8)
%for ch=channelOrder
%     baseNumber=0;
%     baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)]
%     pvRoot = [baseRootPath, 'CryoChannels:CryoChannel[', num2str(ch), ']:'];
%     lcaPut( [pvRoot, 'amplitudeScale'], 15 );
%     lcaPut( [pvRoot, 'centerFrequencyMHz'], 0 );
%
%     pause(0.1);
%     cmdStr=sprintf('ssh -Y umux@171.64.108.89 "python /home/umux/python_vna/get_sa_marker.py %f %f %s"',ch,0,'chOrder_swh_20180519.dat');
%     disp(['cmdStr=' cmdStr]);
%     system(cmdStr);
%     Off;
%     pause(0.1);
%end

