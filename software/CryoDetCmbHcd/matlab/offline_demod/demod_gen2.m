function [phase_all, psd_pow, pwelch_f, time]=demod_gen2(dfn,swapFdF,numPhi0)
    if nargin < 2
        swapFdF = false;
    end

    % assume rtm is enable if user says nothing
    if nargin < 3
        numPhi0 = 'rtm';
    end

    % for automated dataset finding
    addpath('./glob/');

    % path to SMuRF data.  Should be pulling from environment, not hard
    % coding...
    path2datedirs='/home/common/data/cpu-b000-hp01/cryo_data/data2/';

    dfn_cands=glob(fullfile(path2datedirs,'/*/',dfn));
    % don't take the one that's in the soft-linked current_data directory
    dfnIdxC=strfind(dfn_cands,'/current_data/');
    dfnIdx=find(cellfun('isempty',dfnIdxC));
    dfn=dfn_cands(dfnIdx);
    fileName=dfn{1,1}; % not sure why this is necessary
    disp(['-> found ' fileName]);
    % components of file name for later use
    [dfpath,dfname,dfext] = fileparts(fileName);
      
    % need some info about run time configuration to demod; pull from dataset's
    runFile=fullfile(dfpath,[dfname,'.mat']);
    % no checking right now.  Pray it exists.
    cfg=load(runFile);
    % run file
    try
        decimation=2^(cfg.decimation);
        phi0Rate=cfg.lmsFreqHz;
        isSingleChannel=cfg.singleChannelReadoutOpt2;
        % the /2 here Mitch says is unlikely to change.  This is only the
        % correct sample rate for all channel data (w/
        % singleChannelReadoutOpt2=0).  
        fsamp=1.e6*cfg.digitizerFrequencyMHz/cfg.numberChannels/2;
    catch
        % need these to demod...if not in run file, give up.
        error('!!! Aborted : missing a critical register in the run file.')
    end
    
    if isSingleChannel
        % fsamp not properly implemented for single channel mode yet,
        % abort.  Notes from Mitch for proper implementation;
        %
        % Mitch says; "For single channel Opt2 readout rate is 2.4MHz - comes from oversample 
        %filter bank (2 parallel filter banks, each handling 256 channels)
        %Then that one is 614.4/256
        
        fsamp = 1.e6 * cfg.digitizerFrequencyMHz / 256; % this should be 2.4e6
        %error('!!! Aborted : fsamp not computed correctly for single channel data - needs to be properly implemented.')
    end

    % place to save results
    outputName = sprintf('./output/%s_output.mat',dfname);

    % run the demod
    [phase_all, psd_pow, pwelch_f, time] = process_demod(fileName, cfg, numPhi0, phi0Rate, decimation, outputName,fsamp,swapFdF);

    % save results
    %save(strcat(folder, outputName, '.mat'))
end