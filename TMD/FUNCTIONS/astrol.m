%  Computes the basic astronomical mean longitudes  s, h, p, N.
%  Note N is not N', i.e. N is decreasing with time.
%  These formulae are for the period 1990 - 2010, and were derived
%  by David Cartwright (personal comm., Nov. 1990).
%  time is UTC in decimal MJD.
%  All longitudes returned in degrees.
%  R. D. Ray    Dec. 1990
%  Non-vectorized version. Re-make for matlab by Lana Erofeeva, 2003
% usage: [s,h,p,N]=astrol(time)
%        time, MJD
function  [s,h,p,N]=astrol(time);
circle=360;
T = time - 51544.4993;
% mean longitude of moon
% ----------------------
s = 218.3164 + 13.17639648 * T;
% mean longitude of sun
% ---------------------
h = 280.4661 +  0.98564736 * T;
% mean longitude of lunar perigee
% -------------------------------
p =  83.3535 +  0.11140353 * T;
% mean longitude of ascending lunar node
% --------------------------------------
N = 125.0445D0 -  0.05295377D0 * T;
%
s = mod(s,circle);
h = mod(h,circle);
p = mod(p,circle);
N = mod(N,circle);
%
if s<0, s = s + circle; end
if h<0, h = h + circle; end
if p<0, p = p + circle; end
if N<0, N = N + circle; end
return

