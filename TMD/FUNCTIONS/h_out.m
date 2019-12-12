function [] =  h_out(cfile,h,th_lim,ph_lim,c_ids)
% Usage: [] = h_out(cfile,h,th_lim,ph_lim,c_ids)
%WARNING!!!! C_IDS HAVE TO BE 4 CHARACTER STRINGS !!!!!!!!!
% writes elevation file in standard format
fid = fopen(cfile,'w','b');
[n,m,nc] = size(h);
%  length of header: allow for 4 character long c_id strings
llHead = 4*(7+nc);
fwrite(fid,llHead,'long');
fwrite(fid,n,'long');
fwrite(fid,m,'long');
fwrite(fid,nc,'long');
fwrite(fid,th_lim,'float');
fwrite(fid,ph_lim,'float');
fwrite(fid,c_ids,'char');
fwrite(fid,llHead,'long');
htemp = zeros(2*n,m);
llConstit = 8*n*m;
for ic = 1:nc
   fwrite(fid,llConstit,'long');
   htemp(1:2:2*n-1,:) = real(h(:,:,ic));
   htemp(2:2:2*n,:) = imag(h(:,:,ic));
   fwrite(fid,htemp,'float');
   fwrite(fid,llConstit,'long');
end
fclose(fid);
