SLAT=71; SLON=-70; HEMI='s';
% the mooring locations are
% M1 -  77° 29.315’S 171° 34.272’E   bottom depth = 789 m  ;  bottom of ice = 219 m (all relative to MSL) 
% M2   - 77° 34.864’S 171° 30.403’E  bottom depth = 862 m ;   bottom of ice =  228 m 
% (more at http://www.whoi.edu/science/PO/coastal/ANDRILL_2010_Mooring/)

Model='DATA/Model_CATs2008aT';

%M1.lat=-(77+29.315/60); M1.lon=171+34.272/60;
M2.lat=-(77+34.864/60); M2.lon=171+30.403/60;

lat=[M2.lat]; lon=[M2.lon];
[x,y]=mapll(lat,lon,SLAT,SLON,HEMI);

%[M1.x,M1.y]=mapll(M1.lat,M1.lon,SLAT,SLON,HEMI);
[M2.x,M2.y]=mapll(M2.lat,M2.lon,SLAT,SLON,HEMI);

[X,Y,Z]=tmd_get_bathy(Model);

wct_int=interp2(X,Y,Z,x,y);
disp(wct_int);

% figure; clf
% pcolor(X,Y,Z); shading interp; caxis([0 1200]); colorbar
% plot_moa(2,'k',SLAT,SLON,HEMI);
% plot(M1.x,M1.y,'r+');
% plot(M2.x,M2.y,'b+')
% set(gcf,'renderer','ZBuffer');

%[K1.umaj,K1.umin,K1.uph,K1.uinc]=tmd_ellipse(Model,lat,lon,'k1');
[O1.umaj,O1.umin,O1.uph,O1.uinc]=tmd_ellipse(Model,lat,lon,'o1');
O1
   [V.amp,V.Gph,V.Depth,V.conList]=tmd_extract_HC(Model,lat,lon,'v',6);
V
break
for i=1:length(V.conList);
    disp([V.conList(i,:) '   ' num2str(V.amp(i)) '   ' num2str(V.Gph(i))])
end
