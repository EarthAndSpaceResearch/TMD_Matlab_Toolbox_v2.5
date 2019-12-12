function [h,th_lim,ph_lim] = h_in(cfile,ic)
%USAGE:  [h,th_lim,ph_lim] = h_in(cfile,ic);
% reads in elevation for constituent # ic in file cfile
fid = fopen(cfile,'r','b');
ll = fread(fid,1,'long');
nm = fread(fid,3,'long');
n=nm(1);
m = nm(2);
nc = nm(3);
th_lim = fread(fid,2,'float');
ph_lim = fread(fid,2,'float');
%nskip = (ic-1)*(nm(1)*nm(2)*8+8) + 8 + 4*nc;
nskip = (ic-1)*(nm(1)*nm(2)*8+8) + 8 + ll - 28;
fseek(fid,nskip,'cof');
htemp = fread(fid,[2*n,m],'float');
h = htemp(1:2:2*n-1,:)+i*htemp(2:2:2*n,:);
fclose(fid);
