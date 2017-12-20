
function [F, dF, fluxRampStrobe] = decodeSingleChannel(file, swapFdF)

% if swapFdF =0 then f stream first, df second
% if swapFdF=1 then f stream second, dF stream first
if nargin < 2
    swapFdF = 0;
end

if swapFdF == 0
    nF = 1; nDF =2;
else
    nF=2; nDF=1;
end

rawData = squeeze(processData(file));
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

F = F' * 19.2/2^23;

%decode frequency errors 
df = data(:,nDF);
neg = find(df >= 2^23);
dF = double(df);
if ~isempty(neg)
    dF(neg) = dF(neg)-2^24;
end

dF = dF' * 19.2/2^23;
