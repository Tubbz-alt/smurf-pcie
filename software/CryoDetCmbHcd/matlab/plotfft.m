function [fft_freqs,fftAmp_data] = plotfft(sig_long,fs,fignum)

    N=length(sig_long);
    %win= blackman(N); % window function (blackman)
    win=ones(N,1);
    % Iwindowed1=(Idata)'.*win; %Windowed Sginal
    % Qwindowed1=(Qdata)'.*win; %Windowed Sginal
    signal_windowed=sig_long.*win;

    signal_win1=fftshift((fft(signal_windowed)));
    IS_win1 = real(signal_win1);
    QS_win1 = imag(signal_win1);

    fft_freqs = (-fs/2:fs/(N-1):round(fs/2));
    %f=abs(450e6-f);
    IS_win_h1 = IS_win1(1:length(fft_freqs));
    IS_win_h1 = IS_win_h1 / sum(win); 
    QS_win_h1 = QS_win1(1:length(fft_freqs));  
    QS_win_h1 = QS_win_h1 / sum(win); 

    %The following is scaled by 2^15 because we are calculating dB full
    %Scale (dBFS) full scale is +/- 2^15
    IS_win_h1=IS_win_h1./(2^15);
    QS_win_h1=QS_win_h1./(2^15);
    fftAmp_data=sqrt(IS_win_h1.^2+QS_win_h1.^2);
figure(fignum)

    plot(fft_freqs/1e6, 20*log10(fftAmp_data));
 %   axis([-310 310 -120 0]);
    xlabel('frequency MHz')
    ylabel('dBFS')