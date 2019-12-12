function [zs]=smooth_patchOB(z,depth,ll_lims1,ll_lims2,hmax,lmax,niter);
% smooth 2D field z with patch already in
% at OB only +-lmax grid cells where depth<hmax
% ll_lims1 - limits of z;ll_lims2 - limits of patch
% hmax - max depth for patching in
% niter - smoothing iterations
[n,m]=size(z);
[lon,lat]=XY(ll_lims1,n,m);
[LON,LAT]=meshgrid(lon,lat);LON=LON';LAT=LAT';
lon1=ll_lims2(1);lon2=ll_lims2(2);
lat1=ll_lims2(3);lat2=ll_lims2(4);
dlon=(lon(2)-lon(1))*lmax;dlat=(lat(2)-lat(1))*lmax;
% find where to smoooth
ik1=find(LON>lon1-dlon & LON<lon2+dlon & LAT>lat1-dlat & LAT<lat1+dlat & depth<1.1*hmax & depth>0);
ik2=find(LON>lon1-dlon & LON<lon2+dlon & LAT>lat2-dlat & LAT<lat2+dlat & depth<1.1*hmax & depth>0);
ik3=find(LON>lon1-dlon & LON<lon1+dlon & LAT>lat1+dlat & LAT<lat2-dlat & depth<1.1*hmax & depth>0);
ik4=find(LON>lon2-dlon & LON<lon2+dlon & LAT>lat1+dlat & LAT<lat2-dlat & depth<1.1*hmax & depth>0);
% If there depth<hmax & depth>hmax in the +/- lmax points neighborhood?
sms=zeros(n,m);
i1=max(find(lon<lon1));i2=min(find(lon>lon2));
j1=max(find(lat<lat1));j2=min(find(lat>lat2));
for k=i1:i2
  for l=j1:j2
    d1=0;d2=0;
    for k1=max(1,k-lmax):min(n,k+lmax)
     for l1=max(1,l-lmax):min(m,l+lmax)
       if depth(k1,l1)<=hmax,d1=1;end
       if depth(k1,l1)>=hmax,d2=1;end
     end
    end
    if d1*d2>0,sms(k,l)=1;end
  end
end
%
ik5=find(LON>lon1-dlon & LON<lon2+dlon & LAT>lat1-dlat & LAT<lat2+dlat & depth>0.8*hmax & depth<1.2*hmax);
ik5=find(sms==1);
ik=[ik1;ik2;ik3;ik4;ik5];
%figure(4);
%plot(LON(ik),LAT(ik),'y.');
zs1=z;zs1(find(isnan(zs1)>0))=0; % zero NaNs
for iter=1:niter
 zs2=smooth(zs1,1,0);
 zs1(ik)=zs2(ik);
end
zs=zs1;
return
