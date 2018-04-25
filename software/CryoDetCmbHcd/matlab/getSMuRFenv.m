function ret=getSMuRFenv(var)
    ret=getenv(var);
    if isempty(ret)
        error(['ERROR! environmental variable ',var,' not defined!']);
    end
end