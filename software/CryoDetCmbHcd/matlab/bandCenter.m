function Fc = bandCenter(band)
bandNo = [ 8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31 0 16 1 17 2 18 3 19 4 20 5 21 6 22 7 23 8];
bn = find(bandNo == band);

Fc = (bn-17)*19.2 + 5250;
end
    