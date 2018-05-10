% script to find the eta parameters and setup 32 frequencies
function chan = setupNotches_umux16_singletone(rootPath,Adrive,bandCenter,resonators)

    %% CMB resonators
    % amount to swing to the left and right of the resonator by, total
    % (one-sided)
%     FsweepFHalf=1;
%     % frequency step size in resonator sweep
%     FsweepDf=0.01;
%     delF=0.05;

    %% X-ray resonators
    %FsweepFHalf=0.9;
    %FsweepDf=0.03;
    %delF=0.180; 
       
    % Nb CMB MKIDs
    %FsweepFHalf=0.75;
    %FsweepDf=0.005;
    %delF=0.05; 
    Adrive=10;
    FsweepFHalf=0.3;
    FsweepDf=0.01;
    delF=0.02; 

    
    if nargin < 1
        rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:']; 
    end

    if nargin < 2
        Adrive=10; % roughly -33dBm at connector on SMuRF card output
    end

    if nargin < 3
        bandCenter=5250;
    end
    
    if nargin < 4
        % no TES
        resonators=[5395.7396];

        % TES
        %resonators=[5310.60];
        
    end
    
    Off

    %
    % if flux ramp is on, turn it off for the sweep
    %rtmSpiRootPath = 'mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:RtmCryoDet:C_RtmSpiSr:';
    % read current state
    %preFRState = lcaGet( [rtmSpiRootPath, 'Cfg_Reg_Ena Bit'] );
    fluxRampOnOff(0);
    pause(0.5);
    %if preFRState == 1
    %	% flux ramp was on when we started the sweep.  Wait a little bit to
    %	% make sure things have settled before doing sweep.
    %    pause(5);
    %end
    %

    band0 = bandCenter;
    bandchans = zeros(32,1);
    
    for ii =1:length(resonators)
        res = resonators(ii);
        display(' ')
        display('_________________________________________________')
        display(['Calibrate line at RF = ' num2str(res) ' MHz  IF = ' num2str(res - bandCenter + 750) ' Mhz'])
        [band, Foff] = f2band(res,bandCenter)    ;
        disp(['band=',num2str(band)]);
        Foff
    
        % track the number of channels in the band
        bandchans(band+1) =bandchans(band+1)+1;
        chan(ii) = 16*band + bandchans(band+1) -1;
        offset(ii) = Foff;

        try
            figure(ii)  
            [eta, F0, latency, resp, f] = etaEstimator(band, [(offset(ii) - FsweepFHalf):FsweepDf:(offset(ii) + FsweepFHalf)],Adrive,delF);
            hold on; subplot(2,2,4);
            ax = axis; xt = ax(1) + 0.1*(ax(2)-ax(1)); 
            yt = ax(4) - 0.1*(ax(4)-ax(3));
            text(xt, yt, ['Line @ ', num2str(res), ' MHz    (' num2str(res - bandCenter) ' wrt band center'])
            hold off;
            etaPhaseDeg(ii) = angle(eta)*180/pi;
            etaScaled(ii) =abs(eta)/19.2;
        catch e
            display(['ERROR: ', e.message])
            display(['Failed to calibrate line number ' num2str(ii)])
            etaPhaseDeg(ii) =0;
            etaScaled(ii)=0;
        end
    
    end

    for ii=1:length(resonators)
        configCryoChannel(rootPath, chan(ii), offset(ii), Adrive, 1, etaPhaseDeg(ii), etaScaled(ii));
    end
end
    