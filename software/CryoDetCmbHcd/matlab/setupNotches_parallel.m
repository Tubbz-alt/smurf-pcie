function resultsDir = setupNotches_parallel(band, Adrive, doPlots, lockBandAtEndofEtaScan, resFile)
    tic
    
    if nargin < 1
	band = 2;
    end

    if nargin < 2
	Adrive = 10; % I am worried about power saturation here though
    end

    if nargin < 3
	doPlots = true;
    end

    if nargin < 4
	lockBandAtEndofEtaScan = true;
    end

    clearvars offset chan etaPhaseDeg etaScaled

    ctime = ctimeForFile; % I hate posix time
    datadir = dataDirFromCtime(ctime);
    resultsDir = fullfile(datadir, strcat(num2str(ctime), 'etascan'))

    baseRootPath = [getSMuRFenv('SMURF_EPICS_ROOT'), sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:', band)];

    if not(exist(resultsDir))
	disp(['-> creating ' resultsDir]);
	mkdir(resultsDir);
    end

    % load the most recent resontaor scan
    if nargin < 4
	M = dlmread('/data/cpu-b000-hp01/cryo_data/data2/current_res');
    else
	M = dlmread(resFile);
    end

    resonators_all = M(:,3,:)';
    resonators = resonators_all; % why though

    FsweepFHalf = 0.3;
    %FsweepDf = 0.002;
    FsweepDf = 0.01 % I am impatient
    delF = 0.010;

    Off(band);
    if doPlots
	close all
    end

    bandCenterMHz = lcaGet([baseRootPath, 'bandCenterMHz']);
    numberChannels = lcaGet([baseRootPath, 'numberChannels']);
    numberSubBands = lcaGet([baseRootPath, 'numberSubBands']);

    numberofChannelsPerSubBand = floor(numberChannels / numberSubBands);
    maxNumChannelsPerSubBand = numberofChannelsPerSubBand;

    digitizerFrequencyMHz = lcaGet([baseRootPath, 'digitizerFrequencyMHz']);
    subBandHalfWidthMHz = (digitizerFrequencyMHz / numberSubBands);

    subbandchans = zeros(numberSubBands, 1);

    clear etaOut etaCfg;

    etaOut = {};
    etaCfg = {};

    etaCfg.('ctime') = ctime;
    etaCfg.('Adrive') = Adrive;
    etaCfg.('FsweepFHalf') = FsweepFHalf;
    etaCfg.('FsweepDf') = FsweepDf;
    etaCfg.('delF') = delF;
    etaCfg.('bandCenterMHz') = bandCenterMHz;

    scanChans = zeros(1,512); % channels to scan for parallelEta
    numScanFreqs = length(-FsweepFHalf:FsweepDf:FsweepFHalf); % number of frequencies swept
    scanFreqs = zeros(numScanFreqs, 512); % frequencies to sweep per channel
    
    for ii=1:length(resonators)
	res = resonators(ii);
	[subband, Foff] = f2band(res, band);

	if subbandchans(subband+1) == maxNumChannelsPerSubBand
	    disp(sptrintf('!! Exceeded maxNumChannelsPerSubband=%d in band %d, have to skip this resonator at %0.3f GHz', maxNumChannelsPerSubband, subband, res));
	    continue;
        end

	channelOrder = getChannelOrder();
	chan(ii) = channelOrder(subband*numberofChannelsPerSubBand + 1 + subbandchans(subband + 1));
	chanNum = chan(ii) + 1; % sorry
	scanChans(chanNum) = 1; % turn on sweeping for this channel
	subbandchans(subband + 1) = subbandchans(subband+1) + 1;
	offset(ii) = Foff;
	scanFreqs(:,chanNum) = [(offset(ii) - FsweepFHalf):FsweepDf:(offset(ii) + FsweepFHalf)];

    end


    disp('beginning eta scan')
    [freq, resp] = parallelScan(band, scanChans, Adrive, scanFreqs);
    disp('end eta scan')


    for ii=1:length(resonators)
        chanNum = chan(ii) + 1;
        respToFit = resp(:, chanNum);
        try
            [Icenter, Qcenter, R, error] = fitResonator(real(respToFit), imag(respToFit));
            disp(['I center ', num2str(Icenter)])
            disp(['Q center ', num2str(Qcenter)])
            disp(['Radius ', num2str(R)])
            resonatorFit.Icenter = Icenter;
            resonatorFit.Qcenter = Qcenter;
            resonatorFit.R = R;

            x = 0:0.05:2*pi;
            Ifit = R*cos(x) + Icenter;
            Qfit = R*sin(x) + Qcenter;
            circ = Ifit + 1i*Qfit;

            a = abs(respToFit);
            idx = find(a==min(a), 1);
            f = freq(:, chanNum);
            F0 = f(idx);

            left = find(f>F0-delF, 1); f(left)
            right = find(f>F0+delF, 1); f(right)

            if doPlots
                figure;
                    %assume higher level code has established a figure or we create a new one
                subplot(2,2,1)
                plot(f, a, '.');grid
                hold on
                plot(f(idx), a(idx), 'r*');
                title(['Amplitude Response for ' num2str(band) '/' num2str(subband)],'FontSize',10)
                xlabel('Frequency (MHz)')
                ylabel('Response (arbs)')
                ax = axis; xt = ax(1)+0.1*(ax(2)-ax(1));
                yt=  ax(3) + 0.1*(ax(4)-ax(3));

                [subBands,subBandCenters]=getSubBandCenters(band);
                subBandCenter=subBandCenters(find(subBands==subband));
                text(xt, yt,['Sub-Band Center = ', num2str(subBandCenter), ' MHz'],'FontSize',8)

                netPhase = unwrap(angle(respToFit));
                %figure(2);
                subplot(2,2,2), plot(f, netPhase, '.');grid
                title(['Phase Response for ' num2str(band) '/' num2str(subband)],'FontSize',10)
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
                subplot(2,2,3), plot(respToFit, '.');grid, hold on
                plot(respToFit(idx),'r*')
                plot(respToFit(left), 'gx')
                plot(respToFit(right), 'g+')
                title(['Complex Response for ' num2str(band) '/' num2str(subband)],'FontSize',10)

                plot(circ, '.k')


                hold off

                pbaspect([1 1 1])
            end

            eta = (f(right) - f(left)) / (respToFit(right) - respToFit(left));
            etaMag = abs(eta);
            etaPhase = angle(eta);
            etaPhaseDeg = etaPhase * 180/pi
            etaScaled = etaMag / subBandHalfWidthMHz

            if doPlots
                %figure(4)
                subplot(2,2,4), plot(respToFit * eta, '.'), grid, hold on
                plot(eta * respToFit(idx), 'r*')
                plot(eta * respToFit(right), 'g+')
                plot(eta * respToFit(left), 'gx')
                plot(circ * eta, 'k.')

                pbaspect([1 1 1])	    

                ax = axis; xt = ax(1) + 0.1*(ax(2)-ax(1));
                yt = ax(4) - 0.1*(ax(4)-ax(3));
                text(xt, yt, ['Line @ ', num2str(res), ' MHz    (' num2str(res - bandCenterMHz) ' wrt band center'])

                yt = ax(3) + 0.1*(ax(4)-ax(3));
                Fc = F0 + bandCenter(band);
                text(xt, yt, ['Min @ ', num2str(Fc), ' MHz    (' num2str(Fc-bandCenterMHz) ' wrt band center'])

                yt = ax(2) - 0.05*(ax(2)-ax(1));
                text(xt, yt, sprintf('ch%d',chan(ii)));
                hold off
            end

            % this is a silly dynamic allocation but I will let it slide
            % for now
            % this is a silly dynamic allocation but I will let it slide
            % for now
            etaOut(chan(ii)+1).('eta')=eta;
            etaOut(chan(ii)+1).('F0') =F0;
            etaOut(chan(ii)+1).('latency')=latency;
            etaOut(chan(ii)+1).('resp')=resp;
            etaOut(chan(ii)+1).('f')=f;
            etaOut(chan(ii)+1).('subband')=subband;
            etaOut(chan(ii)+1).('band')=band;
            etaOut(chan(ii)+1).('Foff')=Foff;
            etaOut(chan(ii)+1).('res')=res;
            etaOut(chan(ii)+1).('etaPhaseDeg')=etaPhaseDeg;
            etaOut(chan(ii)+1).('etaScaled')=etaScaled;
            etaOut(chan(ii)+1).('chan')=chan(ii);

            etaOut(chan(ii)+1).('Icenter') = resonatorFit.Icenter;
            etaOut(chan(ii)+1).('Qcenter') = resonatorFit.Qcenter;
            etaOut(chan(ii)+1).('R') = resonatorFit.R;
            etaOut(chan(ii)+1).('error') = std(resonatorFit.error);

            if doPlots
                figureFileName = fullfile(resultsDir, [num2str(ctime), '_etaEst_b', num2str(band), '_sb', num2str(subband), 'ch', num2str(chan(ii)), '.png']);
                saveas(gcf, figureFileName);
            end
        catch
            display(['Failed to calibrate line number ' num2str(ii)])
            etaPhaseDeg(ii) = 0;
            etaScaled(ii) = 0;
        end    
            
            
        if doPlots
            close all
        end
        
    end

    etaOutFileName = fullfile(resultsDir, [num2str(ctime), '_etaOut.mat']);
    save(etaOutFileName, 'etaOut', 'etaCfg');

    %system('rm /data/cpu-b000-hp01/cryo_data/data2/current_eta');
    %system(sprintf('ln -s %s /data/cpu-b000-hp01/cryo_data/data2/current_eta', etaOutFileName));

    runFileName = fullfile(resultsDir, [num2str(ctime), '.mat']);
    writeRunFile(baseRootPath, runFileName);

    if lockBandAtEndofEtaScan
        reLock(band);
    end

    toc
end
