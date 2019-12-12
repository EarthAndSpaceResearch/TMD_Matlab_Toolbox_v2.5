%  Input File should be an ascii file with 2 to 10 columns, including:
%
%  lat lon {yyyy mm dd hh mi {sec dt(min) L}}
%
% {} means the columns might be omited
%
% If the mode is "Extract Tidal constants" 
% then columns 3-10 are omited OR ignored.
%
% If the mode is "Predict tide" then the columns
% yyyy mm dd hh mi MUST be in the file, but the columns
% {sec dt(min) L} might be omited, then by default:
% sec(seconds)            = 00
% dt (time step, minutes) = 60
% L ( time series length) = 1
%
% See the file "LAT_LON/lat_lon_time" for example.
%
