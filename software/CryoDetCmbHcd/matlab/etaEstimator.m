function [eta, F0, latency, resp, f] = etaEstimator(baseNumber, band, freqs, Adrive, delF, doPlots)
%sweep frequencies in a band,
% aquire complex repsonse vs frequency at dF block where eta is used
% fit to dF/dS21 to estimate eta
% must scan twice, once to get real part, once to get imag part

%SSmith 22 Nov 2017

if nargin <3 
    Adrive = 12; %default -6dB
end; 

if nargin <4 
    delF = 0.05; %default 50kHz
end; 

if nargin <5
    doPlots=true;
end; 


Nread = 1   ;    %normally run with Nread>=4

eta = 0;
F0 = 0; 
latency = 0;

%dwell = 0.07; [resp, f] = etaScan(band, freqs, Nread, dwell, Adrive);
dwell = 0.0; [resp, f] = fastEtaScan(band, freqs, Nread, dwell, Adrive, baseNumber);

a = abs(resp); idx = find(a==min(a),1);
F0 = f(idx) %center frequency in MHz
left = find(f>F0-delF,1); f(left)
right = find(f>F0+delF,1); f(right)

if doPlots
    figure;
    %assume higher level code has established a figure or we create a new one
    subplot(2,2,1)
    plot(f, a, '.');grid
    hold on
    plot(f(idx), a(idx), 'r*');
    title(['Amplitude Response for Band ' num2str(band)])
    xlabel('Frequency (MHz)')
    ylabel('Response (arbs)')
    ax = axis; xt = ax(1)+0.1*(ax(2)-ax(1)); 
    yt=  ax(3) + 0.1*(ax(4)-ax(3));
    text(xt, yt,['Band Center = ', num2str(band*38.4), ' MHz'])
 
    netPhase = unwrap(angle(resp));
    %figure(2); 
    subplot(2,2,2), plot(f, netPhase, '.');grid
    title(['Phase Response for Band ' num2str(band)])
    xlabel('Frequency (MHz)')
    ylabel('Phase')
    Nf = length(f);
    latency = (netPhase(Nf)-netPhase(1))/(f(Nf)-f(1))/2/pi
    hold on
    plot(f(left), netPhase(left), 'gx')
    plot(f(right), netPhase(right), 'g+')

    p = polyfit([f(left), f(right)], [netPhase(left), netPhase(right)], 1);
        plot(f, polyval(p,f), 'k--')
    axis([f(1), f(end), min(netPhase) - 0.2, max(netPhase) + 0.2])

    %complex Response Plot
    %figure(3)
    subplot(2,2,3), plot(resp, '.');grid, hold on
    plot(resp(idx),'r*')
    plot(resp(left), 'gx')
    plot(resp(right), 'g+')
    title(['Complex Response for Band ' num2str(band)])

    hold off
    pbaspect([1 1 1])
    %axis([-0.25 0.25 -0.25 0.25])
end

baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
digitizerFrequencyMHz=lcaGet([baseRootPath,'digitizerFrequencyMHz']);
numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
subBandHalfWidthMHz=(digitizerFrequencyMHz/numberSubBands);

%estimate eta
eta = (f(right)-f(left))/(resp(right)-resp(left))
etaMag = abs(eta);   %magnitude in MHz per unit response
etaPhase = angle(eta);
etaPhaseDeg = angle(eta)*180/pi
etaScaled = etaMag/subBandHalfWidthMHz

if doPlots
    %figure(4)
    subplot(2,2,4), plot(resp*eta, '.'), grid, hold on
    plot(eta*resp(idx),'r*')
    plot(eta*resp(right), 'g+')
    plot(eta*resp(left), 'gx')
    
    pbaspect([1 1 1])
    %axis([-0.25 0.25 -0.25 0.25])
end

end
% end of function etaEstimator


%_________________________________________________________________________
% subfunction etaScan

function [resp, f] = etaScan(band, freqs, Nread, dwell, Adrive)
% Sweep frequency, plot complex response at input to dF calculation
% band selects one of 32 sub bands (0:31  allowed)
% freqs is a vector of frequencies in the range 
% - digitizerFrequencyMHz/numberSubBands (MHz) to 
% + digitizerFrequencyMHz/numberSubBands (MHz)

% resp is complex response demodulated response
% Nread (optional) number of reads of response per frequency setting
% dwell (optional) dwell time between setting and read and between reads
% Example:
%   Response  = etaScan(7, (-9.6:.1:9.6)*1e6) sweeps from -9.6 MHz to
%   +9.6 MHz in steps of 100kHz
% SS 20Nov2017

rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];

if nargin <3 
    Nread = 2; % default number of reads per frequnecy setting
end; 

if nargin <4 
    dwell = 0.002; %dwell time default is 1 ms
end; 


respI = zeros(1, Nread*length(freqs)); %allocate response vector
respQ = respI;

% up to 16 tones are summed/sub-band
% toneScale selects the scaling after summing 16 channels - global setting
%   0 is scaled by 1/8
%   1 is scaled by 1/4
%   2 is scaled by 1/2
%   3 is scaled by 1    (used for outputting single tone/sub-band)
%lcaPut( [rootPath, 'toneScale'], 3 )  % full amplitude in a single tone

% global feedback enable
lcaPut( [rootPath, 'feedbackEnable'], 0 ) %Disable FB
pause(dwell)

%Qualify inputs
if band <0 | band > 31 
    display('band out of range ( 0 <= band <= 31')
    return
end

baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',baseNumber)];
digitizerFrequencyMHz=lcaGet([baseRootPath,'digitizerFrequencyMHz']);
numberSubBands=lcaGet([baseRootPath,'numberSubBands']);
subBandHalfWidthMHz=(digitizerFrequencyMHz/numberSubBands);
if min(freqs) < -subBandHalfWidthMHz  |  max(freqs) > subBandHalfWidthMHz
    display(sprintf('frequencies must be in range +-%0.2f MHz',subBandHalfWidthMHz))
    return
end

subchan = 16*band; % use channel 0 of this band

lcaPut( [rootPath, 'rfEnable'], 1 ) %enable RF
pause(dwell)
lcaPut( [rootPath, 'statusChannelSelect'], subchan)   %set monitor channel to this channel
chanPVprefix = [rootPath, 'CryoChannels:CryoChannel[', num2str(subchan), ']:']
  %      dfword = lcaGet( [rootPath, 'CryoChannels:CryoChannel[0]:', 'frequencyError'])/2^24*38.4 ;


%loop over frequencies
% first for real part
etaMag =1;
etaPhase = 0;

for j=1:length(freqs)
    % configCryoChannel( rootPath, subchan, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
    configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, etaPhase, etaMag )

    pause(dwell);
    for nr = 1:Nread
        %read dF, save response as complex vector

 %       configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, etaPhase, etaMag ); %write again to trigger status register update
      pause(0.002);

        dFword = lcaGet([chanPVprefix, 'frequencyError']); %get real part
        if dFword >= 2^23
            dFword = dFword-2^24;   %treat as signed 24 bit
        end
        respI((j-1)*Nread + nr) = dFword/2^23; %get real part

        f((j-1)*Nread + nr) = freqs(j); 
    end
end

etaPhase = -90;     % should this be +90? +270?
for j=1:length(freqs)
    % configCryoChannel( rootPath, subchan, frequency_mhz, amplitude, feedbackEnable, etaPhase, etaMag )
    configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, etaPhase, etaMag )
    pause(dwell);
    
    for nr = 1:Nread
        pause(0.002);
        dFword = lcaGet([chanPVprefix, 'frequencyError']); %get real part
        if dFword >= 2^23
            dFword = dFword-2^24;   %treat as signed 24 bit
        end
        respQ((j-1)*Nread + nr) = dFword/2^23; %get imaginary part
    end
end

resp = respI + 1i*respQ;    %form complex response

%Adrive = 1; %turn down to very low amplitude
Adrive = 0; % turn channel OFF
configCryoChannel( rootPath, subchan, freqs(j), Adrive, 0, 0, 0 ) ;
end
