% converts lat,lon to x,y(km) and back
% usage: [x,y]=xy_ll(lon,lat,'F'); or
%        [lon,lat]=xy_ll(x,y,'B');
function [x,y]=xy_ll(lon,lat,BF);
if BF=='F', % lat,lon ->x,y
 x=(90.-lat)*111.7.*cos(lon./180.*pi);
 y=(90.-lat)*111.7.*sin(lon./180.*pi);
else
 x=lon;y=lat;
 lat=90-sqrt(x.^2+y.^2)/111.7;
 lon=atan2(y,x)*180/pi;
 ii=find(lon<0);
 lon(ii)=lon(ii)+360;
 x=lon;y=lat;
end
return
 
