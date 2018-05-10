disp('!!! Remember, must read the correct ADC.  Should match the band # in setup.m');

% 2.4e6 is downconverted channel rate
Band = 1;
Fadc = 614.4e6;
rootPath = [getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];

%% What does DAC think it's putting out?
dacNumber = Band;
dacData = readDacData( rootPath, dacNumber );
figure
w = blackman(length(dacData));
pwelch(dacData, w, [], [], Fadc, 'centered')
title('DAC data PSD')

% figure
% plot(real(dacData))


%% check ADC
adcNumber = Band;
adcData = readAdcData( rootPath , adcNumber );
figure
w = blackman(length(adcData));
pwelch(adcData, w, [], [], Fadc, 'centered')
title('ADC data PSD')

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
    

