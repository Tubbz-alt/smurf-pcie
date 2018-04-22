function [f,resp]=fullBandAmplSweep(bands,Adrive,Nread,dwell,freqs)
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
        Nread = 2;
    end

    if nargin < 4
        dwell  =0.02;
    end

    if nargin < 5
        freqs = -10:0.1:10; %frequencies in MHz
    end

    resp = zeros(32, size(freqs,2)*Nread);
    f = zeros(32, size(freqs,2)*Nread);

    band_centers1 = circshift((0:1:15)'-8, 8);
    band_centers2 = circshift((0.5:1:15.5)'-8, 8);
    band_centers = [band_centers1; band_centers2]*38.4;

    %for band=0:31
    for band=bands
        disp(['band ' num2str(band)])
        %[resp(band+1,:), f(band+1,:)] = amplSweep(band, freqs, Nread, dwell);
        %[resp(band+1,:), f(band+1,:)] = fastEtaScan(band, freqs, Nread, dwell, Adrive);
        [resp(band+1,:), f(band+1,:)] = fastEtaScan(band, freqs, Nread, dwell, Adrive);
        f(band+1,:) = f(band+1,:) + band_centers(band+1);
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
