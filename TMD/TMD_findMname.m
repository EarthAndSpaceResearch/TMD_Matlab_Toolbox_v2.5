function [Mname]=TMD_findMname(hfile,ufile);
L=min(length(hfile),length(ufile));
% find k where common path ends
for k=1:L
 if strncmp(hfile,ufile,k)==0,break;end
end
hname=hfile(k:end);
uname=ufile(k:end);
% now find common in hname and uname
L=length(hname);
Mname=[];ind=[];
for k=1:L
  ik=findstr(uname,hname(k:k));
  if isempty(ik)==0,ind=[ind k];end
end
dind=[1, ind(2:end)-ind(1:end-1)];
ik=find(dind==1);
Mname=['h/UV' hname(ind(ik))];
return
