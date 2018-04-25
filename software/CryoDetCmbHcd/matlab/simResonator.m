function [Iout,Qout]=simResonator(fc,Npt)
    %% starting IQ
    % amplitude,phase
    [Iin,Qin]=IQ(1,0);
    
    %% mix up
    % carrier frequency
    %fc=5.0e9; % Hz
    % times to simulate over
    t=linspace(0,10./fc,Npt); % sec
    % mix up I and Q to carrier frequency
    rfIn=mixUpIQ(Iin,Qin,fc,t);
    
    %% stuff happens
    fres=5.0e9;
    Qr=100.e3;
    Qc=110.e3;
    rfOut=resS21(fc,fres,Qr,Qc)*rfIn;
    
    %% plot real and imaginary components of resonator S21
    %df=5.0e6; % Hz
    %fs=linspace(fres-df,fres+df,1000);
    %S21=resS21(fs,fres,Qr,Qc);
    %figure(1);
    %plot(real(S21));
    %figure(2);
    %plot(imag(S21));
    
    %% mix down
    [Iout,Qout]=mixDown2IQ(rfOut,fc,t);
    
    disp(['Iin = ' num2str(Iin)]);
    disp(['Qin = ' num2str(Qin)]);
    
    %scatter(Iout,Qout);
    
    disp(['Iout = ' num2str(Iout)]);
    disp(['Qout = ' num2str(Qout)]);
    
    % plot the voltage versus time of the tone
    %plot(t,real(rfIn));
end

function S21=resS21(ftone,fres,Qr,Qc)
    S21 = 1.-(Qr/Qc)*(1 + 2*j*Qr*((ftone - fres)/fres)).^(-1);
    %S21=1 - (Qr/Qc)/(1+2*j*Qr*(ftone-fres)/fres);
end

% returns I+jQ for input amplitude and phase
function [I,Q]=IQ(A,phi)
    I=A*cos(phi);
    Q=A*sin(phi);
end

% mixes I and Q voltages up to rf tone with carrier frequency fc
% add LO phase?  right now assumes LO phase is zero
function rf=mixUpIQ(I,Q,fc,t)
    rf=(I+j*Q)*exp(j*2*pi*fc*t);
end

% mixes complex rf signal to baseband I and Q, given carrier frequency fc
% add LO phase? right now assumes LO phase is zero
% requires fs because we filter as part of the demod
function [I,Q]=mixDown2IQ(rf,fc,t)
    % x with inphase/quadrature 
    % not sure why this doesn't work
    rfDemod=exp(-j*2*pi*fc*t).*rf;
    
    I=real(rfDemod);
    Q=imag(rfDemod);
end