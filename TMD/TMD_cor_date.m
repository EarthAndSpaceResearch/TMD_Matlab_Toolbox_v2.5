% check/correct date
function [yy,mm,dd]=TMD_cor_date(yy,mm,dd,uT);
a=datevec(datenum(yy,mm,dd,0,0,0));
if a(1)==yy & a(2)==mm & a(3)==dd,
 return;
else
 yy=a(1);mm=a(2);dd=a(3);
end
for it=1:3
 set(uT(it),'String',int2str(a(it)));
end
return
