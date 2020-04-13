%
% plots figure 1 for TMD
screen=get(0,'screensize');
maxPicSize=0.8*screen(4);minPicSize=0.2*screen(4);
maxPriSize=8;
minrat=0.6;
nFig=nFig+1;
if exist('puser2')==0 & nFig>1
    w2=p1(4)/2;
    posfig2=[p1(1)+50,p1(2)+p1(4)-w2,p1(3)*1.2,w2];
end
if nFig>1
    puser1=get(gcf,'position');
    p1=puser1;
    if exist('puser2')==0
        w2=p1(4)/2;
        posfig2=[p1(1)+50,p1(2)+p1(4)-w2,p1(3)*1.2,w2];
    else
        posfig2=puser2;
    end
    lat0=lat(1);lon0=lon(1);
    yy0=yy(1);mm0=mm(1);dd0=dd(1);hh0=hh(1);mi0=mi(1);nh0=nh(1);
    eval(['save ' tmpFileName ' lat0 lon0 yy0 mm0 dd0 hh0 mi0 nh0 p1 posfig2']);
end
%ic1=min(find(icon>0)); % upper checked constituent id
ic1=icpl;
if exist('uPl','var')>0,ik=get(uPl,'value');end
%
ip1=find(ipar==1); % checked parameter
if isempty(ic1)>0 & isempty(ip1)>0
    if icp1==ic1 & ik1==ik & ipp1==ip1 % Nothing new to plot
        return
    else
        icp1=ic1;ik1=ik;ipp1=ip1;
    end
end
set(gcf,'Pointer','watch');
reset(gca);
%
if exist('pp1','var')>0, clear pp1;end
%
if(ip1==1),c2='h';else c2='u';end
%%
if ik==1,
    if exist('H1','var')==0
        [xy_lims,H,mz,iob,dt]=grd_in(Gname);
        if dt<0,km=1;end
        H1=H;H1(find(H==0))=NaN;
        H=H.*mz;
        [n,m]=size(H);[xg,yg]=XY(xy_lims,n,m);x=xg;y=yg;
        stepx=x(2)-x(1);stepy=y(2)-y(1);
        [hu,hv]=Huv(H);H(find(H==0))=NaN;
        hu(find(hu==0))=NaN;hv(find(hv==0))=NaN;
    end
    H1(find(H1>0 & mz==0))=-100;
    cla;imagesc(x,y,H1',[-200,6000]);
    colormap('bone');map=colormap;
    map=1-map;map(:,1)=max(0.05,map(:,1)-0.2);
    map(:,2)=max(0.05,map(:,2)-0.1);
    map(:,3)=min(1,map(:,3)+0.2);map(1,:)=[0.1,0.9,0.1];
    map(2,:)=[1 1 0.0]; % yellow masked land
    colormap(map);
    ccc='m';
else
    if c2=='h'
        if icz1~=ic1 | exist('z','var')==0
            [z,th_lim,ph_lim]=h_in(hfile,ic1);
            [nnz,mmz]=size(z);
            if check_dim(CFname,n,m,nnz,mmz)==0
                fprintf('hfile: %s\n ufile: %s\n grid: %s\n',hfile,ufile,Gname);
                return;
            end
            nnanz=find(z~=0);z(find(z==0))=NaN;
            icz1=ic1;
        end
    else
        if icu1~=ic1 | exist('u','var')==0
            [u,v,th_lim,ph_lim]=u_in(ufile,ic1);
            [nnu,mmu]=size(u);
            if check_dim(CFname,n,m,nnu,mmu)==0
                fprintf('hfile: %s\n ufile: %s\n grid: %s\n',hfile,ufile,Gname);
                return;
            end
            nnanuv=find(u~=0 & v~=0);
            u(find(u==0))=NaN+i*NaN;
            v(find(v==0))=NaN+i*NaN;
            icu1=ic1;
        end
        if ip1==6 & ice1~=ic1
            % since u,v are on different grids we need to calculate
            % ellipse on z grid
            ut=[u(1,:); 0.5*(u(1:end-1,:)+u(2:end,:))];
            vt=[v(:,1), 0.5*(v(:,1:end-1)+v(:,2:end))];
            ut=ut./max(H,10)*100.*mz;
            vt=vt./max(H,10)*100.*mz;
            [uMaj,uMin,uIncl,uPhase]=TideEl(ut,vt);
            % Cut off 0.1% of too big values
            Emax=max(max(uMaj));
            ii=0;NNZ=floor(sum(sum(mz))/1000);
            while length(ii)<NNZ
                iip=ii;Emax=0.9*Emax;ii=find(uMaj>Emax);
            end
            Emax=round(Emax/0.9*10)/10;
            if iip(1)~=0,uMaj(iip)=Emax;end
            uMin(find(uMin> Emax))= Emax;
            uMin(find(uMin<-Emax))=-Emax;
            ice1=ic1;
        end
    end
    if ik==2
        if ipar(6)==0
            if ip1==1
                ha=abs(z);
                imagesc(x,y,ha');
                amax1=4.*mean(ha(nnanz));
                cax=caxis;pct=max(0,1-amax1/cax(2))*100;
                TMD_setcaxis(2,1,ha,pct);
                ccc='m';
            elseif ip1==2
                ua=abs(u);
                imagesc(x-stepx/2,y,ua');
                amax1=6.*mean(ua(nnanuv));
                cax=caxis;pct=max(0,1-amax1/cax(2))*100;
                TMD_setcaxis(0,1,ua,pct);
                ccc='m/s^2';
            elseif ip1==3
                va=abs(v);
                imagesc(x,y-stepy/2,va');
                amax1=6.*mean(va(nnanuv));
                cax=caxis;pct=max(0,1-amax1/cax(2))*100;
                TMD_setcaxis(0,1,va,pct);
                ccc='m/s^2';
            elseif ip1==4
                ua=abs(u)./hu*100;
                imagesc(x-stepx/2,y,ua');
                amax1=8.*mean(ua(nnanuv));
                cax=caxis;pct=max(0,1-amax1/cax(2))*100;
                TMD_setcaxis(2,1,ua,pct);
                ccc='cm/s';
            elseif ip1==5
                va=abs(v)./hv*100;
                imagesc(x,y-stepy/2,va');
                amax1=8.*mean(va(nnanuv));
                cax=caxis;pct=max(0,1-amax1/cax(2))*100;
                TMD_setcaxis(2,1,va,pct);
                ccc='cm/s';
            end
        else   % major axis here
            imagesc(x,y,uMaj');
            amax1=8.*mean(uMaj(nnanuv));
            cax=caxis;pct=max(0,1-amax1/cax(2))*100;
            TMD_setcaxis(2,1,uMaj,pct);
            ccc='cm/s';
        end
    elseif ik==3 % plot phase
        xpp=x;ypp=y;
        if ip1==1
            pp=atan2(-imag(z),real(z))/pi*180;
        elseif ip1==2|ip1==4
            pp=atan2(-imag(u),real(u))/pi*180;
            xpp=x-stepx/2;
        elseif ip1==6
            pp=uPhase;
        else
            pp=atan2(-imag(v),real(v))/pi*180;
            ypp=y-stepy/2;
        end
        pp(find(pp<0))= pp(find(pp<0))+360;
        imagesc(xpp,ypp,pp',[-12,360]);
        ccc='o';
    elseif ik==4
        tmp=uMin;il=find(tmp<-Emax*0.9);
        tmp(il)=-Emax*0.9;
        imagesc(x,y,tmp');
        caxis([-Emax,Emax]);
        ccc='cm/s';
    elseif ik==5
        imagesc(x,y,uIncl',[-6,180]);ccc='^o';
    end
end
if ik~=1
    colormap('jet');
    map=colormap;map(1,:)=[0.5,0.5,0.5];colormap(map);
end
if exist('AX','var')==0
    AX=axis;AX0=AX;
end
axis(AX);
%
dx=x(2)-x(1);dy=y(2)-y(1);
if exist('r','var')==0
    if km==1,r=(y(end)-y(1))/(x(end)-x(1));else
        r=(y(end)-y(1))/((x(end)-x(1))*cos(y(end)/180*pi));
        if abs(y(end))==90, r=0;end
    end
    r=max(r,minrat);
    p2=get(gcf,'paperposition');
    if exist('p1','var')==0
        p1=get(gcf,'position');
        if r<1
            p1(3)=maxPicSize;p1(4)=p1(3)*r;
            if p1(4)<minPicSize,p1(4)=minPicSize;p1(3)=p1(4)/r;end
        else
            p1(4)=maxPicSize;p1(3)=p1(4)/r;
            if p1(3)<minPicSize,p1(3)=minPicSize;p1(4)=p1(3)*r;end
        end
        if p1(1)+p1(3)>0.85*screen(3),p1(1)=0.85*screen(3)-p1(3);end
        if p1(2)+p1(4)>0.85*screen(4),p1(2)=0.85*screen(4)-p1(4);end
        p1(1)=max(p1(1),1);p1(2)=max(p1(2),1);
    end
    if r<1
        p2(3)=maxPriSize;p2(4)=p2(3)*r;
    else
        p2(4)=maxPriSize;p2(3)=p2(4)/r;
    end
end
set(gcf,'position',p1,'paperposition',p2);
axis('xy');
hold on;
% plot coordinate grid
iarc=findstr(hfile,'Arc');
if isempty(iarc)>0,iarc=findstr(ufile,'Arc');end
if isempty(iarc)>0,iarc=findstr(Gname,'Arc');end
iCATs=findstr(hfile,'CATs');
if isempty(iCATs)>0,iCATs=findstr(ufile,'CATs');end
if isempty(iCATs)>0,iCATs=findstr(Gname,'CATs');end
%
if (isempty(iarc)==0 | isempty(iCATs)==0) & km==1 % SPECIAL CASE: Arctic in km
    set(gca,'xtick',[],'ytick',[]);
    plot([x(1) x(end)],[0 0],'k');
    eval(['[tlon1,tlat1]=' Fxy_ll '(x(1)  ,0,''B'');']);
    eval(['[tlon2,tlat2]=' Fxy_ll '(x(end),0,''B'');']);
    lab1=[int2str(round(tlon1)) '^oE'];
    lab2=[int2str(round(tlon2)) '^oE'];
    text(x(end)-50*dx,10*dy,lab2,'FontWeight','bold');
    text(x(1)+10*dx,10*dy,lab1,'FontWeight','bold');
    plot([0 0],[y(1) y(end)],'k');
    eval(['[tlon3,tlat3]=' Fxy_ll '(0,y(1)  ,''B'');']);
    eval(['[tlon4,tlat4]=' Fxy_ll '(0,y(end),''B'');']);
    lab3=[int2str(round(tlon3)) '^oE'];
    lab4=[int2str(round(tlon4)) '^oE'];
    text(5*dx,y(end)-20*dy,lab4,'FontWeight','bold');
    text(5*dx,y(1)+10*dy,0,lab3,'FontWeight','bold');
    plon=[0:360];
    if isempty(iarc)==0,K=[80:-10:60];SN='N';else K=[-80:10:-60];SN='S';end
    for k=K
        plat=ones(1,361)*k;
        eval(['[x1,y1]=' Fxy_ll '(plon,plat,''F'');']);
        plot(x1,y1,'k');
        s=[int2str(abs(k)) '^o' SN];
        text(x1(1),y1(1),s,'FontWeight','bold','VerticalAlignment','top');
    end
elseif km==0
    if AX==AX0
        xtick=get(gca,'xtick');ytick=get(gca,'ytick');
        ntick=min(length(xtick),length(ytick));
        if ntick<xtick
            dtick=floor((xtick(end)-xtick(1))/(ntick-1));
            xtick=[xtick(1):dtick:xtick(end)];
        else
            dtick=floor((ytick(end)-ytick(1))/ntick);
            ytick=[ytick(1):dtick:ytick(end)];
        end
        xtickl=get(gca,'xticklabel');
        xadd=[];
        for k=1:length(xtick)
            if xtick(k)>=0,xadd=[xadd; 'E'];
            else xadd=[xadd; 'W'];end
        end
        yadd=[];
        for k=1:length(ytick)
            if ytick(k)>=0,yadd=[yadd; 'N'];
            else yadd=[yadd; 'S'];end
        end
    end
    set(gca,'xticklabel',[num2str(abs(xtick)'),xadd]);
    set(gca,'FontWeight','bold','xtick',xtick,'ytick',ytick,...
        'xgrid','on','ygrid','on','XAxislocation','top');
    set(gca,'yticklabel',[num2str(abs(ytick)'),yadd]);
else
    set(gca,'FontWeight','bold','xgrid','on',...
        'ygrid','on','XAxislocation','top');
end
if exist('p3')==0
    p3=get(gca,'position');
    p3(1)=0.05;p3(3)=p3(3)-0.02;
    p3(2)=0.97-p3(4);
end
%%%%%%%% COLORBAR
ax=p3(3);ay=p3(4);bh=0.8*ay/nb;
dh=0.2*ay/(nb-1);
bw=(0.98-0.04-(p3(1)+ax))/2;
ch=nc*bh+(nc-1)*dh+0.02;
% CONSTITUENT FRAME POSITION
pos0=[p3(1)+ax+0.02+bw, max(0.01,p3(2)+p3(4)-ch), bw+0.02,ch ];
% COLORBAR POSITION
pos1=pos0;pos1(1)=p3(1)+ax+0.01;pos1(3)=0.02;CBpos=pos1;
CBpos(2)=CBpos(2)+0.02;CBpos(4)=CBpos(4)-0.04; % adjust to add up/down arrows
cb=colorbar;
text(1.07,0.41,ccc,'units','normalized','FontWeight','bold');
set(cb,'position',CBpos,'FontWeight','bold');
set(gca,'position',p3);
if ik>1
    tcon=[upper(conList(ic1,1)) '_' conList(ic1,2),':',hints(np-ip1+1,:)];
    text(AX(1)+(AX(2)-AX(1))/20,AX(4)-(AX(4)-AX(3))/20,tcon,...
        'FontSize',20,'FontWeight','bold');
end
if length(XLP)>0
    plot(XLP,YLP,'ko','MarkerFaceColor',[0.5,0.5,0.5]);
end
if length(XL)>0
    plot(XL,YL,'ko','MarkerFaceColor','k');
end
if exist('lat','var')==0
    lon=(xy_lims(1)+xy_lims(2))/2;
    lat=(xy_lims(3)+xy_lims(4))/2;
    if km==1,eval(['[lon,lat]=' Fxy_ll '(lon,lat,''B'');']);end
    lon=floor(lon*10)/10;
    lat=floor(lat*10)/10;
    if km==1,eval(['[x0,y0]=' Fxy_ll '(lon,lat,''F'');']);
    else x0=lon;y0=lat;end
end
if exist('x0','var')>0 & isempty(XL)>0,pp1=plot(x0,y0,'ko');end
set(gcf,'Pointer','arrow');
