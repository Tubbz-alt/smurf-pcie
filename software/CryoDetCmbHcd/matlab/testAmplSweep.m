%script testAmplSweep

Nread = 4
dwell = 0.001
freqs = -15:0.1:15;   %frequencies in MHz

for band=0:7
    [resp, f] = amplSweep(band, freqs, Nread, dwell);
    display(['for band ', num2str(band), ' stDev = ', num2str(std(resp),5)])
    figure(band+1);plot(f, abs(resp), '.');grid
    title(['Band ' num2str(band) ' Amplitude Response'])
    xlabel('Frequency (MHz)')
    ylabel('Response (arbs)')

    %figure(band+11);plot(abs(resp), '.');grid
    %title(['Band ' num2str(band) ' Amplitude Response' ])
    %xlabel('sample number')
    %ylabel('Response (arbs)')
       
    figure(100), subplot(2, 4, band+1), plot(f, abs(resp), '.');grid
    title(['Band ' num2str(band) ' Amplitude Resp.' ])
    xlabel('Frequency (MHz)')
    ylabel('Response (arbs)')
    ax = axis; ax(1) = min(freqs);  ax(2) = max(freqs);  axis(ax);  
    xt = ax(1)+0.1*(ax(2)-ax(1)); yt = ax(3) + 0.1*(ax(4)-ax(3));
    text(xt,yt,['Band Center = ', num2str(band*38.4), ' MHz'])
end

    