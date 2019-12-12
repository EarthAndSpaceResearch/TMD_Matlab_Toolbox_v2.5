function mjd=date_mjd(year,month,day,hour,mm,ss);
% convert a date given as integers - year,month,day,hour,mm,ss 
% to Modified Julian Days (mjd)
% usage: mjd=date_mjd(year,month,day,hour,mm,ss);
%        last arguments are optional
mjd0=48622;d0=datenum(1992,1,1,0,0,0);
% Jan 1, 1992 00:00 GMT  is 48622mjd
%
switch nargin
 case 0
  year=0;month=1;day=1;hour=0;mm=0;ss=0;
 case 1
  month=1;day=1;hour=0;mm=0;ss=0;
 case 2
  day=1;hour=0;mm=0;ss=0;
 case 3
  hour=0;mm=0;ss=0;
 case 4
  mm=0;ss=0;
 case 5
  ss=0;
end
% sanity check
month=max(month,1);month=min(month,12);
dpm=[31,28,31,30,31,30,31,31,30,31,30,31];
if floor(year/4)*4==year,dpm(2)=dpm(2)+1;end
day=max(day,1);day=min(day,dpm(month));
hour=max(hour,0);hour=min(hour,23);
mm=max(mm,0);mm=min(mm,59);ss=max(ss,0);ss=min(ss,59);
d=datenum(year,month,day,hour,mm,ss);
mjd=mjd0+d;
return


