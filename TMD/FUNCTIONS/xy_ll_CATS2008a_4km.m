% converts lat,lon to x,y(km) and back
% usage: [x,y]=xy_ll_CATS2008a_4km(lon,lat,'F'); or
%        [lon,lat]=xy_ll_CATS2008a_4km(x,y,'B');
function [x2,y2]=xy_ll_CATS2008a_4km(x1,y1,BF);
if BF=='F', % lat,lon ->x,y
    [x2,y2]=mapll(y1,x1,71,-70,'s');
else
    [y2,x2]=mapxy(x1,y1,71,-70,'s');
end
return
 
