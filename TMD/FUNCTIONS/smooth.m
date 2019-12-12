% smooth z with simple 2 dim filter
% usage: zs=smooth(z,niter,globe), niter - # iterations
% zs - smoothed z
function zs=smooth(zo,niter,globe);
if niter==0,
 zs=zo;
 return
end
if nargin<3, globe=0; end
f=[0.05 0.10 0.05;...
   0.10 0.40 0.10;...
   0.05 0.10 0.05];
%
z=zo;
mz=(z~=0);
mz0=mz; %mz(2:end-1,2:end-1);
if globe,
 mz1m=[mz(end,:);mz(1:end-1,:)];      %mz(1:end-2,2:end-1);
 mz1p=[mz(2:end,:);mz(1,:)];          %mz1p=mz(3:end  ,2:end-1);
else
 mz1m=[mz(1,:);mz(1:end-1,:)];
 mz1p=[mz(2:end,:);mz(end,:)];
end
mz2m=[mz(:,1),mz(:,1:end-1)];        %mz2m=mz(2:end-1,1:end-2);
mz2p=[mz(:,2:end),mz(:,end)];        %mz2p=mz(2:end-1,3:end  );
%
mz1m2m=[mz1m(:,1),mz1m(:,1:end-1)];  %mz1m2m=mz(1:end-2,1:end-2);
mz1m2p=[mz1m(:,2:end),mz1m(:,end)];  %mz(1:end-2,3:end);
mz1p2m=[mz1p(:,1),mz1p(:,1:end-1)];  %mz(3:end  ,1:end-2);
mz1p2p=[mz1p(:,2:end),mz1p(:,end)];  %mz(3:end  ,3:end);
for iter=1:niter
 zs=zeros(size(z));
% z0  =z(2:end-1,2:end-1);
% z1m=z(1:end-2,2:end-1);z2m=z(2:end-1,1:end-2);
% z1p=z(3:end  ,2:end-1);z2p=z(2:end-1,3:end  );
% z1m2m=z(1:end-2,1:end-2);z1m2p=z(1:end-2,3:end);
% z1p2m=z(3:end  ,1:end-2);z1p2p=z(3:end  ,3:end);
 z0=z;
 if globe,
  z1m=[z(end,:);z(1:end-1,:)];          
  z1p=[z(2:end,:);z(1,:)];
 else
  z1m=[z(1,:);z(1:end-1,:)];          
  z1p=[z(2:end,:);z(end,:)];
 end           
 z2m=[z(:,1),z(:,1:end-1)];   
 z2p=[z(:,2:end),z(:,end)];        
 z1m2m=[z1m(:,1),z1m(:,1:end-1)];  
 z1m2p=[z1m(:,2:end),z1m(:,end)];  
 z1p2m=[z1p(:,1),z1p(:,1:end-1)];  
 z1p2p=[z1p(:,2:end),z1p(:,end)]; 
%
 z1=z1m2m*f(1,1)+z1m*f(1,2)+z1m2p*f(1,3)+...
    z2m  *f(2,1)+ z0*f(2,2)+  z2p*f(2,3)+...
    z1p2m*f(3,1)+z1p*f(3,2)+z1p2p*f(3,3);
 ms=mz1m2m*f(1,1)+mz1m*f(1,2)+mz1m2p*f(1,3)+...
    mz2m  *f(2,1)+ mz0*f(2,2)+  mz2p*f(2,3)+...
    mz1p2m*f(3,1)+mz1p*f(3,2)+mz1p2p*f(3,3);
%
% zs(2:end-1,2:end-1)=z1./max(ms,1e-3);
 zs=z1./max(ms,1e-3);
 zs=zs.*mz;
 z=zs;
end
return
