% function to extract tidal ellipse grids from a model 
% 
% usage:
% [x,y,umaj,umin,uphase,uincl]=tmd_get_ellipse(Model,cons);
% 
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
% cons - tidal constituent given as char* 
%
% output:
% umaj,umin - major and minor ellipse axis (cm/s)
% uphase, uincl - ellipse phase and inclination degrees GMT
% x,y - grid coordinates
%
% sample call:
% [x,y,umaj,umin,uphase,uincl]=tmd_get_ellipse('DATA/Model_Ross_prior','k1');
%
% TMD release 2.02: 21 July 2010
%
function [x,y,umaj,umin,uphase,uincl]=tmd_get_ellipse(Model,cons);
w=what('TMD');funcdir=[w.path '/FUNCTIONS'];
path(path,funcdir);
[ModName,GridName,Fxy_ll]=rdModFile(Model,2);
[Flag]=checkTypeName(ModName,GridName,'u');
if Flag>0,return;end
%
[ll_lims,hz,mz,iob]=grd_in(GridName);
[n,m]=size(hz);
[x,y]=XY(ll_lims,n,m);
stx=x(2)-x(1);
sty=y(2)-y(1);
conList=rd_con(ModName);
[nc,dum]=size(conList);
cons=deblank(lower(cons));
bcon=deblank(cons(end:-1:1));
cons=bcon(end:-1:1);
lc=length(cons);
k0=0;
for k=1:nc
 if cons==conList(k,1:lc),ic=k;else k0=k0+1;end
end
if k0==nc,
 fprintf('No constituent %s in %s\n',cons,ModName);
 return
end
%
[U,V,th_lim,ph_lim]=u_in(ModName,ic);
[nn,mm]=size(U);if check_dim(Model,n,m,nn,mm)==0,return;end
% Extrapolate U and V on z-grid since U,V nodes are on different grids
U1=[U(1,:); 0.5*(U(1:end-1,:)+U(2:end,:))];
V1=[V(:,1), 0.5*(V(:,1:end-1)+V(:,2:end))];
ut=U1./max(hz,10)*100.*mz;vt=V1./max(hz,10)*100.*mz;
[umaj,umin,uincl,uphase]=TideEl(ut,vt);
%% Cut off 0.1% of too big values
%umax=max(max(umaj));
%ii=0;L=floor(sum(sum(mz))/1000);
%k=1;
%while length(ii)<L,
% umax=0.9*umax;
% ii=find(umaj>umax);
%end
%umaj(ii)=umax;
umaj=umaj';umin=umin';uincl=uincl';uphase=uphase';
return
