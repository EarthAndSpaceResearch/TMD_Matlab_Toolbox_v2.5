% 
function []=TMD_timeOnOff(uTime,uT,action);
set(uTime,'Enable',action);
nt=length(uT);
for it=1:nt,
 set(uT(it),'Enable',action);
end
return
