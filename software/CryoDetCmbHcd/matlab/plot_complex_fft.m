function plot_complex_fft(indata,fs,fullscale_bits,fignum)

N=length(indata);
%win= blackman(N); % window function (blackman)
    win=ones(N,1);
signal_windowed=indata.*win;


signal_win1=fftshift((fft(signal_windowed)))+1e-5;
IS_win1 = real(signal_win1);
QS_win1 = imag(signal_win1);

f = (-fs/2:fs/(N-1):round(fs/2));
%f=abs(750e6-f);
IS_win_h1 = IS_win1(1:length(f));  %Times 2 for single sideband FFT
IS_win_h1 = IS_win_h1 / sum(win); 
QS_win_h1 = QS_win1(1:length(f));  %Times 2 for single sideband FFT
QS_win_h1 = QS_win_h1 / sum(win); 

%The following is scaled by 2^15 because we are calculating dB full
%Scale (dBFS) full scale is +/- 2^15  furthmermore we divide
%by an extra 2 because of I and Q at full scale will add double when
%in phase
IS_win_h1=IS_win_h1./(2^(fullscale_bits-1));
QS_win_h1=QS_win_h1./(2^(fullscale_bits-1));
Amp=sqrt(IS_win_h1.^2+QS_win_h1.^2);
phases=(atan2(QS_win_h1,IS_win_h1));
%[pks,locs]=findpeaks(20*log10(Amp),'MinPeakHeight',-60);
figure(fignum)
plot(f/1e6, 20*log10(Amp));
%axis([500.392 500.592 -120 -20]);
xlabel('frequency MHz')
ylabel('dBFS')