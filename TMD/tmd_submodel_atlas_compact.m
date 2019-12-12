%function []=tmd_submodel_atlas_compact
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
% sample call:    tmd_submodel_atlas;
%
% Written by:  Lana Erofeeva (OSU): serofeeva@coas.oregonstate.edu
% Modified by: Laurie Padman (ESR): padman@esr.org
% Modified by:  Lana Erofeeva (OSU): serofeeva@coas.oregonstate.edu, 2014
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
%[fname,fpath] = uigetfile('DATA/Model*','Model file to process ...');
%if(~fname) % user pressed Cancel in file dialog box
%    return;
%end;
%Model=fullfile(fpath,fname);
%
fpath='DATA/';
Model='/home/volkov/lana/TMD/DATA/Model_tpxo8_atlas_compact';fname='Model_tpxo8_atlas_compact';
%
i1=findstr(fname,'_');
len=length(fname);
Name_old=fname((i1+1):len);
[hname,gname]=rdModFileA(Model,1);
[uname,gname]=rdModFileA(Model,2);
% Create new file name (will be placed temporarily in same directory)
disp(' ')
disp('Enter name of new model, skipping "Model_" prefix.')
disp('e.g., for a new name of "Model_New", enter "New".');
Name_new=input('Enter name of new model ...','s');
disp(' ')
%
% Get grid so you can throw up a plot of the parent domain
fprintf('Reading & plotting atlas grid, wait ...');
[xy_lim,xg,yg,Hg,pmask,Modp]=tmd_get_bathyC(Model);
xy_lim=xy_lim';hz=Hg';mz=(hz>0);
S=max([length(xg) length(yg)]);
nd=max([round(S/500) 1]);
xg=xg(1:nd:end); yg=yg(1:nd:end); Hg=Hg(1:nd:end,1:nd:end);
figure(10); clf
Hg(Hg==0)=NaN;
pcolor(xg,yg,Hg); shading flat; colorbar
axis([min(xg) max(xg) min(yg) max(yg)]); grid on
cons=rd_conA(hname);
[nc,i4]=size(cons);
cid=reshape(cons',1,nc*i4);

fprintf('done\n');
% Enter new limits
disp(' ')
%
    disp('Grid limits of atlas are ...')
    disp([num2str(xy_lim) '  degrees.'])
    glob=1;
    disp(' ')
    lims=input('Enter lon, lat limits: vector [lon1 lon2 lat1 lat2]  ... ');
% adjust silly lim input
    while max(lims(1:2))>360,lims(1:2)=lims(1:2)-360;end
    lims(3)=max(-90,lims(3));lims(4)=min(90,lims(4));
%
% check limits
if ((xy_lim(1)<=lims(1) && xy_lim(2)>=lims(2)) || glob) &&...
     xy_lim(3)<=lims(3) && xy_lim(4)>=lims(4),
   [n,m]=size(hz);
   [x,y]=XY(xy_lim,n,m);
   stx=x(2)-x(1);sty=y(2)-y(1);
   if glob && lims(1)<xy_lim(1),
     ir1=find(x>=180);ir2=find(x<180);
     x=[x(ir1)-360,x(ir2)];
     xy_lim(1)=x(1)-stx/2;xy_lim(2)=x(end)+stx/2;
     if xy_lim(1)<=lims(1) && xy_lim(2)>=lims(2),
      hz=[hz(ir1,:);hz(ir2,:)];mz=[mz(ir1,:);mz(ir2,:)];
% update figure
      xg=x(1:nd:end);yg=y(1:nd:end); 
      Hg=hz(1:nd:end,1:nd:end)';
      figure(10);clf
      Hg(Hg==0)=NaN;
      pcolor(xg,yg,Hg); shading flat; colorbar
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
   i1=min(find(x>=lims(1))); i2=max(find(x<=lims(2)));x1=x(i1:i2);
   j1=min(find(y>=lims(3))); j2=max(find(y<=lims(4)));y1=y(j1:j2);
   new_lims=[x(i1)-stx/2,x(i2)+stx/2,...
             y(j1)-sty/2,y(j2)+sty/2];
   n1=i2-i1+1;m1=j2-j1+1;
   hz1=hz(i1:i2,j1:j2);mz1=mz(i1:i2,j1:j2);
   [mu1,mv1]=Muv(mz1);
   %disp([i1 i2 j1 j2])
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
[X1,Y1]=meshgrid(x1,y1);
cname1=['Model_' Name_new];
gname1=['grid_' Name_new];
hname1=['h_' Name_new];
uname1=['UV_' Name_new];
fprintf('Click your area on updated plot to continue\n');
waitforbuttonpress;
%
fprintf('Writing control file %s\n',fullfile(fpath,cname1));
fid=fopen(fullfile(fpath,cname1),'w');
fprintf(fid,'%s\n',hname1);
fprintf(fid,'%s\n',uname1);
fprintf(fid,'%s\n',gname1);
dt=12;
fclose(fid);
[xy_lims1,hz1,mz1]=mk_30_grid(xy_lim,hz,pmask,Modp,lims);
fprintf('Writing grid file %s...', gname1);
grd_out(fullfile(fpath,gname1),xy_lims1,hz1,mz1,[],dt);
fprintf('done\n');
%
cons=rd_con(char(hname));
[nc,dum]=size(cons);
[n1,m1]=size(hz1);
H=zeros(n1,m1,nc);U=H;V=H;
cid=[];
for ic=1:nc
 con=cons(ic,:);
 fprintf('Recovering constituent %s from %s\n',con,char(hname));
 [z,th_lim,ph_lim,Modp]=h_in_p(char(hname),con);
 [u,v,th_lim,ph_lim,ModpU]=u_in_p(char(uname),con);
 z1=mk_30_z(xy_lim,z,hz1,xy_lims1,pmask,Modp,lims);
 [u1,v1]=mk_30_uv(xy_lim,u,v,hz1,xy_lims1,pmask,ModpU,lims);
 H(:,:,ic)=z1;U(:,:,ic)=u1;V(:,:,ic)=v1;
 cid=[cid, con];
end
%
fprintf('Writing elevation file ...',hname1);
h_out(fullfile(fpath,hname1),H,xy_lims1(3:4),xy_lims1(1:2),cid);
fprintf('done\n');
%
fprintf('Writing transport file ...',uname1);
uv_out(fullfile(fpath,uname1),U,V,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');
%return
