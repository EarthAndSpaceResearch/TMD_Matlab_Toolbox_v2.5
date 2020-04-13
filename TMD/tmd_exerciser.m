%========================================================================
% tmd_exerciser.m
%
% This function runs through a few uses of script access to TMD-formatted
%   tide models, just to see if they work, and to show the use of various
%   scripts.
% This version is for TMD2.05
%
% Inputs:   Model name
%
% Sample call:  tmd_exerciser;
%
% Written by:   Laurie Padman (ESR): padman@esr.org
%               April 7, 2020
%
%========================================================================

%function tmd_exerciser

% Some routines are sensitive to the Matlab version you are running. So,
%   first interrogate Matlab for version number.
OS_info=version;
disp(['Running Matlab version ' OS_info]);

% Select the model to test
[fname,fpath] = uigetfile('Model*','File to process ...');
if(~fname) % user pressed Cancel in file dialog box
    return
end


% Access and plot model bathymetry (water column thickness under ice shelves)
Model=fullfile(fpath,fname);
[x,y,H]=tmd_get_bathy(Model);
loc=find(H==0); H(loc)=NaN;
figure(1); clf
pcolor(x,y,H);shading flat; colorbar
title(['Model H\wct for ' fname],'FontSize',15,...
    'Interpreter','none');
% ========================================================================


% Report whether model is (lat,lon) or Polar Stereographic ===============
[ModName,GridName,Fxy_ll]=rdModFile(Model,1)
if(isempty(Fxy_ll))
    disp('Model is coded in (lat,lon)')
else
    disp(['Model is coded in Polar Stereo (x,y) using function ' Fxy_ll])
end  
% ========================================================================


% Choose a point in the map for time series ==============================
disp(' ');
disp('Use mouse to select point in domain for testing tide_pred')
disp('  and extract_hc.  Put cursor over point, and left-click.')
disp(' ')
[lon,lat]=ginput(1);
hold on
plot(lon,lat,'rp','MarkerSize',12);
% ========================================================================


% Speed up future plotting by only doing a small area around the selected 
%   point. Try for something like a 200 x 200 point array.
ix_max=200; iy_max=200;
ixh=round(ix_max/2); iyh=round(iy_max/2);
axlim=[min(x) max(x) min(y) max(y)];
dx=x(2)-x(1); dy=y(2)-y(1);
indx=round((lon-min(x))/dx)+1;
indy=round((lat-min(y))/dy)+1;
ix1=max([(indx-ixh) 1]); ix2=min([(indx+ixh) length(x)]); 
iy1=max([(indy-iyh) 1]); iy2=min([(indy+iyh) length(y)]); 
% ========================================================================


% Exercise tmd_extract_HC ================================================
% Grab harmonic constants for a specified Model, variable, and lat/lon
%
% For Polar Stereographic (PS) models, selected point will be (x,y):
% convert to (lat,lon)
if(~isempty(Fxy_ll))
    xp=lon; yp=lat;
    eval(['[lon,lat]=' Fxy_ll '(lon,lat,''B'')']);
end

[amp,Gph,depth,constit]=tmd_extract_HC(Model,lat,lon,'z');
[r,c]=size(constit);
disp('Exercising EXTRACT_HC')
disp('Constit    Amp       Phase')
for i=1:r
    disp([constit(i,:) '      ' num2str(amp(i),'%6.2f') '    ' ...
          num2str(Gph(i),'%7.2f')]);
end
disp(' ')
disp(['Model depth = ' num2str(depth)]);
% ========================================================================


% Exercise tmd_tide_pred =================================================
disp(' '); disp(' ');
disp('Exercising tmd_tide_pred: should produce Figure 2 plot of u & v.')
% Predict model tide height or velocity components for a given time.
% Do hourly prediction for 31 days starting January 1, 2020;
t_0=datenum(2020,1,1);
time=t_0+(0:(31*24))/24;
[u,constit]=tmd_tide_pred(Model,time,lat,lon,'u');
[v,constit]=tmd_tide_pred(Model,time,lat,lon,'v');
figure(2); clf
subplot(2,1,1); 
plot(time-t_0,u,'r','LineWidth',1);
grid on
xlabel('Time, days since start 2020')
ylabel('u (E/W) current (cm/s)')
subplot(2,1,2); 
plot(time-t_0,v,'b','LineWidth',1);
grid on
xlabel('Time, days since start 2020')
ylabel('v (N/S) current (cm/s)')
% ========================================================================


% Exercise tmd_ellipse ===================================================
disp(' '); disp(' ');
disp('Exercising ELLIPSE: should return ellipse properties for K1.')
% Returns tidal current ellipse parameters for a specified location and
%   constituent
constit='k1';
[umaj,umin,uph,uinc] = tmd_ellipse(Model,lat,lon,constit);
disp(['Ellipse properties for ' constit ' at lat/lon = ' ...
      num2str(lat) '/' num2str(lon)]);
disp(['Umaj        = ' num2str(umaj)]);
disp(['Umin        = ' num2str(umin)]);
disp(['Inclination = ' num2str(uinc)]);
disp(['Phase       = ' num2str(uph)]);
% ========================================================================


% Exercise tmd_get_coeff =================================================
% Returns map of tidal amplitudes and phases for a specified constituent.
disp(' '); disp(' ');
disp('Exercising tmd_get_coeff: should create Figure 3: amplitude and phase')
[x,y,amp,phase] = tmd_get_coeff(Model,'z','m2');
loc=find(amp<=0);
amp(loc)=NaN; phase(loc)=NaN;

figure(3); clf; orient tall
subplot(2,1,1);
pcolor(x,y,amp); shading flat; colorbar; hold on
clim=get(gca,'CLim');
[h,c]=contour(x,y,H,[500 1000 2000],'w');
set(c,'LineWidth',1);
caxis(clim);

subplot(2,1,2);
pcolor(x,y,phase); shading flat; colorbar; hold on
clim=get(gca,'CLim');
contour(x,y,H,[500 1000 2000],'w');
set(c,'LineWidth',1);
caxis(clim);
% ========================================================================


% Exercise tmd_get_ellipse ===============================================
% Returns map of tidal ellipse properties for a specified constituent.
disp(' '); disp(' ');
disp('Exercising tmd_get_ellipse: should create Figure 4') 
disp('                            umaj, umin, orientation, phase')
[x,y,umaj,umin,uphase,uincl] = tmd_get_ellipse(Model,'k1');

loc=find(umaj<=0);    % Set land values to NaN;
umaj(loc)=NaN; umin(loc)=NaN; uphase(loc)=NaN; uincl(loc)=NaN;

figure(4); clf; orient tall
subplot(2,2,1);
pcolor(x,y,umaj); shading flat; caxis([0 20]);colorbar; hold on
clim=get(gca,'CLim');
[h,c]=contour(x,y,H,[500 1000 2000],'w');
set(c,'LineWidth',1);
caxis(clim);

subplot(2,2,2);
pcolor(x,y,umin); shading flat; caxis([-20 20]);colorbar; hold on
clim=get(gca,'CLim');
[h,c]=contour(x,y,H,[500 1000 2000],'w');
set(c,'LineWidth',1);
caxis(clim);

subplot(2,2,3);
pcolor(x,y,uphase); shading flat; colorbar; hold on
clim=get(gca,'CLim');
[h,c]=contour(x,y,H,[500 1000 2000],'w');
set(c,'LineWidth',1);
caxis(clim);

subplot(2,2,4);
pcolor(x,y,uincl); shading flat; colorbar; hold on
clim=get(gca,'CLim');
[h,c]=contour(x,y,H,[500 1000 2000],'w');
set(c,'LineWidth',1);
caxis(clim);

disp(' '); disp(' ');
disp('Finished tmd_exerciser')

return