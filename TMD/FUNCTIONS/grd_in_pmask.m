% input OTIS atlas grid
% USAGE: [ll_lims,hz,mz,pmask,Modp]=grd_in_pmask(cfile);
% ll_lims - global grid limits
% hz - global bathymety
% mz - global land/water mask
% Modp - structure of patched-in local models bathymetries

function [ll_lims,hz,mz,pmask,Modp]=grd_in_pmask(cfile);
% first read standard part (as in grd_in)
Modp=[];
fid = fopen(cfile,'r','b');
fseek(fid,4,'bof');
n = fread(fid,1,'long');
m = fread(fid,1,'long');
lats = fread(fid,2,'float');
lons = fread(fid,2,'float');
dt = fread(fid,1,'float');
ll_lims = [lons ; lats ];
nob = fread(fid,1,'long');
if nob == 0, 
   fseek(fid,20,'cof');
   iob = [];
else
   fseek(fid,8,'cof');
   iob = fread(fid,[2,nob],'long');
   fseek(fid,8,'cof');
end
hz = fread(fid,[n,m],'float');
fseek(fid,8,'cof');
mz = fread(fid,[n,m],'long');
fseek(fid,8,'cof');
pmask = fread(fid,[n,m],'long');
fseek(fid,4,'cof');
% read local models
s=0;nmod=0;
while s>=0,
  s=fseek(fid,4,'cof');if s<0,break;end
  nmod=nmod+1;
  n1 = fread(fid,1,'long');
  m1 = fread(fid,1,'long');  
  nd = fread(fid,1,'long');
  lats1 = fread(fid,2,'float');
  lons1 = fread(fid,2,'float'); 
  ll_lims1 = [lons1 ; lats1 ];
  a = fread(fid,20,'uchar');name=char(a');
  s=fseek(fid,8,'cof');
  id=fread(fid,2*nd,'long');
  iz=id(1:nd);jz=id(nd+1:2*nd);
  s=fseek(fid,8,'cof');
  d=fread(fid,nd,'float');
  s=fseek(fid,4,'cof');
  tmp=struct('n',n1,'m',m1,'nd',nd,'depth',d,'iz',iz,'jz',jz,...
                    'll_lims',ll_lims1,'name',name);
  %Modp(nmod)=struct('n',n1,'m',m1,'nd',nd,'depth',d,'iz',iz,'jz',jz,...
  %                  'll_lims',ll_lims1,'name',name);
  Modp=[Modp,tmp];
end
fprintf('Local patched in grids: %d\n',nmod);
fclose(fid);
return
