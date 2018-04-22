
function [F, dF, fluxRampStrobe] = decodeData(file,swapFdF)


% if swapFdF =0 then f stream first, df second
% if swapFdF=1 then f stream second, dF stream first
if nargin < 2
    swapFdF = 0
end

if swapFdF == 0
    nF = 1; nDF =2;
else
    nF=2; nDF=1;
end

%rawData = squeeze(processData(file));
%revised processData will not need buffsize parameter, or squeeze function
[rawData, header] = processData2(file);

%decode strobes
strobes = floor(rawData/2^30);
data = rawData - 2^30*strobes;
ch0Strobe = mod(strobes, 2);
fluxRampStrobe = floor((strobes-ch0Strobe)/2);

%decode frequencies
ch0idx = find(ch0Strobe(:,1) == 1);
Ffirst = ch0idx(1);
Flast = ch0idx(length(ch0idx))-1;
freqs = data(Ffirst:Flast,1);
neg = find(freqs >= 2^23);
F = double(freqs);
if ~isempty(neg)
    F(neg) = F(neg)-2^24;
end

if mod(length(F),512)~=0
    Npoints = length(F)/512;  % bug??
    F = [];
else
    F = reshape(F,512,[]) * 19.2/2^23;
    F = F';
end

fluxRampStrobeF = fluxRampStrobe(Ffirst:Flast, nF);

%decode frequency errors 
% UNTESTED until fixed data stream tested
ch0idx = find(ch0Strobe(:,2) == 1);
if ~isempty(ch0idx)
    Dfirst = ch0idx(1);
    Dlast = ch0idx(length(ch0idx))-1;
    df = data(Dfirst:Dlast,2);
    neg = find(df >= 2^23);
    dF = double(df);
    if ~isempty(neg)
        dF(neg) = dF(neg)-2^24;
    end

    if mod(length(dF),512)~=0
        Npoints = length(dF)/512;  % bug??
        dF = [];
    else
        dF = reshape(dF,512,[]) * 19.2/2^23;
        dF = dF';
    end

else
    dF = [];
end

fluxRampStrobeDF = fluxRampStrobe(Dfirst:Dlast, nDF);
