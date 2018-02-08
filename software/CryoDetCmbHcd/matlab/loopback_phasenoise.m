% clear;  
close all
global DMBufferSizePV

data_length=2^22;
compare_length=2^14;
N=data_length;
tsamp=1/614.4e6; %current sample rate
fs=1/tsamp;
fif=450e6;
tif=1/fif;
Band=3;


% mitch - this will cause us to take data, then process
for takedata = [1 0]
% takedata=0;

if takedata == 1
    
% enable tone file output
    lcaPut(['mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:','waveformSelect'], 1);
    lcaPut(['mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:','waveformStart'], 1);
    

    
    
    %%%%Set Playback file to single tone%%%%%%
string1='source /afs/slac/g/lcls/package/pyrogue/control-server/current/setup_epics.sh';
filedir='/home/cryo/ssmith/cryo-det/software/CryoDetCmbHcd/matlab/toneFiles/';
%filename='multitone_2MHztones_baseband16k.csv';

filename='multitone_1tonehalfscale_baseband16k.csv';
string2=['caput -S mitch_epics:AMCc:FpgaTopLevel:AppTop:DacSigGen[0]:CsvFilePath ' filedir filename]


string3=['caput -S mitch_epics:AMCc:FpgaTopLevel:AppTop:DacSigGen[0]:LoadCsvFile ' filedir filename]

fid = fopen('write_csv2.sh','wt');
fprintf(fid, '%s\n%s\n%s', string1, string2, string3);
fclose(fid);

!chmod 777 write_csv2.sh
!write_csv2.sh
    
    
    
    
    %%%%% Set up Bands %%%%%%
    

    
%%%  Turn off bands not being measured %%%%%
%     if Band==1
%         %%%   Ch1  %%%
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch3')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch2')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','UserData')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','UserData')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','OutputOnes')
% 
%     elseif Band==2
%         %%%   Ch2   %%%   
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch0')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch1')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','UserData')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','UserData')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','OutputOnes')   
% 
% 
%     elseif Band==3   
%         %%%   Ch3   %%%  
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch7')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch6')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','UserData')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','UserData')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','OutputOnes')    
% 
%     elseif Band==4
%        %%%  Ch4 %%%  
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch4')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch5')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','OutputOnes')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','UserData')
%        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','UserData') 
%     end
    
%%%%All Bands On %%%%%    
    if Band==1
        %%%   Ch1  %%%
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch3')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch2')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','UserData')

    elseif Band==2
        %%%   Ch2   %%%   
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch0')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch1')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','UserData')


    elseif Band==3   
        %%%   Ch3   %%%  
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch7')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch6')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','OutputOnes')  

    elseif Band==4
       %%%  Ch4 %%%  
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch4')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch5')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','UserData')
       lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','UserData')
    end 
    
    
% For taking long data    
rootPath = 'mitch_epics';
fileName = 'myData.dat';
dataLength = data_length; % max is 2^25
dataType = 'adc';
channel = Band;
if exist(fileName, 'file') == 2
    delete(fileName)
end
takeDebugData( rootPath, fileName, dataLength, dataType, channel )

% data = processData( fileName );
% Idata=(data(1:end-2,1)');  %  This is a hack for JESD misalignment
% Qdata=(data(3:end,2)');
% data_length=length(Idata);
% N=data_length;    
%     
%     
% 
%     scale=0.99;
%     time=tsamp*(0:1:data_length-1);

%     setBufferSize(data_length)
%     lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:CmdDacSigTrigArm',1)
%     %triggerDM
%     pause(1)
%     stm_size = lcaGet(DMBufferSizePV);
%     Idata=lcaGet('mitch_epics:AMCc:Stream0', stm_size);
%     Qdata=lcaGet('mitch_epics:AMCc:Stream1', stm_size);
%     ampls=sqrt(Idata.^2 + Qdata.^2);


    
    
    
%     figure(1)data = processData( fileName );
%     Idata=(data(1:end-2,1)');  %  This is a hack for JESD misalignment
%     Qdata=(data(3:end,2)');
%     data_length=length(Idata);
%     N=data_length;    
%     plot(time/tsamp,Idata,time/tsamp,Qdata);
%     legend('I','Q');
%     phases=atan2(Qdata,Idata);
%     meanphase=mean(phases)*180/pi;
%     iqdata=zeros(N,4);   %generate four column variable with length of the data (32k)
%     iqdata(:,1)=Idata; %copy file into 1st column
%     iqdata(:,2)=Qdata; %copy file into 2nd column
%     iqdata(:,3)=round(Idata); 
%     iqdata(:,4)=round(Qdata);
% 
% 
%     figure(2)
%     signal=(Idata+1i*Qdata)';
%     sig_long = signal;
% 
%     N=length(sig_long);
%     %win= blackman(N); % window function (blackman)
%     win=ones(N,1);
%     % Iwindowed1=(Idata)'.*win; %Windowed Sginal
%     % Qwindowed1=(Qdata)'.*win; %Windowed Sginal
%     signal_windowed=sig_long.*win;
% 
%     signal_win1=fftshift((fft(signal_windowed)));
%     IS_win1 = real(signal_win1);
%     QS_win1 = imag(signal_win1);
% 
%     f = (-fs/2:fs/(N-1):round(fs/2));
%     %f=abs(450e6-f);
%     IS_win_h1 = IS_win1(1:length(f));
%     IS_win_h1 = IS_win_h1 / sum(win); 
%     QS_win_h1 = QS_win1(1:length(f));  
%     QS_win_h1 = QS_win_h1 / sum(win); 
% 
%     %The following is scaled by 2^15 because we are calculating dB full
%     %Scale (dBFS) full scale is +/- 2^15
%     IS_win_h1=IS_win_h1./(2^15);
%     QS_win_h1=QS_win_h1./(2^15);
%     Amp=sqrt(IS_win_h1.^2+QS_win_h1.^2);
%     phases=(atan2(QS_win_h1,IS_win_h1));
%    
%     
%     [pks,freqpk]=findpeaks(20*log10(Amp),f/1e6,'MinPeakHeight',-62);
%     %plot(f/1e6, 20*log10(abs(IS_win_h1)),f/1e6, 20*log10(abs(QS_win_h1)));
%     
%   plot_complex_fft(signal,fs,16,2)
%  axis([-260 260 -130 -0])
%  title(['Full Band Plot for Band ' num2str(Band) ' (DAC/Up/Down convert/ADC)']);

% restore DSP output
    lcaPut(['mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:','waveformSelect'], 0);
    lcaPut(['mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:','waveformStart'], 0);

end
anadata=1;
if anadata == 1 && takedata == 0
    rootPath = 'mitch_epics';
    fileName = 'myData.dat';
    if exist( fileName, 'file' ) ~= 2
       error(['File ', fileName, ' does not exist!']) 
    end
    dataLength = 2^25; % max is 2^25
    dataType = 'adc';
    channel = 1;
    data = double(processData( fileName, 'int16' ));
% 
    Qdata=(data(1:end-2,1)');  %  This is a hack for JESD misalignment
    Idata=(data(3:end,2)');
    
%     
%     Qdata=(data(1:end,1)');  %  This is a hack for JESD misalignment
%     Idata=(data(1:end,2)');
%     
    
    % check for ADC saturation
    maxI  = find(abs(Idata) >= 2^15-1);
    maxQ  = find(abs(Qdata) >= 2^15-1);
    if ~isempty(maxI) || ~isempty(maxQ)
       error('ADC saturating!') 
    end
    

    
    data_length=length(Idata);
    N=data_length;    
    
    

    scale=0.99;
    time=tsamp*(0:1:data_length-1);    
    
    
    
    figure(1)
    plot(time/tsamp,Idata,time/tsamp,Qdata);
    legend('I','Q');
    phases=atan2(Qdata,Idata);
    meanphase=mean(phases)*180/pi;
    iqdata=zeros(N,4);   %generate four column variable with length of the data (32k)
    iqdata(:,1)=Idata; %copy file into 1st column
    iqdata(:,2)=Qdata; %copy file into 2nd column
    iqdata(:,3)=round(Idata); 
    iqdata(:,4)=round(Qdata);


    figure(2)
    signal=(Idata+1i*Qdata)';
    sig_long = signal;

    N=length(sig_long);
    %win= blackman(N); % window function (blackman)
    win=ones(N,1);
    % Iwindowed1=(Idata)'.*win; %Windowed Sginal
    % Qwindowed1=(Qdata)'.*win; %Windowed Sginal
    signal_windowed=sig_long.*win;

    signal_win1=fftshift((fft(signal_windowed)));
    IS_win1 = real(signal_win1);
    QS_win1 = imag(signal_win1);

    f = (-fs/2:fs/(N-1):round(fs/2));
    %f=abs(450e6-f);
    IS_win_h1 = IS_win1(1:length(f));
    IS_win_h1 = IS_win_h1 / sum(win); 
    QS_win_h1 = QS_win1(1:length(f));  
    QS_win_h1 = QS_win_h1 / sum(win); 

    %The following is scaled by 2^15 because we are calculating dB full
    %Scale (dBFS) full scale is +/- 2^15
    IS_win_h1=IS_win_h1./(2^15);
    QS_win_h1=QS_win_h1./(2^15);
    Amp=sqrt(IS_win_h1.^2+QS_win_h1.^2);
    phases=(atan2(QS_win_h1,IS_win_h1));
   
    
    [pks,freqpk]=findpeaks(20*log10(Amp),f/1e6,'MinPeakHeight',-62);
    %plot(f/1e6, 20*log10(abs(IS_win_h1)),f/1e6, 20*log10(abs(QS_win_h1)));
    
  plot_complex_fft(signal,fs,16,2)
 axis([-260 260 -130 -0])
 title(['Full Band Plot for Band ' num2str(Band) ' (DAC/Up/Down convert/ADC)']);

    
    
    
    
    
    
    
    
    
    
    
    
    
    %load('multitone_2MHztones_baseband16k.mat')
    load('toneFiles/multitone_1tonehalfscale_baseband16k.mat')
    flo=freqs_actual(1)-0; %Pick any tone you like
    sig_lo=exp(1i*(2*pi*flo*time))';
    sig_multp=sig_lo.*signal;  % Downconvert
    plotfft(sig_multp,fs,100);

    %%% Filtered Data (Get rid of sidebands)
    fp=1e6/fs;  %Be careful on ratio here
    fst=5e6/fs;

     d = fdesign.lowpass('Fp,Fst,Ap,Ast',fp,fst,0.1,50);
     Hd = design(d);
     output = filtfilt(Hd.Numerator,1,sig_multp);
    %output=sig_multp;
    plotfft(output,fs,101);
    xlim([-2 2])
    Idatfilt=real(output);
    Qdatfilt=imag(output);
    phase=unwrap(atan2(Qdatfilt,Idatfilt));
    %calibrate things
    %phase=phase+pi*sin(2*pi*10e3.*time)';
    figure(200)
    plot(Idatfilt(1000:end-1000),Qdatfilt(1000:end-1000))
    axis([-2^13 2^13 -2^13 2^13])
    figure(500)
    plot(time,Idatfilt,time,Qdatfilt)





    %%%%%%%%%%%%%%%%% Phase Noise Plot %%%%%%%%%%%%%%%%%%%%%
    f = (0:fs/N:round(fs/2));
    df=f(2)-f(1);
    win    = blackman(N);

    normphase2=phase-mean(phase);
    wphase2=normphase2.*win; %window phase
    P_win_ch2 = abs(fft(wphase2))./pi; % divide by pi for normalized to dBc
    P_win_hCh2 = 2*P_win_ch2(1:length(f));  % Not sure why this two is here
    P_win_hCh2 = P_win_hCh2 / sum(win);  % correct for windowing


    figure(7)

    % %some filtering on the FFT data - an experiment
    % d1 = designfilt('lowpassiir','FilterOrder',12, ...
    %     'HalfPowerFrequency',0.75,'DesignMethod','butter');
    % 
    % P_win_hCh2=filtfilt(d1,P_win_hCh2);



    %Scale by pi radians for dBCrad
    semilogx(f, 20*log10(P_win_hCh2)-10*log10(df)); %scaling effective noise floor by bucket size (however, will scale spurs improperly)
    % For example with pi radian signal the resultand spur level is -24.75 dB
    % for a df of 292.97 Hz
    xlabel('Frequency Hz')
    ylabel('dBC/Hz')
    axis([1 10e6  -200 0])
    legend('ch1 phase')
    set(gca, 'XTick',[10.^0 10.^1 10.^2 10.^3 10.^4 10.^5 10.^6 10.^7]);

    normphase2=phase-mean(phase);
    wphase2=normphase2.*win; %window phase
    P_win_ch2 = abs(fft(wphase2))./pi;
    P_win_hCh2 = 2*P_win_ch2(1:length(f));
    P_win_hCh2 = P_win_hCh2 / sum(win);
end

end