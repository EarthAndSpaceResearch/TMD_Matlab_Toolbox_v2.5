% function to predict tidal time series
% using harmonic constants
% INPUT: time (days) relatively Jan 1, 1992 (48622mjd)
%        con(nc,4) - char*4 tidal constituent IDs 
%        hc(nc) - harmonic constant vector  (complex)
% OUTPUT:hhat - time series reconstructed using HC
%  
%        Nodal corrections included
%
% usage: [hhat]=harp1(time,hc,con);
%
function [hhat]=harp1(time,hc,con);
L=length(time);
[n1,n2]=size(time);
if n1==1,time=time';end
[nc,dum]=size(con);
for k=1:nc
 [ispec(k),amp(k),ph(k),omega(k),alpha(k),cNum]=constit(con(k,:));
end
%
igood=find(ispec~=-1);ibad=find(ispec==-1);
con1=con(igood,:);
%
[pu1,pf1]=nodal(time+48622,con1);
pu=zeros(L,nc);pf=ones(L,nc);
pu(:,igood)=pu1;pf(:,igood)=pf1;
%
hhat=zeros(size(time));
x=zeros(2*nc,1);
x(1:2:end)=real(hc);
x(2:2:end)=imag(hc);
for k=1:nc
  arg=   pf(:,k).*x(2*k-1).*cos(omega(k)*time*86400+ph(k)+pu(:,k))...
       - pf(:,k).*x(2*k)  .*sin(omega(k)*time*86400+ph(k)+pu(:,k));
  hhat=hhat+arg;
end
return
 
