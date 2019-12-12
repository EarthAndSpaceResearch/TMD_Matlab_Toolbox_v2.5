function [] = uv_out(cfile,u,v,th_lim,ph_lim,c_ids)
%USAGE:  [] = uv_out(cfile,u,v,th_lim,ph_lim,c_ids);
% writes out transports in file cfile
[n,m,nc]=size(u);
fid = fopen(cfile,'w','b');
llHead = 4*(7+nc);
fwrite(fid,llHead,'long');
fwrite(fid,n,'long');
fwrite(fid,m,'long');
fwrite(fid,nc,'long');
fwrite(fid,th_lim,'float');
fwrite(fid,ph_lim,'float');
fwrite(fid,c_ids,'char');
fwrite(fid,llHead,'long');
uv = zeros(4*n,m);
llConstit = 2*8*n*m;
for ic = 1:nc
   fwrite(fid,llConstit,'long');
   uv(1:4:4*n-3,:)=real(u(:,:,ic));
   uv(2:4:4*n-2,:)=imag(u(:,:,ic));
   uv(3:4:4*n-1,:)=real(v(:,:,ic));
   uv(4:4:4*n  ,:)=imag(v(:,:,ic)); 
   fwrite(fid,uv,'float');
   fwrite(fid,llConstit,'long');
end
fclose(fid);
