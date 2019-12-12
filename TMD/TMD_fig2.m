% Time series plot for TMD
% Parameters needed: TimeSeries nh SerialDay L
nFig2=nFig2+1;
figure(2);
if nFig2>0,
 puser2=get(gcf,'position');
 posfig2=puser2;
else
 if exist('posfig2','var')==0,posfig2=get(gcf,'position');end
end
[ncc,dum]=size(Cid);
if ncc>1,
 cid=[];
 for ic=1:ncc
  cid=[cid,deblank(Cid(ic,:))];
  if ic<ncc,cid=[cid,','];end
 end
else
 cid=Cid;
end
if SLDT==0 & L>1 & ATD==0,
 figure(1);
 for k=1:L
  if nh(k)>1,
   figure(gcf+1);clf;
   i1=sum(nh(1:k-1))+1;
   i2=sum(nh(1:k));
   SD=SDA(i1:i2);
   T=TA(i1:i2,:);
   DD=round(D(k)*10)/10;
   tit=['Lat:',num2str(lat(k)),', Lon:',num2str(lon(k)),...
       ', Depth:',num2str(DD),'(m), Start Time:',T(1,:),...
       ', Constituents:',cid];
   TS=TSA(i1:i2);
   ps(k)=plot(SD-SD(1),TS);hold on;
   plot(SD-SD(1),TS,'ok','MarkerFaceColor','k');
   set(ps(k),'Color','k','LineWidth',2);
   title(tit,'FontWeight','bold');
   if k==L,xlabel('Days since Start Time','FontWeight','bold');end
   set(gca,'xgrid','on','ygrid','on','FontWeight','bold');
   legend(oname);
   set(gcf,'position',posfig2,'paperorientation',...
   'landscape','paperposition',[0.25,2.1,10.5,4.3]);
   posfig2(1)=posfig2(1)+10;posfig2(2)=posfig2(2)-10;
  end
 end
else
 figure(2);clf;
 SD=SDA;T=TA;
 DD=round(D(1)*10)/10;
 tit=['Lat:',num2str(lat(1)),', Lon:',num2str(lon(1)),...
      ', Depth:',num2str(DD),'(m), Start Time:',T(1,:),...
      ', Constituents:',cid];
 if ATD==1,
  tit=['Along Track Prediction. Start Time:',T(1,:),...
      ', Constituents:',cid];
 end
 TS=TSA;
 ps=plot(SD-SD(1),TS);hold on;
 plot(SD-SD(1),TS,'ok','MarkerFaceColor','k');
 set(ps,'Color','k','LineWidth',2);
 title(tit,'FontWeight','bold');
 xlabel('Days since Start Time','FontWeight','bold');
 set(gca,'xgrid','on','ygrid','on','FontWeight','bold');
 legend(oname);
 set(gcf,'position',posfig2,'paperorientation',...
      'landscape','paperposition',[0.25,2.1,10.5,4.3]);
end
return
