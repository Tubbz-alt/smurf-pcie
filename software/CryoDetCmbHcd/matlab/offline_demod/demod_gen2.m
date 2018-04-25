function [phase_all, psd_pow, pwelch_f, time]=demod_gen2(dfn)
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
    
    numPhi0 = 'rtm';
    
    % this is the phi0Rate, not the flux ramp rate
    phi0Rate = 9060;

    decimation = 1;
    
    [dfpath,dfname,dfext] = fileparts(fileName);
    outputName = sprintf('./output/%s_output.mat',dfname);
    %save(strcat(outputName, '.mat'))

    [phase_all, psd_pow, pwelch_f, time] = process_demod(fileName, numPhi0, phi0Rate, decimation, outputName);

    %save(strcat(folder, outputName, '.mat'))
end