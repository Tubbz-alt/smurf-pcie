function takeOpenLoopIQData(fres,Adrive)
%fres=5039.870;
%Adrive=10;
    bandCenter=4250;

    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
    chan=setupNotches_umux16_singletone(rootPath,Adrive,bandCenter,[fres]);

    Foff=openLoop(rootPath,chan);

    % invert Foff to find frequency
    band=floor(chan/16);
    bandNo = [ 8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17 2 18 3 19 4 20 5 21 6 22 7 23 8];
    bb=find(bandNo == band,1,'first') - 1;
    F=Foff + (bandCenter -307.2) + bb*19.2;
    
    disp(['F=',num2str(F)]);
    
    % check 
    [bandchk,Foffchk]=f2band(F,bandCenter);
    disp(['[bandchk,Foffchk]=[',num2str(bandchk),',',num2str(Foffchk),']']);
    
    % all off
    Off;

    % now generate quadrature tone on resonance and take data
    label='on res, Full DSP quadrature';
    [qPhase, Imax]=findQuadrature2( rootPath,  (F-bandCenter), 0, 1000, Adrive,bandCenter);
    filename=takeData;
    disp(sprintf('Onres quadrature F=%0.4f',F))
    
    [fp,fn,fext] = fileparts(filename)
    save(fullfile(fp,[fn,'_iq.mat']),'F','qPhase','Imax','label');
    
    % now generate inphase tone on resonance and take data
    label='on res, Full DSP inphase';
    [qPhase, Imax]=findQuadrature2( rootPath,  (F-bandCenter), 1, 1000, Adrive,bandCenter);
    filename=takeData;
    disp(sprintf('Onres inphase F=%0.4f',F))
    
    [fp,fn,fext] = fileparts(filename)
    save(fullfile(fp,[fn,'_iq.mat']),'F','qPhase','Imax','label');
    
    Off;

    dOffRes=1.5; % MHz
    F=F-dOffRes;

    % now generate quadrature tone off resonance and take data
    label=sprintf('-%0.2fMHz off res, Full DSP quadature',dOffRes);
    [qPhase, Imax]=findQuadrature2( rootPath,  (F-bandCenter), 0, 1000, Adrive,bandCenter);
    filename=takeData;
    disp(sprintf('Offres quadrature F=%0.4f',F))
    
    [fp,fn,fext] = fileparts(filename)
    save(fullfile(fp,[fn,'_iq.mat']),'F','qPhase','Imax','label');
    
    % now generate inphase tone on resonance and take data
    label=sprintf('-%0.2fMHz off res, Full DSP inphase',dOffRes);
    [qPhase, Imax]=findQuadrature2( rootPath,  (F-bandCenter), 1, 1000, Adrive,bandCenter);
    filename=takeData;
    disp(sprintf('Offres inphase F=%0.4f',F))
    
    [fp,fn,fext] = fileparts(filename)
    save(fullfile(fp,[fn,'_iq.mat']),'F','qPhase','Imax','label');
    
    disp(sprintf('Onres F=%0.4f',F))
    disp(sprintf('Offres F=%0.4f',F-1.5))
    
    Off;