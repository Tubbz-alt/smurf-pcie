function resultsDir = setupNotches_umux16(band,Adrive,doPlots,lockBandAtEndOfEtaScan,resFile)
    tic
    
    if nargin < 1
        band=0;
    end
    smurfRoot = getSMuRFenv('SMURF_EPICS_ROOT')
    baseRootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),sprintf(':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[%d]:',band)]; 

    if nargin < 2
        Adrive=10; % roughly -33dBm at connector on SMuRF card output
    end
    
    if nargin < 3
        doPlots=true;
    end
    
    if nargin<4
        lockBandAtEndOfEtaScan=true;
    end
    
    clearvars offset chan etaPhaseDeg etaScaled

    ctime=ctimeForFile;

    % create directory for results
    datadir=dataDirFromCtime(ctime);

    resultsDir=fullfile(datadir,num2str(ctime));

    % if resuls directory doesn't exist yet, make it
    if not(exist(resultsDir))
        disp(['-> creating ' resultsDir]);
        mkdir(resultsDir);
    end
    % done creating directory for results

    %load the most recent resonator scan
    if nargin < 4
        M=dlmread(['/data/cpu-b000-hp01/cryo_data/data2/current_res_',smurfRoot]);
    else
        M=dlmread(resFile);
    end
        
    resonators_all=M(:,3,:)';

    %resonators=resonators_all(resonators_all>5.2e3)
    resonators=resonators_all;
    
    %Voltage on the FPGA associated to the tone (if it`s too high it can
    %saturate for some tones). Each unit is +3dB.
    FsweepFHalf=0.3;
    FsweepDf=0.002;
    delF=0.010; 

    Off(band);
    if doPlots
        close all;
    end
    
    bandCenterMHz = lcaGet([baseRootPath,'bandCenterMHz']);
    numberChannels = lcaGet([baseRootPath,'numberChannels']);
    numberSubBands = lcaGet([baseRootPath,'numberSubBands']);
    
    numberOfChannelsPerSubBand=floor(numberChannels/numberSubBands);
    % ideally this should be the same as the number of channels allocated
    % per sub-band; but in some testing fw limits us to fewer.
    maxNumChannelsPerSubBand=numberOfChannelsPerSubBand;
    
    digitizerFrequencyMHz=lcaGet([baseRootPath,'digitizerFrequencyMHz']);
    subBandHalfWidthMHz=(digitizerFrequencyMHz/numberSubBands);

    subbandchans = zeros(numberSubBands,1);

    clear etaOut etaCfg;
    etaOut={};
    etaCfg={};

    etaCfg.('ctime')=ctime;
    etaCfg.('Adrive')=Adrive;
    etaCfg.('FsweepFHalf')=FsweepFHalf;
    etaCfg.('FsweepDf')=FsweepDf;
    etaCfg.('delF')=delF;
    etaCfg.('bandCenterMHz')=bandCenterMHz;

    for ii =1:length(resonators)
        res = resonators(ii);
        display(' ')
        display('_________________________________________________')

        display(['Calibrate line at RF = ' num2str(res) ' MHz  IF = ' num2str(res - bandCenterMHz + 750) ' Mhz'])
        [subband, Foff] = f2band(res,band);
        subband
        Foff
    
        % track the number of channels in the band
        % right now, firmware limited to only being able
        % to track 8 channels per band; set that as a hard
        % limit
        if subbandchans(subband+1)==maxNumChannelsPerSubBand
            disp(sprintf('!! Exceeded maxNumChannelsPerSubBand=%d in band %d, have to skip this resonator at %0.3f GHz',maxNumChannelsPerSubBand,subband,res));
            continue;
        end

        % old way
        %subbandchans(subband+1) = subbandchans(subband+1)+1;
        %chan(ii) = 16*subband + subbandchans(subband+1) -1;
        channelOrder=getChannelOrder();
        chan(ii)=channelOrder(subband*numberOfChannelsPerSubBand+1+subbandchans(subband+1));
        subbandchans(subband+1) = subbandchans(subband+1)+1;
        offset(ii) = Foff;

        try     
            [eta, F0, latency, resp, f, resonatorFit] = etaEstimator(band, subband, [(offset(ii) - FsweepFHalf):FsweepDf:(offset(ii) + FsweepFHalf)],Adrive,delF,doPlots);
            
            if max(resp) - min(resp) < 1 % condition on phase jump being big enough to be a real resonance
                subbandchans(subband+1) = subbandchans(subband+1)-1; % this is stpuid but avoid rearranging things
                disp(sprintf('!! Not a resonance! Skipping at freq=%0.3f', F0))
            else
                if doPlots
                    hold on; subplot(2,2,4);
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

                etaPhaseDeg(ii) = angle(eta)*180/pi;
                etaScaled(ii) =abs(eta)/subBandHalfWidthMHz;

                % will store result to disk
                etaOut(chan(ii)+1).('eta')=eta;
                etaOut(chan(ii)+1).('F0')=F0;
                etaOut(chan(ii)+1).('latency')=latency;
                etaOut(chan(ii)+1).('resp')=resp;
                etaOut(chan(ii)+1).('f')=f;
                etaOut(chan(ii)+1).('subband')=subband;
                etaOut(chan(ii)+1).('band')=band;
                etaOut(chan(ii)+1).('Foff')=Foff;
                etaOut(chan(ii)+1).('res')=res;
                etaOut(chan(ii)+1).('etaPhaseDeg')=etaPhaseDeg(ii);
                etaOut(chan(ii)+1).('etaScaled')=etaScaled(ii);
                etaOut(chan(ii)+1).('chan')=chan(ii);

                etaOut(chan(ii)+1).('Icenter') =resonatorFit.Icenter;
                etaOut(chan(ii)+1).('Qcenter') =resonatorFit.Qcenter;
                etaOut(chan(ii)+1).('R')       =resonatorFit.R;
                etaOut(chan(ii)+1).('error')   =std(resonatorFit.error);

                if doPlots
                    % save plot for later review
                    figureFileName=fullfile(resultsDir,[num2str(ctime),smurfRoot,'_etaEst_b',num2str(band),'_sb',num2str(subband),'ch',num2str(chan(ii)),'.png']);
                    saveas(gcf,figureFileName);
                end
            end
        catch
            display(['Failed to calibrate line number ' num2str(ii)])
            etaPhaseDeg(ii) =0;
            etaScaled(ii)=0;
        end
        %if doPlots
            %close all
        %end
    end

    % write out full eta info, including data
    etaOutFileName=fullfile(resultsDir,[num2str(ctime),smurfRoot,'_etaOut.mat']);
    save(etaOutFileName,'etaOut','etaCfg');

    % update convenient link to most recent etaScan parameters
    system(sprintf('rm /data/cpu-b000-hp01/cryo_data/data2/current_eta_%s', smurfRoot));
    system(sprintf('ln -s %s /data/cpu-b000-hp01/cryo_data/data2/current_eta_%s',etaOutFileName, smurfRoot));
    
    % also save system configuration for etaScan in eta directory
    runFileName=fullfile(resultsDir,[num2str(ctime),smurfRoot,'.mat']);
    writeRunFile(baseRootPath,runFileName);

    if lockBandAtEndOfEtaScan
        reLock(band);
    end

    toc;


