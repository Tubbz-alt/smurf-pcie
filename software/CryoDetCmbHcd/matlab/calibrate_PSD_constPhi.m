function pArtHz = calibrate_PSD_constPhi(f_psd,pxx,bandNo,phi,phi0_norm)

if nargin < 5 || phi0_norm == 0
  disp('No phi0 given')
  npts_sq = 100;
  disp('Mapping f_res vs. phi...')
  [f_array,phi_array,fn] = get_f_vs_phi(bandNo,npts_sq);
  s = load(fn);
  phi0_norm = s.phi0;
  disp(['phi0_norm = ' num2str(phi0_norm)])
end

dfdphi = get_dfdphi(bandNo,phi);

phi0 = 2.0678e-15; % in Wb
M = 228e-12; % mutual inductance from TES coil to SQUID in H
pA = 1e-12;

pArtHz = sqrt(pxx)*(phi0/phi0_norm)/(M*abs(dfdphi))/pA;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dfdphi = get_dfdphi(bandNo,phi)

[f_array,phi_array,fn] = get_f_vs_phi(bandNo,2,phi,phi*1.001);
dphi = phi_array(2) - phi_array(1);
df = f_array(2) - f_array(1);

dfdphi = df/dphi;

end
