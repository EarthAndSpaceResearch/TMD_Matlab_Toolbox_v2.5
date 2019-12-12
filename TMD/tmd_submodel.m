%function []=tmd_submodel
% =====================================================================
% Function to make a submodel from a model ModName (TMD format)
%   calculated on bathymetry grid Gridname
%
% PARAMETERS
%
% INPUT: User specified interactively
%
% OUTPUT:
%   Model_<Name_new> ... control file of 3 or 4 lines
%                        (as in old)
%   h.<Name_new> ....... elevation file   
%   UV.<Name_new> ...... transports file
%   grid_<Name_new> .... grid file
%
% sample call:    tmd_submodel;
%
% Written by:  Lana Erofeeva (OSU): serofeeva@coas.oregonstate.edu
% Modified by: Laurie Padman (ESR): padman@esr.org
%
% TMD release 2.02: 21 July 2010
%
% ======================================================================

slash='/';
MACH=computer; lmach=length(MACH);
if(lmach==5)
    if(computer=='PCWIN'); slash='\'; end
end
w=what('TMD');funcdir=[w.path slash 'FUNCTIONS'];
path(path,funcdir);
% Select the input model to trim down
[fname,fpath] = uigetfile('DATA/Model*','Model file to process ...');
if(~fname) % user pressed Cancel in file dialog box
    return;
end;
Model=fullfile(fpath,fname);
i1=findstr(fname,'_');
len=length(fname);
Name_old=fname((i1+1):len);

% Create new file name (will be placed temporarily in same directory)
disp(' ')
disp('Enter name of new model, skipping "Model_" prefix.')
disp('e.g., for a new name of "Model_New", enter "New".');
Name_new=input('Enter name of new model ...','s');
disp(' ')
disp('Select new limits for the model.');
disp('If parent model is lat/lon, enter')
disp('   string "[lon_min lon_max lat_min lat_max]".');
disp('If parent model is x/y, enter')
disp('   string "[x_min x_max y_min y_max]".');
disp(' ')

[hname,gname,Fxy_ll]=rdModFile(Model,1);
[uname,gname,Fxy_ll]=rdModFile(Model,2);

if(isempty(Fxy_ll));
    disp('Parent Model is coded in lat/lon')
else;
    disp('Parent model is coded in polar stereo x/y')
end
disp(' ')

% Get grid so you can throw up a plot of the parent domain
[xg,yg,Hg]=tmd_get_bathy(Model);
S=max([length(xg) length(yg)]);
nd=max([round(S/500) 1]);
xg=xg(1:nd:end); yg=yg(1:nd:end); Hg=Hg(1:nd:end,1:nd:end);
figure(10); clf
Hg(Hg==0)=NaN;
pcolor(xg,yg,Hg); shading flat; colorbar
if(~isempty(Fxy_ll));
    axis('equal'); 
end
axis([min(xg) max(xg) min(yg) max(yg)]); grid on
cons=rd_con(hname);
[nc,i4]=size(cons);
cid=reshape(cons',1,nc*i4);
[xy_lim,hz,mz,iob]=grd_in(gname);
xy_lim=xy_lim';
disp(xy_lim)
% Enter new limits
disp(' ')
if(isempty(Fxy_ll))
    disp('Grid limits on old file are ...')
    disp([num2str(xy_lim) '  degrees.'])
    glob=0;
    if xy_lim(2)-xy_lim(1)>=360,
     disp('Grid is GLOBAL');glob=1;
    end
    disp(' ')
    lims=input('Enter lon, lat limits: vector "[lon1 lon2 lat1 lat2]" ) ... ');
% adjust silly lim input
    while max(lims(1:2))>360,lims(1:2)=lims(1:2)-360;end
    lims(3)=max(-90,lims(3));lims(4)=min(90,lims(4));
else
    disp('Grid limits on old file are ...')
    disp([num2str(xy_lim) '  km.'])
    disp(' ')
    lims=input('Enter x, y limits: vector "[x_min x_max y_min y_max]" ) ... ');
end
% check limits
if ((xy_lim(1)<=lims(1) && xy_lim(2)>=lims(2)) || glob) &&...
    xy_lim(3)<=lims(3) && xy_lim(4)>=lims(4),
   [n,m]=size(hz);
   [x,y]=XY(xy_lim,n,m);
   stx=x(2)-x(1);sty=y(2)-y(1);
   if glob && lims(1)<xy_lim(1),
     i1=find(x>=180);i2=find(x<180);
     x=[x(i1)-360,x(i2)];
     xy_lim(1)=x(1)-stx/2;xy_lim(2)=x(end)+stx/2;
     if xy_lim(1)<=lims(1) && xy_lim(2)>=lims(2),
      hz=[hz(i1,:);hz(i2,:)];
% update figure
      xg=x(1:nd:end); Hg=hz(1:nd:end,1:nd:end)';
      figure(10);clf
      Hg(Hg==0)=NaN;
      pcolor(xg,yg,Hg); shading flat; colorbar
      if(~isempty(Fxy_ll));
        axis('equal'); 
      end
      axis([min(xg) max(xg) min(yg) max(yg)]); grid on
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     else
      fprintf('Can not adjust global model for requested limits\n');
      fprintf('Adjusted %s limits: %10.4f %10.4f %10.4f %10.4f\n',...
               Name_old,xy_lim);
      fprintf('Your limits: %10.4f %10.4f %10.4f %10.4f\n',lims);
      return
     end
   end
   i1=min(find(x>=lims(1))); i2=max(find(x<=lims(2)));
   j1=min(find(y>=lims(3))); j2=max(find(y<=lims(4)));
   new_lims=[x(i1)-stx/2,x(i2)+stx/2,...
             y(j1)-sty/2,y(j2)+sty/2];
   n1=i2-i1+1;m1=j2-j1+1;
   hz1=hz(i1:i2,j1:j2);mz1=mz(i1:i2,j1:j2);
   disp([i1 i2 j1 j2])
   % and draw them
   figure(10); hold on
   %rectangle('Position',[lims(1) lims(3) diff(lims(1:2)) diff(lims(3:4))],...
   %    'EdgeColor','k','LineWidth',2);
   %rectangle('Position',[new_lims(1) new_lims(3) diff(new_lims(1:2)) diff(new_lims(3:4))],...
   %    'EdgeColor','r','LineWidth',1);
   line([lims(1) lims(2) lims(2) lims(1) lims(1)],...
        [lims(3) lims(3) lims(4) lims(4) lims(3)],'Color','k');
   line([new_lims(1) new_lims(2) new_lims(2) new_lims(1) new_lims(1)],...
        [new_lims(3) new_lims(3) new_lims(4) new_lims(4) new_lims(3)],'color','r');
   pause(2)
else
  fprintf('Requested limits are out of Model area\n');
  fprintf('%s limits: %10.4f %10.4f %10.4f %10.4f\n',...
            Name_old,xy_lim);
  fprintf('Your limits: %10.4f %10.4f %10.4f %10.4f\n',lims);
  return
end
%
cname1=['Model_' Name_new];
gname1=['grid_' Name_new];
hname1=['h_' Name_new];
uname1=['UV_' Name_new];

fprintf('Writing control file %s\n',fullfile(fpath,cname1));
fid=fopen(fullfile(fpath,cname1),'w');
fprintf(fid,'%s\n',hname1);
fprintf(fid,'%s\n',uname1);
fprintf(fid,'%s\n',gname1);
dt=12;
if isempty(Fxy_ll)==0,
 fprintf(fid,'%s\n',Fxy_ll);dt=-dt;
end
fclose(fid);

fprintf('Writing grid file %s...', gname1);
grd_out(fullfile(fpath,gname1),new_lims,hz1,mz1,[],dt);
fprintf('done\n');

fprintf('Reading elevation file %s\n',hname);
H=zeros(n1,m1,nc);
for ic=1:nc
 [h1,th_lim,ph_lim]=h_in(hname,ic);
 H(:,:,ic)=h1(i1:i2,j1:j2);
 fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing elevation file ...',hname1);
h_out(fullfile(fpath,hname1),H,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');

fprintf('Reading transports file %s\n',uname);
U=zeros(n1,m1,nc);V=U;
for ic=1:nc
 [u1,v1,th_lim,ph_lim]=u_in(uname,ic);
 U(:,:,ic)=u1(i1:i2,j1:j2);V(:,:,ic)=v1(i1:i2,j1:j2);
 fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing transport file ...',uname1);
uv_out(fullfile(fpath,uname1),U,V,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');
%return
