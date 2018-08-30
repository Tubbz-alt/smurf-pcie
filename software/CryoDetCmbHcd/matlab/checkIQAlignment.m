disp('!!! Remember, must read the correct ADC.  Should match the band # in setup.m');

for Band=[0,1,2,3]
    % 2.4e6 is downconverted channel rate
    Fadc = 614.4e6;
    rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[2]:'];
    
    %% What does DAC think it's putting out?
    dacNumber = Band;
    dacData = readDacData( rootPath, dacNumber );
    figure
    w = blackman(length(dacData));
    pwelch(dacData, w, [], [], Fadc, 'centered')
    title(sprintf('DAC data PSD band%d',Band))
    
    % figure
    % plot(real(dacData))
    
    
    %% check ADC
    adcNumber = Band;
    adcData = readAdcData( rootPath , adcNumber );
    figure
    w = blackman(length(adcData));
    pwelch(adcData, w, [], [], Fadc, 'centered')
    title(sprintf('ADC data PSD band%d',Band))
    
    % save data
    ctime=ctimeForFile();
    filename=num2str(ctime);
    datadir=dataDirFromCtime(ctime);
    
    adcDataFile=fullfile(datadir,[filename '_adc.mat']);
    dacDataFile=fullfile(datadir,[filename '_dac.mat']);
    
    save(adcDataFile,'adcData');
    save(dacDataFile,'dacData');

    disp(['adcDataFile=' adcDataFile]);
    disp(['dacDataFile=' dacDataFile]);
end

