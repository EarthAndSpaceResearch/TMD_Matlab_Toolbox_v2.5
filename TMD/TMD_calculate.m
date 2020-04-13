%%%
if sum(icon)==0
    fprintf('TMD message: NO ACTION, REASON: NO constituent choosen\n');
    return
end
% Provide input (lat,lon,time) from Input file
ss(1)=0;dt(1)=1/24;
if exist('vi','var')>0
    if vi==1
        fid=fopen(InFname,'r');
        if fid<0
            fprintf('Sorry, input file %s does not exist: NO action\n',InFname);
            return
        end
        clear lat lon yy mm dd hh mi nh;
        s1=0;k=0;
        while s1(1)~=-1
            s1=fgetl(fid);
            if s1(1)==-1,break;end
            n1=str2num(s1);
            if isempty(n1)==0
                k=k+1;
                ncol=length(n1);
                if ncol>1,if k==1,clear lat lon;end;lat(k)=n1(1);lon(k)=n1(2);end
                if ncol>2
                    if ncol<7
                        fprintf('Wrong dates in %s: NO action done\n',InFname);
                        return
                    end
                    if k==1, clear yy mm dd hh mi nh; end
                    yy(k)=n1(3);mm(k)=n1(4);dd(k)=n1(5);hh(k)=n1(6);mi(k)=n1(7);
                    ss(k)=0;dt(k)=60/(60*24);nh(k)=1;
                    if ncol>7,ss(k)=n1(8);end
                    if ncol>8,dt(k)=n1(9)/(60.*24.);end
                    if ncol>9,nh(k)=n1(10);end
                end
            end
        end
        fclose(fid);
        if mode==2 & ncol==2
            fprintf('Input file %s has only %d columns:\n',InFname,ncol);
            fprintf('Date & time columns should be given to predict tide\n');
            fprintf('NO action done\n');
            return
        end
    end
end
set(uGo,'Enable','off');
set(gcf,'Pointer','watch');
if exist('pp1','var')>0,set(pp1,'Visible','off');clear pp1;end
if km==1,eval(['[xl,yl]=' Fxy_ll '(lon,lat,''F'');']);
else xl=lon;yl=lat;end
XLP=[XLP XL];YLP=[YLP YL]; % move old points to a gray array
XL=xl;YL=yl;
plot(XLP,YLP,'ko','MarkerFaceColor',[0.5,0.5,0.5]);
plot(xl,yl,'ko','MarkerFaceColor','k');
mode=get(uAT,'value');
oname=pname(np-find(ipar>0)+1,:);
%
o1=deblank(oname);
if oname=='Ell'
    oname='Ell(cm/s)';
elseif o1=='U' | o1=='V'
    oname=[o1 '(m^2/s)'];
elseif o1=='u' | o1=='v'
    oname=[o1 '(cm/s)'];
else
    oname=[o1 '(m)'];
end
%
if ipar(1)==1,c2='h';else c2='u';end
%
xt=xl;yt=yl;L=length(xt);
fmt= '%10.4f %10.4f %10s %2s %10.4f %10.2f\n';
fmt1='%10.4f %10.4f %10s %2s %10.4f %10.2f %12.4f %8.2f\n';
nz=sum(icon);amp=zeros(nz,L);pha=amp;
if ipar(6)==1,umaj1=amp;umin1=amp;uphase1=amp;uincl1=amp;end
nz=0;Cid=[];
for ic=1:nc
    if icon(ic)==1
        nz=nz+1;
        Cid=[Cid;conList(ic,:)];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ic2=1;
xu=x-dx/2;yv=y-dy/2;
[X,Y]=meshgrid(x,y);[Xu,Yu]=meshgrid(xu,y);[Xv,Yv]=meshgrid(x,yv);
D=interp2(X,Y,H',xt,yt);D=D';
for ic=1:nc
    if(icon(ic)==1)
        if c2=='h'
            [z,th_lim,ph_lim]=h_in(hfile,ic);
            [nnz,mmz]=size(z);
            if check_dim(CFname,n,m,nnz,mmz)==0
                fprintf('hfile: %s\n ufile: %s\n grid: %s\n',hfile,ufile,Gname);
                break;
            end
            z(find(z==0))=NaN;
        else
            [u,v,th_lim,ph_lim]=u_in(ufile,ic);
            [nnu,mmu]=size(u);
            if check_dim(CFname,n,m,nnu,mmu)==0
                fprintf('hfile: %s\n ufile: %s\n grid: %s\n',hfile,ufile,Gname);
                break;
            end
            u(find(u==0))=NaN;v(find(v==0))=NaN;
        end
        if ipar(1)==1
            z1=interp2(X,Y,z',xt,yt);z1=z1';
            % correct NaNs if possible
            inan=find(isnan(z1)>0);
            z1(inan)=BLinterp(x,y,z,xt(inan),yt(inan),km);
            amp(ic2,:)=abs(z1)';
            pha(ic2,:)=atan2(-imag(z1),real(z1))';
        elseif ipar(2)==1 | ipar(4)==1
            u1=interp2(Xu,Yu,u',xt,yt);u1=u1';
            % correct NaNs if possible
            inan=find(isnan(u1)>0);
            u1(inan)=BLinterp(x,y,u,xt(inan),yt(inan),km);
            amp(ic2,:)=abs(u1)';
            pha(ic2,:)=atan2(-imag(u1),real(u1))';
        elseif ipar(3)==1 | ipar(5)==1
            v1=interp2(Xv,Yv,v',xt,yt);v1=v1';
            % correct NaNs if possible
            inan=find(isnan(v1)>0);
            v1(inan)=BLinterp(x,y,v,xt(inan),yt(inan),km);
            amp(ic2,:)=abs(v1)';
            pha(ic2,:)=atan2(-imag(v1),real(v1))';
        else % ellipse ipar(6)==1
            u1=interp2(Xu,Yu,u',xt,yt);u1=u1'./D*100;
            v1=interp2(Xv,Yv,v',xt,yt);v1=v1'./D*100;
            % correct NaNs if possible
            inan=find(isnan(u1)>0);
            u1(inan)=BLinterp(x,y,u,xt(inan),yt(inan),km);
            inan=find(isnan(v1)>0);
            v1(inan)=BLinterp(x,y,v,xt(inan),yt(inan),km);
            [umaj2,umin2,uincl2,uphase2]=TideEl(u1,v1);
            umaj1(ic2,:)=umaj2';
            umin1(ic2,:)=umin2';
            uincl1(ic2,:)=uincl2';
            uphase1(ic2,:)=uphase2';
        end
        ic2=ic2+1;
    end
end
if ipar(4)==1 | ipar(5)==1
    for ic=1:nz
        amp(ic,:)=amp(ic,:)./D'*100;
    end
end
pha=pha*180/pi;pha(find(pha<0))=pha(find(pha<0))+360;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mode==1
    % open/append file for HC output
    disp(OutFname)
    if arw=='a'
        fout=fopen(OutFname,'a');fprintf('Appending %s...\n',OutFname);
        nf=0;
    else
        fout=fopen(OutFname,'w');fprintf('Rewriting %s...\n',OutFname);
        nf=1;
    end
    fprintf('NEW records done in file %s:\n',OutFname);
    if nf==1
        fprintf(fout,'  %s\n',datestr(now));
        fprintf(fout,['   Latitude  Longitude Parameter Con   ',...
            'Ampl/MajAxis Phase(o,GMT) MinAxis Incl(o,GMT)\n']);
        fprintf(['   Latitude  Longitude Parameter Con   ',...
            'Ampl/MajAxis Phase(o,GMT) MinAxis Incl(o,GMT)\n']);
    end
    %
    if ipar(6)==0
        for k=1:L
            for ic=1:nz
                fprintf(fout,fmt,lat(k),lon(k),oname,Cid(ic,:),amp(ic,k),pha(ic,k));
                fprintf(fmt,lat(k),lon(k),oname,Cid(ic,:),amp(ic,k),pha(ic,k));
            end
        end
    else
        for k=1:L
            for ic=1:nz
                fprintf(fout,fmt1,lat(k),lon(k),oname,Cid(ic,:),...
                    umaj1(ic,k),uphase1(ic,k),umin1(ic,k),uincl1(ic,k));
                fprintf(fmt1,lat(k),lon(k),oname,Cid(ic,:),...
                    umaj1(ic,k),uphase1(ic,k),umin1(ic,k),uincl1(ic,k));
            end
        end
    end
    fclose(fout);
else
    %%%% Predict tidal time series at given time
    % open and rewind ouput file
    if arw=='a'
        fidTS=fopen(OutFname,'a');
    else
        fidTS=fopen(OutFname,'w');
    end
    SerialDay=[];TimeSeries=[];
    d0=datenum(1992,1,1); % corresponds to 48622mjd
    % check situation: same lat,lon for all lines in the file
    k1=find(lat==lat(1) & lon==lon(1));
    SLDT=0;if length(k1)==L & L>1,SLDT=1;end
    % check situation: along track 1 point data at each location
    % ALL nh==1
    ATD=0;if sum(nh)==L,ATD=1;end
    for k=1:L
        if k==1 | SLDT==0
            fprintf(fidTS,'Lat: %10.4f, Lon: %10.4f, Parameter: %s\n',...
                lat(k),lon(k),oname);
            fprintf(fidTS,'Depth (m): %10.2f\n',D(k));
            fprintf(fidTS,'Constituents included: ');
            for ic=1:nz
                fprintf(fidTS,'%s',Cid(ic,:));
            end
            fprintf(fidTS,'\n');
            th=int2str(hh(k));if length(th)<2, th=['0' th];end
            tm=int2str(mi(k));if length(tm)<2, tm=['0' tm];end
            ts=[th ':' tm];
            fprintf(fidTS,'Time start: %s, %2d.%2d.%4d \n',ts,mm(k),dd(k),yy(k));
            fprintf(fidTS,'Time step (min): %10.2f\n',dt(k)*24*60);
            fprintf(fidTS,'Time Series length (hours):%d\n',nh(k));
        end
        [yy(k),mm(k),dd(k)]=TMD_cor_date(yy(k),mm(k),dd(k),uT);
        d1=datenum(yy(k),mm(k),dd(k),hh(k),mi(k),ss(k));
        time=d1-d0;
        cph= -i*pha(:,k)*pi/180;
        cam= amp(:,k).*exp(cph);
        hc=zeros(1,1,nz);
        hc(1,1,:)=cam;
        for kt=0:nh(k)-1
            hhat=harp(time,hc,Cid);
            fprintf(fidTS,'%s %10.4f\n',datestr(d1,0),hhat);
            TimeSeries=[TimeSeries hhat];
            SerialDay=[SerialDay d1];
            time=time+dt(k);d1=d1+dt(k);
        end
        if SLDT==0,fprintf(fidTS,'\n');end
    end
    %%% plot of time series
    fprintf('File %s done\n',OutFname);
    fclose(fidTS);
    %%%   ALWAYS output corresponding *.mat file
    constituents=Cid;depth=D;
    Time=datestr(SerialDay);
    i1=findstr(OutFname,'.');
    parameter=oname;
    SDA=SerialDay;
    TA=datestr(SerialDay);
    TSA=TimeSeries;
    if SLDT==1,lat=lat(1);lon=lon(1);depth=depth(1);end
    if isempty(i1)==0,MatFname=[OutFname(1:i1(end)-1),'.mat'];
    else MatFname=[OutFname,'.mat'];end
    if L==1 | SLDT==1 | ATD==1
        eval(['save ',MatFname,...
            ' lat lon constituents parameter depth SerialDay Time TimeSeries;']);
        fprintf('File %s done\n',MatFname);
    else
        bname=MatFname(1:end-4);
        SerialDayAll=SerialDay;
        TimeAll=Time;
        TimeSeriesAll=TimeSeries;
        for k=1:L
            MatFname=[bname '_' int2str(k) '.mat'];
            i1=sum(nh(1:k-1))+1;
            i2=sum(nh(1:k));
            SerialDay=SerialDayAll(i1:i2);
            Time=TimeAll(i1:i2,:);
            TimeSeries=TimeSeriesAll(i1:i2);
            depth=D(k);
            eval(['save ',MatFname,...
                ' lat lon constituents parameter depth SerialDay Time TimeSeries;']);
            fprintf('File %s done\n',MatFname);
        end
    end
end
%
lat0=lat(1);lon0=lon(1);
if exist('yy','var')>0
    yy0=yy(1);mm0=mm(1);dd0=dd(1);hh0=hh(1);mi0=mi(1);nh0=nh(1);
else
    yy0=1992;mm0=1;dd0=1;hh0=0;mi0=0;nh0=24;
end
if exist('posfig2','var')==0,posfig2=get(gcf,'position');end
eval(['save ' tmpFileName ' lat0 lon0 yy0 mm0 dd0 hh0 mi0 nh0 p1 posfig2']);
set(uGo,'Enable','on');
set(gcf,'Pointer','arrow');
if mode==2,TMD_fig2;end % Parameters needed: TimeSeries nh SerialDay
return
