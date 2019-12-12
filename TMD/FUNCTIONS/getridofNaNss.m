% usage: [z2]=getridofNaNss(z1,mz,globe,maxiter);
% get rid of extra NaNs at the coast (interp2 put them to NaNs)
% default: globe=0lmaxiter=20;
% same as getridofNaNs, but silent
function [D2]=getridofNaNss(D1,mz,globe,maxiter);
%
sm=0;
if nargin<3,globe=0;end
if nargin<4,maxiter=20;end
D2=D1;
if sm>0,
 D2(find(isnan(D2)>0))=0;
 D2=smooth(D2,10,1);
 D2(find(mz==0 | isnan(D1)>0))=NaN;
end
[lx,ly]=size(D1);COR=zeros(lx,ly);
ii=find(isnan(D2)>0 & mz==1);L1=length(ii);
iter=0;
while isempty(ii)==0,
 C21=[NaN*zeros(lx,1),D2(:,1:end-1)];
 C22=[D2(:,2:end),NaN*zeros(lx,1)];
 if(globe==1),
  C11=[D2(end,:);D2(1:end-1,:)];
  C12=[D2(2:end,:);D2(1,:)];
 else
  C11=[NaN*zeros(1,ly);D2(1:end-1,:)];
  C12=[D2(2:end,:);NaN*zeros(1,ly)];
 end
 i1=find(isnan(D2)>0 & isnan(C11)==0 & mz>0);
 i2=find(isnan(D2)>0 & isnan(C12)==0 & mz>0);
 i3=find(isnan(D2)>0 & isnan(C21)==0 & mz>0);
 i4=find(isnan(D2)>0 & isnan(C22)==0 & mz>0);
%
 cor=zeros(size(D2));mcor=cor;
 cor(i1)=C11(i1);mcor(i1)=1;
 cor(i2)=cor(i2)+C12(i2);mcor(i2)=mcor(i2)+1;
 cor(i3)=cor(i3)+C21(i3);mcor(i3)=mcor(i3)+1;
 cor(i4)=cor(i4)+C22(i4);mcor(i4)=mcor(i4)+1;
 cor=cor./max(mcor,1);
 COR=COR+cor;COR=smooth(COR,5,1);
 icor=find(mcor>0);
 D2(icor)=COR(icor);
 %D2(i1)=C11(i1);D2(i2)=C12(i2);
 %D2(i3)=C21(i3);D2(i4)=C22(i4);

 ii=find(isnan(D2)>0 & mz==1);
 if L1==length(ii) | iter>maxiter,ii=[];break;else L1=length(ii);iter=iter+1;
    end 
end
ninan=find(isnan(D1)==0);
D2(ninan)=D1(ninan);
D2(find(mz==0))=0;
D2(find(isnan(D2)>0))=0;
return
