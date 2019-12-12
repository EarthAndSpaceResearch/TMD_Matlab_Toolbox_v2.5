function [l]=check_dim(ModName,n,m,n1,m1);
l=1;
if n~=n1 | m~=m1,
 fprintf('ERROR:\n');
 fprintf('Control file %s contains inconsistent files:\n',ModName);
 fprintf('Grid  size: %d x %d \n',n,m);
 fprintf('Elevation/transport size: %d x %d \n',n1,m1);
 l=0;
end
return;

