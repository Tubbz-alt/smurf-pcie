function fnFull = takeDataConstPhi(bandNo,phi,npts)

if nargin < 3
  npts = 2^18;
end

fluxRampSetupFixedBias(phi);

fnFull = takeData(bandNo,npts);

[f,df,frs] = decodeSingleChannel(fnFull);
%figure;
%plot(f);

fluxRampSetupFixedBias(0);

end
