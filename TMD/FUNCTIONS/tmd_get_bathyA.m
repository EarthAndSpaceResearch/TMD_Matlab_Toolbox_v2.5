%========================================================================
% tmd_get_bathyA.m
%
% Gets map of bathymetry (water column thickness under ice shelves) for
%   specified atlas model
%
% Written by:   Laurie Padman (ESR): padman@esr.org
%               August 18, 2004
% Modified by Lana Erofeeva for atlas models, 2014
% Sample call:
%              [long,latg,H]=tmd_get_bathyA('Model_tpxo8_atlas30');
%
%========================================================================
% TMD release 2.02: 21 July 2010
%
function [long,latg,H]      = tmd_get_bathyA(Model);
w=what('TMD');funcdir=[w.path '/FUNCTIONS'];
path(path,funcdir);
[ModName,GridName]=rdModFileA(Model,1);
gname=char(GridName{end});
check=exist(gname,'file');
if(check~=2);   % Grid File not found
    disp(' ')
    disp('Grid file not found. Add directory containing model grids')
    disp('  to bottom of Matlab path definition (use "File -> Set Path')
    disp('  on Matlab toolbar) or use full path name when specifying')
    disp('  Model name.')
    disp(' ')
end

[latlon_lims, H, mz, iob] = grd_in(gname);
[n,m]=size(H);
[long,latg]=XY(latlon_lims, n, m);
H=H';
return
