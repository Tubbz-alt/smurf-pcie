%clear;
%close all

%%
global DMBufferSizePV

%close all
data_length=2^19;
compare_length=2^14;
N=data_length;
tsamp=1/614.4e6; %current sample rate
fs=1/tsamp;
fif=450e6;
tif=1/fif;

scale=0.99;
time=tsamp*(0:1:data_length-1);
%%%data needs to be in multiples of 256
%%%%so, modify fif to nearest value
% Num_tones=3;
% spacing=1e6;
% fcenter=0;% For baseband(1/tsamp)/4;
% %fcenter=260e6;
% fif=fcenter-(Num_tones-1)*spacing/2;
% tif=1/fif;
% %added for sidebands
% df=100e3; %delta for the two sidebands;
setBufferSize(data_length)
lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:CmdDacSigTrigArm'],1)
%triggerDM
pause(1)

stm_size = lcaGet(DMBufferSizePV);

Qdata=lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:Stream0'], stm_size);
Idata=lcaGet([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:Stream1'], stm_size);
figure
pwelch(Idata + j*Qdata ,[],[],[],614.4e6,'centered')

figure
plot(Idata)
hold on
plot(Qdata)
