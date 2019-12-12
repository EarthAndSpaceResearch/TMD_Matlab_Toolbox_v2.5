function [U,V,th_lim,ph_lim,Modp] = u_in_p(cfile,con)
% USAGE:  [U,V,th_lim,ph_lim,Modp] = u_in_p(cfile,con);
% reads in transports for constituent con from file cfile
% th_lim,ph_lim - global grid limits
% u,v - global transports
% Modp - structure of patched-in local models transports
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
 htemp = fread(fid,[4*n,m],'float');
 if k==ic,
  U = htemp(1:4:4*n-3,:)+i*htemp(2:4:4*n-2,:);
  V = htemp(3:4:4*n-1,:)+i*htemp(4:4:4*n,:);
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
  nu = fread(fid,1,'long');
  nv = fread(fid,1,'long');
  %[n1 m1 nc1 nu nv]
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
  id=fread(fid,2*nu,'long');
  iu=id(1:nu);ju=id(nu+1:2*nu);
  s=fseek(fid,8,'cof');
  id=fread(fid,2*nv,'long');
  iv=id(1:nv);jv=id(nv+1:2*nv);
  s=fseek(fid,4,'cof');
   u=[];v=[];
  for k=1:nc1
   s=fseek(fid,4,'cof');
   tmpu=fread(fid,2*nu,'float');
   s=fseek(fid,8,'cof');
   tmpv=fread(fid,2*nv,'float');
   s=fseek(fid,4,'cof');
   if k==ic1,
    u=tmpu(1:2:end)+i*tmpu(2:2:end);
    v=tmpv(1:2:end)+i*tmpv(2:2:end);
  end
  end 
   Modp(nmod)=struct('n',n1,'m',m1,'nu',nu,'nv',nv,'u',u,'v',v,...
                     'iu',iu,'ju',ju,'iv',iv,'jv',jv,...
                    'll_lims',ll_lims1,'name',name);
end
fprintf('Local patched in uv-models: %d\n',nmod);
fclose(fid);
return
