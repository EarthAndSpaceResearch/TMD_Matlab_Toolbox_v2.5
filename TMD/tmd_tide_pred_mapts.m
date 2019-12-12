%%%% Version of tmd_tide_pred for time series on a map
%%%% 
% USAGE:
% [TS,ConList]=tmd_tide_pred_mapts(Model,SDtime,lat,lon,ptype,Cid);
% 
% PARAMETERS
% Input:
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
% SDtime  - vector of times expressed in serial days:
%             see 'help datenum' in matlab
%  
% lat,lon  - coordinates in degrees;
% DIMENSIONS:
%
%           "Map"        : SDtime(Nt,1),lon(N,M),lat(N,M) 
%
% ptype - char*1 - one of
%            'z' - elevation (m)
%            'u','v' - velocities (cm/s)
%            'U','V' - transports (m^2/s);
% Cid - indices of consituents to include (<=nc); if given
%             then included constituents are: conList(Cid,:),
%             NO minor constituents inferred;
%             if Cid=[] (or not given), ALL model constituents
%             included, minor constituents inferred if possible
%
% Ouput:     TS(N,M,Nt) - predicted time series on a map
%            conList(nc,4) - list of ALL model 
%                            constituents (char*4)
%
% Dependencies: 'Fxy_ll',h_in,u_in,grd_in,XY,rd_con,BLinterp, tmd_extract_HC
%               harp1,constit,nodal,checkTypeName
%
% Sample calls:
%
% SDtime=[floor(datenum(now)):1/24:floor(datenum(now))+14];
% lat=18.5:0.02:19.5;lon=72:0.02:73.5;
% [lon,lat]=meshgrid(lon,lat);
% [z,conList]=tmd_tide_pred_mapts('DATA/Model_PerS',SDtime,lon,lat,'z');
%
% ConList([5,6])=
% k1
% o1
% [z1,conList]=tmd_tide_pred_mapts('DATA/Model_PerS',SDtime,lon,lat,'z',[5,6]);
%
%  
%
function [TS,conList]=tmd_tide_pred_mapts(Model,SDtime,lat,lon,ptype,Cid);
TS=[];conList=[];
w=what('TMD');funcdir=[w.path '/FUNCTIONS'];
path(path,funcdir);
if ptype=='z',k=1;else k=2;end
[ModName,GridName,Fxy_ll]=rdModFile(Model,k);
[Flag]=checkTypeName(ModName,GridName,ptype);
if Flag>0,return;end
[N,M]=size(lat);
[k1,k2]=size(SDtime);
if k1<k2,SDtime=SDtime';end;
if k1~=1 & k2 ~=1, fprintf('Wrong call: SDtime should be vector!\n');return;end
Nt=k1*k2;
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Reading %s and extracting HC...',ModName);
if nargin>5,
 [amp,pha,D,conList]=tmd_extract_HC(Model,lat,lon,ptype,Cid);
else
 [amp,pha,D,conList]=tmd_extract_HC(Model,lat,lon,ptype);
end
cph= -i*pha*pi/180;
hc = amp.*exp(cph);
hc=squeeze(hc);
[nc,dum]=size(conList); % nc here is # of ALL constituents in the model
if conList(1:4)=='stop',TS=NaN;return;end
fprintf('Done extracting HC\n');
d0=datenum(1992,1,1); % corresponds to 48622mjd
d1=SDtime;
time=d1-d0;
fprintf('Predicting tide ...\n');
%
if nargin<=5,
 fprintf('Minor constituents inferred\n');
 for k=1:nc
   hci(:,:,k)=hc(k,:,:);
 end
 for it=1:Nt
   TS(:,:,it)=harp(time(it),hci,conList);
   dh=InferMinor(hc,conList,SDtime(it));
   if ndims(hci)~=ndims(hc),dh=dh';end
   TS(:,:,it)=TS(:,:,it)+dh;
 end
else
  if isempty(Cid)==0,
   Cid(find(Cid<1))=1;Cid(find(Cid>nc))=nc;
   if nc>1,
     for k=1:length(Cid)
      hci(:,:,k)=hc(k,:,:);
     end
    else
      hci=hc;
    end
    for it=1:Nt
      TS(:,:,it)=harp(time(it),hci,conList(Cid,:));
    end
  else % same as above Cid=[]: all constituents included
    fprintf('Minor constituents inferred\n');
    for k=1:nc
     hci(:,:,k)=hc(k,:,:);
    end
    for it=1:Nt
      TS(:,:,it)=harp(time,hci,conList);
      dh=InferMinor(hc,conList,SDtime(it));
      TS(:,:,it)=TS(:,:,it)+dh;
    end
  end 
end
fprintf('done\n');
return
