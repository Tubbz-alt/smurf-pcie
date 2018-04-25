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
resonators = 5250 + [-1.3, 0.5, 4.1,  15, 20.2, 34, 39.5, 45.6, 50.1, 55.5, 61.3,...
    67.5, 75.9, 81.2, 112, 116, 121, 127, 133, 140.3, 146.6, 152.6, ...
    158, 162.2, 168, 174, 177.5,  187.6, 195.4]
%, -138.3, -128, -133.2, -138.3, -142.5  ];

%resonators = 5250 + [-1.3, 0.5, 4.1, 14.8, 19.9, 34, 40, 45.6, 55.4, 61.3];  %bands 0, 16, 2
%resonators = 5250 + [67.4 127 133 140.33 168];  

Off

load etaParams.mat %presumes this is already saved and the correct size

locked = [1 2 3 4 7];

%resonators = resonators(locked);

band0 = 5.25e3;
bandchans = zeros(32,1);


for j =1:length(locked)
    
    ii = locked(j);
    
    if etaPhaseDeg_all(ii) ~= 0
        continue
    else
        res = resonators(ii);
        display(' ')
        display('_________________________________________________')
        display(['Calibrate line at RF = ' num2str(res) ' MHz  IF = ' num2str(res - 5250 + 750) ' Mhz'])
        [band, Foff] = f2band(res)    ;
        band
        Foff

        % track the number of channels in the band
        bandchans(band+1) =bandchans(band+1)+1;
        chan(ii) = 16*band + bandchans(band+1) -1;
        offset(ii) = Foff;

        try
            figure(ii)
            [eta, F0, latency, resp, f] = etaEstimator(band, [(offset(ii) - .3):0.01:(offset(ii) + 0.3)]);
            hold on; subplot(2,2,4);
            ax = axis; xt = ax(1) + 0.1*(ax(2)-ax(1)); 
            yt = ax(4) - 0.1*(ax(4)-ax(3));
            text(xt, yt, ['Line @ ', num2str(res), ' MHz    (' num2str(res - 5250) ' wrt band center'])
            hold off;
            etaPhaseDeg(ii) = angle(eta)*180/pi;
            etaScaled(ii) =abs(eta)/19.2;
                   
            etaPhaseDeg_all(ii) = etaPhaseDeg(ii);
            etaScaled_all(ii) = etaScaled(ii);   
            
        catch
            display(['Failed to calibrate line number ' num2str(ii)])
            etaPhaseDeg(ii) =0;
            etaScaled(ii)=0;
        end
        
 
    
    end
end

save('etaParams.mat','etaPhaseDeg_all', 'etaScaled_all')
    

for j=1:length(locked)
    ii = locked(j);
    configCryoChannel(rootPath, chan(ii), offset(ii), 12, 1, etaPhaseDeg_all(ii), etaScaled_all(ii));
end
    
    