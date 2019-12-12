function [mz,mu,mv] = Muv(hz)
%  Given a rectangular bathymetry grid, construct masks for zeta, 
%   u and v nodes on a C-grid
%  USAGE: [mz,mu,mv] = Muv(hz);
[n,m] = size(hz);
mz = hz > 0;
indx = [2:n 1];
indy = [2:m 1];
mu(indx,:) = mz.*mz(indx,:); 
mv(:,indy) = mz.*mz(:,indy); 
