% function to read model control file
% usage:
% [ModName,GridName,Fxy_ll]=rdModFile(Model,k);
%
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
% k =1/2 for elevations/transports
%
% OUTPUT
% ModName - model file name for elvations/transports
% GridName - grid file name
% Fxy_ll - function to convert lat,lon to x,y
%          (only for models on cartesian grid (in km));
%          If model is on lat/lon grid Fxy_ll=[];

function [ModName,GridName,Fxy_ll]=rdModFile(Model,k);
Model=strrep(Model,'\','/');
i1=findstr(Model,'/');
pname=[];
if isempty(i1)==0,pname=Model(1:i1(end));end
fid=fopen(Model,'r');
ModName=[];GridName=[];Fxy_ll=[];
if fid<1,fprintf('File %s does not exist\n',Model);return;end
hfile=fgetl(fid);hfile=strrep(hfile,'\','/');
ufile=fgetl(fid);ufile=strrep(ufile,'\','/'); % BUG fix 2014
gfile=fgetl(fid);gfile=strrep(gfile,'\','/'); % BUG fix 2014
i1=findstr(hfile,'/');
i2=findstr(ufile,'/');
i3=findstr(gfile,'/');
if isempty(i3)==0,GridName=gfile;else GridName=[pname gfile];end
if k==1 & isempty(i1)==0,pname=[];end
if k==2 & isempty(i2)==0,pname=[];end
if k==1,ModName=[pname hfile];else ModName=[pname ufile];end
Fxy_ll=fgetl(fid);
if Fxy_ll==-1,Fxy_ll=[];end
fclose(fid);
% check if the file exist
fid=fopen(ModName,'r');
if fid<1,fprintf('File does not exist: %s\n',ModName);
         ModName=[];GridName=[];return;end
%
return

