function [f_array,phi_array,fn] = get_f_vs_phi(bandNo,npts,phi_min,phi_max)

if nargin < 2
  npts = 10;
end

% phi is normalized to its max value
if nargin < 3
    phi_min = 0;
end

if nargin < 4
    phi_max = 1;
end

dphi = (phi_max - phi_min)/(npts - 1);

f_array = zeros(npts,1);
phi_array = zeros(npts,1);
for i = 0:npts - 1
  phi = phi_min + i*dphi;
  disp(' ')
  disp(['****** Set flux ramp to ' num2str(phi)])
  fluxRampSetupFixedBias(phi);
  [f,df,frs] = quickDataSingleChannel(bandNo); % assumes singleChannelReadout
  f_avg = mean(f);

  f_array(i + 1) = f_avg;
  phi_array(i + 1) = phi;
end
disp(' ')
disp('Set flux to 0')
fluxRampSetupFixedBias(0);

fn = save_f_vs_phi(f_array,phi_array);
plot_f_vs_phi(fn);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fn = save_f_vs_phi(f_array,phi_array)

s.f = f_array;
s.phi = phi_array;
s.phi_max_slope = phi_array(find_max_dfdphi(f_array,phi_array));
s.phi_min_slope = phi_array(find_min_dfdphi(f_array,phi_array));
s.phi_stationary = phi_array(find_stationary_dfdphi(f_array,phi_array));
s.phi0 = get_phi0(f_array,phi_array);

fn = get_fn()
disp(['Saving data to ' fn]);
save(fn,'-struct','s');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dfdphi_array,phi_array_df] = get_df_dphi(f_array,phi_array)

npts = length(f_array);
dfdphi_array = zeros(npts - 1,1);
for i = 1:length(dfdphi_array)
  df = f_array(i+1) - f_array(i);
  dphi = phi_array(i+1) - phi_array(i);
  dfdphi_array(i) = df/dphi;
end

phi_array_df = phi_array(1:length(phi_array)-1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function i_max = find_max_dfdphi(f_array,phi_array)

[dfdphi_array,phi_array_df] = get_df_dphi(f_array,phi_array);

dfdphi_max = max(dfdphi_array);

ndxs = find(dfdphi_array == dfdphi_max);
i_max = ndxs(1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function i_stat = find_stationary_dfdphi(f_array,phi_array)

[dfdphi_array,phi_array_df] = get_df_dphi(f_array,phi_array);

mag_dfdphi_array = abs(dfdphi_array);
  mag_dfdphi_min = min(mag_dfdphi_array);

  ndxs = find(mag_dfdphi_array == mag_dfdphi_min);
i_stat = ndxs(1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function i_min = find_min_dfdphi(f_array,phi_array)

[dfdphi_array,phi_array_df] = get_df_dphi(f_array,phi_array);

dfdphi_min = min(dfdphi_array);

ndxs = find(dfdphi_array == dfdphi_min);
i_min = ndxs(1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fn = get_fn()

dir_data = 'test_ari';
system(['mkdir -p ' dir_data]);
fn = [dir_data '/test_f_vs_phi.mat'];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_f_vs_phi(fn)

s = load(fn);
f_array = s.f;
phi_array = s.phi;
i_max = find(phi_array == s.phi_max_slope);
i_min = find(phi_array == s.phi_min_slope);
i_stat = find(phi_array == s.phi_stationary);

figure;
plot(phi_array,f_array);
hold on
plot(phi_array(i_max),f_array(i_max),'o');
plot(phi_array(i_min),f_array(i_min),'o');
plot(phi_array(i_stat),f_array(i_stat),'o');
hold off

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function phi0 = get_phi0(f_array,phi_array)

% find consecutive maxima
npts = length(f_array);
i_max_1 = 0;
i_max_2 = 0;
for i = 2:npts-1
  if (f_array(i-1) < f_array(i)) && (f_array(i) > f_array(i+1))
    if i_max_1 == 0
      i_max_1 = i;
    elseif i_max_2 == 0
      i_max_2 = i;
      break;
    end
  end
end

if i_max_1 == 0 || i_max_2 == 0
    phi0 = 0;
else
    phi0 = phi_array(i_max_2) - phi_array(i_max_1);
end

end
