%========================================================================
% tmd_get_bathy.m
%
% Gets map of bathymetry (water column thickness under ice shelves) for
%   specified model.
%
% Written by:   Laurie Padman (ESR): padman@esr.org
%               August 18, 2004
%
% Sample call:
%              [long,latg,H]=tmd_get_bathy('Model_ISPOL');
%
%========================================================================
% TMD release 2.02: 21 July 2010
%
function [long,latg,H]      = tmd_get_bathy(Model);
w=what('TMD');funcdir=[w.path '/FUNCTIONS'];
path(path,funcdir);
[ModName,GridName,Fxy_ll]=rdModFile(Model,1);

check=exist(GridName,'file');
if(check~=2);   % Grid File not found
    disp(' ')
    disp('Grid file not found. Add directory containing model grids')
    disp('  to bottom of Matlab path definition (use "File -> Set Path')
    disp('  on Matlab toolbar) or use full path name when specifying')
    disp('  Model name.')
    disp(' ')
end

[latlon_lims, H, mz, iob] = grd_in(GridName);
[n,m]=size(H);
[long,latg]=XY(latlon_lims, n, m);
H=H';
return
