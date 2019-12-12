function [h,th_lim,ph_lim,Modp] = h_in_p(cfile,con)
% USAGE:  [h,th_lim,ph_lim,Modp] = h_in_p(cfile,con);
% reads in elevation for constituent con from file cfile
% th_lim,ph_lim - global grid limits
% h - global elevations
% Modp - structure of patched-in local models elevations
%
[conList]=rd_con(cfile);
[nc,dum]=size(conList);
ic=0;con=deblank(lower(con));
for k=1:nc
  if strcmp(con,deblank(conList(k,:))),ic=k;end
end
if ic==0,
 fprintf('No constituent %s found\n', con);return
end
% 
fid = fopen(cfile,'r','b');
ll = fread(fid,1,'long');
nm = fread(fid,3,'long');
n=nm(1);
m = nm(2);
nc = nm(3);
th_lim = fread(fid,2,'float');
ph_lim = fread(fid,2,'float');
C=fread(fid,nc*4,'uchar');
fseek(fid,4,'cof');
for k=1:nc
 fseek(fid,4,'cof');
 htemp = fread(fid,[2*n,m],'float');
 if k==ic,
  h = htemp(1:2:2*n-1,:)+i*htemp(2:2:2*n,:);
 end
 fseek(fid,4,'cof');
end
% read local models
s=0;nmod=0;
while s>=0,
  s=fseek(fid,4,'cof');if s<0,break;end
  nmod=nmod+1;
  n1 = fread(fid,1,'long');
  m1 = fread(fid,1,'long');
  nc1 = fread(fid,1,'long');  
  nz = fread(fid,1,'long');
  %[n1 m1 nc1 nz]
  lats1 = fread(fid,2,'float');
  lons1 = fread(fid,2,'float'); 
  ll_lims1 = [lons1 ; lats1 ];
  c=fread(fid,nc1*4,'uchar');c=reshape(c,4,nc1);c=c';cons=char(c);
  ic1=0;
  for k=1:nc1
   if strcmp(con,deblank(cons(k,:))),ic1=k;end
  end
  a = fread(fid,20,'uchar');name=char(a');
  s=fseek(fid,8,'cof');
  id=fread(fid,2*nz,'long');
  iz=id(1:nz);jz=id(nz+1:2*nz);
  s=fseek(fid,4,'cof');
  z=[];
  for k=1:nc1
   s=fseek(fid,4,'cof');
   tmp=fread(fid,2*nz,'float');
   s=fseek(fid,4,'cof');
   if k==ic1,z=tmp(1:2:end)+i*tmp(2:2:end);end
  end 
  Modp(nmod)=struct('n',n1,'m',m1,'nz',nz,'z',z,'iz',iz,'jz',jz,...
                    'll_lims',ll_lims1,'name',name);
end
fprintf('Local patched in z-models: %d\n',nmod);
fclose(fid);
return
