con='m2  ';
y1=2000;y2=2030;
pu=zeros(20*12,1);pf=pu;time=pu;k=1;
for yyyy=y1:y2
  for mon=1:12
    day=15;
    mjd=date_mjd(yyyy,mon,day);
    [pf(k),pu(k)]=nodal(mjd,con);
    time(k)=datenum(yyyy,mon,day);k=k+1;
  end
end
figure(1);clf
xt=[y1:4:y2]';
xl=int2str(xt);
subplot(2,1,1);
plot(time,pu,'LineWidth',2);
title(['Nodal amplitude correction (factor): ',con],'FontSize',16);

set(gca,'xtick',datenum(xt,1,1),'xticklabel',xl,'FontSize',14);
grid on;xlabel('YEAR');
subplot(2,1,2);
plot(time,pf,'LineWidth',2);
title(['Nodal phase correction (radian): ',con],'FontSize',16);
set(gca,'xtick',datenum(xt,1,1),'xticklabel',xl,'FontSize',14);
grid on;xlabel('YEAR');

