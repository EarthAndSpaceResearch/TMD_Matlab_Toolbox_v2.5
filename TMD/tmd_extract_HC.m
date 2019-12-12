% Function to extract tidal harmonic constants out of a tidal model
% for given locations
% USAGE
% [amp,Gph,Depth,conList]=tmd_extract_HC(Model,lat,lon,type,Cid);
%
% PARAMETERS
% Input:
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
%             lat(L),lon(L) or lat(N,M), lon(N,M) - coordinates in degrees;
%             type - char*1 - one of
%                    'z' - elvation (m)
%                    'u','v' - velocities (cm/s)
%                    'U','V' - transports (m^2/s);
% Cid - indices of consituents to include (<=nc); if given
%             then included constituents are: ConList(Cid,:),
%             if Cid=[] (or not given),
%             ALL model constituents included
%
% Ouput:     
%            amp(nc0,L) or amp(nc0,N,M) - amplitude
%            Gph(nc0,L) or Gph(nc0,N,M) - Greenwich phase (o)
%            Depth(L) or Depth(N,M)  - model depth at lat,lon
%            conList(nc,4) - constituent list
%            if Cid==[], L=nc, else L=length(Cid); end 
%
% Sample call:
% [amp,Gph,Depth,conList]=tmd_extract_HC('DATA/Model_Ross_prior',lat,lon,'z');
%
% Dependencies:  h_in,u_in,grd_in,XY,rd_con,BLinterp,checkTypeName
% 
% TMD release 2.02: 21 July 2010
function [amp,Gph,D,conList]=tmd_extract_HC(Model,lat,lon,type,Cid);
amp=[];Gph=[];D=[];conList=[];
w=what('TMD');funcdir=[w.path '/FUNCTIONS'];
path(path,funcdir);
if type=='z',k=1;else k=2;end
[ModName,GridName,Fxy_ll]=rdModFile(Model,k);
km=1;
if isempty(Fxy_ll)>0,km=0;end
[Flag]=checkTypeName(ModName,GridName,type);
if Flag>0,return;end
ik=findstr(GridName,'km');
if isempty(ik)==0 & km==0,
 fprintf('STOPPING...\n');
 fprintf('Grid is in km, BUT function to convert lat,lon to x,y is NOT given\n');
 conList='stop';
 amp=NaN;Gph=NaN;D=NaN;
 return
end
if km==1,
 eval(['[xt,yt]=' Fxy_ll '(lon,lat,''F'');']);
else
 xt=lon;yt=lat;
end
[ll_lims,H,mz,iob]=grd_in(GridName);
if type ~='z',
 [mz,mu,mv]=Muv(H);[hu,hv]=Huv(H);
end
[n,m]=size(H);
[x,y]=XY(ll_lims,n,m);
dx=x(2)-x(1);dy=y(2)-y(1); 
conList=rd_con(ModName);
[nc,dum]=size(conList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
glob=0;
if x(end)-x(1)==360-dx,glob=1;end
if glob==1,
% extend limits
 x=[x(1)-dx,x,x(end)+dx];
 H=[H(end,:);H;H(1,:)];
 mz=[mz(end,:);mz;mz(1,:)];
end
% adjust lon convention
xmin=min(min(xt));xmax=max(max(xt));
if km==0,
 ikm1=[];ikm2=[];
 if xmin<x(1), ikm1=find(xt<0);xt(ikm1)=xt(ikm1)+360;end
 if xmin>x(end), ikm2=find(xt>180);xt(ikm2)=xt(ikm2)-360;end
end
%
xu=x-dx/2;yv=y-dy/2;
[X,Y]=meshgrid(x,y);[Xu,Yu]=meshgrid(xu,y);[Xv,Yv]=meshgrid(x,yv);
H(find(H==0))=NaN;
if type ~='z',
 if glob==1,
  hu=[hu(end,:);hu;hu(1,:)];hv=[hv(end,:);hv;hv(1,:)];
  mu=[mu(end,:);mu;mu(1,:)];mv=[mv(end,:);mv;mv(1,:)];
 end
 hu(find(hu==0))=NaN;hv(find(hv==0))=NaN;
end
D=interp2(X,Y,H',xt,yt);
mz1=interp2(X,Y,real(mz)',xt,yt);
% Correct near coast NaNs if possible
i1=find(isnan(D)>0 & mz1>0);
if isempty(i1)==0,
  D(i1)=BLinterp(x,y,H,xt(i1),yt(i1),km);
end
%
cind=[1:nc];
if nargin>4, if isempty(Cid)==0;cind=Cid;end;end
fprintf('\n');
for ic0=1:length(cind),
 ic=cind(ic0); 
 fprintf('Interpolating constituent %s...',conList(ic,:));
 if type=='z',
  [z,th_lim,ph_lim]=h_in(ModName,ic);
  [nn,mm]=size(z);if check_dim(Model,n,m,nn,mm)==0,break;end
  if glob==1,z=[z(end,:);z;z(1,:)];end
  z(find(z==0))=NaN;
 else
  [u,v,th_lim,ph_lim]=u_in(ModName,ic);
  [nn,mm]=size(u);if check_dim(Model,n,m,nn,mm)==0,break;end
   if glob==1,
    u=[u(end,:);u;u(1,:)];v=[v(end,:);v;v(1,:)];
   end
   u(find(u==0))=NaN;v(find(v==0))=NaN;
  %%%%if type=='u',u=u./hu*100;end
  %%%%if type=='v',v=v./hv*100;end
 end
 if type=='z',
       z1=interp2(X,Y,z',xt,yt);z1=conj(z1);
% Correct near coast NaNs if possible
       i1=find(isnan(z1)>0 & mz1>0);
       if isempty(i1)==0,
         z1(i1)=BLinterp(x,y,z,xt(i1),yt(i1),km);
       end
       amp(ic0,:,:)=abs(z1);
       Gph(ic0,:,:)=atan2(-imag(z1),real(z1));
 elseif type=='u' | type=='U',
       u1=interp2(Xu,Yu,u',xt,yt);u1=conj(u1);
       mu1=interp2(Xu,Yu,real(mu)',xt,yt);
% Correct near coast NaNs if possible
       i1=find(isnan(u1)>0 & mu1>0);
       if isempty(i1)==0,
         u1(i1)=BLinterp(xu,y,u,xt(i1),yt(i1),km);
       end
       if type=='u',u1=u1./D*100;end
       amp(ic0,:,:)=abs(u1);
       Gph(ic0,:,:)=atan2(-imag(u1),real(u1));
 elseif type=='v' | type=='V',
       v1=interp2(Xv,Yv,v',xt,yt);v1=conj(v1);
       mv1=interp2(Xv,Yv,real(mv)',xt,yt);
% Correct near coast NaNs if possible      
       i1=find(isnan(v1)>0 & mv1>0);
       if isempty(i1)==0,
         v1(i1)=BLinterp(x,yv,v,xt(i1),yt(i1),km);
       end
       if type=='v',v1=v1./D*100;end
       amp(ic0,:,:)=abs(v1);
       Gph(ic0,:,:)=atan2(-imag(v1),real(v1));
 else
      fprintf(['Wrong Type %s, should be one ',...
               'of:''z'',''u'',''v'',''U'',''V''\n'],type);
      amp=NaN;Gph=NaN;
      return 
 end
 fprintf('done\n');
end
Gph=Gph*180/pi;Gph(find(Gph<0))=Gph(find(Gph<0))+360;
Gph=squeeze(Gph);amp=squeeze(amp);
if km==0,
 xt(ikm1)=xt(ikm1)-360;xt(ikm2)=xt(ikm2)+360;
end
%%%if nargin>4,conList=conList(cind,:);end % commented Oct 23, 2008
return
