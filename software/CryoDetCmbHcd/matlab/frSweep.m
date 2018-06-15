
now=datetime('now');

fbEn=0;

for pwr=0:1:15
%for pwr=[12]
    disp(['pwr=' num2str(pwr)]);
    pwrStr=['pwr' strrep(num2str(pwr),'.','pt')]
    chanStr=['ch' num2str(chan)]
    outfilename=sprintf('%s_%s_%s.dat',num2str(round(posixtime(now))),chanStr,pwrStr);
    disp(['outfilename=' outfilename]);

    configCryoChannel(rootPath, chan, offset, pwr, fbEn, etaPhaseDeg, etaScaled);
    pause(3);
    v=-1;
    % for flux ramp
    %for v=0:0.02:1.64
    % for TES bias
    %for v=0:0.0001:0.010
    %    disp(['v=' num2str(v)]);
        %takeData;
    
        %% to vary low noise DAC voltage
        %cmdStr=sprintf('ssh -Y pi@171.64.108.91 "~/dac_cmdr/dac_cmdr -v %f"',v);
        %system(cmdStr);
        %disp(cmdStr);
        %pause(1);
        
        
        cmdStr=sprintf('ssh -Y umux@171.64.108.89 "python /home/umux/python_vna/get_sa_marker.py %f %f %s"',v,pwr,outfilename);
        disp(['cmdStr=' cmdStr]);
        system(cmdStr);
    
        %% to measure transmitted power
    %    pwr=ii
    %    pause(1);
    %    configCryoChannel(rootPath,chan,offset,pwr,0,etaPhaseDeg,etaScaled)
    %    cmdStr=sprintf('ssh -Y umux@171.64.108.89 "python /home/umux/python_vna/get_sa_marker.py %d"',pwr);
    %    system(cmdStr);
    %    disp(cmdStr);
    %    pause(1);
    %end
end

return;

for foff=-5:0.1:5
configCryoChannel(rootPath, chan, offset+foff, pwr, fbEn, etaPhaseDeg, etaScaled);
pause(0.1)
end