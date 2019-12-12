%  reads a grid file in matlab
% USAGE: [ll_lims,hz,mz,iob,dt] =  grd_in(cfile);


function [ll_lims,hz,mz,iob,dt] =  grd_in(cfile);

fid = fopen(cfile,'r','b');
fseek(fid,4,'bof');
n = fread(fid,1,'long');
m = fread(fid,1,'long');
lats = fread(fid,2,'float');
lons = fread(fid,2,'float');
dt = fread(fid,1,'float');
if(lons(1) < 0) & (lons(2) < 0 ) & dt>0,
   lons = lons + 360;
end
ll_lims = [lons ; lats ];
%fprintf('Time step (sec): %10.1f\n',dt);
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
fclose(fid);
