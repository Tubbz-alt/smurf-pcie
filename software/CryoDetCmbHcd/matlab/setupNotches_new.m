% script to find the eta parameters and setup 32 frequencies

resonatorsOld = [4.9980, 5.0003, 5.0055, 5.0106, 5.0165, 5.0219, 5.0283,...
    5.0352, 5.0410, 5.0476, 5.0533, 5.0592, 5.0660, 5.0726,...
    5.0794, 5.0863, 5.0924, 5.1083, 5.1126, 5.1178, 5.1228,...
    5.1287, 5.1343, 5.1415, 5.1476, 5.1538, 5.1603, 5.1656,...
    5.1721, 5.1783, 5.1854, 5.1923, 5.1995, 5.2493, 5.2511,... 
    5.2546, 5.2594, 5.2653, 5.2708, 5.2780, 5.2847, 5.2906,...
    5.2962, 5.3007, 5.3061, 5.3119, 5.3180, 5.3265, 5.3319,...
    5.3386, 5.3592, 5.3625, 5.3664, 5.3714, 5.3774, 5.3836,...
    5.3914, 5112,  5.4030, 5.4085, 5.4127, 5.4184, 5.4246,...
    5.4284, 5.4383, 5.4461]*1e3;

%working from testAmplSweep 4Dec2017
resonators = 5250 + [-1.3, 0.5, 4.1, 8.9, 14.8, 20.2, 34, 40, 45.6, 50.1, 55.4, 61.3,...
    67.4, 76, 81.2, 112, 116, 121, 127, 133, 140.3, 146.5, 152.5, ...
    158, 162.2, 168, 174, 177.5,  187.6, 195.3, -138.3, -128, -133.2, -138.3, -142.5  ];
%resonators = 5250 + [-1.3, 8.8, 50.0, 67.4, 162.3, -138.3]; %
%resonators = 5250 + [-1.3, 0.5, 4.1, 14.8, 20.2, 34, 40, 45.6, 55.4, 61.3,...
 %   76, 81.2, -58.5, 127, 133, 129, 146];


Off

bandCtr = 5250;
bandchans = zeros(32,1);

for ii =1:length(resonators)
    res = resonators(ii);
    Resonator{ii}.Fest = res
    FwrtBandCtr = res - bandCtr
    
    [subBand, Foff] = f2band(res);
    Resonator{ii}.subBand = subBand
    Resonator{ii}.Foff = Foff
    
    % track the number of channels in the band
    bandchans(subBand+1) =bandchans(subBand+1)+1;
    chan(ii) = 16*subBand + bandchans(subBand+1);
    offset(ii) = Foff;

    try
        [eta, F0, latency, resp, f] = etaEstimator(subBand, Foff +(-.3:0.01:0.3));
        etaPhaseDeg(ii) = angle(eta)*180/pi;
        etaScaled(ii) = abs(eta)/19.2;
    catch
        display(['Failed to calibrate line number ' num2str(ii)])
        etaPhaseDeg(ii) =0;
        etaScaled(ii)=0;
    end
    
end

for ii=1:length(resonators)
    configCryoChannel(rootPath, chan(ii), offset(ii), 10, 1, etaPhaseDeg(ii), etaScaled(ii));
end
    
    

