function [data, datasize]=nii2mat(fnii,crop_start,voln) 

% set_parameters;

nii=load_nii(fnii);
data = nii.img;

data = single(reshape(data,[(size(data,1)*size(data,2)*size(data,3)),size(data,4)]));
if nargin ==1
    crop_start=0;
    voln=size(data,2);
elseif nargin==2;
    voln=size(data,2);
end

s=(crop_start+1);
e=s+voln-1;

if isempty(voln);
    data=data(:,s:end);
else
    data=data(:,s:e);
end
datasize = size(data);
end






