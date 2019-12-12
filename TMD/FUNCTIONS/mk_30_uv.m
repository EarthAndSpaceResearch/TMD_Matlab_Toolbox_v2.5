function [u1,v1]=mk_30_uv(gll_lims,u,v,hz1,ll_lims1,pmask,Modp,lims);
% recovers 1/30 x 1/30 u,v with local patches
% for area limited by lims
%
hzmin=500;pmask0=pmask;
globe=0;if lims(2)-lims(1)==360,globe=1;end 
[hu1,hv1]=Huv(hz1);
%
[ng,mg]=size(u);
[glon,glat]=XY(gll_lims,ng,mg);
gx=glon(2)-glon(1);gy=glat(2)-glat(1);
[GLON,GLAT]=meshgrid(glon,glat);
[GLONu,GLATu]=meshgrid(glon-gx/2,glat);
[GLONv,GLATv]=meshgrid(glon,glat-gy/2);
%
glon30=[1/30:1/30:360];;n30=length(glon30);
glat30=[-90:1/30:90];m30=length(glat30);
%
if lims(1)<0,
  ik1=find(glon30>180);ik2=find(glon30<=180);
  glon30=[glon30(ik2)-360; glon30(ik1)];
  u=[u(ik1,:);u(ik2,:)];
  v=[v(ik1,:);v(ik2,:)];
  pmask=[pmask(ik1,:);pmask(ik2,:)];
end
%
ii=find(glon30>lims(1)-1 & glon30<lims(2)+1);
jj=find(glat30>lims(3)-1 & glat30<lims(4)+1);
ii1=find(glon>lims(1) & glon<lims(2));
jj1=find(glat>lims(3) & glat<lims(4));
lon1=glon30(ii);n1=length(lon1);
lat1=glat30(jj);m1=length(lat1);
%
[GLON30,GLAT30]=meshgrid(lon1,lat1);
[GLON30u,GLAT30u]=meshgrid(lon1-1/60,lat1);
[GLON30v,GLAT30v]=meshgrid(lon1,lat1-1/60);
%
u(find(u==0))=NaN;v(find(v==0))=NaN;
ug=interp2(GLONu,GLATu,u',GLON30u,GLAT30u);ug=ug';
vg=interp2(GLONv,GLATv,v',GLON30v,GLAT30v);vg=vg';
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
u1=zeros(n1,m1)+NaN;
v1=zeros(n1,m1)+NaN;
for imod=idm 
  if isempty(Modp(imod).u)==0,
  ll_lims=Modp(imod).ll_lims;
  lnames=[lnames;Modp(imod).name];
  if ll_lims(1)<0 & lims(1)>0,ll_lims(1:2)=ll_lims(1:2)+360;end
  if ll_lims(1)>0 & lims(1)<0,ll_lims(1:2)=ll_lims(1:2)-360;end
  n=Modp(imod).n;m=Modp(imod).m;
  iu=Modp(imod).iu;ju=Modp(imod).ju;
  iv=Modp(imod).iv;jv=Modp(imod).jv;
  fprintf('Recovering u,v %s...',Modp(imod).name);
 [lon,lat]=XY(ll_lims,n,m);
  dxl=lon(2)-lon(1);dyl=lat(2)-lat(1);
 [LON,LAT]=meshgrid(lon,lat);
 [LONu,LATu]=meshgrid(lon-dxl/2,lat);
 [LONv,LATv]=meshgrid(lon,lat-dyl/2);
 ul=zeros(n,m)+NaN;vl=zeros(n,m)+NaN;
 for k=1:length(iu)
  ul(iu(k),ju(k))=Modp(imod).u(k);
 end
 for k=1:length(iv)
  vl(iv(k),jv(k))=Modp(imod).v(k);
 end
%
 ii=find(LON'>ll_lims1(1) & LON'<ll_lims1(2) & ... 
         LAT'>ll_lims1(3) & LAT'<ll_lims1(4) );
 ulc=reshape(ul(ii),n1,m1);
 vlc=reshape(vl(ii),n1,m1);
 ik=find(isnan(u1)>0 & isnan(ulc)==0);
 u1(ik)=ulc(ik);
 ik=find(isnan(v1)>0 & isnan(vlc)==0);
 v1(ik)=vlc(ik);
 fprintf('done\n');
 else
  ik=find(isnan(u1)>0);
  u1(ik)=ug(ik);
  ik=find(isnan(v1)>0);
  v1(ik)=vg(ik);
 end
end
ig=find(isnan(u1)>0 & hu1>hzmin);
u1(ig)=ug(ig);
u1(find(isnan(u1)>0))=0;
ig=find(isnan(v1)>0 & hv1>hzmin);
v1(ig)=vg(ig);
v1(find(isnan(v1)>0))=0;
pmask=pmask0;
return


