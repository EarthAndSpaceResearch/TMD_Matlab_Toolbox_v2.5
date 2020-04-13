% Tidal Model Driver (TMD)
% Output harmonic constants and predict tides
%
close all; clear all;
w=what('TMD');funcdir=[w.path '/FUNCTIONS'];
path(path,funcdir);
fprintf('Welcome to TMD: Tidal Model Driver!\n');
fprintf('\n');
fprintf('TMD FILE NAME/FORMAT CONVENTION (MUST follow!):\n');
fprintf('1. TMD supports format of models downloaded from: ,\n');
fprintf('      http://volkov.oce.orst.edu/tides \n');
fprintf('      http://www.esr.org/polar_tides_models \n');
fprintf('2. Elevation file name should start from ''h''.\n');
fprintf('3. Transport file name should start from ''UV''.\n');
fprintf('4. Bathymetry grid file name should start from ''g''.\n');
fprintf('5. If grid is uniform in km string ''km'' should be found\n');
fprintf('   either in model file names or in grid file name.\n')';
fprintf('6. For any tidal model a control file starting from \n');
fprintf('   ''Model_*'' ib subdirectory TMD/DATA should be given. \n');
fprintf('   The file MUST contain 3 lines:\n');
fprintf('         <Elevation file name>\n');
fprintf('         <Transport file name>\n');
fprintf('         <Bathymetry grid file name>\n');
fprintf('   If the model files are NOT in TMD/DATA, exact path should be included.\n');
fprintf('   If the model files are in TMD/DATA, no path in file names is needed.\n');
fprintf('   If grid is uniform in km the NAME of function converting\n');
fprintf('   lat,lon to x,y and back should be provided in 4-th line, \n');
fprintf('   for example:''xy_ll'' for Arctic or ''xy_ll_S'' for Antarctic\n');
fprintf('\n');
%
curdir=pwd;
dir_check=exist('DATA','dir');
if(dir_check==0)
    disp('Subdirectory DATA not found. You must navigate to');
    disp('location of Model files from current directory.');
    return
else
    eval('cd DATA');
end
cfile=0;
[cfile,pname]=uigetfile('Model*','Open MODEL files listed in ');
if cfile==0,eval(['cd ' curdir]);return;end
CFname=[pname cfile];
fid=fopen(CFname,'r');
hfile=fgetl(fid);ufile=fgetl(fid);Gname=fgetl(fid);Fxy_ll=fgetl(fid);
fclose(fid);
eval(['cd ' curdir]);
%
if strcmp(hfile(1:4),'DATA')>0
    hfile=[curdir '/' hfile];
    ufile=[curdir '/' ufile];
    Gname=[curdir '/' Gname];
elseif isempty(findstr(hfile,'/'))>0 & isempty(findstr(hfile,'\'))>0
    % files are assumed to be in TMD/DATA
    hfile=[curdir '/DATA/' hfile];
    ufile=[curdir '/DATA/' ufile];
    Gname=[curdir '/DATA/' Gname];
end
k=0;
% Check if the files exist
if exist(hfile,'file')==0
    fprintf ('File %s does NOT exist\n',hfile);k=1;
end
if exist(ufile,'file')==0
    fprintf ('File %s does NOT exist\n',ufile);k=1;
end
if exist(Gname,'file')==0
    fprintf ('File %s does NOT exist\n',Gname);k=1;
end
if k==1
    fprintf('Check control file: %s\n',CFname);
    return
end
%
km=0;
ikm=findstr(hfile,'km');
if isempty(ikm)>0,ikm=findstr(ufile,'km');end
if isempty(ikm)>0,ikm=findstr(Gname,'km');end
if isempty(ikm)==0,km=1;end
if km==0, % new grid convention, dt<0->km
    [sy_lims,H,mz,iob,dt]=grd_in(Gname);
    if dt<0,km=1;end
end
if km==1,fprintf('The model is on uniform grid in km\n');
else fprintf('The model is on uniform grid in lat,lon\n');end
if km==1 & Fxy_ll==-1,
    fprintf('   If grid is uniform in km the NAME of function converting\n');
    fprintf('   lat,lon to x,y and back MUST be given in 4-th line of\n');
    fprintf('%s\n',CFname);
    fprintf('TMD exiting...\n');
    return;close all
end
if km==0, Fxy_ll='Fdum';end
% define model name by comparing strings hfile and ufile
Mname=TMD_findMname(hfile,ufile);
k=findstr(CFname,'/');
if isempty(k)>0,k=findstr(CFname,'\');end % PC path names
if isempty(k)==0,
    Mname=CFname(k(end)+7:end);
end
if exist('junk','dir')==0, mkdir junk;end
tmpFileName=['junk/tmp' Mname '.mat'];
%
nFig=0;nFig2=0;mode=1;
InFname='LAT_LON/lat_lon';
OutFname='data.out';
if exist(tmpFileName,'file')>0,
    eval(['load ' tmpFileName]);
    lat=lat0;lon=lon0;yy=yy0;mm=mm0;dd=dd0;hh=hh0;mi=mi0;nh=nh0;
    if km==1,eval(['[x0,y0]=' Fxy_ll '(lon,lat,''F'');']);
    else x0=lon;y0=lat;end
end
[conList]=rd_con(hfile);
[nc,dum]=size(conList);
np=6;
nb=nc+np;
nt=6;
bgCol=[.4,.4,.6];
icon=zeros(1,nc);icon(1)=1;
ipar=[1 0 0 0 0 0];ipar1=ipar;
XL=[];YL=[];XLP=[];YLP=[];
icz1=0;icu1=0;ice1=0;icp1=0;ik1=0;ipp1=0;
ic1=1;ik=1;arw='r';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
fprintf('Loading TMD (Tidal Model Driver)...');
icpl=1;
TMD_fig1;
%
set(gcf,'numbertitle','off','menubar','none','name',...
    ['Tidal Model Driver     Model:',Mname,...
    '      Programmed by: Lana Erofeeva, 2003-2010']);
fprintf('done\n');
fprintf('\n');
fprintf('See button tips for HELP.\n');
fprintf('Type ''help  tmd_extract_HC'',''help tmd_tide_pred'', ''help tmd_ellipse'',\n');
fprintf('Type ''help  tmd_get_coeff'',''help tmd_get_ellipse'',\n');
fprintf('if you wish to use the scripts instead of GUI.\n');
fprintf('Model and files are in %s\n and %s.\n',hfile,ufile);
fprintf('Bathymetry grid file is in %s.\n',Gname);
fprintf('Input file examples are in LAT_LON\n');
fprintf('\n');
fprintf('Programmed by: Lana Erofeeva: ');TMD_release;
fprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax=p3(3);ay=p3(4);bh=0.8*ay/nb;
dh=0.2*ay/(nb-1);
bw=(0.98-0.04-(p3(1)+ax))/2;
ch=nc*bh+(nc-1)*dh+0.02;
% CONSTITUENT FRAME POSITION
pos0=[p3(1)+ax+0.02+bw, p3(2)+p3(4)-ch+0.015, bw+0.02,ch ];
%%%%%
% Buttons (right)
% CONSTITUENTS
vc=0;
Cfc=['vc=1-vc;if vc==1,icon=ones(nc,1);else ',...
    'icon=zeros(nc,1);end;',...
    'for k=1:nc,set(uc(k),''value'',icon(k));end;'];
fc=uicontrol('Style','pushbutton','units','normalized','position',pos0,...
    'BackgroundColor',bgCol,'Callback',Cfc,...
    'ToolTipString','Click on FRAME to Select/Unselect ALL');
pos=pos0;
pos(1)=pos0(1)+0.01;pos(2)=pos(2)+0.01;pos(3)=bw;pos(4)=bh;
Cbk1=['for k=1:nc,icon(nc-k+1)=get(uc(k),''value'');end;'];
%
if exist('poscf','var')==0,
    poscf=pos;poscf(2)=poscf(2)+(nc-1)*(bh+dh);
    poscf(1)=poscf(1)-5e-3;poscf(3)=poscf(3)+0.01;
    poscf(2)=poscf(2)-5e-3;poscf(4)=poscf(4)+0.01;
    poscf2=pos(2)-5e-3;bhdh=bh+dh;
    icpl=1;
end
BDFcn=['icpl=icpl+1;if icpl>nc,icpl=icpl-nc;end;',...
    'poscf(2)=poscf2+(nc-icpl)*bhdh;',...
    'set(ucpf,''position'',poscf);if ik>1,TMD_fig1;end'];
ucpf=uicontrol('Style','Frame','units','normalized','position',poscf,...
    'BackgroundColor','g','ToolTipString',...
    'Constituent to plot: Right click to change');
%
for ic=1:nc
    con=upper(conList(nc-ic+1,:));
    BDFcn=['icpl=nc-',int2str(ic),'+1;',...
        'poscf(2)=poscf2+(nc-icpl)*bhdh;',...
        'set(ucpf,''position'',poscf);if ik>1,TMD_fig1;end'];
    bdf1=int2str(ic);
    uc(ic)=uicontrol('Style','radiobutton','units','normalized','position',pos,...
        'string',con,'value',icon(nc-ic+1),'FontWeight','bold',...
        'CallBack',Cbk1,'ToolTipString',...
        'Left click to Select/Unselect, Right click to plot',...
        'ButtonDownFcn',BDFcn);
    pos(2)=pos(2)+(bh+dh);
end

% PARAMETERS
Cbk2=['for k=1:np,ipar(np-k+1)=get(upar(k),''value'');end;',...
    'if mode==2 & ipar(6)==1,ipar=ipar1;end;dif=ipar-ipar1;',...
    'if sum(dif)>0,ipar=zeros(1,np);ipar(min(find(dif~=0)))=1;ipar1=ipar;end;',...
    'for k=1:np,set(upar(k),''value'',ipar(np-k+1));end;',...
    'if ipar(6)==0,val1=get(uPl,''value'');',...
    'if val1>3,set(uPl,''value'',3);end;set(uPl,''string'',sPl1);',...
    'else set(uPl,''string'',sPl2);end;',...
    'k=get(uPl,''value'');if k>1,TMD_fig1;end;'];
pname=['Ell';'v  ';'u  ';'V  ';'U  ';'z  ';];
hints=['Tidal Ellipse  ';'North velocity ';'East velocity  ';...
    'North transport';'East transport ';'Elevation      '];
bw=0.98-(p3(1)+ax)-0.02;
bw1=(0.98-(p3(1)+ax)-0.02-0.01)/2;
pos1(2)=p3(2);
pos1(3)=bw+0.02;
pos1(4)=np*bh+(np-1)*dh-0.02;
posf=pos1;posf(2)=posf(2)+posf(4)/2-0.01;posf(4)=posf(4)/2+0.01;
uicontrol('Style','Frame','units','normalized','position',posf,...
    'BackgroundColor',bgCol);
dh=0.9*dh;
bh=(pos1(4)-0.02-(np-1)*dh)/np;
pos=[p3(1)+ax+0.02, p3(2)+np/2*bh+(np/2-1)*dh+0.02, bw1, bh ];
val=0;
for ic=1:np
    upar(ic)=uicontrol('Style','radiobutton','units','normalized',...
        'position',pos,...
        'string',pname(ic,:),'value',ipar(np-ic+1),'FontWeight','bold',...
        'CallBack',Cbk2,'ToolTipString',hints(ic,:));
    pos(2)=pos(2)+(bh+dh);
    if ic==3, pos(2)=p3(2)+np/2*bh+(np/2-1)*dh+0.02;pos(1)=pos(1)+bw1+0.01;end
end
%%%%% Input/Output files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
posf1=posf;posf1(2)=p3(2);posf1(4)=posf1(4)-0.015;
uicontrol('Style','Frame','units','normalized','position',posf1,...
    'BackgroundColor',bgCol);
pos3=posf1;pos3(4)=(pos3(4)-0.02)/4;pos3(2)=pos3(2)+0.75*posf1(4);
pos3(1)=pos3(1)+0.005;pos3(3)=pos3(3)-0.01;
CbkI=['vi=get(uinF,''Value'');if vi==1,set(uTinF,''Enable'',''on'');',...
    'set(uP,''Enable'',''off'');set(uPlat,''Enable'',''off'');',...
    'set(uPlon,''Enable'',''off'');TMD_timeOnOff(uTime,uT,''off'');',...
    'else set(uTinF,''Enable'',''off'');',...
    'set(uP,''Enable'',''on'');set(uPlat,''Enable'',''on'');',...
    'if mode==2,TMD_timeOnOff(uTime,uT,''on'');end;',...
    'set(uPlon,''Enable'',''on'');end'];
uinF=uicontrol('Style','radiobutton','units','normalized',...
    'position',pos3,'string','Input from File','FontWeight','bold',...
    'CallBack',CbkI,'ToolTipString',...
    'Enable/Disable input from FILE (Edit name below))');
pos4=pos3;pos4(2)=posf1(2)+0.005+pos3(4);
CbkO=['vo=get(uoutF,''Value'');if vo==1,arw=''a'';',...
    'set(uoutF,''String'',''Append File'');',...
    'else arw=''w'';set(uoutF,''String'',''Rewrite File'');end'];
uoutF=uicontrol('Style','radiobutton','units','normalized',...
    'position',pos4,'string','Rewrite File',...
    'FontWeight','bold',...
    'CallBack',CbkO,'ToolTipString',...
    'Rewrite/Append Output file');
pos5=pos3;pos5(2)=pos5(2)-posf1(4)/4+0.005;
uTinF=uicontrol('Style','Edit','units','normalized','position',pos5,...
    'value',0,'FontWeight','bold','String',InFname,'Enable','off',...
    'CallBack','InFname=get(gcbo,''String'');','ToolTipString',...
    'Type ''help TMD_InFileFormat'' on Input File Format');
pos6=pos4;pos6(2)=pos4(2)-posf1(4)/4+0.005;
uToutF=uicontrol('Style','Edit','units','normalized','position',pos6,...
    'value',0,'FontWeight','bold','String',OutFname,'Enable','on',...
    'CallBack','OutFname=get(gcbo,''String'');','ToolTipString',...
    'Edit Output File name');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Buttons, down
ax=pos1(1)+pos1(3)-p3(1);
dw=0.01;bw=(1-4*dw)*ax/3;
pos0=[p3(1)-0.01 p3(2)-3*bh-0.03 ax+0.01 2*bh+0.03];
pos0(2)=max(0,pos0(2));
uicontrol('Style','Frame','units','normalized','position',pos0,...
    'BackgroundColor',bgCol);
pos=pos0;pos(1)=pos(1)+0.01;pos(2)=pos(2)+0.02+bh;pos(3)=bw;pos(4)=bh;
cpos0=pos;
ATs=['EXTRACT TIDAL CONSTANTS';'PREDICT TIDE           '];
Cbk5=['mode=get(uAT,''value'');vi=get(uinF,''Value'');',...
    'if mode==1, TMD_timeOnOff(uTime,uT,''off'');set(upar(1),''Enable'',''on'');',...
    'elseif vi==0, TMD_timeOnOff(uTime,uT,''on'');end;',...
    'if mode==2, if ipar(6)==1, ipar(6)=0;ipar(3)=1;ipar1=ipar;',...
    'set(upar(np-3+1),''value'',1);set(upar(1),''value'',0);end;',...
    'set(upar(1),''Enable'',''off'');',...
    'uPlVal=get(uPl,''value'');uPlVal=min(uPlVal,3);',...
    'set(uPl,''string'',sPl1,''value'',uPlVal);TMD_fig1;end;'];
uAT=uicontrol('Style','popupmenu','units','normalized','position',pos,...
    'string',ATs,'FontWeight','bold',...
    'ToolTipString','Choose Calculation Mode','CallBack',Cbk5);
%%%%%%%%%%% WINDOW PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos(2)=pos(2)-0.01-bh;
sPl1=['PLOT BATHYMETRY ';'PLOT AMPLITUDE  ';'PLOT PHASE      '];
sPl2=['PLOT BATHYMETRY ';'PLOT MAJOR AXIS ';'PLOT PHASE      ';...
    'PLOT MINOR AXIS ';'PLOT INCLINATION'];
ival=1;
uPlTip=['Choose what to plot for framed constituent'];
uPl=uicontrol('Style','popupmenu','units','normalized','position',pos,...
    'string',sPl1,'FontWeight','bold',...
    'ToolTipString',uPlTip,'CallBack','TMD_fig1');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Change Subgrid
pos=pos0;
pos(1)=pos(1)+bw+0.02;pos(2)=pos(2)+0.01;pos(3)=(bw-0.01)/2;pos(4)=bh;
uSG=uicontrol('style','radiobutton', ...
    'units','normalized', ...
    'position',pos,'FontWeight','bold',...
    'string','Sub-grid','ToolTipString','Activate RubberBox to choose smaller area', ...
    'callback','TMD_subgrid;',...
    'Value',0);
pos1=pos;
%  Restore Full Grid
pos(1)=pos(1)+pos(3)+0.01;
uFG=uicontrol('style','pushbutton', ...
    'units','normalized', ...
    'position',pos,'FontWeight','bold',...
    'string','Full Grid','ToolTipString','Restore Full Grid',...
    'callback','AX=AX0;axis(AX);set(uFG,''value'',0);',...
    'Value',0);
pos2=pos;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LAT & LON
pos=pos1;pos(2)=pos(2)+bh+0.01;pos(3)=0.3*bw;
Cbk3=['if exist(''pp1'',''var'')>0,set(pp1,''Visible'',''off'');end;',...
    'clear pp1;[xl,yl]=ginput(1);if exist(''x0'',''var'')>0,x0=xl;y0=yl;end;',...
    'if km==1,[lon,lat]=',Fxy_ll,...
    '(xl,yl,''B'');else lon=xl;lat=yl;end;',...
    'set(uPlat,''String'',num2str(lat));',...
    'set(uPlon,''String'',num2str(lon));set(uP,''value'',0);',...
    'pp1=plot(xl,yl,''ko'');'];
uP=uicontrol('Style','radiobutton','units','normalized','position',pos,...
    'string','Point','value',0,'FontWeight','bold',...
    'ToolTipString','CrossBar to pick lat,lon','Callback',Cbk3);
pos(1)=pos(1)+0.3*bw;pos(3)=0.7*bw/2;
uPlat=uicontrol('Style','Edit','units','normalized','position',pos,...
    'value',0,'FontWeight','bold','String',num2str(lat),...
    'ToolTipString','Edit LATITUDE (o)N','CallBack',...
    'clat=get(gcbo,''String'');lat=TMD_check_lat_lon(clat,1,uPlat);');
pos(1)=pos(1)+pos(3);
uPlon=uicontrol('Style','Edit','units','normalized','position',pos,...
    'value',0,'FontWeight','bold','String',num2str(lon),...
    'ToolTipString','Edit LONGITUDE (o)E','CallBack',...
    'clon=get(gcbo,''String'');lon=TMD_check_lat_lon(clon,2,uPlon);');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  RESTART and GO
pos=pos0;
pos(1)=pos(1)+2*bw+3*dw;
pos(2)=pos(2)+0.01;pos(3)=(bw-0.01)/2;pos(4)=bh;
uRe=uicontrol('style','pushbutton', ...
    'units','normalized', ...
    'position',pos,'FontWeight','bold',...
    'string','RESTART', ...
    'callback','eval([''!rm '' tmpFileName]);TMD;',...
    'Value',0);
pos1=pos;
pos(1)=pos(1)+pos(3)+dw;
uGo=uicontrol('style','pushbutton', ...
    'units','normalized', ...
    'position',pos,'FontWeight','bold',...
    'string','GO','ToolTipString','Start Extracting/Predicting', ...
    'callback','TMD_calculate;','Value',0);
%%% TIME
pos=pos1;pos(2)=pos(2)+bh+0.01;pos(3)=0.2*bw;
uTime=uicontrol('Style','text','units','normalized','position',pos,...
    'string',['Start';'Time '],'FontWeight','bold',...
    'ToolTipString','Time is GMT','Enable','off');
pos(1)=pos(1)+0.2*bw;dw1=0.8*bw/(nt+1);pos(3)=2*dw1;
TTip=['Edit YEAR:yyyy    ';'Edit MONTH:mm     ';'Edit DAY:dd       ';...
    'Edit HOUR:hh      ';'Edit MINUTE:mm    ';'Edit TS length (h)'];
if exist('yy','var')==0,
    yy=1992;mm=01;dd=01;hh=00;mi=00;nh=48;
end
st0=int2str([mm;dd;hh;mi;nh]);
Cbk4=['yy=str2num(get(gcbo,''String''));yy=TMD_check_date(yy,''yy'',uT(1));';...
    'mm=str2num(get(gcbo,''String''));mm=TMD_check_date(mm,''mm'',uT(2));';...
    'dd=str2num(get(gcbo,''String''));dd=TMD_check_date(dd,''dd'',uT(3));';...
    'hh=str2num(get(gcbo,''String''));hh=TMD_check_date(hh,''hh'',uT(4));';...
    'mi=str2num(get(gcbo,''String''));mi=TMD_check_date(mi,''mi'',uT(5));';...
    'nh=str2num(get(gcbo,''String''));nh=TMD_check_date(nh,''nh'',uT(6));';];

uT(1)=uicontrol('Style','Edit','units','normalized','position',pos,...
    'value',0,'FontWeight','bold','String',int2str(yy),...
    'ToolTipString',TTip(1,:),'Enable','off','CallBack',Cbk4(1,:));
pos(1)=pos(1)+pos(3);pos(3)=dw1;
for it=2:nt
    uT(it)=uicontrol('Style','Edit','units','normalized','position',pos,...
        'value',0,'FontWeight','bold','String',st0(it-1,:),...
        'ToolTipString',TTip(it,:),'Enable','off','CallBack',Cbk4(it,:));
    pos(1)=pos(1)+pos(3);
end
set(uT(nt),'BackGroundColor','w');
%%%% Changing caxis up/down arrows
posar1=[CBpos(1)-0.01,CBpos(2)-0.03,0.025,0.025];
har1=uicontrol('style','pushbutton','units','normalized','position',posar1,...
    'string','<','FontWeight','bold',...
    'ToolTipString','Decrease lower color scale level',...
    'CallBack','TMD_changeCaxis(1,''-'',cb,CBpos);');
posar2=posar1;posar2(1)=posar2(1)+0.025;
har2=uicontrol('style','pushbutton','units','normalized','position',posar2,...
    'string','>','FontWeight','bold',...
    'ToolTipString','Increase lower color scale level',...
    'CallBack','TMD_changeCaxis(1,''+'',cb,CBpos);');
posar3=posar1;posar3(2)=CBpos(2)+CBpos(4)+0.01;
har3=uicontrol('style','pushbutton','units','normalized','position',posar3,...
    'string','<','FontWeight','bold',...
    'ToolTipString','Decrease upper color scale level',...
    'CallBack','TMD_changeCaxis(2,''-'',cb,CBpos);');
posar4=posar3;posar4(1)=posar4(1)+0.025;
har4=uicontrol('style','pushbutton','units','normalized','position',posar4,...
    'string','>','FontWeight','bold',...
    'ToolTipString','Increase upper color scale level',...
    'CallBack','TMD_changeCaxis(2,''+'',cb,CBpos);');

