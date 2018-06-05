function [cfg,phase,f,pArtHz]=plotIQNoise(fname,path2data)

    if nargin<2
        path2data='/home/common/data/cpu-b000-hp01/cryo_data/data2/';
    end

    % need to find the file; that way we don't have to put the path above,
    % which is annoying.
    dfn_cands=glob(fullfile(path2data,'/*/',fname));
    % don't take the one that's in the soft-linked current_data directory
    dfnIdxC=strfind(dfn_cands,'/current_data/');
    dfnIdx=find(cellfun('isempty',dfnIdxC));
    dfn=dfn_cands(dfnIdx);
    dfn=dfn{1,1}; % not sure why this is necessary
    disp(['-> found ' dfn]);
    
    cfg = load(strrep(dfn,'.dat','.mat'));
    [I, Q, fluxRampStrobe] = decodeSingleChannel(dfn,cfg);

    fs=600e3/(2^(cfg.decimation));
    if cfg.singleChannelReadoutOpt2==1
        fs=2.4e6;
    end
    if cfg.singleChannelReadout==1 && cfg.singleChannelReadoutOpt2==1
        error('!!! Both singleChannelReadout and singleChannelReadoutOpt2 == 1 for this dataset...abort!');
    end
    
    phase = atan2(Q,I);
    %figure; 
    %plot(phase);
    [pxx, f] = pwelch(phase - mean(phase), [], [], [], fs);
    %figure;

    pA_per_Phi0 = 9e-6; %pA/Phi0
    %loglog(f, sqrt(pxx)/(2*pi)*pA_per_uPhi0*1e12, 'color', 'k')
    pArtHz=sqrt(pxx)/(2*pi)*pA_per_Phi0*1e12;
    
    %semilogx(f,(1.e6*sqrt(pxx)/(2.*pi))*9.e-6);
    %ylim([1,1000]);
    
    %semilogx(f, 10*log10(pxx))
    grid minor
end