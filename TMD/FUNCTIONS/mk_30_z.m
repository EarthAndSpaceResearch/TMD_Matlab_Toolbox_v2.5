function [z1]=mk_30_z(gll_lims,z,hz1,ll_lims1,pmask,Modp,lims);
% recovers 1/30 x 1/30 grid with local patches
% for area limited by lims
%
hzmin=500;pmask0=pmask;
zmax=6;
globe=0;if lims(2)-lims(1)==360,globe=1;end 
%
mz=(z>0); % global grid mask
[dum,mu,mv]=Muv(z);
[ng,mg]=size(z);
[glon,glat]=XY(gll_lims,ng,mg);
[GLON,GLAT]=meshgrid(glon,glat);
gx=glon(2)-glon(1);gy=glat(2)-glat(1);
glon30=[1/30:1/30:360];;n30=length(glon30);
glat30=[-90:1/30:90];m30=length(glat30);
%
if lims(1)<0,
  ik1=find(glon30>180);ik2=find(glon30<=180);
  glon30=[glon30(ik2)-360; glon30(ik1)];
  z=[z(ik1,:);z(ik2,:)];mz=(z>0);
  pmask=[pmask(ik1,:);pmask(ik2,:)];
end
%
ii=find(glon30>lims(1)-1 & glon30<lims(2)+1);
jj=find(glat30>lims(3)-1 & glat30<lims(4)+1);
ii1=find(glon>lims(1) & glon<lims(2));
jj1=find(glat>lims(3) & glat<lims(4));
lon1=glon30(ii);n1=length(lon1);
lat1=glat30(jj);m1=length(lat1);
[LON1,LAT1]=meshgrid(lon1,lat1);
%
%ll_lims1=[lon1(1)-1/60,lon1(end)+1/60,...
%          lat1(1)-1/60,lat1(end)+1/60];ll_lims1=ll_lims1';
[GLON30,GLAT30]=meshgrid(lon1,lat1);
z(find(z==0))=NaN;
zg=interp2(GLON,GLAT,z',GLON30,GLAT30);zg=zg';
%
pmask1=pmask(ii1,jj1);
nmodg=length(Modp);idm=[];
for k=1:nmodg
 ik=find(pmask1==k);
 if isempty(ik)==0,idm=[idm k];end;
end
% recover local limits from Modp, find nmod and nz
[dum,nmod]=size(Modp);
nloc=0;lnames=[];
% insert local models into global matrix
z1=zeros(n1,m1)+NaN;
for imod=idm 
  if isempty(Modp(imod).z)==0,
  ll_lims=Modp(imod).ll_lims;
  lnames=[lnames;Modp(imod).name];
  if ll_lims(1)<0 & lims(1)>0,ll_lims(1:2)=ll_lims(1:2)+360;end
  if ll_lims(1)>0 & lims(1)<0,ll_lims(1:2)=ll_lims(1:2)-360;end
  n=Modp(imod).n;m=Modp(imod).m;
  iz=Modp(imod).iz;jz=Modp(imod).jz;
  fprintf('Recovering z %s...',Modp(imod).name);
 [lon,lat]=XY(ll_lims,n,m);[LON,LAT]=meshgrid(lon,lat);
 dxl=lon(2)-lon(1);dyl=lat(2)-lat(1);
 hl=zeros(n,m)+NaN;
 for k=1:length(iz)
  hl(iz(k),jz(k))=Modp(imod).z(k);
 end
 %%%hi=interp2(LON,LAT,hl',LON1,LAT1);hi=hi';
 ii=find(LON'>ll_lims1(1) & LON'<ll_lims1(2) & ... 
         LAT'>ll_lims1(3) & LAT'<ll_lims1(4) );
 hlc=reshape(hl(ii),n1,m1);
 ik=find(isnan(z1)>0 & isnan(hlc)==0);
 z1(ik)=hlc(ik);
 fprintf('done\n');
 else
  ik=find(isnan(z1)>0);
  z1(ik)=zg(ik);
 end
end
ig=find(isnan(z1)>0 & hz1>hzmin);
z1(ig)=zg(ig);
z1(find(isnan(z1)>0))=0;
imax=find(abs(z)>zmax);
if isempty(imax)==0,
 z(imax)=z(imax)./abs(z(imax))*zmax;
end
pmask=pmask0;
return


