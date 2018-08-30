function res=findAllPeaks(sweepDataFile,bands,plotsaveprefix)
    sweep=load(sweepDataFile);
    res=[];
    if nargin < 2
        % leftmost, but unusable is 8,24,9 -> lots of peaks found here, need to fix
        % rightmost, but unusable is 7,23,8 -> lots of peaks found here, need to
        % fix
        bands=[25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17 2 18 3 19 4 20 5 21 6 22];
    end
    if nargin < 3
        plotsaveprefix='';
    end
    
    nres=0;
    for bandnum=bands
        fpb=findPeaks(sweep,bandnum,plotsaveprefix);
        good=[fpb.good];
        phres=[fpb.phres];
        bandres=phres(find(good==1));
        nres=nres+length(res);

        g=sprintf('%0.3f ', bandres);
        fprintf('bandnum %d : %s\n', bandnum,g);
        res=horzcat(res,bandres);
    end
    %fprintf('nres=%d\n',nres);
end