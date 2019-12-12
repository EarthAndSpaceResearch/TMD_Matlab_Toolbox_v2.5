% calculates tidal ellipse parameters for the arrays of
% u and v - COMPLEX amplitudes of EW and NS currents of
% a given tidal constituent
% land should be set to 0 or NaN in u,v prior to calling tideEl
% usage: [umajor,uminor,uincl,uphase]=tideEl(u,v);
function [umajor,uminor,uincl,uphase]=tideEl(u,v);
% change to polar coordinates 
% in Robin's was - + + -, this is as in Foreman's
t1p = (real (u) - imag(v));
t2p = (real (v) + imag(u));
t1m = (real (u) + imag(v));
t2m = (real (v) - imag(u));
% ap, am - amplitudes of positevely and negatively
% rotated vectors
ap = sqrt( (t1p.^2 + t2p.^2)) / 2.;
am = sqrt( (t1m.^2 + t2m.^2)) / 2.;
% ep, em - phases of positively and negatively rotating vectors
ep = atan2( t2p, t1p);
ep = ep + 2 * pi * (ep < 0.0);
ep = 180. * ep / pi;
em = atan2( t2m, t1m);
em = em + 2 * pi * (em < 0.0);
em = 180. * em / pi;
%  determine the major and minor axes, phase and inclination using Foreman's formula 
umajor = (ap + am); 
uminor = (ap - am);
uincl = 0.5 * (em + ep);
uincl = uincl - 180. *  (uincl > 180);
uphase = - 0.5*(ep-em) ;
uphase = uphase + 360. * (uphase < 0);
uphase = uphase - 360. * (uphase >= 360);
return
