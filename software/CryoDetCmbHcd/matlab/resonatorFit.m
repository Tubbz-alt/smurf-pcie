function [Ic, Qc, R, error] = resonatorFit(I, Q)

 H   = [I(:), Q(:), ones(size(I(:)))];
 obs = -(I(:).^2 + Q(:).^2);
 a   = H\obs; 

 Ic  = -0.5*a(1);
 Qc  = -0.5*a(2);
 R   = sqrt((a(1).^2 + a(2).^2)/4 - a(3));
 
 error = H*a-obs;

end