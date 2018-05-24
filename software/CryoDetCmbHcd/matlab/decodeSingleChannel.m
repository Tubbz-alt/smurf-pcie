
function [F, dF, fluxRampStrobe] = decodeSingleChannel(file, swapFdF)

% digitizerFrequencyMHz/numberSubBands
subBandHalfWidthMHz=4.8;

% if swapFdF =0 then f stream first, df second
% if swapFdF=1 then f stream second, dF stream first
if nargin < 3
    swapFdF = 0;
end

if swapFdF == 0
    nF = 1; nDF =2;
else
    nF=2; nDF=1;
end

%rawData = squeeze(processData(file));
[rawData, header] = processData2(file);
%revised processData will not need buffsize parameter, or squeeze function

%decode strobes
strobes = floor(rawData/2^30);
data = rawData - 2^30*strobes;
ch0Strobe = mod(strobes, 2) ==1;
fluxRampStrobe = floor(strobes/2);


%decode frequencies

freqs = data(:,nF);
neg = find(freqs >= 2^23);
F = double(freqs);
if ~isempty(neg)
    F(neg) = F(neg)-2^24;
end

F = F' * subBandHalfWidthMHz/2^23;

%decode frequency errors 
df = data(:,nDF);
neg = find(df >= 2^23);
dF = double(df);
if ~isempty(neg)
    dF(neg) = dF(neg)-2^24;
end

dF = dF' * subBandHalfWidthMHz/2^23;
