% read constituents from h*out or u*out file
% usage: [conList]=rd_con(fname);
function [conList]=rd_con(fname);
fid = fopen(fname,'r','b');
ll = fread(fid,1,'long');
nm = fread(fid,3,'long');
n=nm(1);
m = nm(2);
nc = nm(3);
th_lim = fread(fid,2,'float');
ph_lim = fread(fid,2,'float');
C=fread(fid,nc*4,'uchar');
C=reshape(C,4,nc);C=C';
conList=char(C);
fclose(fid);
return
