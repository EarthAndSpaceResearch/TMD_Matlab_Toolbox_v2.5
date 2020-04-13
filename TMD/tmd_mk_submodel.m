% function to make a submodel from a model ModName (TMD format)
% calculated on bathymetry grid Gridname
%
% usage:
% ()=tmd_mk_submodel(Name_old,Name_new,limits);
%
% PARAMETERS
%
% INPUT
% Name_old - ROOT in "DATA/Model_ROOT" control file for EXISTING
%            tidal model. File Model_* consists of lines:
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in TMD format
%
% Name_new - root in "DATA/Model_root" control file for SUBMODEL of
%            tidal model. The submodel is defined by
% limits - [lon1,lon2,lat1,lat2] OR [x1 x2 y1 y2] for a model in km;
%          might be slightly CHANGED to adjust to original model grid
%
% OUTPUT:
%
% in TMD/DATA
% Model_<Name_new> - control file of 3 or 4 lines
%                    (as in old)
%       h.<Name_new> - elevation file
%       UV.<Name_new> - transports file
%       grid_<Name_new> - grid file
%
% sample call:
%
% tmd_mk_submodel('AOTIM5','AOTIM5_subdomain_test',[-1000 1000 -1000 1000]);
%
% TMD release 2.02: 21 July 2010
%
function []=tmd_mk_submodel(Name_old,Name_new,lims)

slash='/';  glob=[];
MACH=computer;
if MACH(1:5)=='PCWIN',slash='\';end
w=what('TMD');funcdir=[w.path slash 'FUNCTIONS'];
path(path,funcdir);
[hname,gname,Fxy_ll]=rdModFile(['DATA' slash 'Model_' Name_old],1);
if isempty(hname)>0,return;end
[uname,gname,Fxy_ll]=rdModFile(['DATA' slash 'Model_' Name_old],2);
if isempty(uname)>0,return;end
cons=rd_con(hname);
[nc,i4]=size(cons);
cid=reshape(cons',1,nc*i4);
%
if isempty(Fxy_ll)
    % adjust silly lim input
    while max(lims(1:2))>360,lims(1:2)=lims(1:2)-360;end
    lims(3)=max(-90,lims(3));lims(4)=min(90,lims(4));
end
%
[xy_lim,hz,mz,iob,dt]=grd_in(gname);xy_lim=xy_lim';
if(isempty(Fxy_ll))
    disp('Grid limits on old file are ...')
    disp([num2str(xy_lim) '  degrees.'])
    glob=0;
    if xy_lim(2)-xy_lim(1)>=360
        disp('Grid is GLOBAL');glob=1;
    end
else
    disp('Grid limits on old file are ...')
    disp([num2str(xy_lim) '  km.'])
end
% check limits
if ((xy_lim(1)<=lims(1) && xy_lim(2)>=lims(2)) || glob) &&...
        xy_lim(3)<=lims(3) && xy_lim(4)>=lims(4)
    [n,m]=size(hz);
    [x,y]=XY(xy_lim,n,m);
    stx=x(2)-x(1);sty=y(2)-y(1);
    if glob & lims(1)<xy_lim(1)
        i1=find(x>=180);i2=find(x<180);
        x=[x(i1)-360,x(i2)];
        xy_lim(1)=x(1)-stx/2;xy_lim(2)=x(end)+stx/2;
        if xy_lim(1)<=lims(1) && xy_lim(2)>=lims(2)
            hz=[hz(i1,:);hz(i2,:)];
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
else
    fprintf('Requested limits are out of Model area\n');
    fprintf('%s limits: %10.4f %10.4f %10.4f %10.4f\n',...
        Name_old,xy_lim);
    fprintf('Your limits: %10.4f %10.4f %10.4f %10.4f\n',lims);
    return
end
%
cname1=['DATA' slash 'Model_' Name_new];
gname1=['grid_' Name_new];
hname1=['h.' Name_new];
uname1=['UV.' Name_new];

fprintf('Writing control file %s\n',cname1);
fid=fopen(cname1,'w');
fprintf(fid,'%s\n',hname1);
fprintf(fid,'%s\n',uname1);
fprintf(fid,'%s\n',gname1);
if isempty(Fxy_ll)==0
    fprintf(fid,'%s\n',Fxy_ll);
end
fclose(fid);
fprintf('Writing grid file DATA%s%s...', slash,gname1);
grd_out(['DATA/' gname1],new_lims,hz1,mz1,[],dt);
fprintf('done\n');
%
fprintf('Reading elevation file %s\n',hname);
H=zeros(n1,m1,nc);
for ic=1:nc
    [h1,th_lim,ph_lim]=h_in(hname,ic);
    H(:,:,ic)=h1(i1:i2,j1:j2);
    fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing elevation file DATA%s%s...',slash,hname1);
new_lims
h_out(['DATA' slash hname1],H,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');
fprintf('Reading transports file %s\n',uname);
U=zeros(n1,m1,nc);V=U;
for ic=1:nc
    [u1,v1,th_lim,ph_lim]=u_in(uname,ic);
    U(:,:,ic)=u1(i1:i2,j1:j2);V(:,:,ic)=v1(i1:i2,j1:j2);
    fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing transport file DATA%s%s...',slash,uname1);
uv_out(['DATA' slash uname1],U,V,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');

return
