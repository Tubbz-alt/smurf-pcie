function find_resonators(calibrate,debug,takedata);
 %to calibrate, takedata and calibrate must both be 1.
 %to find resonators just set takedata to 1.
 
% calibrate = 0;
% debug=1;
% takedata=0;
tryfit=0;
%clear;
    %close all
    % calibrate=0;  %set to 1 for calibration
    % debug=1; %graphs you might want to see & use test data
    % takedata=0;
    % tryfit=0;
    location='NIST';

    if takedata == 1
    % Turn off Controls%%%
    lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:enable','True')

    end


    % %%%%% Write the proper noise file%%%%%%
    % 
    % string1='source /afs/slac.stanford.edu/g/lcls/vol9/package/pyrogue/control-server/current/setup_epics.sh';
    % filedir='/afs/slac.stanford.edu/u/rl/dandvan/cryo_det/matlab/';
    % filename='broad_noise4.csv';
    % string2=['caput -S mitch_epics:AMCc:FpgaTopLevel:AppTop:DacSigGen[0]:LoadCsvFile ' filedir filename];
    % 
    % 
    % fid = fopen('write_noise.sh','wt');
    % fprintf(fid, '%s\n%s', string1, string2);
    % fclose(fid);
    % 
    % !chmod 777 /afs/slac.stanford.edu/u/rl/dandvan/cryo_det/matlab/write_noise.sh
    % !/afs/slac.stanford.edu/u/rl/dandvan/cryo_det/matlab/write_noise.sh
    % 
    % 
    % 
    % delay_counts=round(214); %211 for calibration through chassis  202 is as close as I can get for ADC to DAC direct  222 with comb filter
    % calc_time_delay=210*(1/307.2e6);
    % lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:DacSigTrigDelay',delay_counts)



    %%%set up some graphic parameters%%%%%

    x0=0;
    y0=100;
    width=300;
    height=200;



    %%%%%Some General Stuff%%%%%%
    %%%%%%Set Analysis Bandwidth%%%%%%
    fbandwidth=249e6;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    data_length=2^16; %length of data record to read from ADC
    compare_length=2^14; %compare to original file length
    N=data_length;
    tsamp=1/614.4e6; %current sample rateamplitude
    fs=1/tsamp;
    fif=450e6;
    tif=1/fif;

    scale=0.99; %To keep from saturating or to set scale at will

    filedir='/home/cryo/matlab/';
    %filename='broad_noise4_NIST.csv';
    filename='broad_noise4_NIST.csv';
    string1='';
    NumberObands=4;
    if takedata==1
        %%%%% Write the proper noise file%%%%%%


        string2=['caput -S mitch_epics:AMCc:FpgaTopLevel:AppTop:DacSigGen[0]:LoadCsvFile ' filedir filename];


        fid = fopen('write_noise.sh','wt');
        fprintf(fid, '%s\n%s', string1, string2);
        fclose(fid);
    % 
    %     !chmod 777 /afs/slac.stanford.edu/u/rl/dandvan/cryo_det/matlab/write_noise.sh
    %     !/afs/slac.stanford.edu/u/rl/dandvan/cryo_det/matlab/write_noise.sh
    %      !chmod 777 write_noise.sh
    %      !./write_noise.sh



        delay_counts_orig = lcaGet('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:DacSigTrigDelay');
        %Set up to play out of csv signal generator
       waveselect_orig = lcaGet('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:waveformSelect');
       wavestart_orig = lcaGet('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:waveformStart');



        delay_counts=round(214); %211 for calibration through chassis  202 is as close as I can get for ADC to DAC direct  222 with comb filter
        calc_time_delay=210*(1/307.2e6);
        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:DacSigTrigDelay',delay_counts)
        %Set up to play out of csv signal generator
        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:waveformSelect',1)
        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:waveformStart',1)

    %%%%%   Main Loop %%%%%%

    Idata=zeros(NumberObands,data_length);
    Qdata=zeros(NumberObands,data_length);
    ampls=zeros(NumberObands,data_length);
    signal=zeros(NumberObands,data_length);
    tfsize=2^14;
    tfarray=zeros(NumberObands,tfsize);
    tffreq=zeros(NumberObands,tfsize);
    TF_Amp=zeros(NumberObands,tfsize);
    tfphase=zeros(NumberObands,tfsize);
        for i=1:NumberObands
    x0=0;
    y0=800;
    width=300;
    height=200;



pause(5)

        if i==1
            %%%   Ch1  %%%
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch3')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch2')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapOut',0)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapIn',0)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','UserData')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','UserData')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','OutputOnes')

        elseif i==2
            %%%   Ch2   %%%   
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch0')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch1')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapOut',0)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapIn',0)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','UserData')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','UserData')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','OutputOnes')   


        elseif i==3   
            %%%   Ch3   %%%  
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch7')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch6')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapOut',0)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapIn',0)
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
            %%%   Ch3   %%%  High Band
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch6')
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch7')
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapOut',1)
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapIn',1)
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','UserData')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','UserData')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','OutputOnes')    

        elseif i==4
           %%%  Ch4 %%%  
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch4')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch5')
    %         lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]',23)
    %         lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]',24)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapOut',0)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapIn',0)
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','OutputOnes')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','UserData')
           lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','UserData') 
    %        %%%  Ch4 %%%   High Band
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[0]','Ch5')
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:DaqMuxV2[0]:InputMuxSel[1]','Ch4')
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapOut',1)
    %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:iqSwapIn',1)
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[0]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[1]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[2]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[3]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[4]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[5]','OutputOnes')   
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[6]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[7]','OutputOnes')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[8]','UserData')
    % %        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdTx:dataOutMux[9]','UserData') 
        end



           %%%%%%%Take the DATA%%%%%%%%
        global DMBufferSizePV
        csvfilename=char(lcaGet('mitch_epics:AMCc:FpgaTopLevel:AppTop:DacSigGen[0]:CsvFilePath'));  %get for later
        setBufferSize(data_length)
        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:CmdDacSigTrigArm',1)
        %triggerDM
        pause(2) %Needed to assure time alignment




        stm_size = lcaGet(DMBufferSizePV);
        Idata(i,:)=lcaGet('mitch_epics:AMCc:Stream0', stm_size);
        Qdata(i,:)=lcaGet('mitch_epics:AMCc:Stream1', stm_size);
        ampls(i,:)=sqrt(Idata(i,:).^2 + Qdata(i,:).^2);



    % scaleI=ampl/max(abs(Idata))*1;Idata=lcaGet('mitch_epics:AMCc:Stream0', stm_size);
    mem_length = N;	% memory length for the built-in network analyzer

    % make a time vector
    time = linspace(0,tsamp*mem_length,mem_length);

    if debug==1
        figure(1) %Plot Time Domain Data
        plot(time/tsamp,Idata(i,:),time/tsamp,Qdata(i,:));
        legend('I','Q');
        set(gcf,'units','points','position',[x0,y0,width,height])
        x0=x0+width;
    end

    % iqdata=zeros(N,4);   %generate four column variable with length of the data (32k)
    % iqdata(:,1)=Idata; %copy file into 1st column
    % iqdata(:,2)=Qdata; %copy file into 2nd column
    % iqdata(:,3)=round(Idata); 
    % iqdata(:,4)=round(Qdata);

    %%%% Create the complex signal %%%%

    signal(i,:)=(Idata(i,:)+1i*Qdata(i,:))';
    sig_long = signal;


    N=length(sig_long);
    %win= blackman(N); % window function (blackman)
    win=ones(N,1);  %Data should be repeating 

    signl=signal(i,:);

    signal_windowed=signl'.*win;

    %%%take FFT of windowed signal %%%%
    signal_win1=fftshift((fft(signal_windowed)));
    IS_win1 = real(signal_win1);
    QS_win1 = imag(signal_win1);

    f = (-fs/2:fs/(N-1):round(fs/2));

    IS_win_h1 = IS_win1(1:length(f));  
    IS_win_h1 = IS_win_h1 / sum(win); 
    QS_win_h1 = QS_win1(1:length(f));  
    QS_win_h1 = QS_win_h1 / sum(win); 

    %The following is scaled by 2^15 because we are calculating dB full
    %Scale (dBFS) full scale is +/- 2^15
    IS_win_h1=IS_win_h1./(2^15);
    QS_win_h1=QS_win_h1./(2^15);
    Amp=sqrt(IS_win_h1.^2+QS_win_h1.^2);
    if debug==1
        figure(2) %Plot FFT of Time domain Data
        plot(f/1e6, 20*log10(Amp));
        axis([-350 350 -140 10]);
        xlabel('frequency MHz')
        ylabel('dBFS')
        set(gcf,'units','points','position',[x0,y0,width,height])
        x0=x0+width;

    end


    %%%%Do the Transfer Function Estimate%%%%%%

    %refIQ=csvread('broad_noise1.csv'); % Full Scale Noise
    refIQ=csvread(filename); % -20 dBFS Noise
    iqref=(refIQ(:,1)+1i*refIQ(:,2));

    C=xcorr(iqref,signl);  %Used to Find time alighment with ref signal

    if debug==1   
        figure(3) % Plot correlation 
        plot(abs(C))
        set(gcf,'units','points','position',[x0,y0,width,height])
        x0=x0+width;
    end

    sadjust=0;  %to tweak alignment ... ended up not making any difference
    corrmax=find(C==max(C),1);
    if corrmax > N  %  this if-then is used to find where the data best aligns with reference
        shift_point=2*N-corrmax+sadjust;
    else
        shift_point=N-corrmax+sadjust;
    end
    shift_point=1; %no longer need correlation because we are trigger timed.
    newdata=signl(shift_point:shift_point+compare_length-1); %create data based upon the best correlation


    %%%%Plot Transfer Function%%%%%


    [tfarray(i,:),tffreq(i,:)]=tfestimate((iqref),(newdata),[],[],2^14,fs,'centered');
    %[tfarray(i,:),tffreq(i,:)]=tfestimate((iqref),(iqref),[],[],2^14,fs,'centered');

    TF_Amp(i,:)=abs(tfarray(i,:));
    tfphase(i,:)=(180/pi)*unwrap(atan2(imag(tfarray(i,:)),real(tfarray(i,:))));
    %TF_Amp=TF_Amp/max(TF_Amp); % Normalize to 0 dB.  comment if you want to know the absolute gain
    figure(4)
    plot(tffreq(i,:)/1e6,20*log10(TF_Amp(i,:)));
    axis([-400 400 -50 50])
    xlabel('frequency MHz');
    ylabel('Amplitude dB');
    grid on
    set(gcf,'units','points','position',[x0,y0,width,height])
    x0=x0+width;





    %save measurement data
    filename_data='resonator_data.mat';
    save(filename_data,'tfarray','tffreq','TF_Amp','tfphase')


    %%%% Get rid of phase slope %%%%%






    end


    filename_cal=['calibration_tf_' location '.mat'];



    if calibrate == 1 
        tfcalarray=tfarray;
        save(filename_cal,'tfcalarray','tffreq')




    else


        tf_array_cald=zeros(NumberObands,tfsize);
        tfphase_cald=zeros(NumberObands,tfsize);
        TF_Amp_cald=zeros(NumberObands,tfsize);
        zeroed_phase=zeros(NumberObands,tfsize);

        for j=1:NumberObands




            load(filename_cal);
            tf_array_cald(j,:)=tfarray(j,:)./tfcalarray(j,:);
            TF_Amp_cald(j,:)=abs(tf_array_cald(j,:));
            tfphase_cald(j,:)=(180/pi)*unwrap(atan2(imag(tf_array_cald(j,:)),real(tf_array_cald(j,:))));
            figure(500)
            plot(tffreq(j,:)/1e6,20*log10(TF_Amp_cald(j,:)));
            xlabel('frequency MHz');
            ylabel('calibrated amplitude (dB)');
            figure(501)
            plot(tffreq(j,:)/1e6,tfphase_cald(j,:));
             xlabel('frequency MHz');
            ylabel('calibrated phase (degrees)');
            idxred=500;

             idxlow=round(length(tffreq(j,:))/2-fbandwidth*length(tffreq(j,:))/(max(tffreq(j,:))-min(tffreq(j,:))));
             idxhigh=round(length(tffreq(j,:))/2+fbandwidth*length(tffreq(j,:))/(max(tffreq(j,:))-min(tffreq(j,:))));
             phase_slope=(tfphase_cald(j,idxhigh-idxred)-tfphase_cald(j,idxlow+idxred))/(tffreq(j,idxhigh-idxred)-tffreq(j,idxlow+idxred));
             zeroed_phase(j,:)=tfphase_cald(j,:)-phase_slope.*tffreq(j,:);
             zeroed_phase(j,:)=zeroed_phase(j,:)-mean(zeroed_phase(j,idxlow:idxhigh));
    %        zeroed_phase=tfphase;
             figure(5)
             plot(tffreq(j,:)/1e6,zeroed_phase(j,:))
             axis([-400 400 -180 180])
             xlabel('frequency MHz')
             ylabel('Zeroed Phase Degrees')
             grid on
             set(gcf,'units','points','position',[x0,y0,width,height])
             x0=x0+width;
             figure(60)    
             of=0;
            plot(of+(tffreq(1,idxlow:idxhigh)+4.25e9)/1e9,20*log10(TF_Amp_cald(1,idxlow:idxhigh)),of+(tffreq(1,idxlow:idxhigh)+4.75e9)/1e9,20*log10(TF_Amp_cald(2,idxlow:idxhigh)),of+(tffreq(1,idxlow:idxhigh)+5.25e9)/1e9,20*log10(TF_Amp_cald(3,idxlow:idxhigh)),of+(tffreq(1,idxlow:idxhigh)+5.75e9)/1e9,20*log10(TF_Amp_cald(4,idxlow:idxhigh)))

            tffreq_concat=[(tffreq(1,idxlow:idxhigh)+4.25e9) (tffreq(1,idxlow:idxhigh)+4.75e9) (tffreq(1,idxlow:idxhigh)+5.25e9) (tffreq(1,idxlow:idxhigh)+5.75e9)]; 
            TF_Amp_cald_concat=[ TF_Amp_cald(1,idxlow:idxhigh) TF_Amp_cald(2,idxlow:idxhigh)  TF_Amp_cald(3,idxlow:idxhigh) TF_Amp_cald(4,idxlow:idxhigh)];
            TF_phase_cald_concat=[ zeroed_phase(1,idxlow:idxhigh) zeroed_phase(2,idxlow:idxhigh)  zeroed_phase(3,idxlow:idxhigh) zeroed_phase(4,idxlow:idxhigh)];



        end

    end   


    end
    figure(70)
    plot(tffreq_concat,TF_phase_cald_concat);
if takedata == 0
    filename_cal=['calibration_tf_' location '.mat'];
    filename_data='resonator_data.mat';
    load(filename_data);
        for j=1:NumberObands




            load(filename_cal);
            tf_array_cald(j,:)=tfarray(j,:)./tfcalarray(j,:);
            TF_Amp_cald(j,:)=abs(tf_array_cald(j,:));
            tfphase_cald(j,:)=(180/pi)*unwrap(atan2(imag(tf_array_cald(j,:)),real(tf_array_cald(j,:))));
            figure(500)
            plot(tffreq(j,:)/1e6,20*log10(TF_Amp_cald(j,:)));
            xlabel('frequency MHz');
            ylabel('calibrated amplitude (dB)');
            figure(501)
            plot(tffreq(j,:)/1e6,tfphase_cald(j,:));
             xlabel('frequency MHz');
            ylabel('calibrated phase (degrees)');
            idxred=500;

             idxlow=round(length(tffreq(j,:))/2-fbandwidth*length(tffreq(j,:))/(max(tffreq(j,:))-min(tffreq(j,:))));
             idxhigh=round(length(tffreq(j,:))/2+fbandwidth*length(tffreq(j,:))/(max(tffreq(j,:))-min(tffreq(j,:))));
             phase_slope=(tfphase_cald(j,idxhigh-idxred)-tfphase_cald(j,idxlow+idxred))/(tffreq(j,idxhigh-idxred)-tffreq(j,idxlow+idxred));
             zeroed_phase(j,:)=tfphase_cald(j,:)-phase_slope.*tffreq(j,:);
             zeroed_phase(j,:)=zeroed_phase(j,:)-mean(zeroed_phase(j,idxlow:idxhigh));
    %        zeroed_phase=tfphase;
             figure(500)
             plot(tffreq(j,:)/1e6,zeroed_phase(j,:))
             axis([-400 400 -180 180])
             xlabel('frequency MHz')
             ylabel('Zeroed Phase Degrees')
             grid on
             set(gcf,'units','points','position',[x0,y0,width,height])
        end
             x0=x0+width;
             figure(60)    
             of=0;
            plot(of+(tffreq(1,idxlow:idxhigh)+4.25e9)/1e9,20*log10(TF_Amp_cald(1,idxlow:idxhigh)),of+(tffreq(1,idxlow:idxhigh)+4.75e9)/1e9,20*log10(TF_Amp_cald(2,idxlow:idxhigh)),of+(tffreq(1,idxlow:idxhigh)+5.25e9)/1e9,20*log10(TF_Amp_cald(3,idxlow:idxhigh)),of+(tffreq(1,idxlow:idxhigh)+5.75e9)/1e9,20*log10(TF_Amp_cald(4,idxlow:idxhigh)))

            tffreq_concat=[(tffreq(1,idxlow:idxhigh)+4.25e9) (tffreq(1,idxlow:idxhigh)+4.75e9) (tffreq(1,idxlow:idxhigh)+5.25e9) (tffreq(1,idxlow:idxhigh)+5.75e9)]; 
            TF_Amp_cald_concat=[ TF_Amp_cald(1,idxlow:idxhigh) TF_Amp_cald(2,idxlow:idxhigh)  TF_Amp_cald(3,idxlow:idxhigh) TF_Amp_cald(4,idxlow:idxhigh)];



 
    
    
    
    
    
    
    
    
end

    
    figure(50)
    plot((tffreq(1,:)+4.25e9)/1e9,20*log10(TF_Amp(1,:)),(tffreq(2,:)+4.75e9)/1e9,20*log10(TF_Amp(2,:)),(tffreq(3,:)+5.25e9)/1e9,20*log10(TF_Amp(3,:)),(tffreq(2,:)+5.75e9)/1e9,20*log10(TF_Amp(4,:)))
    xlabel('frequency (GHz)')
    ylabel('Raw Amplitude (dB)')
    axis([3.5 6.5 -100 20])


    if calibrate == 0

          %%%%%%  Find dips using findpeaks %%%%%%
        mindip=5;
        figure(6)
        banddata=(20*log10(1./TF_Amp_cald_concat));
        banddata_norm=(20*log10(TF_Amp_cald_concat));
        banddata_norm_lin=TF_Amp_cald_concat;
        fdata=tffreq_concat;
        findpeaks(banddata,fdata/1e6,'MinPeakDistance',5e6/1e6,'MinPeakHeight',mindip);
        [pks,fpks]=findpeaks(banddata,fdata,'MinPeakDistance',5e6,'MinPeakHeight',mindip);
        xlabel('frequency MHz')
        set(gcf,'units','points','position',[x0,y0,width,height])
        x0=x0+width;
        if tryfit==1
           numPeaks=length(fpks);         
            





        %%%%% Beginings of curve fitting #####


        span=10e6;
        fitfreqs=zeros(numPeaks:1);
        fitQs=zeros(numPeaks:1);
        counter =1;
        % try







%             for k=1:numPeaks
%             for k=1:numPeaks
%                
%                 peaktofit=k;
%                 foffset=0; % offset to avoid negative frequency resonances
%                 tffreq_trans=tffreq+foffset;
%                 fdata_trans=fdata+foffset;
%                 fpks_trans=fpks+foffset;
%                 wo = 2*pi*fpks_trans(peaktofit);
%                 Qoguess=300;
% 
% 
%                 idxl=find(fdata==fpks(peaktofit))-round((span/2)*(length(fdata)/(max(fdata)-min(fdata))));
%                 idxh=find(fdata==fpks(peaktofit))+round((span/2)*(length(fdata)/(max(fdata)-min(fdata))));
% 
%                 ampl=abs(10^(pks(peaktofit)/20));
%                 Hw=ampl*((wo/Qoguess)*1i*2*pi.*fdata_trans)./((1i*2*pi*fdata_trans).^2 + 1i*2*pi*fdata_trans.*(wo/Qoguess) + wo^2);
%                 figure(7)
%                 plot(fdata_trans(idxl:idxh),20*log10(abs(1./Hw(idxl:idxh))),fdata_trans(idxl:idxh),banddata_norm(idxl:idxh));
%                 set(gcf,'units','points','position',[x0,y0,width,height])
% 
% 
%                  fdat=fdata_trans(idxl:idxh)/1e6;
%                  data=banddata_norm_lin(idxl:idxh);
%                 % figure(10)
%                 wot=wo/1e6;
%                 % newdat=1./abs(((ampl*(wot/Qoguess)*1i*2*pi.*fdat)./(-(2*pi.*fdat).^2 + 1i*2*pi.*fdat*(wot/Qoguess) + wot^2)));
%                 % plot(fdat,newdat);
%                 f0=wot/2/pi+.02;
%                 gamma=1.2;
%                 ampp=1; % 0<=ampp<1
%                 passloss=0.275;
% 
%                 %http://mathworld.wolfram.com/LorentzianFunction.html
%                 %%%Normalized Lorentz (amp=1)
%                 lorentz=(pi*gamma/2)*(1/pi)*(0.5*gamma)./((fdat-f0).^2 + (0.5*gamma)^2);
% 
%                 lorentzinv=passloss*(1-ampp*lorentz);
%                 figure(7)
%                 plot(fdat,data,fdat,lorentzinv);
% 
%                 equation_test=passloss*(1-ampp*((pi*gamma/2)*(1/pi)*(0.5*gamma)./((fdat-f0).^2 + (0.5*gamma)^2)));
% 
%                 FUN=['l(fdat)=passloss*(1-ampp*(pi*gamma/2)*(1/pi)*(0.5*gamma)./((fdat-f0).^2 + (0.5*gamma)^2)); passloss=0.25; gamma=1.2; ampp=1;f0=' num2str(f0)];
% 
%                 aa=ezfit(fdat,data,FUN);
% 
%                 fwhm=aa.m(3);
%                 fitQs(k)=aa.m(2)/fwhm;
%                 fitfreqs(k)=aa.m(2)*1e6-foffset;fsandqs=zeros(length(fitfreqs),2);
%         fsandqs(:,1)=fitfreqs+5.25e9;
%         fsandqs(:,2)=fitQs;
%         csvfilename=['fitfreqsandQs_' location '.csv'];
%         csvwrite(csvfilename,fsandqs);
%                 delta(k)=fitfreqs(k)-fpks(k);
% 
%                 counter=counter+1;
% 
%                 %set(gcf,'units','points','position',[x0,y0,width,height])
% 

%             end

%                   figure(11)
%                 plot(fitQs)
%                 %x0=x0+width;
%                 figure(8)
%                 [pks,fpks]=findpeaks(banddata,fdata,'MinPeakDistance',5e6,'MinPeakHeight',mindip);
%                 plot(delta/1e3);
%                 xlabel('resonator number')
%                 ylabel('frequency change (kHz)')
%                 %set(gcf,'units','points','position',[x0,y0,width,height])
%                 %x0=x0+width;
%                 figure(9)
%                 plot(fdat,data)
%                 showfit(FUN);
%                 %set(gcf,'units','points','position',[x0,y0,width,height])
%                 %x0=x0+width;
%                 figure(11)
%                 plot(fitQs)

   
        filename1=['multitones_' num2str(length(fitfreqs))  '_' num2str(round(juliandate(datetime)))  'fitfreqs' location '.mat'];
        save(filename1,'fpks','fitfreqs');

%         fsandqs=zeros(length(fitfreqs),2);
%         fsandqs(:,1)=fitfreqs+5.25e9;
%         fsandqs(:,2)=fitQs;
%         csvfilename=['fitfreqsandQs_' location '.csv'];
%         csvwrite(csvfilename,fsandqs);

    end

if takedata == 1
        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:DacSigTrigDelay',delay_counts_orig)
        %Set up to play out of csv signal generator
        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:waveformSelect',waveselect_orig)
        lcaPut('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:waveformStart',wavestart_orig)
end

%%%%create resonator file;

b0pks=find(fpks<4.5e9);
fb0pks=fpks(b0pks);
b1pks=find(4.5e9<fpks & fpks <5e9);
fb1pks=fpks(b1pks);
b2pks=find(5.e9<fpks & fpks < 5.5e9);
fb2pks=fpks(b2pks);
b3pks=find(5.5e9<fpks & fpks < 6e9);
fb3pks=fpks(b3pks);

ab0=zeros(length(b0pks),3);
ab1=zeros(length(b1pks),3);
ab2=zeros(length(b2pks),3);
ab3=zeros(length(b3pks),3);
    
for m=1:length(b0pks)    
  [band0 res0]=f2band(fb0pks(m)/1e6,4250)  ;
  ab0(m,1)=band0;
  ab0(m,2)=res0;
  ab0(m,3)=fb0pks(m)/1e6;
end
[b0 c0]=unique(ab0(:,1));
dlmwrite('current_resB0',double(ab0(c0,:)),'delimiter','\t','precision','%0.3f');

for m=1:length(b1pks)  
  [band1 res1]=f2band(fb1pks(m)/1e6,4750)  ;
  ab1(m,1)=band1;
  ab1(m,2)=res1;
  ab1(m,3)=fb1pks(m)/1e6;
end
[b1 c1]=unique(ab1(:,1));
dlmwrite('current_resB1',double(ab1(c1,:)),'delimiter','\t','precision','%0.3f');

for m=1:length(b2pks)  
  [band2 res2]=f2band(fb2pks(m)/1e6,5250)  ;
  ab2(m,1)=band2;
  ab2(m,2)=res2;
  ab2(m,3)=fb2pks(m)/1e6;
end
[b2 c2]=unique(ab2(:,1));
dlmwrite('current_resB2',double(ab2(c2,:)),'delimiter','\t','precision','%0.3f');

for m=1:length(b3pks)  
  [band3 res3]=f2band(fb3pks(m)/1e6,5750)  ;
  ab3(m,1)=band3;
  ab3(m,2)=res3;
  ab3(m,3)=fb3pks(m)/1e6;
end
[b3 c3]=unique(ab3(:,1));
dlmwrite('current_resB3',double(ab3(c3,:)),'delimiter','\t','precision','%0.3f');

    end



























