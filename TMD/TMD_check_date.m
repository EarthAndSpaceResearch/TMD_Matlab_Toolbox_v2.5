function [d]=TMD_check_date(d,type,uT);
if isempty(d)>0, d=1;end
if length(d)>1,d=d(1);end
d=round(d);
if type=='yy',
 if d<1800 | d>2200, d=1992;end
elseif type=='mm',
 if d<1 | d>12, d=1;end
elseif type=='dd',
 if d<1 | d>31, d=1;end
elseif type=='hh',
 if d<0 | d>24, d=1;end
elseif type=='mi',
 if d<0 | d>60, d=1;end
elseif type=='nh',
 if d<0, d=1;end
end
set(uT,'String',int2str(d));
return
