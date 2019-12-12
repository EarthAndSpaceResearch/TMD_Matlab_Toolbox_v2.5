% usage: TMD_changeCaxis(n12,act);
%        change
%        n12 - 1/2 lower/upper limit
%        act   '+'/'-' increase/descrease 
function []=TMD_changeCaxis(n12,act,cb,CBpos);
cax=caxis;
dcax=(cax(2)-cax(1))/50;
if act=='-',
 cax(n12)=floor((cax(n12)-dcax)*100)/100;
else
 cax(n12)=ceil((cax(n12)+dcax)*100)/100;
end
caxis(cax);
h=get(cb,'children');set(h,'ydata',cax);
set(cb,'FontWeight','bold','position',CBpos,'YLim',cax);
return
