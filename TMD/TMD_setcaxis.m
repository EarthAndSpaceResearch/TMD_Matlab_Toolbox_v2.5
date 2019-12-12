% function to set "good" caxis on current axis
% n - degree of 10 to round
% psn - -1/0/1; -1 negative, 0 symmetric, 1 positive
% ha - array to plot
% pct - % of higher amplitudes points to cut off
% set NaNs/0 in ha first for land nodes
%
% usage: TMD_setcaxis(n,psn,ha,pct);
%
function []=TMD_setcaxis(n,psn,ha,pct);
icax=0;% cut off 20% of higher amplitudes
cax=caxis;
camax=cax(2)*(1.-pct/100.);
if psn>0, % positive
 cax(2)=min(floor(cax(2)*10^n)/10^n,camax);
 cax(1)=-cax(2)/30;
elseif psn==0, % symmetric
 c1=floor(0.5*(abs(cax(1))+abs(cax(2)))*10^n)/10^n;
 cax=[-min(c1,camax),min(c1,camax)];
elseif psn==-1, % negative
 cax(1)=max(-camax,ceil(cax(1)*10^n)/10^n);
 cax(2)=-cax(1)/30;
end
if cax==[0,0],cax=[0,10^(-n)];end
caxis(cax);
return
