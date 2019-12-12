%  outputs a grid file in matlab
% USAGE:   grd_out(cfile,ll_lims,hz,mz,iob,dt);

function   grd_out(cfile,ll_lims,hz,mz,iob,dt);

%   open this way for files to be read on Unix machine
fid = fopen(cfile,'w','b');
[dum,nob] = size(iob);
[n,m] = size(hz);
reclen = 32;
fwrite(fid,reclen,'long');
fwrite(fid,n,'long');
fwrite(fid,m,'long');
fwrite(fid,ll_lims(3:4),'float');
fwrite(fid,ll_lims(1:2),'float');
fwrite(fid,dt,'float');
fwrite(fid,nob,'long');
fwrite(fid,reclen,'long');
%
if nob == 0,
   fwrite(fid,4,'long');
   fwrite(fid,0,'long');
   fwrite(fid,4,'long');
else
   reclen=8*nob; 
   fwrite(fid,reclen,'long');
   fwrite(fid,iob,'long');
   fwrite(fid,reclen,'long');
end
%
reclen = 4*n*m;
fwrite(fid,reclen,'long');
fwrite(fid,hz,'float');
fwrite(fid,reclen,'long');
fwrite(fid,reclen,'long');
fwrite(fid,mz,'long');
fwrite(fid,reclen,'long');
fclose(fid);
return
