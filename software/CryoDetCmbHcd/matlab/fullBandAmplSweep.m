function [f,resp]=fullBandAmplSweep(bands,Adrive,baseNumber,Nread,dwell,freqs)
    %function amplSweep2
    %sweeps the full band
    f=[];
    resp=[];
    if nargin < 1
        bands=0:31
    end
    
    if nargin < 2
        Adrive = 10;
    end
    
    if nargin < 3
        baseNumber=0;
    end
    
    if nargin < 4
        Nread = 2;
    end

    if nargin < 5
        dwell  =0.02;
    end
    
    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)]
    digitizerFrequencyMHz=lcaGet([baseRootPath,'digitizerFrequencyMHz']);
    numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
    bandCenterMHz=lcaGet([baseRootPath,'bandCenterMHz']);
    subBandWidthMHz=2*digitizerFrequencyMHz/numberSubBands;

    if nargin < 6
        freqs = -3:0.1:3; %frequencies in MHz
    end

    resp = zeros(numberSubBands, size(freqs,2)*Nread);
    f = zeros(numberSubBands, size(freqs,2)*Nread);

    [band_numbers,band_centers]=getSubBands(baseNumber,true);

    %for band=0:31
    for band=bands
        disp(['band ' num2str(band)])
        %[resp(band+1,:), f(band+1,:)] = amplSweep(band, freqs, Nread, dwell);
        %[resp(band+1,:), f(band+1,:)] = fastEtaScan(band, freqs, Nread, dwell, Adrive);
        [resp(band+1,:), f(band+1,:)] = fastEtaScan(band, freqs, Nread, dwell, Adrive, baseNumber);
        f(band+1,:) = f(band+1,:) + band_centers(find(band_numbers==band));
    end
end

%figure
%hold on;
%xlabel('Frequency (MHz)')
%ylabel('Amplitude (normalized)')
%title('32 sub-band response')
%
%
%for band=0:31
%    disp(['band ' num2str(band)])
%    [resp(band+1,:), f(band+1,:)] = amplSweep(band, freqs, Nread, dwell);
%    f(band+1,:) = f(band+1,:) + band_centers(band+1);
%    if band == 10
%        xlim([-300 300]);
%    end
%    plot(f(band+1,:), abs(resp(band+1,:)), '.', 'color', rand(1,3))
%    grid on;
%
%end
%
%xlim([-300 300])
%xlabel('Frequency (MHz)')
%ylabel('Amplitude (normalized)')
%title('32 sub-band response')
