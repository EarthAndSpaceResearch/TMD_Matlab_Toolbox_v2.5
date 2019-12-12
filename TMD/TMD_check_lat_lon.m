function [ll]=TMD_check_lat_lon(cll,ik,uP);
ll=str2num(cll);
if isempty(ll)>0, % bad number
 S1=[];
 for k=1:length(cll),
  if cll(k:k)~='.',
   n1=str2num(cll(k:k));S1=[S1 num2str(n1)];
  else
   S1=[S1 '.'];
  end
 end
 ll=str2num(S1);
 if isempty(ll)>0,ll=90;end
 set(uP,'String',num2str(ll));
 return;
end
if length(ll)>1,ll=ll(1);end
sl=num2str(ll);
sl1=sl(1:end-1);sl2=sl(2:end);
ll1=str2num(sl1);ll2=str2num(sl2);
i1=0;
if isempty(ll1)==0,
 if ik==1 & ll1>=-90 &  ll1<=90,  i1=1;end
 if ik==2 & ll1>=-180 & ll1<=360, i1=1;end
end
i2=0;
if isempty(ll2)==0,
 if ik==1 & ll2>=-90  & ll2<=90,  i2=1;end
 if ik==2 & ll2>=-180 & ll2<=360, i2=1;end
end
ls=90;
if i1==1,ls=ll1;elseif i2==1,ls=ll2;end
if ik==1, % lat
 if ll<-90 | ll>90, ll=ls;end
else
 if ll<-180 | ll>360, ll=ls;end
end
set(uP,'String',num2str(ll));
return
