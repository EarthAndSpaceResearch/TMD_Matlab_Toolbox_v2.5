function [hu,hv] = Huv(hz);
%  Usage [hu,hv] = Huv(hz);
[n,m] = size(hz);
[mu,mv,mz] = Muv(hz);
indxm = [n,1:n-1];
indym = [m,1:m-1];

hu = mu.*(hz + hz(indxm,:))/2;
hv = mv.*(hz + hz(:,indym))/2;

