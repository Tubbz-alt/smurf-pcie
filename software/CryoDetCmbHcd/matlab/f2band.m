function [band, fresid] = f2band(F,bandCenter)

if nargin <2
    bandCenter=5250;
end

bandNo = [ 8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17 2 18 3 19 4 20 5 21 6 22 7 23 8];

bb = floor((F-(bandCenter-307.2-9.6))/19.2);
fresid = F - (bandCenter -307.2) - bb*19.2;

bandsInverted = false;    % Jan 19 2018 WTF
if bandsInverted
    fresid = -fresid
    bandInvert = bandNo(33:-1:1);
    bandNo = bandInvert;
end

band = bandNo(bb+1);

end
    