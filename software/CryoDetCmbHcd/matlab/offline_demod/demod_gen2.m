folder = '/home/common/data/cpu-b000-hp01/cryo_data/data2/';

file = '20180424/1524584170.dat'

fileName = fullfile(folder, file);

numPhi0 = 'rtm';

% this is the phi0Rate, not the flux ramp rate
phi0Rate = 9060;

decimation = 1;


[phase_all, psd_pow, pwelch_f, time] = process_demod(fileName, numPhi0, phi0Rate, decimation, outputName);

%outputName = './output/1524583589_output';
%save(strcat(folder, outputName, '.mat'))

%/home/common/data/cpu-b000-hp01/cryo_data/data2/20180328/1522237354_Ch0.dat