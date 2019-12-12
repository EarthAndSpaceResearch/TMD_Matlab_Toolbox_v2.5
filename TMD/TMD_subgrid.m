% uSG handle
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');point1=point1(1,1:2);
finalRect = rbbox;
point2 = get(gca,'CurrentPoint');point2=point2(1,1:2);
while point1==point2,
 k =waitforbuttonpress;
 point2=get(gca,'CurrentPoint');point2=point2(1,1:2);
end
x1=point1(1);x2=point2(1);y1=point1(2);y2=point2(2);
if (x1>x2),tmp=x1;x1=x2;x2=tmp;end
if (y1>y2),tmp=y1;y1=y2;y2=tmp;end
x2=max(x1+10*dx,x2);y2=max(y1+10*dy,y2);
x1=max(x(1),x1);x2=min(x(end),x2);
y1=max(y(1),y1);y2=min(y(end),y2);
AX=[x1 x2 y1 y2];
axis(AX);set(gcf,'position',p1);
set(uSG,'value',0);
