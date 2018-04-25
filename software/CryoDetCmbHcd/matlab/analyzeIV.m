%analyzeIV
% v,f,df,sync
close all;
%% 5264.368 GHz
%fullfn='/data/cpu-b000-hp01/cryo_data/data2/20180203/1517658978_Ch256_FvPhi.mat';
%% 5325.069 GHz
%fullfn='/data/cpu-b000-hp01/cryo_data/data2/20180203/1517653901_Ch32_FvPhi.mat';
%% 5426.637 GHz
%fullfn='/data/cpu-b000-hp01/cryo_data/data2/20180202/1517608673_Ch320_FvPhi.mat';

%fullfn='/data/cpu-b000-hp01/cryo_data/data2/20180202/1517571735_Ch80_FvPhi.mat';
fullfn='/data/cpu-b000-hp01/cryo_data/data2/20180205/1517871046_Ch256_FvPhi.mat';

[filepath,filename,ext]=fileparts(fullfn);

load(fullfn);

doFit=true;

resets=find(sync>0.5)

applyFilter=false;
[bfilt,afilt]=butter(4,.01);
clear phase;
phase=[]
trunc=floor(length(frame)/4.);
%for ii=[1100 1101 1102 1103]
Nr=length(resets);
counter=0;
phi0est=1.0;

rTemplate=length(resets);

for ii=fliplr(1:Nr)
    %frame0=f(resets(ii):resets(ii+1)-1);
    frame0=f(resets(rTemplate-1):resets(rTemplate)-1);
    if applyFilter
        frame0=filter(bfilt,afilt,frame0);
    end
    frame0=frame0(trunc:end-trunc);
    
    if ~(ii==1)
        frame1=f(resets(ii-1):resets(ii)-1);
    else
        frame1=f(1:resets(ii+1)-1);
    end
    if applyFilter
        frame1=filter(bfilt,afilt,frame1);
    end

    if counter<10
        figure(100);
        plot(frame1); hold on;
    end
    frame1=frame1(trunc:end-trunc);
    
    %plot(frame); hold on;
    %plot(trunc:trunc+length(filtf)-1,filtf); hold on;
    
    %plot(frame0); hold on;
    %plot(frame1);
    
    fr0norm=(frame0-mean(frame0))/std(frame0);    
    fr1norm=(frame1-mean(frame1))/std(frame1);
    [xc,lag] = xcorr(fr0norm,fr1norm,'coeff');
    xc=xc/max(xc);
    [Mc,Ic]=max(xc);

    % doesn't seem to work very well
    %% estimate phi0 from peaks in correlation function
    %if counter==0
    %    [pk,loc]=findpeaks(xc);
    %    
    %    % sort
    %    [~,pkSort]=sort(pk);
    %    sortedLoc=loc(pkSort);
    %    max1loc=sortedLoc(end);
    %    max2loc=sortedLoc(end-1);
    %    phi0est=abs(max2loc-max1loc);    
    %end
    
    phase(counter+1)=lag(Ic);
    counter=counter+1;
    
    %figure(101);
    %plot(lag,xc); hold on;
end

% use maxima locations to estimate phi0
[pk0,loc0]=findpeaks(frame0,'MinPeakDistance',length(frame0)/8);
phi0est=abs(loc0(2)-loc0(1));
phi0est=702;
disp(['phi0est=' num2str(phi0est)]);

%% Unwrap
phase=unwrap(2*pi*(phase/phi0est));

%% Plot
%n2plot=length(phase);
%scatter(1:n2plot,phase(1:n2plot)); hold on;
%plot(1:n2plot,phase(1:n2plot));
%disp(max(phase(1:n2plot)));
%%plot(phase);

% need to reverse phase order;
phase=fliplr(phase);

coeffs=polyfit(v,phase,1);
coeffs=[1200.5,0.];
fittedphase=polyval(coeffs,v);

% plot reconstructed phase versus applied voltage
figure(101);
scatter(v(1:50:end),phase(1:50:end)); hold on;
if doFit
    plot(v,fittedphase,'r--');
end
    
grid on;
xlabel('TES bias (V)');
ylabel('Demodulated phase (rad)');

title([filename ext],'Interpreter','none');

if doFit
    legend('data (%50)',sprintf('linear fit -> %0.1f rad/VTES',coeffs(1)),'Location','northwest');
else
    legend('data (%50)','Location','northwest'); 
end

return;
%%% Fitting not working yet..

frame0=frame0*1e6+5.25e9;

%% apparently no fitting is included in this version of matlab.
%F=@(x,xdata) f0*(1.+f0*A*lambda*cos(2*pi*dphidN*x-phi0)/(1.+lambda*cos(2*pi*dphidN*xdata-phi0)));
%p(1)=f0
%p(2)=A
%p(3)=lambda
%p(4)=dphidN
%p(5)=phi0
dF=@(p,x) (p(1)+p(1)*p(1)*p(2)*p(3)*cos(2*pi*p(4)*x-p(5)).*power((1.+p(3)*cos(2*pi*p(4)*x-p(5))),-1));%*(power((1.+p(3)*cos(2*pi*p(4)*x-p(5))),-1)));

close all;

p0=[];
p0(1)=min(frame0); % f0
p0(2)=5.e-10*(max(frame0)-min(frame0))/p0(1)/2.; % A
p0(3)=0.3; % lambda
p0(4)=2./(length(frame0)); % dphidN
p0(5)=0.; % phi0
plot(frame0); hold on;
plot(dF(p0,0:length(frame0)));

dFdata=frame0;
N=1:length(dFdata);
OLS=@(p) sum((dF(p,N) - dFdata).^2);
B = fminsearch(OLS,p0);

plot(dF(B,N));
%plot(dF(p0,0:length(frame0)));


