function [u,v,th_lim,ph_lim] = u_in(cfile,ic)
%USAGE:  [u,v,th_lim,ph_lim] = u_in(cfile,ic);
% reads in transports for constituent # ic in file cfile
fid = fopen(cfile,'r','b');
ll = fread(fid,1,'long');
nm = fread(fid,3,'long');
n=nm(1);
m = nm(2);
nc = nm(3);
th_lim = fread(fid,2,'float');
ph_lim = fread(fid,2,'float');
%nskip = (ic-1)*(nm(1)*nm(2)*16+8) + 8 + 4*nc;
nskip = (ic-1)*(nm(1)*nm(2)*16+8) + 8 + ll-28;
fseek(fid,nskip,'cof');
htemp = fread(fid,[4*n,m],'float');
ur= htemp(1:4:4*n-3,:);
%fprintf('ur ');
ui= htemp(2:4:4*n-2,:);
%fprintf('ui ');
vr= htemp(3:4:4*n-1,:);
%fprintf('vr ');
vi= htemp(4:4:4*n,:); 
%fprintf('vi done\n');
clear htemp;
u= ur+i*ui;clear ur ui; 
v =vr+i*vi;
fclose(fid);
