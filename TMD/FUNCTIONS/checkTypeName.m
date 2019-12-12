% returns Flag=0, if ModName, GridName & type OK
%         Flag>0, if they are not or files do not exist
%         Flag<0, if not possible to define
% usage:  [Flag]=checkTypeName(ModName,GridName,type);
function [Flag]=checkTypeName(ModName,GridName,type);
Flag=0;
% check if files exist
if exist(ModName,'file')==0,
 fprintf('File %s NOT found\n',ModName); Flag=1;
 return
end
if exist(GridName,'file')==0,
 fprintf('File %s NOT found\n',GridName); Flag=1;
 return
end
type=deblank(type);btype=deblank(type(end:-1:1));
type=btype(end:-1:1);type=type(1:1);
% Check type
if type~='z' & type~='U'& type~='u'& type~='V' & type~='v',
  fprintf('WRONG TYPE %s: should be one of: ''z'',''U'',''u'',''V'',''v''\n',type);
  Flag=2;
  return
end
% Check type/name correspondence
i1=findstr(ModName,'/');
if isempty(i1)>0,i1=1;else i1=i1(end)+1;end 
if ModName(i1:i1)=='h',
 if type=='U'| type=='u'|type=='V'| type=='v',
  fprintf('For file %s only legal type is ''z'' (%s given)\n',...
           ModName(i1:end),type);
  Flag=3;
  return
 end
elseif ModName(i1:i1)=='u' | ModName(i1:i1)=='U',
 if type=='z',
   fprintf('For file %s legal types are: ''U'',''u'',''V'',''v'' (%s given)\n',...
            ModName(i1:end),type);
   Flag=4;
   return
 end
else
 fprintf('WARNING: Model name %s does not correspond TMD convention:\n',ModName(i1:end));
 fprintf('Can not check type %s:...\n',type);
 Flag=-1;
end
return
