function [xfreq,psdx] = psd(x,Fs)
    Nx=length(x)-1;
    xdft = fft(x(1:end-1));
    xdft = xdft(1:round(Nx/2+1));
    psdx = (1/(Fs*Nx)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    xfreq = 0:Fs/length(x):Fs/2;
