% Bilinear interpolation (neigbouring NaNs avoided)
% in point xt,yt
% x(n),y(m) - coordinates for h(n,m)
% xt(N),yt(N) - coordinates for interpolated values
% Global case is considered ONLY for EXACTLY global solutions,
% i.e. given in lon limits, satisfying:
% ph_lim(2)-ph_lim(1)==360
% (thus for C-grid: x(end)-x(1)==360-dx )
%
% usage:
% [hi]=BLinterp(x,y,h,xt,yt,km);
% km=1 if model is on Cartesian grid (km) otherwise 0
%
function [hi]=BLinterp(x,y,h,xt,yt,km);
% 
if nargin<5,km=0;end
%
dx=x(2)-x(1);dy=y(2)-y(1);
glob=0;
if km==0 & x(end)-x(1)==360-dx,glob=1;end
inan=find(isnan(h)>0);
h(inan)=0;
mz=(h~=0);
n=length(x);m=length(y);
[n1,m1]=size(h);
if n~=n1 | m~=m1,
 fprintf('Check dimensions\n');
 hi=NaN;
 return
end
% extend solution both sides for global

if glob==1,
  h0=h;mz0=mz;
 [k1,k2]=size(x);if k1==1,x=x';end
 [k1,k2]=size(y);if k1==1,y=y';end % just for consistency
 x=[x(1)-2*dx;x(1)-dx;x;x(end)+dx;x(end)+2*dx];
 h=[h(end-1,:);h(end,:);h;h(1,:);h(2,:)];
 mz=[mz(end-1,:);mz(end,:);mz;mz(1,:);mz(2,:)];
end
% Adjust lon convention
% THIS should be done only if km==0 !!!!!!!
xti=xt;
if km==0,
 ik=find(xti<x(1) | xti>x(end));
 if x(end)>180,xti(ik)=xti(ik)+360;end
 if x(end)<0,  xti(ik)=xti(ik)-360;end
 ik=find(xti>360);
 xti(ik)=xti(ik)-360;
 ik=find(xti<-180);
 xti(ik)=xti(ik)+360;
end
%
[X,Y]=meshgrid(x,y);
q=1/(4+2*sqrt(2));q1=q/sqrt(2);
h1=q1*h(1:end-2,1:end-2)+q*h(1:end-2,2:end-1)+q1*h(1:end-2,3:end)+...
   q1*h(3:end,1:end-2)+q*h(3:end,2:end-1)+q1*h(3:end,3:end)+...
   q*h(2:end-1,1:end-2)+q*h(2:end-1,3:end);
mz1=q1*mz(1:end-2,1:end-2)+q*mz(1:end-2,2:end-1)+q1*mz(1:end-2,3:end)+...
   q1*mz(3:end,1:end-2)+q*mz(3:end,2:end-1)+q1*mz(3:end,3:end)+...
   q*mz(2:end-1,1:end-2)+q*mz(2:end-1,3:end);
mz1(find(mz1==0))=1;
h2=h;
h2(2:end-1,2:end-1)=h1./mz1;
ik=find(mz==1);
h2(ik)=h(ik);
h2(find(h2==0))=NaN;
hi=interp2(X,Y,h2',xti,yt);hi=conj(hi);
if glob==1, h=h0;mz=mz0;end
return
