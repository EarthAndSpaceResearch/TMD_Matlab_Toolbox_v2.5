% function to read model control file for atlas models
% usage:
% [ModName,GridName]=rdModFileA(Model,k);
%
% Model - control file name for atlas tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
% Since atlas can consists of per/constituent files (or be compact)
% '*' is allowed in file names
% Model h/uv/grid files for 1/30 atlas are provided in OTIS format
% Model h/uv/grid files for compact atlas are provided in compact
% format
% k =1/2 for elevations/transports
%
% OUTPUT
% ModName - model file name(s) for elevations/transports
% GridName - grid file name(s)
%

function [ModName,GridName]=rdModFileA(Model,k);
Model=strrep(Model,'\','/');
i1=findstr(Model,'/');
pname=[];
if isempty(i1)==0,pname=Model(1:i1(end));end
fid=fopen(Model,'r');
ModName=[];GridName=[];
if fid<1,fprintf('File %s does not exist\n',Model);return;end
hfile=fgetl(fid);hfile=strrep(hfile,'\','/');
ufile=fgetl(fid);ufile=strrep(ufile,'\','/');
gfile=fgetl(fid);gfile=strrep(gfile,'\','/');
i1=findstr(hfile,'/');
i2=findstr(ufile,'/');
i3=findstr(gfile,'/');
if isempty(i3)==0,GridName=gfile;else GridName=[pname gfile];end
if k==1 & isempty(i1)==0,pname=[];end
if k==2 & isempty(i2)==0,pname=[];end
if k==1,ModName=[pname hfile];else ModName=[pname ufile];end
fclose(fid);
% 
if exist('ltmp','file')>0,delete ltmp;end
eval(['!ls -1 ' ModName '>ltmp']);
fid=fopen('ltmp','r');
s=1;k=1;
while s>0,
  s=fgetl(fid);
  if s<0,break;end;
  if isempty(s)>0, break;end
  if isempty(deblank(s))>0, break;end
  MName{k}=s;
  k=k+1;
end
fclose(fid);
if length(MName)<0,fprintf('No matching files found: %s\n',ModName);return;end
ModName=MName;
% 
if exist('ltmp','file')>0,delete ltmp;end
eval(['!ls -1 ' GridName '>ltmp']);
fid=fopen('ltmp','r');
s=1;k=1;
while s>0,
  s=fgetl(fid);
  if s<0,break;end;
  if isempty(s)>0, break;end
  if isempty(deblank(s))>0, break;end
  GName{k}=s;
  k=k+1;
end
fclose(fid);
if length(GName)<0,fprintf('No matching files found: %s\n',GridName);return;end
GridName=GName;
return

