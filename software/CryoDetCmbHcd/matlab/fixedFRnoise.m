addpath('./glob/');

close all;

path2datedirs='/data/cpu-b000-hp01/cryo_data/data2/';
fSample=2.4e6;

clear dls;

% right now this is too slow, but Steve is working on a faster version
videoAvg=false;
videoAvgM=20;

%Imax is only used for I and Q
%Imax=1.;
%dls={{'1518091722_Ch496.dat','quadrature direction','adc'}};
%dls={ ...
%        % dataset1
%        struct('fn','1518091859_Ch496.dat', ...
%               'label','inphase direction', ...
%               'type','adc', ...
%               'Imax',318307.4857) ...
%        % dataset2
%        struct('fn','1518091722_Ch496.dat', ...
%               'label','quadrature direction', ...
%               'type','adc', ...
%               'Imax',318307.4857), ...
%    };

%dls={ ...
        % dataset1
        %struct('fn','1519171138_Ch64.dat', ...
        %       'label','open loop, refPhaseDelay=0x5', ...
        %       'type','f', ...
        %       'swapFdF',false, 'medFilterN',3, 'alpha',0.5) ...
        %struct('fn','1519170718_Ch64.dat', ...
        %       'label','closed loop, refPhaseDelay=0x5', ...
        %       'type','f', ...
        %       'swapFdF',true, 'medFilterN',3, 'alpha',0.5) ...
        %struct('fn','1518107010_Ch256.dat', ...
        %       'label','inphase direction', ...
        %       'type','adc', ...
        %       'swapFdF',false, ...
        %       'Imax',3451415.3009) ...
% %         struct('fn','1518108523_Ch256.dat', ...
% %                'label','quadrature direction (analysisScale=0x3)', ...
% %                'type','adc', ...
% %                'swapFdF',false, ...
% %                'Imax',6901537.0756),...
% %         struct('fn','1518107965_Ch256.dat', ...
% %                'label','quadrature direction (analysisScale=0x0)', ...
% %                'type','adc', ...
% %             sImax   'swapFdF',false, ...
% %                'Imax',1727758.3618), ...
% %         struct('fn','1518107078_Ch256.dat', ...
% %                'label','quadrature direction', ...
% %                'type','adc', ...
% %                'swapFdF',false, ...
% %                'Imax',3451415.3009), ...
         %struct('fn','1518210585_Ch256.dat', ...
         %      'label','DSP quadrature', ...
         %      'type','adc', ...
         %      'swapFdF',false, ...
         %      'Imax',5261193.0746, ...
         %      'medFilterN',3, ...
         %      'alpha',0.5), ...
         %struct('fn','1518210661_Ch256.dat', ...
         %      'label','DSP inphase', ...
         %      'type','adc', ...
         %      'swapFdF',false, ...
         %      'Imax',5261193.0746, ...
         %      'medFilterN',3, ...
         %      'alpha',0.5) ...
         %struct('fn','1519260119_Ch416.dat', ...
         %       'type','adc', ...
         %       'swapFdF',false, ...
         %       'medFilterN',3, ...
         %       'alpha',0.5) ...
         %struct('fn','1519220532_Ch416.dat', ...
         %      'label','DSP quadrature', ...
         %      'type','adc', ...
         %      'swapFdF',false, ...
         %      'medFilterN',3, ...
         %      'alpha',0.5) ...
%    };

dls={ ...
struct('fn','1519826131_Ch48.dat', ...
               'label','', ...
               'type','adc', ...
               'swapFdF',true, ...
               'medFilterN',5, ...
               'alpha',0.5), ...
struct('fn','1519826175_Ch48.dat', ...
               'label','', ...
               'type','adc', ...
               'swapFdF',true, ...
               'medFilterN',5, ...
               'alpha',0.5), ...
};

%idf={'1519261697_Ch256.dat','1519261741_Ch256.dat'};
%%idf={'1519688827_Ch64.dat','1519690164_Ch64.dat'};
%%dls=repmat({struct('type','adc','swapFdF',false,'medFilterN',3,'alpha',0.5)}, 1, length(idf))
%%for ii=1:length(idf)
%%    x=idf(ii);
%%    dls{ii}=setfield(dls{ii},'fn',x{1});
%%end

dlb={ %struct('fn','1518178932_lb_dBcHz.mat', ...
      %       'label','dan loopback thru fridge', ... 
      %       'medFilterN', 11, ...
      %       'alpha',0.75) ...
      %struct('fn','1518212232_lb_dBcHz.mat', ...
      %       'label','dan loopback thru fridge w/ DSP tone gen', ... 
      %       'medFilterN', 11, ...
      %       'alpha',0.75) ...
             };

%plotTitle='SWH 5085.5649MHz  thru fridge +1.5MHz off resonance';
%fres=5039.8147;
%plot_details='on resonance';
%plot_details='+1.5MHz off resonance'; fres=fres+1.5;
plotTitle='SWH FP Run 24 umux16c post-mumetal';
%plotTitle='CY 5.396 GHz no TES, fixed input/variable output attenuation';

% auto-append date
now=datetime('now')
plotTitle=[datestr(now,'yyyy/mm/dd') ' ' plotTitle];

plotTitle='2018/2/28 SWH FP Run 24 umux16c pre-mumetal';

clear fs dfs asds fpws;
fs=[]; dfs=[]; asds=[]; fpws=[];

ColOrd = get(gca,'ColorOrder');
times=linspace(0,33554432/fSample,33554432);

curr_plt=[];
clear LegendString;
LegendString = cell(1,numel(dls)+numel(dlb));
legendCounter=1;
for c=1:length(dls)
    dfn=getfield(dls{c},'fn')
    
    % need to find the file; that way we don't have to put the path above,
    % which is annoying.
    dfn_cands=glob(fullfile(path2datedirs,'/*/',dfn));
    % don't take the one that's in the soft-linked current_data directory
    dfnIdxC=strfind(dfn_cands,'/current_data/');
    dfnIdx=find(cellfun('isempty',dfnIdxC));
    dfn=dfn_cands(dfnIdx);
    dfn=dfn{1,1}; % not sure why this is necessary
    disp(['-> found ' dfn]);
    
    [dfpath,dfname,dfext] = fileparts(dfn);
    dsnum=dfname(7:10);

    if(isfield(dls{c},'label'))
        dfleg=getfield(dls{c},'label');
        disp([dfn ' : ' dfleg]);
    else
        dfleg='';
    end
    [filepath,name,ext] = fileparts(dfn)
    
    clear f;
    clear df;
    clear frs;
    % to swap f & df, decodeSingleChannel(dfn,1)
    [f,df,frs]=decodeSingleChannel(dfn);
    fs(c,:)=f;
    dfs(c,:)=df;

    figure(1);
    if c==1
        clf;
    end
    
    swapFdF=false;
    if(isfield(dls{c},'swapFdF'))
        swapFdF=getfield(dls{c},'swapFdF');
    end
    fordf=getfield(dls{c},'type');
    % this is a kludge.
    if (strcmp(fordf,'df')||swapFdF)
        f=df;
    end
    
    Imax=1;
    if(strcmp(fordf,'adc'))
        % decodeSingleChannel assumes data is frequency,
        % so if you're trying to read ADC data directly
        % need to undo the conversion it does
        f=(2^23/19.2)*f;
        df=(2^23/19.2)*f;

        % load Imax if it exists
        iqcfgfile=fullfile(dfpath,[dfname,'_iq.mat']);
        disp(iqcfgfile);
        if exist(iqcfgfile, 'file')
            load(iqcfgfile);
            disp(['Imax=',num2str(Imax)]);
            disp(['F=',num2str(F)]);
            disp(['label=',num2str(label)]);

            dfleg=[sprintf('f=%0.3fMHz, ',F),' ',label,' ',dfleg]
            disp(['dfleg=',dfleg]);
        end
    end

    % truncate by stripping off last 10 samples; for some reason a lot of
    % the time the last sample or so is a glitch for either f or df
    f=f(1:end-10);
    df=df(1:end-10);

    % subtract off mean from f/df
    f=f-mean(f);
    df=df-mean(df);
    
    %ph = atan2(f, ones(size(f))*dls{c}.Imax);
    %w = blackman(length(ph));
    %[pxx, ff] = pwelch(ph,w,[],[],fSample);
    
    subplot(length(dls),1,c);
    Col = ColOrd(c,:)
    plot(times(1:length(f)),f,'Color',Col);
    if c==1
        title(plotTitle,'FontSize',8);
    end
    %ylim(1.5*ylim);
    ylabel('\DeltaF (MHz)');
    if strcmp(fordf,'adc')
        ylabel('ADC counts');
    end
    legend(dfleg);
    if c==length(dls)
        xlabel('Time (s)');
        xl=xlim();
        yl=ylim();
    end
    
    % plot power spectra
    figure(2);
    if c==1
        clf;
        %% plot power spectra on same axis from Dan's loopback script
        for jj=1:length(dlb)
            % optionally plot data from other files 
            flbn=getfield(dlb{jj},'fn')
            flbn_cands=glob(fullfile(path2datedirs,'/*/',flbn));
            % don't take the one that's in the soft-linked current_data directory
            flbnIdxC=strfind(flbn_cands,'/current_data/');
            flbnIdx=find(cellfun('isempty',flbnIdxC));
            flbn=flbn_cands(flbnIdx);
            flbn=flbn{1,1}; % not sure why this is necessary
            disp(['-> found ' flbn]);
            
            [dlbpath,dlbname,dlbext] = fileparts(flbn);
            dlbnum=dlbname(7:10);
            
            dlbleg=getfield(dlb{jj},'label');
            LegendString{legendCounter} = [dlbleg ' (' dlbnum ')'];
            legendCounter=legendCounter+1;
            
            %Scale by pi radians for dBCrad
            S=load(flbn,'f','dBcHz');
            dBcHz=S.dBcHz;
            if isfield(dlb{jj},'medFilterN')
                mf1N=getfield(dlb{jj},'medFilterN');
                dBcHz=medfilt1(dBcHz,mf1N);
                LegendString{legendCounter-1} = [LegendString{legendCounter-1},' mf1N=',num2str(mf1N)];
            end
            curr_plt=semilogx(S.f, dBcHz); %scaling effective noise floor by bucket size (however, will scale spurs improperly)
            hold on;
            
            if isfield(dlb{jj},'alpha')
                alpha=getfield(dlb{jj},'alpha');
                curr_plt.Color(4)=alpha;
            end     
        end
        %% done plotting power spectra on same axis from Dan's loopback script
    end
    
    % legend for upcoming dls plot
    LegendString{legendCounter} = [dfleg ' (' dsnum ')'];
    legendCounter=legendCounter+1;
    
    % w/ windowing
    [pxxpw,fpw] = pwelch(f,2^22,2^10,2^22,fSample);
    
    asd=sqrt(pxxpw);
    
    if videoAvg
        asd=videoAverage(asd,videoAvgM);
    end
    
    if isfield(dls{c},'medFilterN')
        mf1N=getfield(dls{c},'medFilterN');
        asd=medfilt1(asd,mf1N);
        LegendString{legendCounter-1} = [LegendString{legendCounter-1},' mf1N=',num2str(mf1N)];
    end
    
    if strcmp(fordf,'adc')
        asd=20.*log10(asd/Imax); % x1e6 to convert from MHz to Hz
        curr_plt=semilogx(fpw,asd);  
    else %frequency data in MHz
        asd=asd*1.e6; % x1e6 to convert from MHz to Hz
        curr_plt=loglog(fpw,asd);
    end
    
    if isfield(dls{c},'alpha')
        alpha=getfield(dls{c},'alpha');
        curr_plt.Color(4)=alpha;
    end  
    
    asds(c,:)=asd; fpws(c,:)=fpw;
   
    if c==1
        hold on;
    end
    
    if c==length(dls)
        xlim([1 fSample/2]);
        xlabel('Frequency (Hz)');
        if strcmp(fordf,'adc')
            ylabel('dBc/Hz');
            ylim([-120,-50]);
        else
            ylim([1e-3 1.e4]);
            ylabel('Frequency ASD (Hz/rtHz)');
        end 
        grid on;
        grid minor;
        
        lgd=legend(LegendString);
        lgd.FontSize=6;
        title(plotTitle,'FontSize',8);
    end
    
    figure(3);
    if c==1
        clf;
    end
    
    % no windowing
    [fpwr,pxxpwr] = psd(f,fSample);
    
    asdr=sqrt(pxxpwr);
    
    if videoAvg
        asdr=videoAverage(asdr,videoAvgM);
    end

    if isfield(dls{c},'medFilterN')
        asd=medfilt1(asd,getfield(dls{c},'medFilterN'));
    end
    
    if strcmp(fordf,'adc')
        asdr=20.*log10(asdr/Imax); % x1e6 to convert from MHz to Hz
        curr_plt=semilogx(fpwr,asdr);
        %semilogx(ff,10*log10(pxx));
    else %frequency data in MHz
        asdr=asdr*1.e6; % x1e6 to convert from MHz to Hz
        curr_plt=loglog(fpwr,asdr);
    end
    
    if isfield(dls{c},'alpha')
        alpha=getfield(dls{c},'alpha');
        curr_plt.Color(4)=alpha;
    end  

    if c==1
        hold on;
    end
    
    if c==length(dls)  
        xlim([1 fSample/2]);
        xlabel('Frequency (Hz)');
        if strcmp(fordf,'adc')
            ylabel('dBc/Hz');
        else
            ylim([1e-3 1.e4]);
            ylabel('Frequency ASD (Hz/rtHz)');
        end 
        grid on;
        grid minor;
        
        lgd=legend(LegendString);
        lgd.FontSize=6;
        
        title(plotTitle,'FontSize',8);
    end
end

disp('----------------------------------------------------------------');
for centerF=[1e3,4e3,30e3]
    dF=100;
    lowerF=centerF-dF;
    upperF=centerF+dF;
    for c=1:length(dls)
        dflabel='';
        if(isfield(dls{c},'label'))
            dflabel=getfield(dls{c},'label');
        end
        fordf=getfield(dls{c},'type');
        if strcmp(fordf,'adc')
            asd=asds(c,:);
            fpw=fpws(c,:);
            asdinterval=NaN(length(asd),1);
            for idf=1:length(asd)
                f=fpw(idf);
                a=asd(idf);
                if f>=lowerF && f<upperF
                    %disp(a);
                    asdinterval(idf)=a;
                end  
                if f>upperF
                    break;
                end
            end
            ls=LegendString(c);
            %disp(length(asdinterval(~isnan(asdinterval))));
            medasdintval=median(asdinterval(~isnan(asdinterval)));
            disp(sprintf('%s [%0.2e Hz, %0.2e Hz] : %0.2f',ls{1},lowerF,upperF,medasdintval));
        end
    end
    disp('----------------------------------------------------------------');
end


%for c=1:length(dls)
%    f=fs(c,:);
%    dfleg=getfield(dls{c},'label');
%    disp(['-> ' dfleg ' : ']);
%    disp(['std(f)=' num2str(std(f)*1.e6) 'Hz']);
%end
