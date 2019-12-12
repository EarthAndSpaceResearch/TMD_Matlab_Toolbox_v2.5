function [x,y] = XY(ll_lims,n,m);
% Usage: [x,y] = XY(ll_lims,n,m);

dx = (ll_lims(2)-ll_lims(1))/n;
dy = (ll_lims(4)-ll_lims(3))/m;
x = ll_lims(1)+dx/2:dx:ll_lims(2)-dx/2;
y = ll_lims(3)+dy/2:dy:ll_lims(4)-dy/2;

