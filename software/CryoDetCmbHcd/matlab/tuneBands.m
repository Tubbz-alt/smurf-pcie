function tuneBands(bands)
    Adrive=9;
    doEtaPlots=true;
    lockBandAtEndOfEtaScan=false;
    
    nbands=length(bands);
    resFreqs = cell(1,nbands);
    etas = cell(1,nbands);
    band_counter=1;
    for band=bands
        resFreqs{band_counter} = findFreqs(band);
        etas{band_counter} = setupNotches_umux16(band,Adrive,doEtaPlots,lockBandAtEndOfEtaScan,resFreqs{band_counter});
        Off(band);
        reLock(band,etas{band_counter});
        band_counter=band_counter+1;        
    end
    
    %% summarize
    band_counter=1;
    for band=bands
        disp(sprintf('---- band%d ----',band));
        disp(sprintf('findFreqs = %s',resFreqs{band_counter}));
        disp(sprintf('etaScan = %s',etas{band_counter}));
        band_counter=band_counter+1;
    end
    %% running this kills band 3
    %reLock(2,eta2);
    
    %dumpJesdStatusValidCnts