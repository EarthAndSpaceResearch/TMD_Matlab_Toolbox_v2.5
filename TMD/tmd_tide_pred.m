%%%% Predict tidal time series in a given locations at given times 
%%%% using tidal model from a file
% USAGE:
% [TS,ConList]=tmd_tide_pred(Model,SDtime,lat,lon,ptype,Cid);
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
% Depending on size of SDtime,lat,lon 3 functional modes possible:
%
%           "Time series": SDtime(N,1),lon(1,1),lat(1,1)
%           "Drift Track": SDtime(N,1),lon(N,1),lat(N,1)
%           "Map"        : SDtime(1,1),lon(N,M),lat(N,M) 
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
% Ouput:     TS(N) or TS(N,M) - predicted time series or map
%            conList(nc,4) - list of ALL model 
%                            constituents (char*4)
%
% Dependencies: 'Fxy_ll',h_in,u_in,grd_in,XY,rd_con,BLinterp, tmd_extract_HC
%               harp1,constit,nodal,checkTypeName
%
% Sample calls:
%
% SDtime=[floor(datenum(now)):1/24:floor(datenum(now))+14];
% [z,conList]=tmd_tide_pred('DATA/Model_Ross_prior',SDtime,-73,186,'z');
% ConList([5,6])=
% k1
% o1
% [z1,conList]=tmd_tide_pred('DATA/Model_Ross_prior',SDtime,-73,186,'z',[5,6]);
%
%  TMD release 2.02: 21 July 2010
%
function [TS,conList]=tmd_tide_pred(Model,SDtime,lat,lon,ptype,Cid);
TS=[];conList=[];
w=what('TMD');funcdir=[w.path '/FUNCTIONS'];
path(path,funcdir);
if ptype=='z',k=1;else k=2;end
[ModName,GridName,Fxy_ll]=rdModFile(Model,k);
[Flag]=checkTypeName(ModName,GridName,ptype);
if Flag>0,return;end
TimeSeries=0;DriftTrack=0;TMap=0;
[N,M]=size(lat);
n1=N*M;
[k1,k2]=size(lon);n2=k1*k2;
[k1,k2]=size(SDtime);n3=k1*k2;
%
if n1==n2,
 if n1==1 & n3>1,
   TimeSeries=1;
   fprintf('MODE: Time series\n');
   SDtime=reshape(SDtime,n3,1);
 elseif n1==n3 & n1>1, 
   DriftTrack=1;N=n1;
% make sure all dimensions correspond
  SDtime=reshape(SDtime,N,1);
  lat=reshape(lat,N,1);
  lon=reshape(lon,N,1);
  fprintf('MODE: Drift Track\n');
 elseif n3==1,
  TMap=1;lon=reshape(lon,N,M);
  if N==1, lon=lon';lat=lat';N=M;M=1;end
  fprintf('MODE: Map\n');
 else
  fprintf('WRONG CALL: lengths of vectors lat,lon, SDtime INCONSISTENT:\n');
  fprintf('Sizes MUST correspond to one of modes:\n');
  fprintf(' 1. Time series: SDtime(N,1),lon(1,1),lat(1,1)\n');
  fprintf(' 2. Drift Track: SDtime(N,1),lon(N,1),lat(N,1)\n');
  fprintf(' 3. Map:         SDtime(1,1),lon(N,M),lat(N,M)\n');
  return
 end
else  
 fprintf('WRONG CALL: lengths of vectors lat,lon are different:\n');
 return
end
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
 if TimeSeries==1,
  TS=harp1(time,hc,conList);
  dh = InferMinor(hc,conList,SDtime);
  TS=TS+dh;
 elseif DriftTrack==1,
  for k=1:N
   TS(k)=harp1(time(k),hc(:,k),conList);
   dh = InferMinor(hc(:,k),conList,SDtime(k));
   TS(k)=TS(k)+dh;
  end
 else % Map
   for k=1:nc
    hci(:,:,k)=hc(k,:,:);
   end
   TS=harp(time,hci,conList);
   dh=InferMinor(hc,conList,SDtime);
   if ndims(hci)~=ndims(hc),dh=dh';end
   TS=TS+dh;
 end
else
  if isempty(Cid)==0,
   Cid(find(Cid<1))=1;Cid(find(Cid>nc))=nc;
   if TimeSeries==1,
    TS=harp1(time,hc,conList(Cid,:));
   elseif DriftTrack==1,
    for k=1:N
     TS(k)=harp1(time(k),hc(:,k),conList(Cid,:));
    end
   else % Map
    if nc>1,
     for k=1:length(Cid)
      hci(:,:,k)=hc(k,:,:);
     end
    else
      hci=hc;
    end
    TS=harp(time,hci,conList(Cid,:));
   end
  else % same as above Cid=[]: all constituents included
    fprintf('Minor constituents inferred\n');
    if TimeSeries==1,
      TS=harp1(time,hc,conList);
      dh = InferMinor(hc,conList,SDtime);
      TS=TS+dh;
    elseif DriftTrack==1,
      for k=1:N
       TS(k)=harp1(time(k),hc(:,k),conList);
       dh = InferMinor(hc(:,k),conList,SDtime(k));
       TS(k)=TS(k)+dh;
      end
    else % Map
     for k=1:nc
      hci(:,:,k)=hc(k,:,:);
     end
     TS=harp(time,hci,conList);
     dh=InferMinor(hc,conList,SDtime);
     TS=TS+dh;
    end
  end 
end
fprintf('done\n');
return
