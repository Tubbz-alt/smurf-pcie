%This script does the eta calibration and lock a set of channels,
%reading the eta values from a text file already created.(It does not
%compute again the eta values channel by channel)



%Voltage on the FPGA associated to the tone (if it`s too high it can
%saturate for some tones). Each unit is +3dB.
Adrive=10;




file_eta = dlmread('/home/common/data/cpu-b000-hp01/cryo_data/data2/20180223/1519384030/1519384030.eta')


chan=file_eta(:,1,:)';
offset=file_eta(:,2,:)';
etaPhaseDeg=file_eta(:,3,:)';
etaScaled=file_eta(:,4,:)';


for ii=1:length(resonators)
%for ii=20:20
   configCryoChannel(rootPath, chan(ii), offset(ii), Adrive, 1, etaPhaseDeg(ii), etaScaled(ii));
end


