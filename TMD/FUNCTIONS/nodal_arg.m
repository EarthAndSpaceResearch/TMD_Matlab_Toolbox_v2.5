% ARGUMENTS and ASTROL FORTRAN subroutines SUPPLIED by RICHARD RAY, March 1999
% This is matlab remake of ARGUMENTS by Lana Erofeeva, Jan 2003
% NOTE - "no1" in constit.h corresponds to "M1" in arguments
% usage: [pu,pf,G]=nodal(time,cid);
% time - mjd, cid(nc,4) - tidal constituents array char*4
% pu(:,nc),pf(:,nc) - nodal corrections for the constituents
% G - phase correction (degress)
% 
   function [pu,pf,Garg]=nodal_arg(time,cid);
%
cid0   =  ['m2  ';'s2  ';'k1  ';'o1  '; ...
           'n2  ';'p1  ';'k2  ';'q1  '; ...
           '2n2 ';'mu2 ';'nu2 ';'l2  '; ...
           't2  ';'j1  ';'no1 ';'oo1 '; ...
		 'rho1';'mf  ';'mm  ';'ssa ';'m4  ';...
		 'ms4 ';'mn4 '];
index=[30,35,19,12,27,17,37,10,25,26,28,33,34,...
	 23,14,24,11,5,3,2,45,46,44];
%     Determine equilibrium arguments
%     -------------------------------
pp=282.94; % solar perigee at epoch 2000
rad=pi/180;
[n1,n2]=size(time);
if n1==1,time=time';end
[s,h,p,omega]=astrol(time);
hour = (time - floor(time))*24.;
t1 = 15*hour;t2 = 30.*hour;
nT=length(t1);
arg=zeros(nT,53);
% arg is not needed for now, but let it be here
% arg is kept in constit.m (phase_data) for time= Jan 1, 1992, 00:00 GMT
arg(:, 1) = h - pp;                        % Sa
arg(:, 2) = 2*h;                           % Ssa
arg(:, 3) = s - p;                         % Mm
arg(:, 4) = 2*s - 2*h;                     % MSf
arg(:, 5) = 2*s;                           % Mf
arg(:, 6) = 3*s - p;                       % Mt
arg(:, 7) = t1 - 5*s + 3*h + p - 90;       % alpha1
arg(:, 8) = t1 - 4*s + h + 2*p - 90;       % 2Q1
arg(:, 9) = t1 - 4*s + 3*h - 90;           % sigma1
arg(:,10) = t1 - 3*s + h + p - 90;         % q1
arg(:,11) = t1 - 3*s + 3*h - p - 90;       % rho1
arg(:,12) = t1 - 2*s + h - 90;             % o1
arg(:,13) = t1 - 2*s + 3*h + 90;           % tau1
arg(:,14) = t1 - s + h + 90;               % M1
arg(:,15) = t1 - s + 3*h - p + 90;         % chi1
arg(:,16) = t1 - 2*h + pp - 90;            % pi1
arg(:,17) = t1 - h - 90;                   % p1
arg(:,18) = t1 + 90;                       % s1
arg(:,19) = t1 + h + 90;                   % k1
arg(:,20) = t1 + 2*h - pp + 90;            % psi1
arg(:,21) = t1 + 3*h + 90;                 % phi1
arg(:,22) = t1 + s - h + p + 90;           % theta1
arg(:,23) = t1 + s + h - p + 90;           % J1
arg(:,24) = t1 + 2*s + h + 90;             % OO1
arg(:,25) = t2 - 4*s + 2*h + 2*p;          % 2N2
arg(:,26) = t2 - 4*s + 4*h;                % mu2
arg(:,27) = t2 - 3*s + 2*h + p;            % n2
arg(:,28) = t2 - 3*s + 4*h - p;            % nu2
arg(:,29) = t2 - 2*s + h + pp;             % M2a
arg(:,30) = t2 - 2*s + 2*h;                % M2
arg(:,31) = t2 - 2*s + 3*h - pp;           % M2b
arg(:,32) = t2 - s + p + 180.;             % lambda2
arg(:,33) = t2 - s + 2*h - p + 180.;       % L2
arg(:,34) = t2 - h + pp;                   % T2
arg(:,35) = t2;                            % S2
arg(:,36) = t2 + h - pp + 180;             % R2
arg(:,37) = t2 + 2*h;                      % K2
arg(:,38) = t2 + s + 2*h - pp;             % eta2
arg(:,39) = t2 - 5*s + 4.0*h + p;          % MNS2
arg(:,40) = t2 + 2*s - 2*h;                % 2SM2
arg(:,41) = 1.5*arg(:,30);                 % M3
arg(:,42) = arg(:,19) + arg(:,30);         % MK3
arg(:,43) = 3*t1;                          % S3
arg(:,44) = arg(:,27) + arg(:,30);         % MN4
arg(:,45) = 2*arg(:,30);                   % M4
arg(:,46) = arg(:,30) + arg(:,35);         % MS4
arg(:,47) = arg(:,30) + arg(:,37);         % MK4
arg(:,48) = 4*t1;                          % S4
arg(:,49) = 5*t1;                          % S5
arg(:,50) = 3*arg(:,30);                   % M6
arg(:,51) = 3*t2;                          % S6
arg(:,52) = 7.0*t1;                        % S7
arg(:,53) = 4*t2;                          % S8
%
%     determine nodal corrections f and u 
%     -----------------------------------
sinn = sin(omega*rad);
cosn = cos(omega*rad);
sin2n = sin(2*omega*rad);
cos2n = cos(2*omega*rad);
sin3n = sin(3*omega*rad);
%%
f=zeros(nT,53);
f(:,1) = 1;                                     % Sa
f(:,2) = 1;                                     % Ssa
f(:,3) = 1 - 0.130*cosn;                        % Mm
f(:,4) = 1;                                     % MSf
f(:,5) = 1.043 + 0.414*cosn;                    % Mf
f(:,6) = sqrt((1+.203*cosn+.040*cos2n).^2 + ...
              (.203*sinn+.040*sin2n).^2);        % Mt

f(:,7) = 1;                                     % alpha1
f(:,8) = sqrt((1.+.188*cosn).^2+(.188*sinn).^2);% 2Q1
f(:,9) = f(:,8);                                % sigma1
f(:,10) = f(:,8);                               % q1
f(:,11) = f(:,8);                               % rho1
f(:,12) = sqrt((1.0+0.189*cosn-0.0058*cos2n).^2 + ...
                 (0.189*sinn-0.0058*sin2n).^2);% O1
f(:, 13) = 1;                                   % tau1
% tmp1  = 2.*cos(p*rad)+.4*cos((p-omega)*rad);
% tmp2  = sin(p*rad)+.2*sin((p-omega)*rad);% Doodson's
tmp1  = 1.36*cos(p*rad)+.267*cos((p-omega)*rad);% Ray's
tmp2  = 0.64*sin(p*rad)+.135*sin((p-omega)*rad);
f(:,14) = sqrt(tmp1.^2 + tmp2.^2);                % M1
f(:,15) = sqrt((1.+.221*cosn).^2+(.221*sinn).^2);% chi1
f(:,16) = 1;                                    % pi1
f(:,17) = 1;                                    % P1
f(:,18) = 1;                                    % S1
f(:,19) = sqrt((1.+.1158*cosn-.0029*cos2n).^2 + ...
                (.1554*sinn-.0029*sin2n).^2);  % K1
f(:,20) = 1;                                    % psi1
f(:,21) = 1;                                    % phi1
f(:,22) = 1;                                    % theta1
f(:,23) = sqrt((1.+.169*cosn).^2+(.227*sinn).^2); % J1
f(:,24) = sqrt((1.0+0.640*cosn+0.134*cos2n).^2 + ...
                (0.640*sinn+0.134*sin2n).^2 ); % OO1
f(:,25) = sqrt((1.-.03731*cosn+.00052*cos2n).^2 + ...
                (.03731*sinn-.00052*sin2n).^2);% 2N2
f(:,26) = f(:,25);                                % mu2
f(:,27) = f(:,25);                                % N2
f(:,28) = f(:,25);                                % nu2
f(:,29) = 1;                                    % M2a
f(:,30) = f(:,25);                                % M2
f(:,31) = 1;                                    % M2b
f(:,32) = 1;                                    % lambda2
temp1 = 1.-0.25*cos(2*p*rad)-0.11*cos((2*p-omega)*rad)-0.04*cosn;
temp2 = 0.25*sin(2*p*rad)+0.11*sin((2*p-omega)*rad)+ 0.04*sinn;
f(:,33) = sqrt(temp1.^2 + temp2.^2);              % L2
f(:,34) = 1;                                    % T2
f(:,35) = 1;                                    % S2
f(:,36) = 1;                                    % R2
f(:,37) = sqrt((1.+.2852*cosn+.0324*cos2n).^2 + ...
                (.3108*sinn+.0324*sin2n).^2);  % K2
f(:,38) = sqrt((1.+.436*cosn).^2+(.436*sinn).^2); % eta2
f(:,39) = f(:,30).^2;                            % MNS2
f(:,40) = f(:,30);                              % 2SM2
f(:,41) = 1;   % wrong                          % M3
f(:,42) = f(:,19).*f(:,30);                     % MK3
f(:,43) = 1;                                    % S3
f(:,44) = f(:,30).^2;                           % MN4
f(:,45) = f(:,44);                              % M4
f(:,46) = f(:,44);                              % MS4
f(:,47) = f(:,30).*f(:,37);                     % MK4
f(:,48) = 1;                                    % S4
f(:,49) = 1;                                    % S5
f(:,50) = f(:,30).^3;                           % M6
f(:,51) = 1;                                    % S6
f(:,52) = 1;                                    % S7
f(:,53) = 1;                                    % S8
%
u=zeros(nT,53);
u(:, 1) = 0;                                       % Sa
u(:, 2) = 0;                                       % Ssa
u(:, 3) = 0;                                       % Mm
u(:, 4) = 0;                                       % MSf
u(:, 5) = -23.7*sinn + 2.7*sin2n - 0.4*sin3n;      % Mf
u(:, 6) = atan(-(.203*sinn+.040*sin2n)./...
             (1+.203*cosn+.040*cos2n))/rad;        % Mt
u(:, 7) = 0;                                       % alpha1
u(:, 8) = atan(.189*sinn./(1.+.189*cosn))/rad;     % 2Q1
u(:, 9) = u(:,8);                                  % sigma1
u(:,10) = u(:,8);                                  % q1
u(:,11) = u(:,8);                                  % rho1
u(:,12) = 10.8*sinn - 1.3*sin2n + 0.2*sin3n;       % O1
u(:,13) = 0;                                       % tau1
u(:,14) = atan2(tmp2,tmp1)/rad;                    % M1
u(:,15) = atan(-.221*sinn./(1.+.221*cosn))/rad;    % chi1
u(:,16) = 0;                                       % pi1
u(:,17) = 0;                                       % P1
u(:,18) = 0;                                       % S1
u(:,19) = atan((-.1554*sinn+.0029*sin2n)./...
           (1.+.1158*cosn-.0029*cos2n))/rad;       % K1
u(:,20) = 0;                                       % psi1
u(:,21) = 0;                                       % phi1
u(:,22) = 0;                                       % theta1
u(:,23) = atan(-.227*sinn./(1.+.169*cosn))/rad;    % J1
u(:,24) = atan(-(.640*sinn+.134*sin2n)./...
           (1.+.640*cosn+.134*cos2n))/rad;         % OO1
u(:,25) = atan((-.03731*sinn+.00052*sin2n)./ ...
           (1.-.03731*cosn+.00052*cos2n))/rad;     % 2N2
u(:,26) = u(:,25);                                 % mu2
u(:,27) = u(:,25);                                 % N2
u(:,28) = u(:,25);                                 % nu2
u(:,29) = 0;                                       % M2a
u(:,30) = u(:,25);                                   % M2
u(:,31) = 0;                                       % M2b
u(:,32) = 0;                                       % lambda2
u(:,33) = atan(-temp2./temp1)/rad ;                % L2
u(:,34) = 0;                                       % T2
u(:,35) = 0;                                       % S2
u(:,36) = 0;                                       % R2
u(:,37) = atan(-(.3108*sinn+.0324*sin2n)./ ...
             (1.+.2852*cosn+.0324*cos2n))/rad;     % K2
u(:,38) = atan(-.436*sinn./(1.+.436*cosn))/rad;    % eta2
u(:,39) = u(:,30)*2;                               % MNS2
u(:,40) = u(:,30);                                 % 2SM2
u(:,41) = 1.5d0*u(:,30);                           % M3
u(:,42) = u(:,30) + u(:,19);                       % MK3
u(:,43) = 0;                                       % S3
u(:,44) = u(:,30)*2;                               % MN4
u(:,45) = u(:,44);                                 % M4
u(:,46) = u(:,30);                                 % MS4
u(:,47) = u(:,30)+u(:,37);                         % MK4
u(:,48) = 0;                                       % S4
u(:,49) = 0;                                       % S5
u(:,50) = u(:,30)*3;                               % M6
u(:,51) = 0;                                       % S6
u(:,52) = 0;                                       % S7
u(:,53) = 0;                                       % S8
% set correspondence between given constituents and supported in OTIS
[ncmx,dum]=size(cid0);
for ic=1:ncmx
 PU(:,ic)=u(:,index(ic))*rad;
 PF(:,ic)=f(:,index(ic));
 G(:,ic)=arg(:,index(ic));
end
% take pu,pf for the set of given cid only
[nc,dum]=size(cid);
pu=[];pf=[];Garg=[];
for ic=1:nc
 ic0=0;
 for k=1:ncmx
  if cid(ic,:)==cid0(k,:),ic0=k;break;end
 end
 if ic0>0,
  pu=[pu,PU(:,ic0)];
  pf=[pf,PF(:,ic0)];
  Garg=[Garg,G(:,ic0)];
 end
end
return
