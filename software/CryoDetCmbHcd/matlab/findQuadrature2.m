% [quadraturePhase, Imax] = findQuadrature2( rootPath, frequency, which, Npts )
% rootPath  - path to SysgenCryo/Base
% frequency - baseband frequency offset -250MHz - 250Mhz
% which - What mode to leave the channel in.  Right now these modes are
%           possible (default is which=0);
%           [which=0]: quadrature direction
%           [which=1]: amplitude direction
% Npts - # of samples to take on ADC to measure phasor at etaPhase=0, 90,
%       and to confirm we've properly oriented in the quadrature direction
%


function [qPhase, Imax] = findQuadrature2( rootPath, frequency, which, Npts, Adrive, freqCenter )

bandNo = 2; % sorry

if nargin <3
    which=0;
end

if nargin <4
    Npts=1000;
end

if nargin <5
    Adrive=10;
end

if nargin <6
    freqCenter     = 5250;
end

% freqOffset     = -20.25;
freqOffset = frequency;
[band, fOff]   = f2band(freqCenter + freqOffset,bandNo);
%chan           = band*16;
chan = 0; % also sorry

feedbackEnable = 0;
etaMag         = 1;
i = 1;

disp(['chan = ',num2str(chan)]);

%%
%% Find signal vector in eta coordinates

% Find component at etaPhase=0
etaPhase=0;
configCryoChannel( rootPath, chan, fOff, Adrive, feedbackEnable, etaPhase, etaMag );
pause(0.1);

adc0=zeros(1,Npts);
for ii = 1:Npts
    [~,  adc0(ii)] = readbackCryoChannel( rootPath, chan );
end

disp( ['Median ADC count for etaPhase=',num2str(etaPhase),' is (Npts=', num2str(Npts), '): ', num2str(median(adc0))] )

% Find component at etaPhase=90
etaPhase=90;
configCryoChannel( rootPath, chan, fOff, Adrive, feedbackEnable, etaPhase, etaMag );
pause(0.1);

adc90=zeros(1,Npts);
for ii = 1:Npts
    [~,  adc90(ii)] = readbackCryoChannel( rootPath, chan );
end

disp( ['Median ADC count for etaPhase=',num2str(etaPhase),' is (Npts=', num2str(Npts), '): ', num2str(median(adc90))] )

%%

%% Return quadrature phase orientation in eta coordinates
%% and IQ amplitude of phasor.
inPhaseRad = atan2(median(adc90),median(adc0));
quadraturePhaseRad = atan2(median(adc90),median(adc0))+pi/2;

inPhaseDeg = inPhaseRad*180./pi;
quadraturePhaseDeg = quadraturePhaseRad*180./pi;

if which==1
    % point in the in-phase direction
    quadraturePhaseRad=quadraturePhaseRad-pi/2;
end

newEtaPhase = quadraturePhaseDeg;
if which==1
    % point in the in-phase direction
    newEtaPhase=inPhaseDeg;
end

Imax=sqrt( power(median(adc90),2) + power(median(adc0),2) );

disp( ['Quadrature phase is: ' num2str(quadraturePhaseDeg), ' degrees'] )
disp( ['Inphase magnitude response is: ', num2str(Imax)] )

qPhase=quadraturePhaseDeg;

%% Set to quadrature and confirm
% set channel to quadrature direction found above
disp( '-> Setting to point in the quadrature direction ...' );
configCryoChannel( rootPath, chan, fOff, Adrive, feedbackEnable, newEtaPhase, etaMag );
pause(0.1);

% take some adc samples in the quadrature direction to confirm
adcnew=zeros(1,Npts);
for ii = 1:Npts
    [~,  adcnew(ii)] = readbackCryoChannel( rootPath, chan );
end

disp( ['-> Taking samples in quadrature direction to confirm we got it right ...'] );
disp( ['Median ADC count for etaPhase=',num2str(newEtaPhase),' is (Npts=', num2str(Npts), '): ', num2str(median(adcnew))] )

% Plot output in what we think is the quadrature direction, with guide line
% at zero.  Drop the first 10 samples (for some reason there's often a
% glitch at the start of these acqs)
plot(adcnew(10:end)); hold on;

if which==0
    line(xlim(),[0,0],'Color','red','LineStyle','--');
end

if which==1
    line(xlim(),[Imax,Imax],'Color','red','LineStyle','--');
end

hold off;
grid on;
xlabel('Sample #')
ylabel('Frequency error')
title('ADC reads in what quadrature2(...) thinks is the quadrature direction');

end